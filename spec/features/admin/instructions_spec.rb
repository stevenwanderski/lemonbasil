require 'spec_helper'

describe 'Admin: Instructions', js: true do
  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  describe 'Search' do
    let!(:meal) { create(:meal) }

    it 'navigates to the meal after searching' do
      visit admin_instructions_path
      fill_in 'meal search', with: 'sea'
      first('.autocomplete-suggestion').click

      expect(current_path).to eq(edit_admin_instruction_path(meal))
    end
  end
end
