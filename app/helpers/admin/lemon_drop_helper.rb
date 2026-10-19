module Admin::LemonDropHelper
  # "Title Page: the lemon drop", or just "Recipes" when there's no heading.
  def section_summary(section)
    [section.sectionable.model_name.human, section.sectionable.heading.to_s.squish.presence].compact.join(': ')
  end

  # A Recipes Section takes its Recipes with it.
  def section_delete_confirm(section)
    name = "this #{section.sectionable.model_name.human} Section"
    recipe_count = section.lemon_drop_recipes_section? ? section.sectionable.recipes.size : 0
    recipe_count.positive? ? "Delete #{name} and its #{pluralize(recipe_count, 'Recipe')}?" : "Delete #{name}?"
  end

  # The Issue's other Recipes Sections, where section's Recipes can be moved.
  # Empty for any other Section type.
  def recipe_move_targets(section)
    return [] unless section.lemon_drop_recipes_section?

    section.issue.sections.lemon_drop_recipes_sections.excluding(section).includes(:sectionable).to_a
  end

  # "Recipes: weeknight dinners (#recipes-2)": the anchor tells apart Recipes
  # Sections with no heading.
  def recipes_section_label(section)
    "#{section_summary(section)} (##{section.anchor})"
  end

  # Where a new Section can go: the top, or after any of the sections.
  def section_positions_for(sections)
    [['At the top', 1]] + sections.map.with_index(2) { |section, position| ["After #{section_summary(section)}", position] }
  end

  # The Section's own errors and its type's, leaving out the generic
  # "Sectionable is invalid". A group's own errors are whole sentences, so
  # they show as written ("Dairy-free, line 2 … needs an arrow").
  def section_error_messages(section)
    section.errors.reject { |error| error.attribute.to_s.start_with?('sectionable') }.map(&:full_message) +
      section.sectionable.errors.map { |error| error.attribute.to_s.end_with?('.base') ? error.message : error.full_message }.uniq
  end
end
