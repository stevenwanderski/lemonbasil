# == Schema Information
#
# Table name: lemon_drop_table_of_contents_sections
#
#  id         :bigint           not null, primary key
#  heading    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class LemonDrop::TableOfContentsSection < ApplicationRecord
  include LemonDrop::Sectionable

  # Built from the page itself, so it never needs updating by hand: the
  # other Sections on the page marked show-in-TOC, in page order. A Section
  # with nothing to label it by (a Recipes Section without a heading or TOC
  # label) is left out rather than shown as an empty link.
  def entries
    section.issue.page_sections.select { |entry| entry.show_in_toc && entry.display_toc_label.present? }.excluding(section)
  end
end
