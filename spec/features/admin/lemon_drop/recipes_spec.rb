require 'spec_helper'

describe 'Admin: Lemon Drop: Recipes', js: true do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:issue) { create(:lemon_drop_issue) }
  let!(:section) { create(:lemon_drop_section, issue: issue, position: 1, sectionable: build(:lemon_drop_recipes_section)) }

  before { login_as(admin, scope: :user) }

  it 'drags a Recipe to the top of its Section, and the order stays after a reload' do
    create(:lemon_drop_recipe, recipes_section: section.sectionable, title: 'chickpea stew', position: 1)
    create(:lemon_drop_recipe, recipes_section: section.sectionable, title: 'harissa chicken', position: 2)

    visit edit_admin_lemon_drop_issue_section_path(issue, section)
    all('.recipe-list__row').last.find('.drag-handle').drag_to(first('.recipe-list__row'), delay: 0.2)

    expect(page).to have_css('.recipe-list__row:first-child', text: 'harissa chicken')
    visit edit_admin_lemon_drop_issue_section_path(issue, section)
    expect(all('.recipe-list__row strong').map(&:text)).to eq(['harissa chicken', 'chickpea stew'])
  end

  it 'adds a Recipe with two ingredient groups and its steps' do
    visit edit_admin_lemon_drop_issue_section_path(issue, section)
    click_link '+ Add recipe'

    fill_in 'Title', with: 'chickpea stew'
    select 'Soup', from: 'Category'
    2.times { click_button '+ Add ingredient group' }
    first_group, second_group = all('.nested-row').to_a
    first_group.fill_in 'Group name', with: 'Produce'
    first_group.fill_in 'Ingredients', with: "1 onion\n2 lemons"
    second_group.fill_in 'Group name', with: 'Pantry'
    second_group.fill_in 'Ingredients', with: 'tahini'
    fill_in 'Steps', with: "Heat the oil.\nSimmer."
    click_button 'Save'

    expect(page).to have_content('Recipe added!')
    recipe = LemonDrop::Recipe.last
    expect(recipe.ingredient_groups.map { |group| [group.name, group.ingredients.map(&:text)] }).to eq([
      ['Produce', ['1 onion', '2 lemons']], ['Pantry', ['tahini']]
    ])
    expect(recipe.steps.map(&:body)).to eq(['Heat the oil.', 'Simmer.'])
  end
end
