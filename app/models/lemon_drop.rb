module LemonDrop
  def self.table_name_prefix
    'lemon_drop_'
  end

  # Section anchors and Recipe slugs share an Issue page's id space: returns
  # base, or base with a number added ("recipes-2") when it's already taken.
  def self.unique_page_id(base, taken)
    candidate = base
    number = 1
    candidate = "#{base}-#{number += 1}" while taken.include?(candidate)
    candidate
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
