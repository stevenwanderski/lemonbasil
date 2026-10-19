# Sections use Rails delegated_type

An Issue is made entirely of Sections, with no limits on type, count or order. A shared `sections` table holds ordering and the fields every Section has (position, theme, anchor, table-of-contents settings), and each Section type has its own table with real columns and validations, joined with `delegated_type`. We chose this over a single table with a `type` column and a JSON settings column because the types differ a lot (Recipes and Grocery Lists have nested children) and real columns are easier to validate and edit.
