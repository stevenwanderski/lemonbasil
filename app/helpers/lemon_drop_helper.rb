module LemonDropHelper
  RICH_TEXT_TAGS = %w[p br strong b em i a ul ol li].freeze
  RICH_TEXT_ATTRIBUTES = %w[href].freeze

  # Intro and Outro bodies: paragraphs, bold, italic, links and lists only
  # (ADR 0004). Everything else is stripped, and so are unsafe link schemes.
  def lemon_drop_rich_text(html)
    sanitize(html, tags: RICH_TEXT_TAGS, attributes: RICH_TEXT_ATTRIBUTES)
  end

  # A heading typed over several lines keeps its breaks ("allergen" / "swaps").
  def lemon_drop_heading(text)
    safe_join(text.to_s.lines.map(&:strip).reject(&:blank?), tag.br)
  end
end
