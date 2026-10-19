module LemonDropHelper
  # Intro and Outro bodies, sanitized again on render (LemonDrop::RichText).
  def lemon_drop_rich_text(html)
    sanitize(html, tags: LemonDrop::RichText::TAGS, attributes: LemonDrop::RichText::ATTRIBUTES)
  end

  # A heading typed over several lines keeps its breaks ("allergen" / "swaps").
  def lemon_drop_heading(text)
    safe_join(text.to_s.lines.map(&:strip).reject(&:blank?), tag.br)
  end
end
