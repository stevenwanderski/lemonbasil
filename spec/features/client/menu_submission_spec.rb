require 'spec_helper'

describe 'Client: Menu Submission', js: true do
  let!(:client) { create(:client, first_name: 'Frank', last_name: 'Zappa', email: 'frank@zappa.com') }
  let!(:menu) { create(:client_menu, client: client, job_date: '2021-03-02', due_at: '2021-02-28') }
  let!(:category1) { create(:client_menu_category, client_menu: menu, name: 'Breakfast') }
  let!(:category2) { create(:client_menu_category, client_menu: menu, name: 'Dinner') }
  let!(:item1) { create(:client_menu_item, client_menu_category: category1, name: 'Eggs Benny', cost: 7) }
  let!(:item2) { create(:client_menu_item, client_menu_category: category1, name: 'French Toast', cost: 12) }
  let!(:item3) { create(:client_menu_item, client_menu_category: category2, name: 'Chicken and Veggies', cost: 22) }
  let!(:item4) { create(:client_menu_item, client_menu_category: category2, name: 'Carrot Soup', cost: 9) }

  before do
    visit menu_slug_path(slug: menu.slug)
  end

  describe 'Initial rendering' do
    it 'shows the client info and menu items' do
      expect(page).to have_content('Frank Zappa')
      expect(page).to have_content('Prep date: 3/2/2021')
      expect(page).to have_content('Submit by: 2/28/2021')
      expect(page).to have_content('Total Estimate: $0')
      expect(page).to have_content('Selected items: 0')

      within("[data-category-id='#{category1.id}']") do
        expect(page).to have_content('Breakfast')
        expect(page).to have_content('Eggs Benny')
        expect(page).to have_content('French Toast')
      end

      within("[data-category-id='#{category2.id}']") do
        expect(page).to have_content('Dinner')
        expect(page).to have_content('Chicken and Veggies')
        expect(page).to have_content('Carrot Soup')
      end
    end
  end

  describe 'Item Selections' do
    it 'updates the total and item count on selection' do
      check "item-#{item1.id}"
      expect(page).to have_content('Total Estimate: $7')
      expect(page).to have_content('Selected items: 1')

      check "item-#{item2.id}"
      expect(page).to have_content('Total Estimate: $19')
      expect(page).to have_content('Selected items: 2')

      check "item-#{item3.id}"
      expect(page).to have_content('Total Estimate: $41')
      expect(page).to have_content('Selected items: 3')

      uncheck "item-#{item1.id}"
      expect(page).to have_content('Total Estimate: $34')
      expect(page).to have_content('Selected items: 2')
    end

    it 'disables submit button unless a slection is made' do
      expect(page).to have_button('Submit Order', disabled: true)

      check "item-#{item1.id}"

      expect(page).to have_button('Submit Order', disabled: false)
    end

    it 'redirects to success page' do
      check "item-#{item1.id}"
      click_button 'Submit Order'

      expect(accept_alert).to eq('Are you sure you want to submit your selections?')
      expect(page).to have_content('thank you!')
    end
  end
end
