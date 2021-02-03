require 'rails_helper'

describe 'Admin: Client Menus', js: true do
  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  describe 'Initial rendering' do
    context 'clients do not exist' do
      it 'shows the add client message' do
        visit admin_client_menus_path

        expect(page).to have_content('Please add a client')
        expect(page).to_not have_button('Add Client Menu')
        expect(page).to_not have_content('No menus yet.')
      end
    end

    context 'clients exist' do
      let!(:client) { create(:client, first_name: 'Frank', last_name: 'Zappa') }

      context 'menus do not exist' do
        it 'shows the empty message' do
          visit admin_client_menus_path

          expect(page).to have_content('No menus yet.')
          expect(page).to_not have_content('Please add a client')
        end
      end

      context 'menus exist' do
        let!(:client_menu) { create(:client_menu, client: client) }

        it 'lists the menus' do
          visit admin_client_menus_path

          expect(page).to have_content(client.full_name)
          expect(page).to_not have_content('No menus yet.')
          expect(page).to_not have_content('Please add a client')
        end
      end
    end
  end

  describe 'Client Menu form' do
    let!(:client) { create(:client, first_name: 'Frank', last_name: 'Zappa') }
    let!(:client2) { create(:client, first_name: 'David', last_name: 'Bowie') }

    it 'creates a client menu' do
      visit admin_client_menus_path
      click_button 'Add Client Menu'
      select 'David Bowie', from: 'client'
      fill_in 'due_at', with: '03/31/2021'
      click_button 'Submit'

      expect(page).to have_content('Loading...')
      expect(page).to_not have_content('New Client Menu')
      expect(page).to have_content('David Bowie: March 31, 2021')
    end

    it 'closes when clicking cancel' do
      visit admin_client_menus_path
      click_button 'Add Client Menu'
      click_button 'Cancel'
      expect(page).to_not have_content('New Client Menu')
    end
  end
end
