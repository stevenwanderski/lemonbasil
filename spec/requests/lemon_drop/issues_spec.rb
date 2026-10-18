require 'spec_helper'

RSpec.describe 'LemonDrop::Issues', type: :request do
  let(:issue) { create(:lemon_drop_issue, :published, starts_on: Date.new(2026, 10, 19), ends_on: Date.new(2026, 10, 23)) }

  def add_title_page(heading, **section_attributes)
    create(:lemon_drop_section,
      issue: issue,
      sectionable: build(:lemon_drop_title_page_section, heading: heading),
      **section_attributes)
  end

  describe 'GET /drops/:slug' do
    it 'renders a Published Issue at its slug' do
      add_title_page('the lemon drop')

      get lemon_drop_issue_path(issue.slug)

      expect(response).to have_http_status(200)
      expect(issue.slug).to eq('2026-10-19')
      expect(response.body).to include('the lemon drop')
      expect(response.body).to include('your weekly meal plan')
    end

    it 'renders Sections in position order' do
      add_title_page('second', position: 2)
      add_title_page('first', position: 1)
      add_title_page('third', position: 3)

      get lemon_drop_issue_path(issue.slug)

      expect(response.body).to match(/first.*second.*third/m)
    end

    it 'follows changes to position' do
      first = add_title_page('first', position: 1)
      add_title_page('second', position: 2)
      first.update!(position: 3)

      get lemon_drop_issue_path(issue.slug)

      expect(response.body).to match(/second.*first/m)
    end

    it 'leaves out Hidden sections' do
      add_title_page('shown')
      add_title_page('hidden away', visible: false)

      get lemon_drop_issue_path(issue.slug)

      expect(response.body).to include('shown')
      expect(response.body).not_to include('hidden away')
    end

    it 'gives several Title Pages unique anchors' do
      3.times { |n| add_title_page("cover #{n}") }

      get lemon_drop_issue_path(issue.slug)

      expect(response.body).to include('id="title-page"', 'id="title-page-2"', 'id="title-page-3"')
    end

    it "wraps each Section in its theme" do
      add_title_page('cream one')
      add_title_page('sage one', theme: 'sage')

      get lemon_drop_issue_path(issue.slug)

      expect(response.body).to include('class="theme-cream"', 'class="theme-sage"')
    end

    it "uses the Issue dates when a Title Page has no date label" do
      add_title_page('the lemon drop')

      get lemon_drop_issue_path(issue.slug)

      expect(response.body).to include('<span>oct 19–23</span>', 'the lemon drop · oct 19–23')
    end

    it "shows the first visible Title Page's date label in the footer" do
      create(:lemon_drop_section, issue: issue, visible: false,
        sectionable: build(:lemon_drop_title_page_section, date_label: 'hidden week'))
      create(:lemon_drop_section, issue: issue,
        sectionable: build(:lemon_drop_title_page_section, date_label: 'harvest week'))

      get lemon_drop_issue_path(issue.slug)

      expect(response.body).to include('the lemon drop · harvest week')
    end

    it 'links home to Lemon & Basil' do
      get lemon_drop_issue_path(issue.slug)

      expect(response.body).to include("href=\"#{root_path}\"")
    end

    it 'renders the cover image' do
      create(:lemon_drop_section, issue: issue,
        sectionable: build(:lemon_drop_title_page_section, cover_image: uploaded_image('chickpea-stew.jpg')))

      get lemon_drop_issue_path(issue.slug)

      expect(response.body).to match(%r{<img[^>]+src="[^"]*/rails/active_storage/representations/[^"]*chickpea-stew\.jpg"})
    end

    it 'returns 404 for a Draft Issue' do
      draft = create(:lemon_drop_issue)

      expect { get lemon_drop_issue_path(draft.slug) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 404 for an unknown slug' do
      expect { get lemon_drop_issue_path('nope') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
