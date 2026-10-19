require 'spec_helper'

describe 'Admin: Lemon Drop: rich text', js: true do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:issue) { create(:lemon_drop_issue) }
  let!(:section) do
    create(:lemon_drop_section, issue: issue, position: 1, sectionable: build(:lemon_drop_intro_section, body_html: nil))
  end

  before do
    login_as(admin, scope: :user)
  end

  it 'types a letter, makes a word bold, saves, and Preview shows it bold' do
    visit edit_admin_lemon_drop_issue_section_path(issue, section)

    editor = find('.rich-text__editor [contenteditable="true"]')
    editor.click
    editor.send_keys('soup season is ')
    click_button 'Bold'
    editor.send_keys('here')
    expect(page).to have_css('.rich-text__button.is-active', text: 'B')

    click_button 'Save'
    expect(page).to have_content('Section updated!')

    preview = window_opened_by { click_link 'Preview' }
    within_window(preview) do
      expect(page).to have_css('.intro .body p', text: 'soup season is here')
      expect(page).to have_css('.intro .body p strong', exact_text: 'here')
    end
  end
end
