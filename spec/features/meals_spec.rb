require 'spec_helper'

describe 'Meals', js: true do
  let!(:meal) { create(:meal) }

  describe 'Search' do
    before do
      visit meals_path
    end

    it 'navigates to the meal after searching' do
      fill_in 'meal search', with: 'sea'
      first('.autocomplete-suggestion').click

      expect(current_path).to eq(meal_path(meal))
      expect(page).to have_content('seafood pasta')
      expect(page).to have_content('cook it')
    end
  end
end
