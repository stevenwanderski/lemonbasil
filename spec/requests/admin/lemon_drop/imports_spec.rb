require 'spec_helper'

RSpec.describe 'Admin::LemonDrop::Imports', type: :request do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:reference_json) { file_fixture('lemon_drop/reference_issue.json').read }

  describe 'as a signed-in non-Admin' do
    before { login_as(create(:user, email: 'staff@test.com', role: 'staff'), scope: :user) }

    {
      'open the Import page' => -> { get new_admin_lemon_drop_import_path },
      'preview an Import' => -> { post preview_admin_lemon_drop_imports_path, params: { raw_json: reference_json } },
      'import an Issue' => -> { post admin_lemon_drop_imports_path, params: { raw_json: reference_json } }
    }.each do |action, request|
      it "is sent to the clients page instead of being able to #{action}" do
        instance_exec(&request)

        expect(response).to redirect_to(admin_clients_path)
        expect(LemonDrop::Issue.count).to eq(0)
        expect(LemonDrop::Import.count).to eq(0)
      end
    end
  end

  describe 'as an Admin' do
    before { login_as(admin, scope: :user) }

    it 'shows the paste box, the upload field and the Claude export instructions' do
      get new_admin_lemon_drop_import_path

      expect(response.body).to include('name="raw_json"', 'name="file"', 'Claude export instructions')
      expect(response.body).to include(CGI.escapeHTML('Output only one fenced `json` block'), '&quot;schema_version&quot;')
    end

    it 'previews pasted JSON without creating anything' do
      post preview_admin_lemon_drop_imports_path, params: { raw_json: reference_json }

      expect(response).to have_http_status(200)
      expect(response.body).to include('Preview: oct 19–23', 'Recipes: 8 recipes', 'Grocery List: 4 groups, 59 items')
      expect(response.body).to include('chickpea stew (soup)')
      expect(LemonDrop::Issue.count).to eq(0)
    end

    it 'previews an uploaded .json file' do
      file = Rack::Test::UploadedFile.new(file_fixture('lemon_drop/reference_issue.json'), 'application/json')

      post preview_admin_lemon_drop_imports_path, params: { file: file }

      expect(response.body).to include('Preview: oct 19–23')
    end

    it 'shows each error with its JSON path and keeps what was pasted' do
      bad = { schema_version: 1, issue: { title: 'x', starts_on: '2026-10-26' }, sections: [{ type: 'intro', colour: 'red' }] }.to_json

      post preview_admin_lemon_drop_imports_path, params: { raw_json: bad }

      expect(response).to have_http_status(422)
      expect(response.body).to include('<code>/sections/0/colour</code>')
      expect(response.body).to include(CGI.escapeHTML(bad))
    end

    it 'creates a Draft Issue and lands on its editor' do
      post admin_lemon_drop_imports_path, params: { raw_json: reference_json }

      issue = LemonDrop::Issue.last
      expect(response).to redirect_to(edit_admin_lemon_drop_issue_path(issue))
      expect(issue).to be_draft
      expect(issue.sections.count).to eq(9)
      expect(LemonDrop::Import.last).to have_attributes(user: admin, issue: issue, raw_json: reference_json)
    end

    it 'shows the errors and creates nothing when the import fails' do
      clash = { schema_version: 1, issue: { title: 'x', starts_on: '2026-10-26' }, sections: [
        { type: 'intro', anchor: 'same' }, { type: 'outro', anchor: 'same' }
      ] }.to_json

      post admin_lemon_drop_imports_path, params: { raw_json: clash }

      expect(response).to have_http_status(422)
      expect(response.body).to include('<code>/sections/1</code>', 'Anchor has already been taken')
      expect(LemonDrop::Issue.count).to eq(0)
    end
  end
end
