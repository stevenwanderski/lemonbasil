require 'spec_helper'

RSpec.describe 'Admin::LemonDrop live editor', type: :request do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:issue) { create(:lemon_drop_issue) }
  let!(:contents) do
    create(:lemon_drop_section, issue: issue, position: 1, anchor: 'contents',
      sectionable: build(:lemon_drop_table_of_contents_section, heading: 'this week’s drop'))
  end
  let!(:intro) do
    create(:lemon_drop_section, issue: issue, position: 2, anchor: 'intro', show_in_toc: true,
      sectionable: build(:lemon_drop_intro_section, heading: 'hello!', body_html: '<p>soup season</p>'))
  end

  def image_upload(name)
    Rack::Test::UploadedFile.new(Rails.root.join('lemon-drop/images', name), Marcel::MimeType.for(name: name))
  end

  def save_from_drawer(section_params)
    patch admin_lemon_drop_issue_section_path(issue, intro, drawer: 1), params: { lemon_drop_section: section_params }
  end

  describe 'as a signed-in non-Admin' do
    before { login_as(create(:user, email: 'staff@test.com', role: 'staff'), scope: :user) }

    {
      'open the live editor' => -> { get admin_lemon_drop_issue_live_editor_path(issue) },
      'open a Section in the drawer' => -> { get edit_admin_lemon_drop_issue_section_path(issue, intro, drawer: 1) },
      'save from the drawer' => -> { save_from_drawer(sectionable_attributes: { heading: 'hacked' }) }
    }.each do |action, request|
      it "is sent to the clients page instead of being able to #{action}" do
        instance_exec(&request)

        expect(response).to redirect_to(admin_clients_path)
        expect(intro.sectionable.reload.heading).to eq('hello!')
      end
    end
  end

  describe 'as an Admin' do
    before { login_as(admin, scope: :user) }

    it 'shows the Issue page in an iframe, in edit mode' do
      get admin_lemon_drop_issue_live_editor_path(issue)

      expect(response.body).to include(%(src="#{admin_lemon_drop_issue_preview_path(issue, editable: 1)}"))
      expect(response.body).to include(%(data-live-editor-form-url-value="/admin/lemon_drop/issues/#{issue.id}/sections/:id/edit?drawer=1"))
    end

    it 'marks each Section with its id only in edit mode' do
      get admin_lemon_drop_issue_preview_path(issue, editable: 1)
      expect(response.body).to include(%(<div id="intro" class="theme-cream" data-section-id="#{intro.id}">))

      get admin_lemon_drop_issue_preview_path(issue)
      expect(response.body).to include('<div id="intro" class="theme-cream">')
      expect(response.body).not_to include('data-section-id')
    end

    it 'gives the drawer just the form, which saves back to the drawer' do
      get edit_admin_lemon_drop_issue_section_path(issue, intro, drawer: 1)

      expect(response.body).not_to include('<html')
      expect(response.body).to include('data-action="submit-&gt;live-editor#save"', 'data-turbo="false"')
      expect(response.body).to include(%(action="#{admin_lemon_drop_issue_section_path(issue, intro, drawer: 1)}"))
      expect(response.body).to include('data-controller="rich-text"', 'name="lemon_drop_section[sectionable_attributes][icon]"')
    end

    it 'answers a save with the Section and the Table of Contents as the page renders them' do
      save_from_drawer(toc_label: 'say hi', sectionable_attributes: { heading: 'hi there', body_html: '<p>stew <strong>season</strong></p>' })

      expect(response).to have_http_status(200)
      expect(response.body).to include(%(<div id="intro" class="theme-cream" data-section-id="#{intro.id}">))
      expect(response.body).to include('<h2>hi there</h2>', '<strong>season</strong>')
      expect(response.body).to include(%(data-section-id="#{contents.id}"), '>say hi</a>')
      expect(response.body).not_to include('<html')
      expect(intro.sectionable.reload.heading).to eq('hi there')
    end

    it 'saves an icon uploaded through the drawer' do
      save_from_drawer(sectionable_attributes: { icon: image_upload('lemon-slice.png') })

      expect(response).to have_http_status(200)
      expect(intro.sectionable.reload.icon).to be_attached
      expect(response.body).to include('class="icon"')
    end

    it 'answers a refused save with the form and its errors, changing nothing' do
      save_from_drawer(anchor: 'contents', sectionable_attributes: { heading: 'never saved' })

      expect(response).to have_http_status(422)
      expect(response.body).to include('form-errors', 'Anchor has already been taken')
      expect(response.body).not_to include('<html')
      expect(intro.reload.anchor).to eq('intro')
      expect(intro.sectionable.reload.heading).to eq('hello!')
    end

    it 'still redirects a save from the Section editor' do
      patch admin_lemon_drop_issue_section_path(issue, intro), params: { lemon_drop_section: { theme: 'sage' } }

      expect(response).to have_http_status(302)
    end
  end
end
