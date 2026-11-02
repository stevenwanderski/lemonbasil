require 'spec_helper'

RSpec.describe 'Admin::LemonDrop live editor: Recipes', type: :request do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:issue) { create(:lemon_drop_issue) }
  let!(:menu) do
    create(:lemon_drop_section, issue: issue, position: 1, anchor: 'menu',
      sectionable: build(:lemon_drop_menu_overview_section, heading: 'your menu'))
  end
  let!(:section) { create(:lemon_drop_section, issue: issue, position: 2, anchor: 'recipes', sectionable: build(:lemon_drop_recipes_section)) }
  let!(:recipe) { create(:lemon_drop_recipe, recipes_section: section.sectionable, title: 'chickpea stew') }

  def page_elements
    Nokogiri::HTML.fragment(response.body).element_children
  end

  it 'is not open to a non-Admin' do
    login_as(create(:user, email: 'staff@test.com', role: 'staff'), scope: :user)

    post preview_admin_lemon_drop_issue_section_recipe_path(issue, section, recipe), params: { lemon_drop_recipe: { title: 'hacked' } }

    expect(response).to redirect_to(admin_clients_path)
  end

  describe 'as an Admin' do
    before { login_as(admin, scope: :user) }

    it 'opens a Recipe and a blank one in the drawer: just the forms' do
      get edit_admin_lemon_drop_issue_section_recipe_path(issue, section, recipe, drawer: 1)

      expect(response.body).not_to include('<html')
      expect(response.body).to include('Recipe: chickpea stew', preview_admin_lemon_drop_issue_section_recipe_path(issue, section, recipe))

      get new_admin_lemon_drop_issue_section_recipe_path(issue, section, drawer: 1)

      expect(response.body).not_to include('<html')
      expect(response.body).to include('New Recipe')
    end

    it 'previews unsaved changes, steps and ingredients included, and keeps nothing' do
      group = recipe.ingredient_groups.first
      post preview_admin_lemon_drop_issue_section_recipe_path(issue, section, recipe), params: { lemon_drop_recipe: {
        title: 'white bean stew', steps_text: "Soak the beans.\nSimmer.",
        ingredient_groups_attributes: { '0' => { id: group.id, ingredients_text: '1 lb white beans', position: 1 } }
      } }

      article = page_elements.sole
      expect(article['data-recipe-id']).to eq(recipe.id.to_s)
      expect(article.css('h2').text).to include('white bean stew')
      expect(article.css('.do li').map(&:text)).to eq(['Soak the beans.', 'Simmer.'])
      expect(article.css('.need li').map(&:text)).to eq(['1 lb white beans'])
      expect(recipe.reload.title).to eq('chickpea stew')
      expect(recipe.steps.count).to eq(1)
      expect(group.ingredients.reload.map(&:text)).to eq(['4 garlic cloves, thinly sliced'])
    end

    it 'saves from the drawer, answering with the Recipe and the Menu Overview' do
      patch admin_lemon_drop_issue_section_recipe_path(issue, section, recipe, drawer: 1),
        params: { lemon_drop_recipe: { title: 'white bean stew', menu_title: 'White Bean Stew' } }

      expect(page_elements.map { |element| element['data-section-id'] || element['data-recipe-id'] }).to eq([menu.id.to_s, recipe.id.to_s])
      expect(page_elements.first.text).to include('White Bean Stew')
      expect(recipe.reload.title).to eq('white bean stew')
    end

    it 'adds a Recipe from the drawer, answering with its whole Recipes Section' do
      post admin_lemon_drop_issue_section_recipes_path(issue, section, drawer: 1),
        params: { lemon_drop_recipe: { title: 'harissa chicken', category: 'entree' } }

      section_html = page_elements.find { |element| element['data-section-id'] == section.id.to_s }
      expect(section_html.css('[data-recipe-id] h2').map(&:text)).to eq(['chickpea stew', 'harissa chicken'])
    end

    it 'deletes a Recipes Section from the drawer, moving its Recipes, and answers with what changed' do
      other = create(:lemon_drop_section, issue: issue, position: 3, anchor: 'more', sectionable: build(:lemon_drop_recipes_section))

      delete admin_lemon_drop_issue_section_path(issue, section, drawer: 1), params: { move_recipes_to: other.id }

      expect(page_elements.map { |element| element['data-section-id'] }).to eq([other.id.to_s, menu.id.to_s])
      expect(page_elements.first.css('[data-recipe-id] h2').map(&:text)).to eq(['chickpea stew'])
      expect(issue.sections.reload).to eq([menu, other])
    end

    it 'shows a refused save in the drawer' do
      patch admin_lemon_drop_issue_section_recipe_path(issue, section, recipe, drawer: 1), params: { lemon_drop_recipe: { title: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).not_to include('<html')
      expect(response.body).to include('form-errors')
    end
  end
end
