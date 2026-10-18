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
end
