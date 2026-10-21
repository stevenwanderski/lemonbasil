require 'spec_helper'

RSpec.describe LemonDrop::Importer do
  let(:admin) { create(:user, email: 'admin@test.com', role: 'admin') }
  let(:reference_json) { file_fixture('lemon_drop/reference_issue.json').read }

  def import(data)
    described_class.new(data.is_a?(String) ? data : data.to_json, admin: admin)
  end

  def week(*sections)
    { schema_version: 1, issue: { title: 'oct 26–30', starts_on: '2026-10-26', ends_on: '2026-10-30' }, sections: sections }
  end

  def recipe(title, **fields)
    { title: title, category: 'entree', ingredient_groups: [{ name: 'Pantry', items: ['s&p'] }], steps: ['Cook it.'], **fields }
  end

  # Everything the page is built from, in page order, without ids, images or
  # the Issue they belong to.
  def contents(issue)
    issue.sections.includes(:sectionable).map do |section|
      sectionable = section.sectionable
      fields = sectionable.attributes.except('id', 'created_at', 'updated_at', 'body_html')
      children =
        case sectionable
        when LemonDrop::RecipesSection
          sectionable.recipes.map do |recipe|
            [recipe.attributes.except('id', 'created_at', 'updated_at', 'recipes_section_id'),
             recipe.ingredient_groups.map { |group| [group.name, group.ingredients.map(&:text)] },
             recipe.steps.map(&:body)]
          end
        when LemonDrop::GroceryListSection
          sectionable.grocery_groups.map { |group| [group.name, group.grocery_items.map(&:text)] }
        when LemonDrop::AllergenSwapSection
          [sectionable.swap_groups.map { |group| [group.name, group.swaps.map { |swap| [swap.from_text, swap.to_text] }] },
           sectionable.swap_recipes.map { |swap_recipe| swap_recipe.attributes.slice('title', 'yield_label', 'ingredients', 'steps', 'use_for') }]
        end
      paragraphs = Nokogiri::HTML.fragment(sectionable.try(:body_html).to_s).css('p').map(&:text)
      [sectionable.class.name, section.slice(:position, :anchor, :theme, :show_in_toc, :toc_label), fields, paragraphs, children]
    end
  end

  it 'makes a Draft of the reference JSON matching the Lemon Drop 7 seed, Section by Section and Recipe by Recipe' do
    load Rails.root.join('db/seeds/lemon_drop.rb')
    seed = LemonDrop::Issue.find_by!(slug: '2026-10-19')

    issue = import(reference_json).commit!

    expect(issue).to have_attributes(title: 'oct 19–23', starts_on: Date.new(2026, 10, 19), ends_on: Date.new(2026, 10, 23),
      status: 'draft', published_at: nil)
    expect(issue.slug).to eq('2026-10-19-2')
    expect(contents(issue)).to eq(contents(seed))
    expect(issue.recipes.map(&:title)).to eq(seed.recipes.map(&:title))
  end

  it 'never publishes, and records the Import with its JSON, Admin and Issue' do
    issue = nil

    expect { issue = import(reference_json).commit! }.to change(LemonDrop::Import, :count).by(1)

    expect(issue.reload).to be_draft
    expect(issue.published_at).to be_nil
    expect(LemonDrop::Import.last).to have_attributes(raw_json: reference_json, user: admin, issue: issue)
    expect(LemonDrop::Import.last.created_at).to be_present
  end

  it 'previews the Sections in order with counts' do
    preview = import(reference_json).preview

    expect(preview).to have_attributes(title: 'oct 19–23', starts_on: '2026-10-19', ends_on: '2026-10-23')
    expect(preview.sections.map(&:label)).to eq([
      'Title Page', 'Intro', 'Table of Contents', 'Hero', 'Menu Overview', 'Recipes', 'Grocery List', 'Allergen Swap', 'Outro'
    ])
    recipes, grocery, swaps = preview.sections.values_at(5, 6, 7)
    expect(recipes.counts).to eq('8 recipes')
    expect(recipes.details.first).to eq('chickpea stew (soup)')
    expect(grocery.counts).to eq('4 groups, 59 items')
    expect(grocery.details).to eq(['Produce: 20 items', 'Pantry: 29 items', 'Dairy/Eggs: 6 items', 'Meat & Seafood: 4 items'])
    expect(swaps.counts).to eq('9 swaps, 4 swap recipes')
    expect(preview.sections[3].heading).to eq('let’s cook')
  end

  it 'imports any number of Sections of any type, in the order given' do
    sections = Array.new(10) { |index| { type: 'recipes', recipes: [recipe("dish #{index + 1}")] } }
    issue = import(week({ type: 'outro', heading: 'bye' }, *sections, { type: 'grocery_list' })).commit!

    expect(issue.sections.map(&:sectionable_type)).to eq(
      ['LemonDrop::OutroSection', *Array.new(10, 'LemonDrop::RecipesSection'), 'LemonDrop::GroceryListSection']
    )
    expect(issue.sections.map(&:position)).to eq((1..12).to_a)
    expect(issue.sections.map(&:anchor)).to include('recipes', 'recipes-2', 'recipes-10')
    expect(issue.recipes.map(&:title)).to eq((1..10).map { |number| "dish #{number}" })
  end

  it 'gives every Recipe a slug of its own across the Issue' do
    issue = import(week({ type: 'recipes', recipes: [recipe('stew')] }, { type: 'recipes', recipes: [recipe('stew')] })).commit!

    expect(issue.recipes.map(&:slug)).to eq(%w[stew stew-2])
  end

  it 'imports an empty week' do
    expect(import(week).commit!.sections).to be_empty
  end

  it 'converts body Markdown to HTML and keeps only what the editor allows' do
    markdown = "hi **there** and _you_, [book](https://example.com)\n\n- one\n- two\n\n" \
               "# big\n\n<script>alert(1)</script><img src=x onerror=alert(1)>\n\n[bad](javascript:alert(1))"
    issue = import(week({ type: 'intro', body_markdown: markdown }, { type: 'outro', body_markdown: 'see *you*' })).commit!

    intro, outro = issue.sections.map(&:sectionable)
    expect(intro.body_html).to include('<p>hi <strong>there</strong> and <em>you</em>, <a href="https://example.com">book</a></p>')
    expect(intro.body_html).to include('<ul>', '<li>one</li>', 'big')
    expect(intro.body_html).to include('<a>bad</a>')
    expect(intro.body_html).not_to include('<h1', '<script', '<img', 'javascript', 'id=')
    expect(outro.body_html).to eq('<p>see <em>you</em></p>')
  end

  it 'keeps the model defaults for fields that are missing or null' do
    issue = import(week({ type: 'allergen_swap', disclaimer: nil, theme: nil }, { type: 'hero', text_color: nil })).commit!

    swaps, hero = issue.sections.map(&:sectionable)
    expect(swaps.disclaimer).to eq(LemonDrop::AllergenSwapSection::DEFAULT_DISCLAIMER)
    expect(issue.sections.first.theme).to eq('cream')
    expect(hero.text_color).to eq('light')
  end

  describe 'invalid input' do
    it 'reports each error with its JSON path' do
      importer = import(week(
        { type: 'recipes', recipes: [{ title: 'stew', category: 'stews', ingredient_groups: [], steps: [] }] },
        { heading: 'no type' }
      ).deep_merge(issue: { starts_on: 'monday' }))

      expect(importer).not_to be_valid
      expect(importer.errors.map(&:path)).to contain_exactly('/issue/starts_on', '/sections/0/recipes/0/category', '/sections/1')
      expect(importer.errors.find { |error| error.path == '/sections/1' }.message).to include('missing required properties: type')
    end

    it 'requires the Issue title, start date, Sections, schema version and each Recipe’s main fields' do
      importer = import({ issue: {}, sections: [{ type: 'recipes', recipes: [{}] }] })

      messages = importer.errors.map { |error| "#{error.path} #{error.message}" }
      expect(messages.join("\n")).to include('schema_version', 'title, starts_on', 'title, category, ingredient_groups, steps')
    end

    it 'rejects unknown keys, on a Section, a Recipe or the Issue' do
      importer = import(week({ type: 'intro', heading: 'hi', colour: 'red' }, { type: 'recipes', recipes: [recipe('stew', serving: 4)] })
        .deep_merge(issue: { subtitle: 'x' }))

      expect(importer.errors.map(&:path)).to contain_exactly('/issue/subtitle', '/sections/0/colour', '/sections/1/recipes/0/serving')
    end

    it 'rejects a field from another Section type' do
      expect(import(week({ type: 'hero', heading: 'let’s cook' })).errors.map(&:path)).to eq(['/sections/0/heading'])
    end

    it 'allows the shared Section fields on any Section' do
      shared = { theme: 'sage', anchor: 'here', show_in_toc: true, toc_label: 'here' }

      expect(import(week({ type: 'table_of_contents', **shared }, { type: 'outro', **shared, anchor: 'there' }))).to be_valid
    end

    it 'says when the text is not JSON at all' do
      expect(import('{ "schema_version": 1,').errors.map(&:path)).to eq(['/'])
      expect(import('').errors.first.message).to include('Paste the JSON')
    end

    it 'refuses to commit or preview' do
      importer = import(week({ type: 'nope' }))

      expect { importer.commit! }.to raise_error(described_class::Invalid)
      expect { importer.preview }.to raise_error(described_class::Invalid)
      expect(LemonDrop::Issue.count).to eq(0)
    end
  end

  it 'creates nothing when a record fails part way through, and says where' do
    importer = import(week({ type: 'intro' }, { type: 'recipes', recipes: [recipe('stew'), recipe('soup')] }))
    saves = 0
    allow_any_instance_of(LemonDrop::Recipe).to receive(:save!).and_wrap_original do |original, *args|
      raise ActiveRecord::RecordInvalid, original.receiver if (saves += 1) == 2

      original.call(*args)
    end

    expect { importer.commit! }.to raise_error(described_class::Invalid)

    expect(LemonDrop::Issue.count).to eq(0)
    expect(LemonDrop::Section.count).to eq(0)
    expect(LemonDrop::Recipe.count).to eq(0)
    expect(LemonDrop::Import.count).to eq(0)
    expect(importer.errors.map(&:path)).to eq(['/sections/1/recipes/1'])
  end

  it 'reports a clashing anchor at its Section' do
    importer = import(week({ type: 'recipes', recipes: [recipe('stew')] }, { type: 'intro', anchor: 'stew' }))

    expect { importer.commit! }.to raise_error(described_class::Invalid)
    expect(importer.errors.map(&:path)).to eq(['/sections/1'])
    expect(LemonDrop::Issue.count).to eq(0)
  end

  it 'puts the rules, the schema and the example into the Claude export instructions' do
    instructions = described_class.claude_instructions

    expect(instructions).to include('Output only one fenced `json` block', 'Never invent quantities')
    expect(instructions).to include(described_class::SCHEMA.read.strip, described_class::EXAMPLE.read.strip)
  end

  it 'accepts the example in the Claude export instructions' do
    expect(import(described_class::EXAMPLE.read)).to be_valid
  end
end
