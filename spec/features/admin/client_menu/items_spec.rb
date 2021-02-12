require 'spec_helper'

describe 'Admin: Client Menu: Items', js: true do
  let(:client) { create(:client, first_name: 'Frank', last_name: 'Zappa') }
  let!(:client_menu) { create(:client_menu, due_at: '2021-02-09', client: client) }

  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  describe 'Initial rendering' do
    before do
      visit admin_client_menu_menu_items_path(client_menu_id: client_menu.id)
    end

    it 'renders the client menu info' do
      expect(page).to have_content('Frank Zappa')
      expect(page).to have_content('February 9, 2021')
    end

    context 'categories do not exist' do
      it 'shows the add category message' do
        expect(page).to have_content('Please add a category first')
        expect(page).to have_link(
          'Go to categories page',
          href: "/admin/client_menus/#{client_menu.id}/categories"
        )
      end
    end

    context 'categories exist' do
      let!(:category1) { create(:client_menu_category, name: 'Dinner', client_menu: client_menu) }
      let!(:category2) { create(:client_menu_category, name: 'Snacks', client_menu: client_menu) }
      let!(:menu_item1) { create(:client_menu_item, name: 'Beef', client_menu_category: category1) }
      let!(:menu_item2) { create(:client_menu_item, name: 'Crisps', client_menu_category: category2) }

      it 'shows the category list' do
        within("[data-category-id='#{category1.id}']") do
          expect(page).to have_content('Dinner')
          expect(page).to have_content('Beef')
        end

        within("[data-category-id='#{category2.id}']") do
          expect(page).to have_content('Snacks')
          expect(page).to have_content('Crisps')
        end

        expect(page).to_not have_content('Go to categories page')
      end
    end
  end

  describe 'Menu Item form' do
    let!(:category1) { create(:client_menu_category, name: 'Dinner', client_menu: client_menu) }
    let!(:category2) { create(:client_menu_category, name: 'Snacks', client_menu: client_menu) }

    let!(:menu_item1) do
      create(:client_menu_item,
        name: 'Crisps',
        cost: '10',
        quantity: 'Pack of 20',
        client_menu_category: category2
      )
    end

    before do
      visit admin_client_menu_menu_items_path(client_menu_id: client_menu.id)
    end

    it 'creates a menu item' do
      within("[data-category-id='#{category1.id}']") do
        click_button '+ Add Item'
      end

      fill_in 'name', with: 'Beef'
      fill_in 'cost', with: '7'
      fill_in 'quantity', with: '1 slab'
      click_button 'Submit'

      within("[data-category-id='#{category1.id}']") do
        expect(page).to have_content('Dinner')
        expect(page).to have_content('Beef')
      end
    end

    it 'creates a menu item' do
      click_link 'Crisps'
      fill_in 'name', with: 'Choco Crisps'
      fill_in 'cost', with: '15'
      fill_in 'quantity', with: 'Sleeve of 5'
      click_button 'Submit'

      within("[data-category-id='#{category2.id}']") do
        expect(page).to have_content('Snacks')
        expect(page).to have_content('Choco Crisps')
      end

      expect(menu_item1.reload.cost).to eq('15')
      expect(menu_item1.quantity).to eq('Sleeve of 5')
    end

    it 'deletes a menu item' do
      click_link 'Crisps'
      click_button 'Delete'

      expect(accept_alert).to eq('Are you sure?')
      expect(page).to_not have_content('Crisps')
    end

    it 'shows validation message' do
      within("[data-category-id='#{category1.id}']") do
        click_button '+ Add Item'
      end

      click_button 'Submit'

      expect(accept_alert).to eq('Name and Cost are required')
    end

    it 'closes when clicking cancel' do
      within("[data-category-id='#{category1.id}']") do
        click_button '+ Add Item'
      end

      click_button 'Cancel'

      expect(page).to_not have_field(:name)
    end
  end

  describe 'Menu form' do
    before do
      visit admin_client_menu_menu_items_path(client_menu_id: client_menu.id)
    end

    it 'updates the menu date' do
      find('.hamburger-nav__control').click
      click_link 'Edit'
      fill_in 'due_at', with: '02/28/21'
      click_button 'Submit'

      expect(page).to have_content('February 28, 2021')
      expect(page).to_not have_link('Edit')
    end

    it 'closes when clicking cancel' do
      find('.hamburger-nav__control').click
      click_link 'Edit'
      click_button 'Cancel'

      expect(page).to_not have_field(:due_at)
    end

    it 'shows validation message' do
      find('.hamburger-nav__control').click
      click_link 'Edit'
      fill_in 'due_at', with: ''
      click_button 'Submit'

      expect(accept_alert).to eq('Prep Date is required')
    end
  end
end
