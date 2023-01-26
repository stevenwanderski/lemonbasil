require 'spec_helper'

describe 'Contact', js: true do
  before do
    ActionMailer::Base.deliveries.clear
    visit contact_path
  end

  it 'redirects to success and sends the contact mailer' do
    visit contact_path

    fill_in 'contact_name', with: 'Frank Zappa'
    fill_in 'contact_email', with: 'frank@zappa.com'
    fill_in 'contact_neighborhood', with: 'Beverly'
    fill_in 'contact_message', with: 'Hello'
    click_button 'Get in touch'

    expect(page).to have_content('thanks!')
    expect(current_path).to eq(contact_success_path)
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end

  context 'blocked email' do
    it 'redirects to success and does not send the contact mailer' do
      visit contact_path

      fill_in 'contact_name', with: 'Frank Zappa'
      fill_in 'contact_email', with: 'no-replyhat@gmail.com'
      fill_in 'contact_neighborhood', with: 'Beverly'
      fill_in 'contact_message', with: 'Hello'
      click_button 'Get in touch'

      expect(page).to have_content('thanks!')
      expect(current_path).to eq(contact_success_path)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end
end
