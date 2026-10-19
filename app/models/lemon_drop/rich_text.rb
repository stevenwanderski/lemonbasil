# Intro and Outro bodies: paragraphs, bold, italic, links and lists only
# (ADR 0004), the same set the editor's toolbar offers. Applied on save and
# again on render; everything else is stripped, and so are unsafe link schemes.
# On save, scripts and styles go along with their contents.
module LemonDrop::RichText
  TAGS = %w[p br strong b em i a ul ol li].freeze
  ATTRIBUTES = %w[href].freeze

  def self.sanitize(html)
    return html if html.blank?

    pruned = Loofah.fragment(html).scrub!(:prune).to_s
    Rails::Html::SafeListSanitizer.new.sanitize(pruned, tags: TAGS, attributes: ATTRIBUTES)
  end
end
