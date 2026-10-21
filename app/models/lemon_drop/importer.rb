# Turns a week's JSON from a Claude chat (config/schemas/issue_import.v1.json)
# into a new Draft Issue. Imports never publish (ADR 0003). The Admin's
# Import page uses it now; a future API or MCP import will call it the same
# way:
#
#   importer = LemonDrop::Importer.new(json, admin: current_user)
#   importer.errors   # what's wrong, each with its JSON path
#   importer.preview  # the Sections in order, with counts
#   importer.commit!  # the new Draft, with everything in it, or nothing
class LemonDrop::Importer
  SCHEMA = Rails.root.join('config/schemas/issue_import.v1.json')
  EXAMPLE = Rails.root.join('config/schemas/issue_import.v1.example.json')
  INSTRUCTIONS = Rails.root.join('config/schemas/issue_import.v1.instructions.md')
  SHARED_FIELDS = %w[theme anchor show_in_toc toc_label].freeze

  Error = Struct.new(:path, :message)
  Preview = Struct.new(:title, :starts_on, :ends_on, :sections)
  SectionPreview = Struct.new(:label, :heading, :counts, :details)

  # Raised by commit! when the JSON is invalid or a record won't save.
  class Invalid < StandardError; end

  attr_reader :raw_json, :admin, :errors

  # What an Admin pastes into a Claude Project's instructions: the rules,
  # then the schema and an example to copy.
  def self.claude_instructions
    [
      INSTRUCTIONS.read.strip,
      "## JSON Schema\n\n```json\n#{SCHEMA.read.strip}\n```",
      "## Example\n\n```json\n#{EXAMPLE.read.strip}\n```"
    ].join("\n\n") + "\n"
  end

  def initialize(raw_json, admin:)
    @raw_json = raw_json.to_s
    @admin = admin
    @errors = validate
  end

  def valid?
    errors.empty?
  end

  def preview
    raise Invalid, 'the JSON is invalid' unless valid?

    issue = data['issue']
    Preview.new(issue['title'], issue['starts_on'], ends_on, data['sections'].map { |section| preview_section(section) })
  end

  # Creates the Draft and records the Import in one transaction: if anything
  # fails, nothing is created, and errors says where.
  def commit!
    raise Invalid, 'the JSON is invalid' unless valid?

    ActiveRecord::Base.transaction do
      @path = '/issue'
      issue = LemonDrop::Issue.create!(title: data['issue']['title'], slug: free_slug, starts_on: data['issue']['starts_on'],
        ends_on: ends_on)
      data['sections'].each.with_index do |section, index|
        @path = "/sections/#{index}"
        create_section(issue, section, index + 1)
      end
      @path = '/'
      LemonDrop::Import.create!(raw_json: raw_json, user: admin, issue: issue)
      issue
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors = [Error.new(@path, e.record.errors.full_messages.to_sentence)]
    raise Invalid, errors.first.message
  end

  private

  def data
    @data ||= JSON.parse(raw_json)
  end

  def validate
    return [Error.new('/', 'Paste the JSON or upload a .json file')] if raw_json.blank?

    found = JSONSchemer.schema(SCHEMA).validate(data).to_a
    # Anything wrong inside a Section's field also marks the whole field as
    # not allowed there; leave that out and keep the error that says why.
    found.reject! do |error|
      error['schema_pointer'].end_with?('/unevaluatedProperties') &&
        found.any? { |other| other['data_pointer'].start_with?("#{error['data_pointer']}/") }
    end
    found.map { |error| Error.new(error['data_pointer'].presence || '/', error['error']) }
  rescue JSON::ParserError => e
    [Error.new('/', "This isn't valid JSON: #{e.message.truncate(200)}")]
  end

  # The end date is optional; a one-day Issue is the safe guess, and it's
  # editable in the Issue settings.
  def ends_on
    data['issue']['ends_on'] || data['issue']['starts_on']
  end

  # The start date ("2026-10-19"), with a number added when another Issue
  # already uses it, so importing the same week twice still works.
  def free_slug
    base = data['issue']['starts_on']
    LemonDrop.unique_page_id(base, LemonDrop::Issue.where('slug LIKE ?', "#{base}%").pluck(:slug))
  end

  def section_class(type)
    "LemonDrop::#{type.camelize}Section".constantize
  end

  def create_section(issue, fields, position)
    shared = fields.slice(*SHARED_FIELDS)
    sectionable = build_sectionable(fields['type'], fields.except('type', *SHARED_FIELDS))
    section = issue.sections.create!(sectionable: sectionable, position: position, **shared.compact.symbolize_keys)
    fields['recipes'].to_a.each.with_index do |recipe, index|
      @path = "/sections/#{position - 1}/recipes/#{index}"
      create_recipe(section.sectionable, recipe, index + 1)
    end
  end

  # The type's own record with its groups, swaps and swap recipes, unsaved.
  # Missing or null fields keep the model's defaults; image hints are only for
  # the Admin, since images are added after import.
  def build_sectionable(type, fields)
    sectionable = section_class(type).new
    fields = fields.except('image_hint', 'image_hints', 'recipes')

    sectionable.heading = fields.delete('heading_lines').join("\n") if fields.key?('heading_lines')
    sectionable.body_html = markdown_html(fields.delete('body_markdown')) if fields.key?('body_markdown')
    fields.delete('groups').to_a.each.with_index(1) do |group, position|
      grocery_group = sectionable.grocery_groups.build(name: group['name'], position: position)
      group['items'].each.with_index(1) { |text, item_position| grocery_group.grocery_items.build(text: text, position: item_position) }
    end
    fields.delete('swap_groups').to_a.each.with_index(1) do |group, position|
      swap_group = sectionable.swap_groups.build(name: group['name'], position: position)
      group['swaps'].each.with_index(1) do |swap, swap_position|
        swap_group.swaps.build(from_text: swap['from'], to_text: swap['to'], position: swap_position)
      end
    end
    fields.delete('swap_recipes').to_a.each.with_index(1) do |recipe, position|
      sectionable.swap_recipes.build(position: position, **recipe.except('ingredients', 'steps').compact.symbolize_keys,
        ingredients: recipe['ingredients'].to_a.join("\n"), steps: recipe['steps'].to_a.join("\n"))
    end

    sectionable.assign_attributes(fields.compact)
    sectionable
  end

  def create_recipe(recipes_section, fields, position)
    recipe = recipes_section.recipes.build(position: position,
      **fields.except('ingredient_groups', 'steps', 'image_hint').compact.symbolize_keys)
    fields['ingredient_groups'].each.with_index(1) do |group, group_position|
      ingredient_group = recipe.ingredient_groups.build(name: group['name'], position: group_position)
      group['items'].each.with_index(1) { |text, item_position| ingredient_group.ingredients.build(text: text, position: item_position) }
    end
    fields['steps'].each.with_index(1) { |body, step_position| recipe.steps.build(body: body, position: step_position) }
    recipe.save!
  end

  # Converted with kramdown, then cut down to what the editor allows.
  def markdown_html(markdown)
    return if markdown.blank?

    LemonDrop::RichText.sanitize(Kramdown::Document.new(markdown).to_html.strip)
  end

  def preview_section(section)
    heading = section['heading_lines']&.join(' ') || section['heading'].to_s.squish
    counts, details =
      case section['type']
      when 'recipes'
        recipes = section['recipes'].to_a
        [count(recipes, 'recipe'), recipes.map { |recipe| "#{recipe['title']} (#{recipe['category']})" }]
      when 'grocery_list'
        groups = section['groups'].to_a
        ["#{count(groups, 'group')}, #{count(groups.flat_map { |group| group['items'] }, 'item')}",
         groups.map { |group| "#{group['name'].presence || 'Unnamed group'}: #{count(group['items'], 'item')}" }]
      when 'allergen_swap'
        groups = section['swap_groups'].to_a
        swap_recipes = section['swap_recipes'].to_a
        ["#{count(groups.flat_map { |group| group['swaps'] }, 'swap')}, #{count(swap_recipes, 'swap recipe')}",
         groups.map { |group| "#{group['name'].presence || 'Unnamed group'}: #{count(group['swaps'], 'swap')}" } +
           swap_recipes.map { |recipe| "Swap recipe: #{recipe['title']}" }]
      when 'intro', 'outro'
        [nil, section['body_markdown'].to_s.split(/\n{2,}/).map(&:squish).reject(&:blank?)]
      end
    SectionPreview.new(section_class(section['type']).model_name.human, heading, counts, details.to_a)
  end

  def count(things, noun)
    "#{things.size} #{noun.pluralize(things.size)}"
  end
end
