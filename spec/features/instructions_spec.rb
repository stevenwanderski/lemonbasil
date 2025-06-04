require 'spec_helper'

describe 'Instructions', js: true do
  let!(:user) { create(:user, slug: 'frank') }
  let!(:meal) { create(:meal, user: user) }

  describe 'Search' do
    before do
      visit instructions_path(slug: user.slug)
    end

    it 'navigates to the meal after searching' do
      fill_in 'meal search', with: 'sea'
      first('.autocomplete-suggestion').click

      expect(current_path).to eq(instruction_path(meal, slug: user.slug))
      expect(page).to have_content('seafood pasta')
      expect(page).to have_content('cook it')
    end
  end
end
