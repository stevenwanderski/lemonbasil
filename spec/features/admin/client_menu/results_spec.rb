require 'spec_helper'

describe 'Admin: Client Menu: Results', js: true do
  let(:client) { create(:client, first_name: 'Frank', last_name: 'Zappa') }
  let!(:menu) { create(:client_menu, job_date: '2021-02-09', client: client) }

  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  describe 'Initial rendering' do
    it 'renders the client menu info' do
      visit admin_client_menu_results_path(client_menu_id: menu.id)

      expect(page).to have_content('Frank Zappa')
      expect(page).to have_content('February 9, 2021')
    end

    context 'submission does not exist' do
      it 'shows the empty message' do
        visit admin_client_menu_results_path(client_menu_id: menu.id)

        expect(page).to have_content('The client has not made selections yet.')
      end
    end

    context 'submission exists' do
      let!(:submission) do
        create(:client_menu_submission,
          client_menu: menu,
          total: 22,
          created_at: '2021-03-02'
        )
      end

      let!(:category1) { create(:client_menu_category, client_menu: menu, name: 'Breakfast') }
      let!(:category2) { create(:client_menu_category, client_menu: menu, name: 'Dinner') }
      let!(:item1) { create(:client_menu_item, client_menu_category: category1, name: 'Eggs Benny', cost: 7) }
      let!(:item2) { create(:client_menu_item, client_menu_category: category1, name: 'French Toast', cost: 12) }
      let!(:item3) { create(:client_menu_item, client_menu_category: category2, name: 'Chicken and Veggies', cost: 22) }
      let!(:item4) { create(:client_menu_item, client_menu_category: category2, name: 'Carrot Soup', cost: 9) }

      let!(:selection1) { create(:client_menu_selection, client_menu_submission: submission, client_menu_item: item1)}
      let!(:selection2) { create(:client_menu_selection, client_menu_submission: submission, client_menu_item: item2)}
      let!(:selection3) { create(:client_menu_selection, client_menu_submission: submission, client_menu_item: item3)}

      it 'shows the selections' do
        visit admin_client_menu_results_path(client_menu_id: menu.id)

        expect(page).to have_content('Total estimate: $22')
        expect(page).to have_content('Submitted: 03/02/2021')

        within("[data-category-id='#{category1.id}']") do
          expect(page).to have_content('Breakfast')
          expect(page).to have_content('Eggs Benny $7')
          expect(page).to have_content('French Toast $12')
        end

        within("[data-category-id='#{category2.id}']") do
          expect(page).to have_content('Dinner')
          expect(page).to have_content('Chicken and Veggies $22')
        end
      end

      context 'notes exist' do
        it 'shows the notes' do
          submission.update!(notes: 'I am notes!')

          visit admin_client_menu_results_path(client_menu_id: menu.id)

          expect(page).to have_content('I am notes!')
        end
      end

      context 'staple selections exist' do
        let!(:staple_category) { create(:staple_category, name: 'Pantry', client_menu: menu) }
        let!(:staple1) { create(:staple, name: 'Rice', staple_category: staple_category) }
        let!(:staple2) { create(:staple, name: 'Beans', staple_category: staple_category) }
        let!(:staple_selection1) { submission.staples << staple1 }
        let!(:staple_notes) { submission.update!(staples_notes: 'I am staple notes.') }

        it 'shows the staples' do
          visit admin_client_menu_results_path(client_menu_id: menu.id)

          expect(page).to have_content('Staples')
          expect(page).to have_content('Rice')
          expect(page).to_not have_content('Beans')
          expect(page).to have_content('I am staple notes.')
        end
      end
    end
  end
end
