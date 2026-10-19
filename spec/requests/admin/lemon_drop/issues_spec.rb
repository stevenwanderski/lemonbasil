require 'spec_helper'

RSpec.describe 'Admin::LemonDrop::Issues', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }

  describe 'as a signed-in non-Admin' do
    let(:issue) { create(:lemon_drop_issue) }

    before { login_as(create(:user, email: 'staff@test.com', role: 'staff'), scope: :user) }

    {
      'list Issues' => -> { get admin_lemon_drop_issues_path },
      'start a new Issue' => -> { get new_admin_lemon_drop_issue_path },
      'create an Issue' => -> { post admin_lemon_drop_issues_path, params: { lemon_drop_issue: { title: 'x' } } },
      'edit an Issue' => -> { get edit_admin_lemon_drop_issue_path(issue) },
      'update an Issue' => -> { patch admin_lemon_drop_issue_path(issue), params: { lemon_drop_issue: { title: 'x' } } },
      'delete an Issue' => -> { delete admin_lemon_drop_issue_path(issue) },
      'preview an Issue' => -> { get admin_lemon_drop_issue_preview_path(issue) },
      'publish an Issue' => -> { post admin_lemon_drop_issue_publication_path(issue) }
    }.each do |action, request|
      it "is sent to the clients page instead of being able to #{action}" do
        instance_exec(&request)

        expect(response).to redirect_to(admin_clients_path)
        expect(issue.reload).to have_attributes(title: 'oct 19–23', status: 'draft')
        expect(LemonDrop::Issue.count).to eq(1)
      end
    end

    it 'is sent to the clients page instead of being able to unpublish an Issue' do
      published = create(:lemon_drop_issue, :published)

      delete admin_lemon_drop_issue_publication_path(published)

      expect(response).to redirect_to(admin_clients_path)
      expect(published.reload.status).to eq('published')
    end

    it 'has no Lemon Drop link in the sidebar' do
      get admin_clients_path

      expect(response.body).not_to include('Lemon Drop')
    end
  end

  it 'sends a signed-out visitor to sign in instead of showing a preview' do
    issue = create(:lemon_drop_issue)

    get admin_lemon_drop_issue_preview_path(issue)

    expect(response).to redirect_to(new_user_session_path)
  end

  describe 'as an Admin' do
    before { login_as(admin, scope: :user) }

    it 'has a Lemon Drop link in the sidebar' do
      get admin_clients_path

      expect(response.body).to include(%(href="#{admin_lemon_drop_issues_path}">Lemon Drop</a>))
    end

    describe 'GET /admin/lemon_drop/issues' do
      it "lists every Issue, whoever made it, with its dates, status and first-published time" do
        create(:lemon_drop_issue, title: 'oct 19–23', starts_on: Date.new(2026, 10, 19), ends_on: Date.new(2026, 10, 23))
        create(:lemon_drop_issue, :published, title: 'oct 26–30', starts_on: Date.new(2026, 10, 26), ends_on: Date.new(2026, 10, 30),
          published_at: Time.zone.local(2026, 10, 25, 9, 30))

        get admin_lemon_drop_issues_path

        expect(response).to have_http_status(200)
        expect(response.body).to match(/oct 26–30.*oct 19–23/m)
        expect(response.body).to include('Oct 19, 2026 – Oct 23, 2026', 'Draft', 'Published', 'Oct 25, 2026 9:30 AM')
      end

      it 'filters by status' do
        create(:lemon_drop_issue, title: 'a draft one')
        create(:lemon_drop_issue, :published, title: 'a published one')

        get admin_lemon_drop_issues_path(status: 'draft')

        expect(response.body).to include('a draft one')
        expect(response.body).not_to include('a published one')
      end
    end

    describe 'POST /admin/lemon_drop/issues' do
      it 'creates a Draft with the title, slug and dates, even when asked to publish' do
        get new_admin_lemon_drop_issue_path
        expect(response).to have_http_status(200)

        post admin_lemon_drop_issues_path, params: { lemon_drop_issue: {
          title: 'oct 19–23', slug: 'fall-drop', starts_on: '2026-10-19', ends_on: '2026-10-23',
          status: 'published', published_at: '2026-10-18 09:00'
        } }

        issue = LemonDrop::Issue.last
        expect(response).to redirect_to(edit_admin_lemon_drop_issue_path(issue))
        expect(issue).to have_attributes(title: 'oct 19–23', slug: 'fall-drop', starts_on: Date.new(2026, 10, 19),
          ends_on: Date.new(2026, 10, 23), status: 'draft', published_at: nil)
      end

      it 'starts the Draft with the nine Sections of the reference layout' do
        post admin_lemon_drop_issues_path, params: { lemon_drop_issue: { title: 'oct 26–30', starts_on: '2026-10-26', ends_on: '2026-10-30' } }

        sections = LemonDrop::Issue.last.sections
        expect(sections.map { |section| [section.sectionable_type.demodulize, section.sectionable.heading] }).to eq([
          ['TitlePageSection', 'the lemon drop'], ['IntroSection', 'hello!'], ['TableOfContentsSection', 'this week’s drop'],
          ['HeroSection', "let’s\ncook"], ['MenuOverviewSection', 'your menu'], ['RecipesSection', nil],
          ['GroceryListSection', 'your grocery list'], ['AllergenSwapSection', "allergen\nswaps"], ['OutroSection', nil]
        ])
        expect(sections.map(&:position)).to eq((1..9).to_a)
        expect(sections.map(&:anchor)).to eq(%w[title-page intro table-of-contents hero menu recipes grocery swaps party])
        expect(sections.select(&:theme_sage?).map(&:anchor)).to eq(%w[grocery swaps])
        expect(sections.select(&:show_in_toc).map { |section| [section.anchor, section.toc_label] }).to eq([
          %w[menu recipes], ['grocery', 'grocery list'], ['swaps', 'allergen swaps']
        ])
        expect(sections.first.sectionable.tagline).to eq('your weekly meal plan')
      end

      it 'shows the errors when the Issue is invalid' do
        post admin_lemon_drop_issues_path, params: { lemon_drop_issue: { title: '', starts_on: '2026-10-19', ends_on: '2026-10-12' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Title can&#39;t be blank", "Ends on can&#39;t be before the start date")
        expect(LemonDrop::Issue.count).to eq(0)
      end
    end

    describe 'PATCH /admin/lemon_drop/issues/:id' do
      it "updates a Draft's title, slug and dates" do
        issue = create(:lemon_drop_issue)

        get edit_admin_lemon_drop_issue_path(issue)
        expect(response).to have_http_status(200)

        patch admin_lemon_drop_issue_path(issue), params: { lemon_drop_issue: {
          title: 'oct 26–30', slug: 'late-october', starts_on: '2026-10-26', ends_on: '2026-10-30'
        } }

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_path(issue))
        expect(issue.reload).to have_attributes(title: 'oct 26–30', slug: 'late-october',
          starts_on: Date.new(2026, 10, 26), ends_on: Date.new(2026, 10, 30))
      end

      it 'refuses to change the slug once the Issue has a first-published time, even back in Draft' do
        issue = create(:lemon_drop_issue, slug: 'fall-drop', published_at: 1.day.ago)

        get edit_admin_lemon_drop_issue_path(issue)
        expect(response.body).to match(/<input[^>]*disabled="disabled"[^>]*name="lemon_drop_issue\[slug\]"/)

        patch admin_lemon_drop_issue_path(issue), params: { lemon_drop_issue: { title: 'renamed', slug: 'new-slug' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Slug can&#39;t be changed once the Issue has been published')
        expect(issue.reload).to have_attributes(slug: 'fall-drop', title: 'oct 19–23')
      end

      it 'still updates the other settings of a once-published Issue' do
        issue = create(:lemon_drop_issue, :published, slug: 'fall-drop')

        patch admin_lemon_drop_issue_path(issue), params: { lemon_drop_issue: { title: 'renamed', slug: 'fall-drop' } }

        expect(issue.reload).to have_attributes(slug: 'fall-drop', title: 'renamed')
      end
    end

    describe 'DELETE /admin/lemon_drop/issues/:id' do
      it 'deletes a Draft along with its Sections' do
        issue = create(:lemon_drop_issue)
        create(:lemon_drop_section, issue: issue)

        get edit_admin_lemon_drop_issue_path(issue)
        expect(response.body).to include('Delete')

        delete admin_lemon_drop_issue_path(issue)

        expect(response).to redirect_to(admin_lemon_drop_issues_path)
        expect(LemonDrop::Issue.exists?(issue.id)).to be(false)
        expect(LemonDrop::Section.count).to eq(0)
      end

      it 'refuses to delete a Published Issue until it is unpublished' do
        issue = create(:lemon_drop_issue, :published)

        get edit_admin_lemon_drop_issue_path(issue)
        expect(response.body).not_to include('Delete')

        delete admin_lemon_drop_issue_path(issue)

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_path(issue))
        follow_redirect!
        expect(response.body).to include('Unpublish this Issue before deleting it')
        expect(LemonDrop::Issue.exists?(issue.id)).to be(true)
      end
    end

    describe 'GET /admin/lemon_drop/issues/:issue_id/preview' do
      it 'renders a Draft as readers will see it, which the public cannot' do
        issue = create(:lemon_drop_issue)
        create(:lemon_drop_section, issue: issue, sectionable: build(:lemon_drop_intro_section, heading: 'hello from the draft'))
        create(:lemon_drop_section, issue: issue, visible: false,
          sectionable: build(:lemon_drop_intro_section, heading: 'hidden away'))

        get edit_admin_lemon_drop_issue_path(issue)
        expect(response.body).to match(%r{<a target="_blank" href="#{admin_lemon_drop_issue_preview_path(issue)}">Preview</a>})

        get admin_lemon_drop_issue_preview_path(issue)

        expect(response).to have_http_status(200)
        expect(response.body).to include('hello from the draft', 'the lemon drop · oct 19–23')
        expect(response.body).not_to include('hidden away', 'Lemon&Basil Admin')
        expect { get lemon_drop_issue_path(issue.slug) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'renders a Published Issue too' do
        issue = create(:lemon_drop_issue, :published)

        get admin_lemon_drop_issue_preview_path(issue)

        expect(response).to have_http_status(200)
      end
    end

    describe 'publishing' do
      let(:issue) { create(:lemon_drop_issue) }

      it 'publishes a Draft and sets its first-published time' do
        travel_to Time.zone.local(2026, 10, 18, 9, 0) do
          post admin_lemon_drop_issue_publication_path(issue)
        end

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_path(issue))
        expect(issue.reload).to have_attributes(status: 'published', published_at: Time.zone.local(2026, 10, 18, 9, 0))
        get lemon_drop_issue_path(issue.slug)
        expect(response).to have_http_status(200)
      end

      it 'unpublishes back to Draft, keeping the first-published time' do
        issue.update!(status: 'published', published_at: Time.zone.local(2026, 10, 18, 9, 0))

        delete admin_lemon_drop_issue_publication_path(issue)

        expect(response).to redirect_to(edit_admin_lemon_drop_issue_path(issue))
        expect(issue.reload).to have_attributes(status: 'draft', published_at: Time.zone.local(2026, 10, 18, 9, 0))
        expect { get lemon_drop_issue_path(issue.slug) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'keeps the first-published time when published again' do
        issue.update!(status: 'draft', published_at: Time.zone.local(2026, 10, 18, 9, 0))

        travel_to Time.zone.local(2026, 10, 25, 9, 0) do
          post admin_lemon_drop_issue_publication_path(issue)
        end

        expect(issue.reload).to have_attributes(status: 'published', published_at: Time.zone.local(2026, 10, 18, 9, 0))
      end

      it 'shows Publish on a Draft and Unpublish on a Published Issue' do
        get edit_admin_lemon_drop_issue_path(issue)
        expect(response.body).to include('Publish')
        expect(response.body).not_to include('Unpublish')

        issue.update!(status: 'published', published_at: Time.current)
        get edit_admin_lemon_drop_issue_path(issue)
        expect(response.body).to include('Unpublish')
      end
    end
  end
end
