require 'spec_helper'

describe 'Admin: Lemon Drop: Import', js: true do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:json) do
    {
      schema_version: 1,
      issue: { title: 'oct 26–30', starts_on: '2026-10-26', ends_on: '2026-10-30' },
      sections: [
        { type: 'intro', heading: 'hello!', body_markdown: 'it’s **soup** season' },
        { type: 'recipes', recipes: [
          { title: 'chickpea stew', category: 'soup', ingredient_groups: [{ name: 'Pantry', items: ['chickpeas'] }],
            steps: ['Simmer.'] }
        ] }
      ]
    }.to_json
  end

  before { login_as(admin, scope: :user) }

  it 'pastes JSON, previews it, confirms, and lands on the new Draft’s editor' do
    visit admin_lemon_drop_issues_path
    click_link 'Import'

    fill_in 'JSON', with: json
    click_button 'Preview'

    expect(page).to have_content('Preview: oct 26–30')
    expect(page).to have_content('Recipes: 1 recipe')
    find('summary', text: 'Recipes: 1 recipe').click
    expect(page).to have_content('chickpea stew (soup)')

    click_button 'Create Draft Issue'

    expect(page).to have_content('Draft Issue imported!')
    issue = LemonDrop::Issue.find_by!(title: 'oct 26–30')
    expect(page).to have_current_path(edit_admin_lemon_drop_issue_path(issue))
    expect(issue).to be_draft
    expect(all('.section-list__row strong').map(&:text)).to eq(%w[Intro Recipes])
  end
end
