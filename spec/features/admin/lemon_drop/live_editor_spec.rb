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

  it 'shows changes on the page as they are typed, saving nothing until Save, and Close puts the page back' do
    visit admin_lemon_drop_issue_live_editor_path(issue)

    within_frame(page_frame) { find("[data-section-id='#{intro.id}']").click }
    within('.live-editor__drawer') do
      fill_in 'Heading', with: 'typing away'
      editor = find('.rich-text__editor [contenteditable="true"]')
      editor.click
      editor.send_keys(:end, ', still typing')
    end

    within_frame(page_frame) do
      expect(page).to have_css('.intro h2', text: 'typing away')
      expect(page).to have_css('.intro .body p', text: 'soup season, still typing')
    end
    expect(intro.sectionable.reload.heading).to eq('hello!')

    within('.live-editor__drawer') { click_button '← All sections' }

    within_frame(page_frame) do
      expect(page).to have_css('.intro h2', text: 'hello!')
      expect(page).to have_no_content('still typing')
    end
    expect(intro.sectionable.reload).to have_attributes(heading: 'hello!', body_html: '<p>soup season</p>')
  end

  it 'shows a picked image on the page at once, attaching it only on Save' do
    visit admin_lemon_drop_issue_live_editor_path(issue)

    within_frame(page_frame) do
      expect(page).to have_no_css('.intro img.icon')
      find("[data-section-id='#{intro.id}']").click
    end
    within('.live-editor__drawer') do
      attach_file 'Icon', Rails.root.join('lemon-drop/images/lemon-slice.png')
      expect(page).to have_css('img.image-field__preview[src^="blob:"]', count: 1)
    end

    within_frame(page_frame) { expect(page).to have_css('.intro img.icon') }
    expect(ActiveStorage::Blob.unattached.count).to eq(1)
    expect(intro.sectionable.reload.icon).not_to be_attached

    within('.live-editor__drawer') { click_button '← All sections' }
    within_frame(page_frame) do
      expect(page).to have_no_css('.intro img.icon')
      find("[data-section-id='#{intro.id}']").click
    end
    within('.live-editor__drawer') do
      attach_file 'Icon', Rails.root.join('lemon-drop/images/lemon-slice.png')
      expect(page).to have_css('[data-uploaded-for]', visible: false)
      click_button 'Save'
    end

    expect(page).to have_no_css('.live-editor__drawer form')
    within_frame(page_frame) { expect(page).to have_css('.intro img.icon') }
    expect(intro.sectionable.reload.icon).to be_attached
    # The second pick is the one attached; the first is left for the cleanup task.
    expect(ActiveStorage::Blob.unattached.count).to eq(1)
  end

  it 'shows a refused save in the drawer, saving nothing, and Close puts the page back' do
    visit admin_lemon_drop_issue_live_editor_path(issue)

    within_frame(page_frame) { find("[data-section-id='#{intro.id}']").click }
    within('.live-editor__drawer') do
      fill_in 'Heading', with: 'never saved'
      fill_in 'Anchor', with: 'party'
      click_button 'Save'
      expect(page).to have_content('Anchor has already been taken')
    end
    expect(intro.sectionable.reload.heading).to eq('hello!')

    within('.live-editor__drawer') { click_button '← All sections' }
    within_frame(page_frame) { expect(page).to have_css('.intro h2', text: 'hello!') }
  end

  it 'keeps the page’s width while a Section is open, picked from the panel’s list' do
    page.current_window.resize_to(1400, 900)
    visit admin_lemon_drop_issue_live_editor_path(issue)
    expect(page).to have_no_css('.sidebar')
    width = evaluate_script("document.querySelector('.live-editor__page').clientWidth")

    within('.live-editor__outline') { click_button 'Intro' }

    within('.live-editor__drawer') { expect(page).to have_field('Heading', with: 'hello!') }
    expect(page).to have_no_css('.live-editor__outline')
    expect(evaluate_script("document.querySelector('.live-editor__page').clientWidth")).to eq(width)
    within_frame(page_frame) { expect(page).to have_css("[data-section-id='#{intro.id}'][data-selected]") }

    within('.live-editor__drawer') do
      fill_in 'Heading', with: 'hi there'
      click_button 'Save'
    end

    within('.live-editor__outline') { expect(page).to have_button('Intro hi there') }
    within_frame(page_frame) { expect(page).to have_no_css('[data-selected]') }
  end

  it 'shows the page at a phone’s width' do
    visit admin_lemon_drop_issue_live_editor_path(issue)

    click_button 'Phone'

    expect(page).to have_css('.live-editor__canvas.is-phone')
    expect(evaluate_script("document.querySelector('.live-editor__page').clientWidth")).to eq(386)
    expect(page).to have_css('button[aria-pressed="true"]', text: 'Phone')
  end

  describe 'Recipes' do
    let!(:recipes) do
      create(:lemon_drop_section, issue: issue, position: 3, anchor: 'recipes', sectionable: build(:lemon_drop_recipes_section))
    end
    let!(:recipe) { create(:lemon_drop_recipe, recipes_section: recipes.sectionable, title: 'chickpea stew') }

    it 'clicks a Recipe on the page, previews it while typing, and saves it' do
      visit admin_lemon_drop_issue_live_editor_path(issue)

      within_frame(page_frame) { find("[data-recipe-id='#{recipe.id}']").click }
      within('.live-editor__drawer') do
        expect(page).to have_css('h2', text: 'Recipe: chickpea stew')
        fill_in 'Title', with: 'white bean stew'
      end

      within_frame(page_frame) do
        expect(page).to have_css("[data-recipe-id='#{recipe.id}'][data-selected] h2", text: 'white bean stew')
      end
      expect(recipe.reload.title).to eq('chickpea stew')

      within('.live-editor__drawer') { click_button 'Save' }

      expect(page).to have_no_css('.live-editor__drawer form')
      within_frame(page_frame) { expect(page).to have_css("[data-recipe-id='#{recipe.id}'] h2", text: 'white bean stew') }
      expect(recipe.reload.title).to eq('white bean stew')
    end

    it 'opens a Recipe from its Section’s list, and adds one, in the drawer' do
      visit admin_lemon_drop_issue_live_editor_path(issue)

      within('.live-editor__outline') { click_button 'Recipes' }
      within('.live-editor__drawer') { click_link 'chickpea stew' }
      within('.live-editor__drawer') { expect(page).to have_css('h2', text: 'Recipe: chickpea stew') }
      expect(page).to have_current_path(admin_lemon_drop_issue_live_editor_path(issue))

      within('.live-editor__drawer') { click_button '← All sections' }
      within('.live-editor__outline') { click_button 'Recipes' }
      within('.live-editor__drawer') do
        click_link '+ Add recipe'
        expect(page).to have_css('h2', text: 'New Recipe')
        fill_in 'Title', with: 'harissa chicken'
        select 'Entree', from: 'Category'
        click_button 'Save'
      end

      expect(page).to have_no_css('.live-editor__drawer form')
      within_frame(page_frame) { expect(page).to have_css('[data-recipe-id] h2', text: 'harissa chicken') }
      expect(recipes.sectionable.recipes.pluck(:title)).to eq(['chickpea stew', 'harissa chicken'])
    end
  end
end
