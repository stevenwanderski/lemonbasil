require 'spec_helper'

describe 'Admin: Client Menu: Categories', js: true do
  let(:client) { create(:client, first_name: 'Frank', last_name: 'Zappa') }
  let!(:client_menu) { create(:client_menu, job_date: '2021-02-09', client: client) }
  let!(:category) { nil }

  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  describe 'Initial rendering' do
    before do
      visit admin_client_menu_categories_path(client_menu_id: client_menu.id)
    end

    it 'renders the client menu info' do
      expect(page).to have_content('Frank Zappa')
      expect(page).to have_content('February 9, 2021')
    end

    context 'categories do not exist' do
      it 'shows the add categories message' do
        expect(page).to have_content('No categories. Add one now!')
      end

      it 'opens the category form' do
        click_button '+ Add Category'
        expect(page).to have_field(:name)
      end
    end

    context 'categories exist' do
      let!(:category) { create(:client_menu_category, name: 'Dinner', client_menu: client_menu) }

      it 'shows the category list' do
        expect(page).to have_content('Dinner')
        expect(page).to_not have_content('No categories. Add one now!')
      end
    end
  end

  describe 'Category form' do
    let!(:category) { create(:client_menu_category, name: 'Dinner', client_menu: client_menu) }

    before do
      visit admin_client_menu_categories_path(client_menu_id: client_menu.id)
    end

    it 'creates a category' do
      click_button '+ Add Category'
      fill_in 'name', with: 'Snacks'
      click_button 'Submit'

      expect(page).to have_content('Snacks')
    end

    it 'edits a category' do
      click_link 'Dinner'
      fill_in 'name', with: 'Lunch'
      click_button 'Submit'

      expect(page).to_not have_content('Dinner')
      expect(page).to have_content('Lunch')
    end

    it 'deletes a category' do
      click_link 'Dinner'
      click_button 'Delete'

      expect(accept_alert).to eq('Are you sure?')
      expect(page).to_not have_content('Dinner')
    end

    it 'shows validation message' do
      click_button '+ Add Category'
      click_button 'Submit'

      expect(accept_alert).to eq('Name is required')
    end

    it 'closes when clicking cancel' do
      click_button '+ Add Category'
      click_button 'Cancel'

      expect(page).to_not have_field(:name)
    end
  end

  describe 'Menu form' do
    let!(:client2) { create(:client, first_name: 'David', last_name: 'Bowie') }

    before do
      visit admin_client_menu_categories_path(client_menu_id: client_menu.id)
    end

    it 'updates the menu info' do
      find('.hamburger-nav__control').click
      click_link 'Edit'
      fill_in 'job_date', with: '02/28/21'
      select 'David Bowie', from: 'dupe_client'
      click_button 'Submit'

      expect(page).to have_content('February 28, 2021')
      expect(page).to have_content('David Bowie')
      expect(page).to_not have_link('Edit')
    end
  end

  describe 'Copy Menu' do
    let!(:category1) { create(:client_menu_category, name: 'Dinner', client_menu: client_menu) }
    let!(:menu_item1) { create(:client_menu_item, name: 'Beef', client_menu_category: category1) }

    before do
      visit admin_client_menu_categories_path(client_menu_id: client_menu.id)
    end

    it 'redirects to the new menu' do
      find('.hamburger-nav__control').click
      click_link 'Copy Menu'
      fill_in 'dupe_job_date', with: '02/15/21'
      fill_in 'dupe_due_at', with: '02/13/21'
      click_button 'Submit'

      expect(page).to have_content('February 15, 2021')

      menu = ClientMenu.order(created_at: :desc).first
      expect(page).to have_current_path(
        admin_client_menu_menu_items_path(client_menu_id: menu.id)
      )
    end

    it 'closes when clicking cancel' do
      find('.hamburger-nav__control').click
      click_link 'Copy Menu'
      click_button 'Cancel'

      expect(page).to_not have_field(:dupe_due_at)
    end

    it 'shows validation message' do
      find('.hamburger-nav__control').click
      click_link 'Copy Menu'
      fill_in 'dupe_job_date', with: ''
      fill_in 'dupe_due_at', with: ''
      click_button 'Submit'

      expect(accept_alert).to eq('Due Date and Prep Date are required')
    end
  end
end
