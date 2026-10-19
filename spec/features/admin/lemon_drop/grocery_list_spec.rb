require 'spec_helper'

describe 'Admin: Lemon Drop: Grocery List form', js: true do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:issue) { create(:lemon_drop_issue) }
  let!(:section) { create(:lemon_drop_section, issue: issue, position: 1, sectionable: build(:lemon_drop_grocery_list_section)) }

  before do
    create(:lemon_drop_grocery_group, grocery_list_section: section.sectionable, name: 'Pantry', position: 1,
      grocery_items: [build(:lemon_drop_grocery_item, text: 'tahini')])
    login_as(admin, scope: :user)
  end

  it 'adds a group, drags it to the top, saves, and the page lists it first' do
    visit edit_admin_lemon_drop_issue_section_path(issue, section)

    click_button '+ Add group'
    new_group = all('.nested-row').last
    new_group.fill_in 'Group name', with: 'Produce'
    new_group.fill_in 'Items', with: "2 lemons\n1 bunch basil"
    new_group.find('.drag-handle').drag_to(first('.nested-row'), delay: 0.2)
    expect(first('.nested-row')).to have_field('Group name', with: 'Produce')

    click_button 'Save'
    expect(page).to have_content('Section updated!')

    preview = window_opened_by { click_link 'Preview' }
    within_window(preview) do
      # The page sets group names in capitals.
      expect(page).to have_css('.grocery-grid h3', text: /pantry/i)
      expect(all('.grocery-grid h3').map { |heading| heading.text.downcase }).to eq(%w[produce pantry])
      expect(all('.grocery-grid li').map(&:text)).to eq(['2 lemons', '1 bunch basil', 'tahini'])
    end
  end
end
