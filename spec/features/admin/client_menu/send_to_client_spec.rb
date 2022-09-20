require 'spec_helper'

describe 'Admin: Client Menu: Send to Client', js: true do
  let(:client) { create(:client, first_name: 'Frank', last_name: 'Zappa', email: 'frank@zappa.com') }
  let!(:menu) { create(:client_menu, job_date: '2021-02-09', client: client) }

  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  describe 'Accept the confirm' do
    it 'sends a mailer to the client' do
      visit admin_client_menu_path(menu)

      find('.hamburger-nav__control').click

      accept_confirm do
        click_link 'Send to Client'
      end

      expect(page).to have_content('Client Menu was sent!')
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq(['frank@zappa.com'])
    end
  end

  describe 'Dismiss the confirm' do
    it 'does not send a mailer to the client' do
      visit admin_client_menu_path(menu)

      find('.hamburger-nav__control').click

      dismiss_confirm do
        click_link 'Send to Client'
      end

      expect(page).to_not have_content('Client Menu was sent!')
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end
end
