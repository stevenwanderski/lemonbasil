# Exporting a lemon drop Issue

When I ask for this week's lemon drop, reply with the whole Issue as JSON that matches the schema below, so it can be pasted into Admin → Import.

## Rules

- Output only one fenced `json` block, with nothing before or after it.
- Set `schema_version` to 1.
- Keep the sections in the order they should appear on the page. Any number of sections of any type is fine, in any order.
- Use only the keys in the schema. Unknown keys are rejected, so check the spelling.
- Use `null` for anything you don't know. Never invent quantities, times or servings.
- Keep ingredient lines exactly as written, one ingredient per line, with their quantities.
- List every ingredient a step uses in that recipe's ingredients.
- Write one step per array entry.
- Write `body_markdown` in plain Markdown: paragraphs, bold, italic, links and lists only.
- Describe the photo each section or recipe needs in `image_hint` (`image_hints` for the outro's photo grid). Images are added in the admin after import.
- `category` is one of: entree, soup, salad, snack, breakfast, side, dessert.
- `theme` is `cream` (the default) or `sage`.
