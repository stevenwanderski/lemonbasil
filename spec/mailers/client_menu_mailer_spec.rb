require 'spec_helper'

describe ClientMenuMailer do
  let!(:client) { create(:client) }
  let!(:menu) { create(:client_menu, client: client, job_date: '2021-03-02') }
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

  describe '#client_submission' do
    let(:mail) { ClientMenuMailer.with(client_menu: menu).client_submission }

    it 'sets `to` as the client email' do
      expect(mail.to).to eq([client.email])
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
      expect(body).to have_content('Eggs Benny $7')
      expect(body).to have_content('French Toast $12')

      expect(body).to have_content('Dinner')
      expect(body).to have_content('Chicken and Veggies $22')
    end

    it 'shows the notes' do
      body = Capybara.string(mail.body.encoded)

      expect(body).to have_content('I am notes!')
    end
  end
end
