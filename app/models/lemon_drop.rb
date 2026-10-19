module LemonDrop
  def self.table_name_prefix
    'lemon_drop_'
  end

  # Text typed or pasted one entry per line: each line trimmed, blank ones
  # left out.
  def self.lines(text)
    text.to_s.lines.map(&:strip).reject(&:blank?)
  end

  # Section anchors and Recipe slugs share an Issue page's id space: returns
  # base, or base with a number added ("recipes-2") when it's already taken.
  def self.unique_page_id(base, taken)
    candidate = base
    number = 1
    candidate = "#{base}-#{number += 1}" while taken.include?(candidate)
    candidate
  end

  # Attaches a fresh copy of each of from's images to to, so the two records
  # never share a stored file.
  def self.copy_attachments(from, to)
    from.class.reflect_on_all_attachments.each do |reflection|
      attached = from.public_send(reflection.name)
      attachments = reflection.macro == :has_many_attached ? attached.attachments : [attached.attachment].compact
      next if attachments.empty?

      to.public_send(reflection.name).attach(*attachments.map do |attachment|
        { io: StringIO.new(attachment.download), filename: attachment.filename.to_s, content_type: attachment.content_type }
      end)
    end
  end

  # Splits items into at most count columns, keeping their order, where the
  # longest column (by the block's size for each item) comes out shortest.
  # The Menu Overview and Grocery List fill their grids this way.
  def self.balanced_columns(items, count, &size)
    return items.map { |item| [item] } if items.size <= count

    cuts = (1...items.size).to_a.combination(count - 1).min_by do |points|
      [0, *points, items.size].each_cons(2).map { |from, to| items[from...to].sum(&size) }.max
    end
    [0, *cuts, items.size].each_cons(2).map { |from, to| items[from...to] }
  end
end
