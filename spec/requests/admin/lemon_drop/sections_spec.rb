require 'spec_helper'

RSpec.describe 'Admin::LemonDrop::Sections', type: :request do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:issue) { create(:lemon_drop_issue) }

  def add_section(sectionable, **section_attributes)
    create(:lemon_drop_section, issue: issue, sectionable: sectionable, **section_attributes)
  end

  # A reference image as a form posts it.
  def image_upload(name)
    Rack::Test::UploadedFile.new(Rails.root.join('lemon-drop/images', name), Marcel::MimeType.for(name: name))
  end

  describe 'as a signed-in non-Admin' do
    let!(:section) { add_section(build(:lemon_drop_title_page_section), position: 1) }

    before { login_as(create(:user, email: 'staff@test.com', role: 'staff'), scope: :user) }

    {
      'add a Section' => -> { post admin_lemon_drop_issue_sections_path(issue), params: { section_type: 'IntroSection' } },
      'edit a Section' => -> { get edit_admin_lemon_drop_issue_section_path(issue, section) },
      'update a Section' => -> { patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { visible: '0' } } },
      'duplicate a Section' => -> { post duplicate_admin_lemon_drop_issue_section_path(issue, section) },
      'delete a Section' => -> { delete admin_lemon_drop_issue_section_path(issue, section) },
      'reorder Sections' => -> { patch reorder_admin_lemon_drop_issue_sections_path(issue), params: { section_ids: [section.id] } }
    }.each do |action, request|
      it "is sent to the clients page instead of being able to #{action}" do
        instance_exec(&request)

        expect(response).to redirect_to(admin_clients_path)
        expect(issue.sections.reload.map { |s| [s.id, s.visible] }).to eq([[section.id, true]])
      end
    end
  end

  describe 'as an Admin' do
    before { login_as(admin, scope: :user) }

    describe 'the Section list' do
      it 'shows every Section in page order with its type, heading and visibility, linking to its form' do
        hero = add_section(build(:lemon_drop_hero_section), position: 2, visible: false)
        title_page = add_section(build(:lemon_drop_title_page_section), position: 1)
        toc = add_section(build(:lemon_drop_table_of_contents_section), position: 3)

        get edit_admin_lemon_drop_issue_path(issue)

        rows = response.body.scan(%r{<li class="section-list__row( is-hidden)?" data-id="(\d+)">.*?<a href="([^"]+)">\s*<strong>([^<]+)</strong>\s*<span>([^<]*)</span>}m)
        expect(rows).to eq([
          [nil, title_page.id.to_s, edit_admin_lemon_drop_issue_section_path(issue, title_page), 'Title Page', 'the lemon drop'],
          [' is-hidden', hero.id.to_s, edit_admin_lemon_drop_issue_section_path(issue, hero), 'Hero', 'let’s cook'],
          [nil, toc.id.to_s, edit_admin_lemon_drop_issue_section_path(issue, toc), 'Table of Contents', 'this week’s drop']
        ])
      end
    end

    describe 'hiding and showing a Section' do
      it 'hides a Section from its row, keeping it on the Issue, and shows it again' do
        section = add_section(build(:lemon_drop_title_page_section), position: 1)

        get edit_admin_lemon_drop_issue_path(issue)
        expect(response.body).to match(%r{<form class="button_to" method="post" action="#{admin_lemon_drop_issue_section_path(issue, section)}">.*?<button[^>]*type="submit">Hide</button>}m)

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { visible: '0' } },
          headers: { 'HTTP_REFERER' => edit_admin_lemon_drop_issue_path(issue) }

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_path(issue))
        expect(section.reload.visible).to be(false)
        follow_redirect!
        expect(response.body).to match(%r{<button[^>]*type="submit">Show</button>})

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { visible: '1' } }

        expect(section.reload.visible).to be(true)
      end
    end

    describe 'the shared fields' do
      it 'are on every Section form and save' do
        LemonDrop::Section::TYPES.each.with_index(1) do |type, position|
          section = issue.insert_section(type.constantize.new, position: position)

          get edit_admin_lemon_drop_issue_section_path(issue, section)

          expect(response.body).to include('name="lemon_drop_section[theme]"', 'name="lemon_drop_section[anchor]"',
            'name="lemon_drop_section[show_in_toc]"', 'name="lemon_drop_section[toc_label]"')
        end

        section = issue.sections.first
        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: {
          theme: 'sage', anchor: 'cover', show_in_toc: '1', toc_label: 'the cover'
        } }

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, section))
        expect(section.reload).to have_attributes(theme: 'sage', anchor: 'cover', show_in_toc: true, toc_label: 'the cover')
      end

      it 'show an anchor already used on the page as an error' do
        add_section(build(:lemon_drop_grocery_list_section), position: 1, anchor: 'grocery')
        hero = add_section(build(:lemon_drop_hero_section), position: 2)

        patch admin_lemon_drop_issue_section_path(issue, hero), params: { lemon_drop_section: { anchor: 'grocery', toc_label: 'x' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Anchor has already been taken')
        expect(hero.reload).to have_attributes(anchor: 'hero', toc_label: nil)
      end
    end

    describe 'the Title Page form' do
      let(:section) { add_section(build(:lemon_drop_title_page_section), position: 1) }

      it 'saves the heading, tagline, date label and cover image' do
        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('enctype="multipart/form-data"', 'name="lemon_drop_section[sectionable_attributes][cover_image]"')

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: {
          heading: 'the lemon drop!', tagline: 'meal plan', date_label: 'late oct', cover_image: image_upload('gnocchi.jpg')
        } } }

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, section))
        expect(section.sectionable.reload).to have_attributes(heading: 'the lemon drop!', tagline: 'meal plan', date_label: 'late oct')
        expect(section.sectionable.cover_image.filename.to_s).to eq('gnocchi.jpg')
        expect(LemonDrop::TitlePageSection.count).to eq(1)

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to match(%r{<img[^>]+gnocchi\.jpg})
      end

      it 'shows the image rule errors and keeps the current image' do
        section.sectionable.update!(cover_image: uploaded_image('gnocchi.jpg'))
        fake = Rack::Test::UploadedFile.new(StringIO.new('just some text'), 'image/jpeg', original_filename: 'photo.jpg')

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: {
          heading: 'renamed', cover_image: fake
        } } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(%r{<ul class="form-errors">\s*<li>Cover image [^<]+</li>})
        expect(section.sectionable.reload).to have_attributes(heading: 'the lemon drop')
        expect(section.sectionable.cover_image.filename.to_s).to eq('gnocchi.jpg')
      end
    end

    describe 'the Hero form' do
      it 'saves the heading lines, both images and the focus, text and height presets' do
        section = add_section(build(:lemon_drop_hero_section), position: 1)

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('<textarea', 'name="lemon_drop_section[sectionable_attributes][heading]"')
        expect(response.body.scan(%r{<option[^>]*value="(\w+)">([^<]+)</option>})).to include(
          %w[top Top], %w[center Center], %w[bottom Bottom], %w[light Light], %w[dark Dark], %w[medium Medium], %w[tall Tall]
        )

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: {
          heading: "let’s\neat", background_image: image_upload('crispy-chickpeas.jpg'), overlay_image: image_upload('fork-knife.png'),
          background_focus: 'bottom', text_color: 'dark', min_height: 'medium'
        } } }

        hero = section.sectionable.reload
        expect(hero).to have_attributes(heading_lines: %w[let’s eat], background_focus: 'bottom', text_color: 'dark', min_height: 'medium')
        expect([hero.background_image.filename.to_s, hero.overlay_image.filename.to_s]).to eq(%w[crispy-chickpeas.jpg fork-knife.png])
      end
    end

    describe 'the Table of Contents form' do
      it 'saves the heading and says where its entries come from' do
        section = add_section(build(:lemon_drop_table_of_contents_section), position: 1)

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('Entries come from the Sections marked “Show in the Table of Contents”')

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: { heading: 'inside' } } }

        expect(section.sectionable.reload.heading).to eq('inside')
      end
    end

    describe 'the Menu Overview form' do
      let(:section) { add_section(build(:lemon_drop_menu_overview_section, category_order: %w[soup entree]), position: 1) }

      it 'lists all seven categories to drag, in the current order, and saves the order submitted' do
        get edit_admin_lemon_drop_issue_section_path(issue, section)

        expect(response.body).to include('data-controller="sortable"', 'name="lemon_drop_section[sectionable_attributes][icon]"')
        expect(response.body.scan(%r{<li class="category-order__row">.*?<input[^>]*name="lemon_drop_section\[sectionable_attributes\]\[category_order\]\[\]" value="(\w+)"}m).flatten)
          .to eq(%w[soup entree salad snack breakfast side dessert])

        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: {
          heading: 'the menu', icon: image_upload('mortar.png'), category_order: %w[breakfast entree soup salad snack side dessert]
        } } }

        menu = section.sectionable.reload
        expect(menu).to have_attributes(heading: 'the menu', category_order: %w[breakfast entree soup salad snack side dessert])
        expect(menu.icon.filename.to_s).to eq('mortar.png')
      end

      it 'refuses a category that Recipes don’t have' do
        patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: {
          category_order: %w[entree brunch]
        } } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Category order can only hold the Recipe categories, once each')
        expect(section.sectionable.reload.category_order).to eq(%w[soup entree])
      end
    end

    describe 'the image rule on the other forms' do
      {
        [:lemon_drop_hero_section, :background_image] => 'Background image',
        [:lemon_drop_hero_section, :overlay_image] => 'Overlay image',
        [:lemon_drop_menu_overview_section, :icon] => 'Icon'
      }.each do |(factory, image), label|
        it "refuses a fake #{label.downcase} with its error" do
          section = add_section(build(factory), position: 1)
          fake = Rack::Test::UploadedFile.new(StringIO.new('just some text'), 'image/jpeg', original_filename: 'photo.jpg')

          patch admin_lemon_drop_issue_section_path(issue, section), params: { lemon_drop_section: { sectionable_attributes: { image => fake } } }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to match(%r{<ul class="form-errors">\s*<li>#{label} [^<]+</li>})
          expect(section.sectionable.reload.public_send(image)).not_to be_attached
        end
      end
    end

    describe 'reordering Sections' do
      let!(:title_page) { add_section(build(:lemon_drop_title_page_section), position: 1) }
      let!(:intro) { add_section(build(:lemon_drop_intro_section), position: 2) }
      let!(:outro) { add_section(build(:lemon_drop_outro_section), position: 3) }

      it 'stores the order posted by the drag as positions, top first' do
        get edit_admin_lemon_drop_issue_path(issue)
        expect(response.body).to include(
          %(<ol class="section-list" data-controller="sortable" data-sortable-url-value="#{reorder_admin_lemon_drop_issue_sections_path(issue)}" data-sortable-param-value="section_ids[]">)
        )

        patch reorder_admin_lemon_drop_issue_sections_path(issue), params: { section_ids: [outro.id, title_page.id, intro.id] }, as: :json

        expect(response).to have_http_status(:no_content)
        expect(issue.sections.reload.map { |section| [section, section.position] }).to eq([[outro, 1], [title_page, 2], [intro, 3]])
      end

      it "refuses a list that isn't exactly the Issue's Sections" do
        other = create(:lemon_drop_section, sectionable: build(:lemon_drop_intro_section))

        patch reorder_admin_lemon_drop_issue_sections_path(issue), params: { section_ids: [outro.id, title_page.id, other.id] }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(issue.sections.reload).to eq([title_page, intro, outro])
      end
    end

    describe 'duplicating a Section' do
      it 'puts a copy right after it, with its own copy of each image' do
        title_page = add_section(build(:lemon_drop_title_page_section, cover_image: uploaded_image('chickpea-stew.jpg')),
          position: 1, theme: 'sage', show_in_toc: true, toc_label: 'cover')
        outro = add_section(build(:lemon_drop_outro_section), position: 2)

        get edit_admin_lemon_drop_issue_section_path(issue, title_page)
        expect(response.body).to match(%r{<form class="button_to" method="post" action="#{duplicate_admin_lemon_drop_issue_section_path(issue, title_page)}">})

        post duplicate_admin_lemon_drop_issue_section_path(issue, title_page)

        copy = issue.sections.reload.second
        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, copy))
        expect(issue.sections.map(&:id)).to eq([title_page.id, copy.id, outro.id])
        expect(copy).to have_attributes(anchor: 'title-page-2', theme: 'sage', show_in_toc: true, toc_label: 'cover', position: 2)
        expect(copy.sectionable).to have_attributes(heading: 'the lemon drop', tagline: 'your weekly meal plan')
        expect(copy.sectionable_id).not_to eq(title_page.sectionable_id)
        expect(copy.sectionable.cover_image.filename.to_s).to eq('chickpea-stew.jpg')
        expect(copy.sectionable.cover_image.blob).not_to eq(title_page.sectionable.cover_image.blob)

        delete admin_lemon_drop_issue_section_path(issue, copy)

        expect(title_page.sectionable.reload.cover_image.blob.service.exist?(title_page.sectionable.cover_image.key)).to be(true)
      end

      it 'copies everything inside, giving copied Recipes their own slugs' do
        recipes_section = build(:lemon_drop_recipes_section, heading: 'this week')
        section = add_section(recipes_section, position: 1)
        create(:lemon_drop_recipe, recipes_section: recipes_section, title: 'chickpea stew', hero_image: uploaded_image('chickpea-stew.jpg'))
        grocery_list = add_section(build(:lemon_drop_grocery_list_section), position: 2)
        create(:lemon_drop_grocery_group, grocery_list_section: grocery_list.sectionable, name: 'Pantry',
          grocery_items: [build(:lemon_drop_grocery_item, text: 'tahini')])

        post duplicate_admin_lemon_drop_issue_section_path(issue, section)
        post duplicate_admin_lemon_drop_issue_section_path(issue, grocery_list)

        sections = issue.sections.reload.to_a
        expect(sections.map(&:anchor)).to eq(%w[recipes recipes-2 grocery-list grocery-list-2])
        recipe_copy = sections.second.sectionable.recipes.sole
        expect(recipe_copy).to have_attributes(title: 'chickpea stew', slug: 'chickpea-stew-2', category: 'soup')
        expect(recipe_copy.ingredient_groups.flat_map { |group| group.ingredients.map(&:text) }).to eq(['4 garlic cloves, thinly sliced'])
        expect(recipe_copy.steps.map(&:body)).to eq(['Heat a generous pour of olive oil.'])
        expect(recipe_copy.hero_image).to be_attached
        expect(sections.fourth.sectionable.grocery_groups.map { |group| [group.name, group.grocery_items.map(&:text)] })
          .to eq([['Pantry', ['tahini']]])
        expect(LemonDrop::Recipe.count).to eq(2)
      end
    end

    describe 'deleting a Section' do
      it 'deletes the Section and closes the gap it leaves' do
        title_page = add_section(build(:lemon_drop_title_page_section), position: 1)
        hero = add_section(build(:lemon_drop_hero_section), position: 2)
        outro = add_section(build(:lemon_drop_outro_section), position: 3)

        get edit_admin_lemon_drop_issue_section_path(issue, hero)
        expect(response.body).to include('data-turbo-confirm="Delete this Hero Section?"')

        delete admin_lemon_drop_issue_section_path(issue, hero)

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_path(issue))
        expect(issue.sections.reload.map { |section| [section, section.position] }).to eq([[title_page, 1], [outro, 2]])
        expect(LemonDrop::HeroSection.exists?(hero.sectionable_id)).to be(false)
      end

      it 'deletes a Recipes Section along with its Recipes, after saying how many' do
        recipes_section = build(:lemon_drop_recipes_section)
        section = add_section(recipes_section, position: 1)
        create_list(:lemon_drop_recipe, 2, recipes_section: recipes_section)

        get edit_admin_lemon_drop_issue_section_path(issue, section)
        expect(response.body).to include('data-turbo-confirm="Delete this Recipes Section and its 2 Recipes?"')

        delete admin_lemon_drop_issue_section_path(issue, section)

        expect(issue.sections.reload).to be_empty
        expect(LemonDrop::Recipe.count).to eq(0)
      end
    end

    describe 'adding a Section' do
      it 'offers every Section type and every position' do
        add_section(build(:lemon_drop_title_page_section), position: 1)

        get edit_admin_lemon_drop_issue_path(issue)

        expect(response.body.scan(%r{<option value="(\w+Section)">([^<]+)</option>})).to eq([
          %w[TitlePageSection Title\ Page], %w[IntroSection Intro], ['TableOfContentsSection', 'Table of Contents'],
          %w[HeroSection Hero], ['MenuOverviewSection', 'Menu Overview'], %w[RecipesSection Recipes],
          ['GroceryListSection', 'Grocery List'], ['AllergenSwapSection', 'Allergen Swap'], %w[OutroSection Outro]
        ])
        expect(response.body.scan(%r{<option (?:selected="selected" )?value="(\d+)">([^<]+)</option>})).to eq([
          ['1', 'At the top'], ['2', 'After Title Page: the lemon drop']
        ])
      end

      it 'inserts the new Section at the chosen position, any number of times, and opens its form' do
        title_page = add_section(build(:lemon_drop_title_page_section), position: 1)
        outro = add_section(build(:lemon_drop_outro_section), position: 2)

        post admin_lemon_drop_issue_sections_path(issue), params: { section_type: 'HeroSection', position: 2 }
        first_hero = issue.sections.reload.second
        post admin_lemon_drop_issue_sections_path(issue), params: { section_type: 'HeroSection', position: 2 }

        sections = issue.sections.reload.to_a
        expect(response).to redirect_to(edit_admin_lemon_drop_issue_section_path(issue, sections.second))
        expect(sections.map(&:sectionable_type)).to eq(%w[LemonDrop::TitlePageSection LemonDrop::HeroSection LemonDrop::HeroSection LemonDrop::OutroSection])
        expect(sections.map(&:position)).to eq([1, 2, 3, 4])
        expect(sections.values_at(0, 2, 3)).to eq([title_page, first_hero, outro])
        expect(sections.map(&:anchor)).to eq(%w[title-page hero-2 hero outro])
      end

      it 'refuses an unknown Section type' do
        post admin_lemon_drop_issue_sections_path(issue), params: { section_type: 'User', position: 1 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(issue.sections.count).to eq(0)
      end
    end
  end
end
