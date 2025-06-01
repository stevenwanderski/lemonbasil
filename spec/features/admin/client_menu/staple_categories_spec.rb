require 'spec_helper'

describe 'Admin: Client Menu: Staple Categories', js: true do
  let(:user) { create(:user) }
  let(:client) { create(:client, user: user, first_name: 'Frank', last_name: 'Zappa') }
  let!(:client_menu) { create(:client_menu, user: user, job_date: '2021-02-09', client: client) }
  let!(:staple_category) { nil }

  before do
    login_as(user, scope: :user)
  end

  describe 'Initial rendering' do
    before do
      visit admin_client_menu_staple_categories_path(client_menu_id: client_menu.id)
    end

    it 'renders the client menu info' do
      expect(page).to have_content('Frank Zappa')
      expect(page).to have_content('February 9, 2021')
    end

    context 'staple categories do not exist' do
      it 'shows the add staple categories message' do
        expect(page).to have_content('Click the button to add a staple category!')
      end

      it 'adds a staple category' do
        click_link '+ Add Staple Category'
        fill_in 'Name', with: 'Snacks'
        click_button 'Save'

        expect(page).to have_content('Snacks')
      end
    end

    context 'staple categories exist' do
      let!(:staple_category) { create(:staple_category, name: 'Dinner', client_menu: client_menu) }

      it 'shows the staple category list' do
        expect(page).to have_content('Dinner')
        expect(page).to_not have_content('No categories. Add one now!')
      end
    end
  end

  describe 'Staple Category form' do
    let!(:staple_category) { create(:staple_category, name: 'Dinner', client_menu: client_menu) }

    before do
      visit admin_client_menu_staple_categories_path(client_menu_id: client_menu.id)
    end

    it 'creates a staple category' do
      click_link '+ Add Staple Category'
      fill_in 'Name', with: 'Snacks'
      click_button 'Save'

      expect(page).to have_content('Snacks')
    end

    it 'edits a staple category' do
      click_link 'Dinner'
      fill_in 'Name', with: 'Lunch'
      click_button 'Save'

      expect(page).to_not have_content('Dinner')
      expect(page).to have_content('Lunch')
    end

    it 'deletes a staple category' do
      click_link 'Dinner'
      click_link 'Delete'

      expect(accept_alert).to eq('Are you sure?')
      expect(page).to_not have_content('Dinner')
    end

    it 'shows validation message' do
      click_link '+ Add Staple Category'
      click_button 'Save'

      expect(page).to have_content('This field is required')
    end

    it 'closes when clicking cancel' do
      click_link '+ Add Staple Category'
      click_button 'Cancel'

      expect(page).to_not have_field('Name')
    end
  end

  describe 'Menu form' do
    before do
      visit admin_client_menu_staple_categories_path(client_menu_id: client_menu.id)
    end

    it 'updates the menu info' do
      find('.hamburger-nav__control').click
      click_link 'Edit'
      fill_in 'Prep Date', with: '02/28/2021'
      click_button 'Save'

      expect(page).to have_content('February 28, 2021')
      expect(page).to_not have_link('Edit')
    end
  end

  describe 'Copy Menu' do
    before do
      visit admin_client_menu_staple_categories_path(client_menu_id: client_menu.id)
    end

    it 'redirects to the new menu' do
      find('.hamburger-nav__control').click
      click_link 'Copy Menu'
      fill_in 'Prep Date', with: '02/15/2021'
      fill_in 'Due Date', with: '02/13/2021'
      page.execute_script('$(".datepicker").datepicker("hide");')
      select 'Frank Zappa', from: 'Client'
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

      expect(page).to_not have_field('Prep Date')
    end

    it 'shows validation message' do
      find('.hamburger-nav__control').click
      click_link 'Copy Menu'
      click_button 'Submit'

      expect(page).to have_content('This field is required')
    end
  end
end
