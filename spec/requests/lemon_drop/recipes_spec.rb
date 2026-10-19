require 'spec_helper'

RSpec.describe 'LemonDrop Recipes', type: :request do
  let(:issue) { create(:lemon_drop_issue, :published) }

  def add_recipes_section(heading: nil, **section_attributes)
    create(:lemon_drop_section, issue: issue, sectionable: build(:lemon_drop_recipes_section, heading: heading),
      **section_attributes).sectionable
  end

  def add_recipe(recipes_section = add_recipes_section, **attributes)
    create(:lemon_drop_recipe, recipes_section: recipes_section, **attributes)
  end

  def issue_page
    get lemon_drop_issue_path(issue.slug)
    response.body
  end

  describe 'on the Issue page' do
    it 'renders a Recipe with its slug as the element ID, using the reference markup' do
      add_recipe(title: 'chickpea stew', hero_image: uploaded_image('chickpea-stew.jpg'), hero_focus: 'top',
        tip: 'consume your cilantro leaves whole!')

      expect(issue_page).to include('<article class="recipe" id="chickpea-stew">', '<h2><span>chickpea stew</span></h2>')
      expect(response.body).to match(%r{<div class="recipe-hero">\s*<img[^>]+chickpea-stew\.jpg})
      expect(response.body).to match(%r{<img[^>]+style="object-position: center top"})
      expect(response.body).to match(%r{<h3>what you need</h3>\s*<h4>Produce</h4>\s*<ul>\s*<li>4 garlic cloves, thinly sliced</li>})
      expect(response.body).to match(%r{<h3>what you do</h3>\s*<ol>\s*<li>Heat a generous pour of olive oil.</li>})
      expect(response.body).to include('<p class="tip">consume your cilantro leaves whole!</p>')
    end

    describe 'time line' do
      it 'shows prep, cook, computed total and servings' do
        add_recipe(prep_minutes: 20, cook_minutes: 60, serves: 5)

        expect(issue_page).to include(
          '<p class="meta mono-caps">prep time: 20 mins / cook time: 1 hour / total time: 1 hour 20 mins / serves: 5</p>'
        )
      end

      it 'appends the time note and uses the total override' do
        add_recipe(prep_minutes: 15, cook_minutes: 40, time_note: '+ marinating', total_label: '1hr', serves: 5)

        expect(issue_page).to include(
          '<p class="meta mono-caps">prep time: 15 mins + marinating / cook time: 40 mins / total time: 1hr / serves: 5</p>'
        )
      end

      it 'leaves out the parts it has no value for' do
        add_recipe(cook_minutes: 120)

        expect(issue_page).to include('<p class="meta mono-caps">cook time: 2 hours / total time: 2 hours</p>')
      end

      it 'is left out when there are no times or servings' do
        add_recipe

        expect(issue_page).not_to include('class="meta')
      end
    end

    it 'renders Recipes in order across several Recipes Sections' do
      later = add_recipes_section(position: 2)
      earlier = add_recipes_section(position: 1)
      add_recipe(later, title: 'ragu', position: 1)
      add_recipe(earlier, title: 'gnocchi', position: 2)
      add_recipe(later, title: 'egg bake', position: 0)
      add_recipe(earlier, title: 'stew', position: 1)

      expect(issue_page).to match(/id="stew".*id="gnocchi".*id="egg-bake".*id="ragu"/m)
    end

    it 'shows the Recipes Section heading only when it has one' do
      add_recipes_section(heading: 'this week’s recipes')
      add_recipes_section

      expect(issue_page.scan('recipes-head').size).to eq(1)
      expect(response.body).to include('<h2>this week’s recipes</h2>')
    end

    describe 'slugs' do
      it 'suffixes a Recipe slug taken by another Recipe in any Recipes Section of the Issue' do
        add_recipe(title: 'chickpea stew')
        add_recipe(title: 'Chickpea Stew!')

        expect(issue_page).to include('id="chickpea-stew"', 'id="chickpea-stew-2"')
      end

      it 'suffixes a Recipe slug taken by a Section anchor' do
        add_recipes_section(anchor: 'stew')
        add_recipe(title: 'stew')

        expect(issue_page).to include('<div id="stew"', '<article class="recipe" id="stew-2">')
      end

      it 'suffixes a Section anchor taken by a Recipe slug' do
        add_recipe(title: 'hero')
        create(:lemon_drop_section, issue: issue, sectionable: build(:lemon_drop_hero_section))

        expect(issue_page).to include('<article class="recipe" id="hero">', '<div id="hero-2"')
      end

      it 'keeps the same slug in different Issues' do
        add_recipe(title: 'chickpea stew')
        other_issue = create(:lemon_drop_issue, :published)
        other_section = create(:lemon_drop_section, issue: other_issue, sectionable: build(:lemon_drop_recipes_section))
        create(:lemon_drop_recipe, recipes_section: other_section.sectionable, title: 'chickpea stew')

        get lemon_drop_issue_path(other_issue.slug)
        expect(response.body).to include('id="chickpea-stew"')
      end
    end

    it 'puts the kicker above the title' do
      add_recipe(title: 'smoky turkey & kale soup', kicker: 'easy freeze')

      expect(issue_page).to include('<h2><small><span>easy freeze</span></small><span>smoky turkey &amp; kale soup</span></h2>')
    end

    it 'leaves out the hero image and tip when there are none' do
      add_recipe

      expect(issue_page).not_to include('class="tip"')
      expect(response.body).not_to match(%r{<div class="recipe-hero">\s*<img})
    end

    it 'keeps ingredient text exactly as written' do
      group = create(:lemon_drop_ingredient_group, recipe: add_recipe, name: 'Pantry')
      create(:lemon_drop_ingredient, ingredient_group: group, text: '2 cans chickpeas (15 oz each), drained and rinsed')

      expect(issue_page).to include('<h4>Pantry</h4>', '<li>2 cans chickpeas (15 oz each), drained and rinsed</li>')
    end
  end

  describe 'GET /drops/:slug/recipes/:recipe_slug' do
    it 'renders the Recipe on its own page in the lemon drop layout' do
      add_recipe(title: 'gnocchi')
      add_recipe(title: 'chickpea stew', prep_minutes: 15, cook_minutes: 30, serves: 5)

      get lemon_drop_recipe_path(issue.slug, 'chickpea-stew')

      expect(response).to have_http_status(200)
      expect(response.body).to include(
        '<title>the lemon drop · chickpea stew</title>',
        '<article class="recipe" id="chickpea-stew">',
        'prep time: 15 mins / cook time: 30 mins / total time: 45 mins / serves: 5',
        "href=\"#{lemon_drop_issue_path(issue.slug)}\""
      )
      expect(response.body).not_to include('id="gnocchi"')
    end

    it 'returns 404 when the Issue is a Draft' do
      issue.update!(status: 'draft')
      add_recipe(title: 'chickpea stew')

      expect { get lemon_drop_recipe_path(issue.slug, 'chickpea-stew') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 404 for a Recipe of another Issue' do
      create(:lemon_drop_recipe, title: 'chickpea stew')

      expect { get lemon_drop_recipe_path(issue.slug, 'chickpea-stew') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 404 for an unknown Recipe slug' do
      expect { get lemon_drop_recipe_path(issue.slug, 'nope') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
