require 'spec_helper'

describe 'Admin: Lemon Drop: Section editor', js: true do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:issue) { create(:lemon_drop_issue) }

  before do
    create(:lemon_drop_section, issue: issue, position: 1, sectionable: build(:lemon_drop_intro_section, heading: 'first up'))
    create(:lemon_drop_section, issue: issue, position: 2, sectionable: build(:lemon_drop_intro_section, heading: 'second up'))
    create(:lemon_drop_section, issue: issue, position: 3, sectionable: build(:lemon_drop_outro_section, heading: 'last word'))
    login_as(admin, scope: :user)
  end

  it 'drags a Section to a new position, and Preview shows the new order' do
    visit edit_admin_lemon_drop_issue_path(issue)

    handle = find('.section-list__row', text: 'last word').find('.drag-handle')
    handle.drag_to(find('.section-list__row', text: 'first up'), delay: 0.2)

    # Only the page reloaded after the drop lists the positions in the new order.
    expect(page).to have_select('position', options: ['At the top', 'After Outro: last word', 'After Intro: first up', 'After Intro: second up'])
    expect(page).to have_css('.section-list__row:first-child', text: 'last word')
    expect(issue.sections.reload.map { |section| section.sectionable.heading }).to eq(['last word', 'first up', 'second up'])

    preview = window_opened_by { click_link 'Preview' }
    within_window(preview) do
      expect(page).to have_css('h2', text: 'second up')
      expect(all('h2').map(&:text)).to eq(['last word', 'first up', 'second up'])
    end
  end
end
