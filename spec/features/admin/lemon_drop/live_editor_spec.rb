require 'spec_helper'

describe 'Admin: Lemon Drop: live editor', js: true do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:issue) { create(:lemon_drop_issue) }
  let!(:intro) do
    create(:lemon_drop_section, issue: issue, position: 1, anchor: 'intro',
      sectionable: build(:lemon_drop_intro_section, heading: 'hello!', body_html: '<p>soup season</p>'))
  end
  let!(:outro) do
    create(:lemon_drop_section, issue: issue, position: 2, anchor: 'party',
      sectionable: build(:lemon_drop_outro_section, heading: 'see you soon'))
  end

  before { login_as(admin, scope: :user) }

  def page_frame
    find('.live-editor__page')
  end

  it 'clicks the Intro, edits it in the drawer, and the page shows it without reloading' do
    visit edit_admin_lemon_drop_issue_path(issue)
    click_link 'Live editor'

    within_frame(page_frame) { find("[data-section-id='#{intro.id}']", text: 'hello!').click }
    # Markers that a reload of either page would wipe out.
    execute_script("window.stillHere = true; document.querySelector('.live-editor__page').contentWindow.stillHere = true")

    within('.live-editor__drawer') do
      expect(page).to have_css('h2', text: 'Intro')
      fill_in 'Heading', with: 'hi there'
      editor = find('.rich-text__editor [contenteditable="true"]')
      editor.click
      editor.send_keys(:end, ', stew time')
      click_button 'Save'
    end

    expect(page).to have_no_css('.live-editor__drawer form')
    within_frame(page_frame) do
      expect(page).to have_css('.intro h2', text: 'hi there')
      expect(page).to have_css('.intro .body p', text: 'soup season, stew time')
      expect(page).to have_css('.outro', text: 'see you soon')
    end
    expect(evaluate_script("window.stillHere && document.querySelector('.live-editor__page').contentWindow.stillHere")).to be(true)
    expect(intro.sectionable.reload).to have_attributes(heading: 'hi there', body_html: '<p>soup season, stew time</p>')
  end

  it 'shows a refused save in the drawer and leaves the page alone' do
    visit admin_lemon_drop_issue_live_editor_path(issue)

    within_frame(page_frame) { find("[data-section-id='#{intro.id}']").click }
    within('.live-editor__drawer') do
      fill_in 'Heading', with: 'never saved'
      fill_in 'Anchor', with: 'party'
      click_button 'Save'
      expect(page).to have_content('Anchor has already been taken')
    end

    within_frame(page_frame) { expect(page).to have_css('.intro h2', text: 'hello!') }
  end
end
