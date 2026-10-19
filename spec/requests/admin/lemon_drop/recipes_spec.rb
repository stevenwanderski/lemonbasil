require 'spec_helper'

RSpec.describe 'Admin::LemonDrop::Recipes', type: :request do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:issue) { create(:lemon_drop_issue) }
  let(:recipes_section) { build(:lemon_drop_recipes_section) }
  let!(:section) { add_section(recipes_section, position: 1) }

  def add_section(sectionable, **section_attributes)
    create(:lemon_drop_section, issue: issue, sectionable: sectionable, **section_attributes)
  end

  def add_recipe(to: recipes_section, **attributes)
    create(:lemon_drop_recipe, recipes_section: to, **attributes)
  end

  # A reference image as a form posts it.
  def image_upload(name)
    Rack::Test::UploadedFile.new(Rails.root.join('lemon-drop/images', name), Marcel::MimeType.for(name: name))
  end

  describe 'as a signed-in non-Admin' do
    let!(:recipe) { add_recipe(title: 'chickpea stew') }

    before { login_as(create(:user, email: 'staff@test.com', role: 'staff'), scope: :user) }

    {
      'add a Recipe' => -> { post admin_lemon_drop_issue_section_recipes_path(issue, section), params: { lemon_drop_recipe: { title: 'soup', category: 'soup' } } },
      'edit a Recipe' => -> { get edit_admin_lemon_drop_issue_section_recipe_path(issue, section, recipe) },
      'update a Recipe' => -> { patch admin_lemon_drop_issue_section_recipe_path(issue, section, recipe), params: { lemon_drop_recipe: { title: 'soup' } } },
      'delete a Recipe' => -> { delete admin_lemon_drop_issue_section_recipe_path(issue, section, recipe) },
      'reorder Recipes' => -> { patch reorder_admin_lemon_drop_issue_section_recipes_path(issue, section), params: { recipe_ids: [recipe.id] } }
    }.each do |action, request|
      it "is sent to the clients page instead of being able to #{action}" do
        instance_exec(&request)

        expect(response).to redirect_to(admin_clients_path)
        expect(recipes_section.recipes.reload.map(&:title)).to eq(['chickpea stew'])
      end
    end
  end

  describe 'as an Admin' do
    before { login_as(admin, scope: :user) }

    describe 'the Recipes Section form' do
      it 'saves the heading and lists its Recipes in order, linking to each and to a new one' do
        second = add_recipe(title: 'harissa chicken', category: 'entree', position: 2)
        first = add_recipe(title: 'chickpea stew', position: 1)

        get edit_admin_lemon_drop_issue_section_path(issue, section)

        rows = response.body.scan(%r{<li class="recipe-list__row" data-id="(\d+)">.*?<a href="([^"]+)">\s*<strong>([^<]+)</strong>}m)
        expect(rows).to eq([
          [first.id.to_s, edit_admin_lemon_drop_issue_section_recipe_path(issue, section, first), 'chickpea stew'],
          [second.id.to_s, edit_admin_lemon_drop_issue_section_recipe_path(issue, section, second), 'harissa chicken']
        ])
        expect(response.body).to include(%(href="#{new_admin_lemon_drop_issue_section_recipe_path(issue, section)}"))

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: { heading: 'weeknights' } } }

        expect(recipes_section.reload.heading).to eq('weeknights')
      end
    end

    describe 'adding a Recipe' do
      it 'saves a complete Recipe, hero image included, in one request, at the end of the Section' do
        add_recipe(title: 'harissa chicken', position: 1)

        get new_admin_lemon_drop_issue_section_recipe_path(issue, section)
        expect(response.body).to include('enctype="multipart/form-data"', 'name="lemon_drop_recipe[hero_image]"')

        post admin_lemon_drop_issue_section_recipes_path(issue, section), params: { lemon_drop_recipe: {
          title: 'chickpea stew', kicker: 'easy freeze', category: 'soup', menu_title: 'Smoky Chickpea Stew',
          menu_blurb: 'tomatoes, greens, crusty bread', prep_minutes: '15', cook_minutes: '40', time_note: '+ soaking',
          total_label: '', serves: '4', tip: 'freezes for 3 months', hero_image: image_upload('chickpea-stew.jpg'),
          hero_focus: 'bottom',
          ingredient_groups_attributes: {
            '0' => { name: 'Produce', ingredients_text: "1 yellow onion, diced\n\n  4 garlic cloves, thinly sliced  \n", position: '1' },
            '1' => { name: 'Pantry', ingredients_text: '2 cans chickpeas (15 oz each), drained and rinsed', position: '2' },
            'NEW' => { name: '', ingredients_text: '', position: '3' }
          },
          steps_text: "Heat the oil.\n\nAdd the onion; cook 5 mins.\nSimmer 30 mins."
        } }

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, section))
        recipe = recipes_section.recipes.reload.last
        expect(recipe).to have_attributes(
          title: 'chickpea stew', slug: 'chickpea-stew', kicker: 'easy freeze', category: 'soup', menu_title: 'Smoky Chickpea Stew',
          menu_blurb: 'tomatoes, greens, crusty bread', prep_minutes: 15, cook_minutes: 40, time_note: '+ soaking',
          serves: 4, tip: 'freezes for 3 months', hero_focus: 'bottom', position: 2
        )
        expect(recipe.hero_image.filename.to_s).to eq('chickpea-stew.jpg')
        expect(recipe.ingredient_groups.map { |group| [group.name, group.ingredients.map(&:text), group.ingredients.map(&:position)] }).to eq([
          ['Produce', ['1 yellow onion, diced', '4 garlic cloves, thinly sliced'], [1, 2]],
          ['Pantry', ['2 cans chickpeas (15 oz each), drained and rinsed'], [1]]
        ])
        expect(recipe.steps.map { |step| [step.body, step.position] }).to eq([
          ['Heat the oil.', 1], ['Add the onion; cook 5 mins.', 2], ['Simmer 30 mins.', 3]
        ])
      end

      it 'shows what’s missing and keeps what was typed' do
        post admin_lemon_drop_issue_section_recipes_path(issue, section), params: { lemon_drop_recipe: {
          title: '', category: '', steps_text: "Heat the oil.\nSimmer."
        } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("<li>Title can&#39;t be blank</li>", "<li>Category can&#39;t be blank</li>", "Heat the oil.\nSimmer.")
        expect(LemonDrop::Recipe.count).to eq(0)
      end
    end

    describe 'editing a Recipe' do
      let!(:recipe) { add_recipe(title: 'chickpea stew') }

      before do
        recipe.ingredient_groups.destroy_all
        recipe.update!(steps_text: "Heat the oil.\nSimmer.", ingredient_groups_attributes: [
          { name: 'Produce', ingredients_text: "1 onion\n2 lemons", position: 1 },
          { name: 'Pantry', ingredients_text: 'tahini', position: 2 },
          { name: 'Spices', ingredients_text: 'cumin', position: 3 }
        ])
      end

      it 'shows the ingredients and steps one per line again' do
        get edit_admin_lemon_drop_issue_section_recipe_path(issue, section, recipe)

        expect(response.body).to include("\n1 onion\n2 lemons</textarea>", "\nHeat the oil.\nSimmer.</textarea>")
      end

      it 'renames, reorders and deletes ingredient groups and replaces the steps in one save' do
        produce, pantry, spices = recipe.ingredient_groups.to_a

        patch admin_lemon_drop_issue_section_recipe_path(issue, section, recipe), params: { lemon_drop_recipe: {
          steps_text: "Simmer.\nServe.",
          ingredient_groups_attributes: {
            '0' => { id: produce.id, name: 'Veg', ingredients_text: "1 onion\n2 lemons", position: '2' },
            '1' => { id: pantry.id, name: 'Pantry', ingredients_text: 'tahini', position: '1' },
            '2' => { id: spices.id, name: 'Spices', ingredients_text: 'cumin', position: '3', _destroy: '1' }
          }
        } }

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, section))
        expect(recipe.reload.ingredient_groups.map(&:name)).to eq(%w[Pantry Veg])
        expect(recipe.steps.map(&:body)).to eq(%w[Simmer. Serve.])
        expect(LemonDrop::Ingredient.pluck(:text)).to match_array(['1 onion', '2 lemons', 'tahini'])
      end
    end

    describe 'the slug' do
      let!(:recipe) { add_recipe(title: 'chickpea stew') }

      it 'defaults from the title, with a number added when the Issue already uses it' do
        add_section(build(:lemon_drop_hero_section), position: 2, anchor: 'harissa-chicken')

        post admin_lemon_drop_issue_section_recipes_path(issue, section), params: { lemon_drop_recipe: { title: 'Harissa Chicken', category: 'entree' } }

        expect(recipes_section.recipes.reload.last.slug).to eq('harissa-chicken-2')
      end

      it 'can be edited' do
        patch admin_lemon_drop_issue_section_recipe_path(issue, section, recipe), params: { lemon_drop_recipe: { slug: 'stew' } }

        expect(recipe.reload.slug).to eq('stew')
      end

      it 'shows an error when it’s another Recipe’s slug or a Section anchor in the Issue' do
        other_section = add_section(build(:lemon_drop_recipes_section), position: 2, anchor: 'more-recipes')
        add_recipe(to: other_section.sectionable, title: 'harissa chicken')

        %w[harissa-chicken more-recipes].each do |taken|
          patch admin_lemon_drop_issue_section_recipe_path(issue, section, recipe), params: { lemon_drop_recipe: { slug: taken } }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('<li>Slug has already been taken</li>')
          expect(recipe.reload.slug).to eq('chickpea-stew')
        end
      end
    end

    describe 'reordering Recipes' do
      it 'stores the order posted by the drag as positions, top first' do
        first = add_recipe(position: 1)
        second = add_recipe(position: 2)
        third = add_recipe(position: 3)

        patch reorder_admin_lemon_drop_issue_section_recipes_path(issue, section), params: { recipe_ids: [third.id, first.id, second.id] }

        expect(response).to have_http_status(:no_content)
        expect(recipes_section.recipes.reload.map { |recipe| [recipe, recipe.position] }).to eq([[third, 1], [first, 2], [second, 3]])
      end

      it 'refuses a list that isn’t exactly the Section’s Recipes' do
        first = add_recipe(position: 1)
        add_recipe(position: 2)

        patch reorder_admin_lemon_drop_issue_section_recipes_path(issue, section), params: { recipe_ids: [first.id] }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe 'moving a Recipe' do
      let(:other_section) { add_section(build(:lemon_drop_recipes_section), position: 2, anchor: 'more-recipes') }

      it 'moves it to the end of another Recipes Section in the Issue, closing the gap it leaves' do
        first = add_recipe(title: 'chickpea stew', position: 1)
        moving = add_recipe(title: 'harissa chicken', position: 2)
        third = add_recipe(title: 'gnocchi', position: 3)
        staying = add_recipe(to: other_section.sectionable, title: 'egg bake', position: 1)

        get edit_admin_lemon_drop_issue_section_recipe_path(issue, section, moving)
        expect(response.body).to include(%(<option value="#{other_section.id}">Recipes (#more-recipes)</option>))

        patch move_admin_lemon_drop_issue_section_recipe_path(issue, section, moving), params: { to_section_id: other_section.id }

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, other_section))
        expect(recipes_section.recipes.reload.map { |recipe| [recipe, recipe.position] }).to eq([[first, 1], [third, 2]])
        expect(other_section.sectionable.recipes.reload.map { |recipe| [recipe, recipe.position] }).to eq([[staying, 1], [moving, 2]])
      end

      it 'offers no move when the Issue has no other Recipes Section' do
        recipe = add_recipe

        get edit_admin_lemon_drop_issue_section_recipe_path(issue, section, recipe)

        expect(response.body).not_to include('Move to')
      end

      it 'won’t move it to another Issue' do
        recipe = add_recipe
        elsewhere = create(:lemon_drop_section, sectionable: build(:lemon_drop_recipes_section))

        expect do
          patch move_admin_lemon_drop_issue_section_recipe_path(issue, section, recipe), params: { to_section_id: elsewhere.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(recipe.reload.recipes_section).to eq(recipes_section)
      end
    end

    describe 'deleting a Recipe' do
      it 'deletes it with its ingredients and steps, closing the gap it leaves' do
        first = add_recipe(position: 1)
        doomed = add_recipe(title: 'harissa chicken', position: 2)
        third = add_recipe(position: 3)

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('data-turbo-confirm="Delete harissa chicken?"')

        delete admin_lemon_drop_issue_section_recipe_path(issue, section, doomed)

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, section))
        expect(recipes_section.recipes.reload.map { |recipe| [recipe, recipe.position] }).to eq([[first, 1], [third, 2]])
        expect(LemonDrop::Step.where(recipe_id: doomed.id)).to be_empty
        expect(LemonDrop::IngredientGroup.where(recipe_id: doomed.id)).to be_empty
      end
    end

    describe 'deleting a Recipes Section that still has Recipes' do
      let!(:recipes) { [add_recipe(title: 'chickpea stew', position: 1), add_recipe(title: 'gnocchi', position: 2)] }

      it 'only confirms, deleting them too, when the Issue has no other Recipes Section' do
        get edit_admin_lemon_drop_issue_section_path(issue, section)

        expect(response.body).to include('data-turbo-confirm="Delete this Recipes Section and its 2 Recipes?"')
        expect(response.body).not_to include('Move them to')
      end

      context 'when the Issue has another Recipes Section' do
        let!(:other_section) { add_section(build(:lemon_drop_recipes_section), position: 2, anchor: 'more-recipes') }
        let!(:staying) { add_recipe(to: other_section.sectionable, title: 'egg bake', position: 1) }

        it 'asks whether to delete them or move them there' do
          get edit_admin_lemon_drop_issue_section_path(issue, section)

          expect(response.body).to include('This Section has 2 Recipes.', 'Delete them too',
            %(value="#{other_section.id}" name="move_recipes_to" id="move_recipes_to_#{other_section.id}" /> Move them to Recipes (#more-recipes)))
        end

        it 'moves them, in order, to the end of the chosen Section' do
          delete admin_lemon_drop_issue_section_path(issue, section), params: { move_recipes_to: other_section.id }

          expect(response).to redirect_to(edit_admin_lemon_drop_issue_path(issue))
          expect(issue.sections.reload.map { |s| [s, s.position] }).to eq([[other_section, 1]])
          expect(other_section.sectionable.recipes.reload.map { |recipe| [recipe.title, recipe.position] }).to eq([
            ['egg bake', 1], ['chickpea stew', 2], ['gnocchi', 3]
          ])
        end

        it 'deletes them along with the Section' do
          delete admin_lemon_drop_issue_section_path(issue, section), params: { move_recipes_to: '' }

          expect(issue.sections.reload).to eq([other_section])
          expect(LemonDrop::Recipe.all).to eq([staying])
        end
      end
    end
  end
end
