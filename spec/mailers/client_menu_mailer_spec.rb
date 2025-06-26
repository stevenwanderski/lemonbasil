require 'spec_helper'

describe ClientMenuMailer do
  let!(:user) { create(:user) }
  let!(:client) { create(:client, user: user) }
  let!(:menu) { create(:client_menu, user: user, client: client, job_date: '2021-03-02', show_pricing: show_pricing) }
  let!(:submission) { create(:client_menu_submission, client_menu: menu, total: 22, notes: 'I am notes!') }

  let!(:category1) { create(:client_menu_category, client_menu: menu, name: 'Breakfast') }
  let!(:category2) { create(:client_menu_category, client_menu: menu, name: 'Dinner') }
  let!(:item1) { create(:client_menu_item, client_menu_category: category1, name: 'Eggs Benny', cost: 7) }
  let!(:item2) { create(:client_menu_item, client_menu_category: category1, name: 'French Toast', cost: 12) }
  let!(:item3) { create(:client_menu_item, client_menu_category: category2, name: 'Chicken and Veggies', cost: 22) }
  let!(:item4) { create(:client_menu_item, client_menu_category: category2, name: 'Carrot Soup', cost: 9) }

  let!(:selection1) { create(:client_menu_selection, client_menu_submission: submission, client_menu_item: item1)}
  let!(:selection2) { create(:client_menu_selection, client_menu_submission: submission, client_menu_item: item2)}
  let!(:selection3) { create(:client_menu_selection, client_menu_submission: submission, client_menu_item: item3)}

  let(:show_pricing) { true }

  describe '#client_submission' do
    let(:mail) { ClientMenuMailer.with(client_menu: menu).client_submission }

    it 'sets `to` as the client email' do
      expect(mail.to).to eq([client.email])
    end

    it 'sets `bbc` as lemonandbasil and the user email' do
      expect(mail.bcc).to match_array(['beth@lemonandbasil.co', user.email])
    end

    it 'sets `from` as the campaign#success_email_from' do
      expect(mail.from).to eq(['hello@lemonandbasil.co'])
    end

    it 'lists all menu selections' do
      body = Capybara.string(mail.body.encoded)

      expect(body).to have_content('Frank Zappa Meal Prep Menu')
      expect(body).to have_content('Total estimate: $22')
      expect(body).to have_content('Prep date: 3/2/2021')

      expect(body).to have_content('Breakfast')
      expect(body).to have_content('Eggs Benny $7', normalize_ws: true)
      expect(body).to have_content('French Toast $12', normalize_ws: true)

      expect(body).to have_content('Dinner')
      expect(body).to have_content('Chicken and Veggies $22', normalize_ws: true)
    end

    it 'shows the notes' do
      body = Capybara.string(mail.body.encoded)

      expect(body).to have_content('I am notes!')
    end

    context 'when show pricing is false' do
      let(:show_pricing) { false }

      it 'hides the pricing' do
        body = Capybara.string(mail.body.encoded)

        expect(body).to have_content('Frank Zappa Meal Prep Menu')
        expect(body).to_not have_content('Total estimate: $22')
        expect(body).to have_content('Prep date: 3/2/2021')

        expect(body).to_not have_content('Eggs Benny $7', normalize_ws: true)
        expect(body).to have_content('Eggs')
      end
    end

    context 'when staple selections do not exist' do
      it 'does not show staples' do
        body = Capybara.string(mail.body.encoded)

        expect(body).to_not have_content('Staples')
      end
    end

    context 'when staple selections exist' do
      let!(:staple_category) { create(:staple_category, name: 'Pantry', client_menu: menu) }
      let!(:staple1) { create(:staple, name: 'Rice', staple_category: staple_category) }
      let!(:staple2) { create(:staple, name: 'Beans', staple_category: staple_category) }
      let!(:staple_selection1) { submission.staples << staple1 }
      let!(:staple_notes) { submission.update!(staples_notes: 'I am staple notes.') }

      it 'shows the staples' do
        body = Capybara.string(mail.body.encoded)

        expect(body).to have_content('Staples')
        expect(body).to have_content('Rice')
        expect(body).to_not have_content('Beans')
        expect(body).to have_content('I am staple notes.')
      end
    end

    context 'when `is_kat` is true' do
      before do
        menu.update!(is_kat: true)
      end

      it 'includes kat in the bcc field' do
        expect(mail.bcc).to match_array([
          'beth@lemonandbasil.co',
          'kat@lemonandbasil.co',
          user.email
        ])
      end
    end
  end
end
