require 'spec_helper'

describe 'Admin: Client Menu: Staples', js: true do
  let(:client) { create(:client, first_name: 'Frank', last_name: 'Zappa') }
  let!(:staple_category1) { nil }
  let!(:staple_category2) { nil }
  let!(:staple1) { nil }
  let!(:staple2) { nil }

  let!(:client_menu) do
    # Use a unique ID so that the menu and the items do not
    # have the same IDs which results in a false positive "edit" test.
    create(:client_menu,
      id: 999,
      due_at: '2021-02-01',
      job_date: '2021-02-05',
      client: client
    )
  end

  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  describe 'Initial rendering' do
    before do
      visit admin_client_menu_staples_path(client_menu_id: client_menu.id)
    end

    it 'renders the client menu info' do
      expect(page).to have_content('Frank Zappa')
      expect(page).to have_content('February 5, 2021')
    end

    context 'staple categories do not exist' do
      it 'shows the add category message' do
        expect(page).to have_content('Please add a staple category first!')
        expect(page).to have_link(
          'Go to staple categories page',
          href: admin_client_menu_staple_categories_path(client_menu)
        )
      end
    end

    context 'staple categories exist' do
      let!(:staple_category1) { create(:staple_category, name: 'Dinner', client_menu: client_menu) }
      let!(:staple_category2) { create(:staple_category, name: 'Snacks', client_menu: client_menu) }
      let!(:staple1) { create(:staple, name: 'Beef', staple_category: staple_category1) }
      let!(:staple2) { create(:staple, name: 'Crisps', staple_category: staple_category2) }

      it 'shows the category list' do
        within("[data-staple-category-id='#{staple_category1.id}']") do
          expect(page).to have_content('Dinner')
          expect(page).to have_content('Beef')
        end

        within("[data-staple-category-id='#{staple_category2.id}']") do
          expect(page).to have_content('Snacks')
          expect(page).to have_content('Crisps')
        end

        expect(page).to_not have_content('Go to staple categories page')
      end
    end
  end

  describe 'Staple form' do
    let!(:staple_category1) { create(:staple_category, name: 'Dinner', client_menu: client_menu) }
    let!(:staple_category2) { create(:staple_category, name: 'Snacks', client_menu: client_menu) }

    let!(:staple1) do
      create(:staple,
        name: 'Crisps',
        staple_category: staple_category2
      )
    end

    before do
      visit admin_client_menu_staples_path(client_menu_id: client_menu.id)
    end

    it 'creates a staple' do
      within("[data-staple-category-id='#{staple_category1.id}']") do
        click_link '+ Add Staple'
      end

      fill_in 'Name', with: 'Beef'
      click_button 'Save'

      within("[data-staple-category-id='#{staple_category1.id}']") do
        expect(page).to have_content('Dinner')
        expect(page).to have_content('Beef')
      end

      click_link 'Beef'
      expect(page).to have_field('Name', with: 'Beef')
    end

    it 'edits a staple' do
      click_link 'Crisps'
      fill_in 'Name', with: 'Choco Crisps'
      click_button 'Save'

      within("[data-staple-category-id='#{staple_category2.id}']") do
        expect(page).to have_content('Snacks')
        expect(page).to have_content('Choco Crisps')
      end

      expect(staple1.reload.name).to eq('Choco Crisps')
    end

    it 'deletes a staple' do
      click_link 'Crisps'
      click_link 'Delete'

      expect(accept_alert).to eq('Are you sure?')
      expect(page).to_not have_content('Crisps')
    end

    it 'shows validation message' do
      within("[data-staple-category-id='#{staple_category1.id}']") do
        click_link '+ Add Staple'
      end

      click_button 'Save'

      expect(page).to have_content('This field is required')
    end

    it 'closes when clicking cancel' do
      within("[data-staple-category-id='#{staple_category1.id}']") do
        click_link '+ Add Staple'
      end

      click_button 'Cancel'

      expect(page).to_not have_field(:name)
    end
  end

  describe 'Menu form' do
    let!(:client2) { create(:client, first_name: 'David', last_name: 'Bowie') }

    before do
      visit admin_client_menu_staples_path(client_menu_id: client_menu.id)
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
    let!(:category1) { create(:client_menu_category, name: 'Dinner', client_menu: client_menu) }
    let!(:menu_item1) { create(:client_menu_item, name: 'Beef', client_menu_category: category1) }
    let!(:client) { create(:client, first_name: 'Frank', last_name: 'Zappa') }

    before do
      visit admin_client_menu_staples_path(client_menu_id: client_menu.id)
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
