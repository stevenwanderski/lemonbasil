require 'spec_helper'

describe 'Admin: Account', js: true do
  before do
    @user = create(:user, password: 'testtest', password_confirmation: 'testtest')
    login_as(@user, scope: :user)
  end

  describe 'Update password' do
    it 'updates the password' do
      visit admin_account_path
      fill_in 'password', with: 'newpassword'
      fill_in 'password_confirmation', with: 'newpassword'
      click_button 'Submit'

      expect(page).to have_content('Success!')
      expect(@user.reload.valid_password?('newpassword')).to eq(true)
    end
  end
end
