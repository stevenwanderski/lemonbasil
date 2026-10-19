require 'spec_helper'

RSpec.describe 'LemonDrop Table of Contents and Menu Overview Sections', type: :request do
  let(:issue) { create(:lemon_drop_issue, :published) }

  def add_section(sectionable, **section_attributes)
    create(:lemon_drop_section, issue: issue, sectionable: sectionable, **section_attributes)
  end

  def page
    get lemon_drop_issue_path(issue.slug)
    response.body
  end

  describe 'Table of Contents' do
    it "lists the other Sections marked show-in-TOC, in page order, by TOC label or heading" do
      add_section(build(:lemon_drop_grocery_list_section), position: 3, show_in_toc: true, anchor: 'grocery')
      add_section(build(:lemon_drop_table_of_contents_section), position: 1, show_in_toc: true)
      add_section(build(:lemon_drop_intro_section), position: 2)
      add_section(build(:lemon_drop_outro_section, heading: 'book your holiday party!'), position: 5,
        show_in_toc: true, toc_label: 'let’s party!', anchor: 'party')

      expect(page).to match(
        %r{<section class="contents">\s*<div class="wrap">\s*<div class="runner">the lemon drop</div>\s*<h2>this week’s drop</h2>\s*<ul>\s*<li><a href="#grocery">your grocery list</a></li>\s*<li><a href="#party">let’s party!</a></li>\s*</ul>}
      )
    end

    it 'leaves out a Section with neither a TOC label nor a heading' do
      add_section(build(:lemon_drop_table_of_contents_section), position: 1)
      add_section(build(:lemon_drop_recipes_section), position: 2, show_in_toc: true, anchor: 'recipes')

      expect(page).to include('<h2>this week’s drop</h2>')
      expect(response.body).not_to include('href="#recipes"')
    end
  end

  describe 'Menu Overview' do
    def add_recipes_section(position:, recipes: [])
      recipes_section = build(:lemon_drop_recipes_section)
      add_section(recipes_section, position: position)
      recipes.each.with_index(1) do |attributes, recipe_position|
        create(:lemon_drop_recipe, recipes_section: recipes_section, position: recipe_position, **attributes)
      end
    end

    it "lists every Recipe in the Recipes Sections, by category in order, in page order within each" do
      add_section(build(:lemon_drop_menu_overview_section, icon: uploaded_image('mortar.png')), position: 1, anchor: 'menu')
      add_recipes_section(position: 4, recipes: [
        { title: 'egg bake', menu_title: 'Harvest Egg Bake', menu_blurb: 'eggs, sweet potato', category: 'breakfast' },
        { title: 'ragu', menu_title: 'Beef & Mushroom Ragu', menu_blurb: 'ground beef, mushrooms', category: 'entree' }
      ])
      add_recipes_section(position: 2, recipes: [
        { title: 'gnocchi', menu_title: 'Brown Butter Gnocchi', menu_blurb: 'gnocchi, brown butter', category: 'entree' }
      ])
      add_recipes_section(position: 5, recipes: [
        { title: 'chickpea stew', menu_blurb: 'chickpeas, spinach', category: 'soup' }
      ])

      expect(page).to match(
        %r{<section class="menu">\s*<div class="wrap">\s*<div class="runner">the lemon drop</div>\s*<img class="mortar"[^>]+mortar\.png[^>]*>\s*<h2>your menu</h2>\s*<div class="menu-grid">\s*<div class="menu-col">\s*<div class="menu-cat mono-caps">entrees</div>\s*<div class="dish"><a href="#gnocchi">Brown Butter Gnocchi</a><p>gnocchi, brown butter</p></div>\s*<div class="dish"><a href="#ragu">Beef &amp; Mushroom Ragu</a><p>ground beef, mushrooms</p></div>\s*</div>\s*<div class="menu-col">\s*<div class="menu-cat mono-caps">soup</div>\s*<div class="dish"><a href="#chickpea-stew">chickpea stew</a><p>chickpeas, spinach</p></div>\s*<div class="menu-cat mono-caps">breakfast</div>\s*<div class="dish"><a href="#egg-bake">Harvest Egg Bake</a><p>eggs, sweet potato</p></div>\s*</div>\s*</div>}
      )
    end

    it 'follows its own category order, with any category it leaves out at the end' do
      add_section(build(:lemon_drop_menu_overview_section, category_order: %w[snack breakfast]), position: 1)
      add_recipes_section(position: 2, recipes: [
        { title: 'chickpea stew', category: 'soup' },
        { title: 'egg bake', category: 'breakfast' },
        { title: 'pumpkin hummus', category: 'snack' }
      ])

      expect(page).to match(/menu-cat mono-caps">snack<.*menu-cat mono-caps">breakfast<.*menu-cat mono-caps">soup</m)
    end

    it 'is skipped, and left out of the Table of Contents, when no Recipes Section has Recipes' do
      add_section(build(:lemon_drop_table_of_contents_section), position: 1)
      add_section(build(:lemon_drop_menu_overview_section), position: 2, anchor: 'menu', show_in_toc: true, toc_label: 'recipes')
      add_recipes_section(position: 4)

      expect(page).to include('<h2>this week’s drop</h2>')
      expect(response.body).not_to include('id="menu"', '<section class="menu">', 'href="#menu"')
    end
  end
end
