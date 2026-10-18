# Spec: Weekly Meal Plan Issues ("the lemon drop")

Add a weekly meal plan feature to this Rails app. Each week an admin publishes an **Issue**: a single scrolling page built entirely from **sortable, editable sections** (title page, intro, table of contents, hero banners, menu overview, recipes, grocery list, allergen swaps, outro). Admins manage everything in an admin panel and can import a week's content as JSON produced in a Claude chat.

**Design reference:** `index.html` + `images/` (the Oct 19–23 issue converted from Canva) is the target look for the public page. Each part of that page corresponds to one section type below; port its CSS and markup into section partials largely as-is.

---

## 1. Fit with the host app (decided)

Vocabulary: see `/GLOSSARY.md`. Decisions: see `/docs/adr/`.

| Concern | Decision for this app |
|---|---|
| Admin authentication/authorization | Devise + `User#admin?` (`role == 'admin'`). The app's `AdminController` only requires sign-in (non-admin chef users can reach `/admin`), so every lemon-drop admin controller inherits from `Admin::LemonDrop::BaseController < AdminController`, whose `before_action` redirects non-admins to `admin_clients_path` (same as `Admin::UsersController`). Nav link shown to admins only. No new roles. |
| Admin UI | The app's custom `Admin::` controllers, `admin` layout and sidebar nav, admin SCSS, Turbo + Stimulus. |
| File storage | Active Storage (install its migrations) on **AWS S3** (public bucket, plain S3 URLs) via the S3 service and `aws-sdk-s3`, plus `image_processing` / libvips. Production currently uses `:local`, which doesn't persist on Heroku (ADR 0005). |
| Rich text | **Tiptap** WYSIWYG (Stimulus controller, esbuild), stored as sanitized HTML in a `text` column. No Action Text, no Markdown in the editor (ADR 0004). |
| Background jobs | None added. Rails' default `:async` adapter is enough: variants are generated on request, and duplicated issues reuse blobs. |
| Change history | `paper_trail` (new to the app). |
| Styling | Public issue pages use their own `lemon_drop` layout with the fonts and CSS from `index.html` and no marketing-site header. The footer carries a small link back to the Lemon & Basil home page. |
| Ownership | Issues are **global**: any admin sees and edits every issue. They are not scoped to `current_user` like the rest of admin. Imports and history record which user acted. |

**Namespace:** everything lives under `LemonDrop` (`LemonDrop::Issue`, `LemonDrop::Section`, `LemonDrop::Recipe`…, tables `lemon_drop_*`, admin controllers `Admin::LemonDrop::*`, public `LemonDrop::IssuesController`). `Page` already exists in the app, `Section` is generic, and `Recipe` would be confused with the existing `Meal` ("Instructions"). Names below are written un-namespaced for readability.

---

## 2. Scope

**In scope**
- Weekly issues composed entirely of ordered sections of nine types, with **no limits** on which types appear, how many of each, or in what order.
- Recipes that belong to exactly one issue (no sharing between issues).
- Admin CRUD for issues, sections and recipes; drag-to-reorder sections and recipes; image uploads; draft/publish workflow; preview.
- JSON import from a Claude chat (paste → validate → preview → create a draft issue).

**Out of scope for v1** (design so they can be added later)
- A recipe library or sharing recipes across issues. Copying content forward is done by duplicating an issue (§5).
- Structured ingredient parsing (quantity/unit/name), serving scaling, auto-generated grocery lists.
- Email newsletter delivery (decided: not planned).
- Subscriber accounts / paywall (decided: all published content is public).
- Scheduled or automatic publishing (decided: admins publish manually).
- New admin roles or permission levels (decided: use the host app's existing admin role).
- Pushing content directly from Claude into the app (API-based import or MCP connector), see §8.
- Standalone content pages (decided: the app's existing `Page` model already serves about, meal-prep and parties; extending it with status/nav is a separate change).
- Per-block menus: Menu Overview always covers every recipe in the issue (decided: no `selected` recipe scope in v1).
- HEIC uploads (decided: JPEG/PNG/WebP only in v1).
- Inline images inside rich text bodies.

---

## 3. Data model

### Overview

```
Issue
 └─ sections (ordered, position)          Section ── delegated_type :sectionable
      ├─ TitlePageSection
      ├─ IntroSection
      ├─ TableOfContentsSection
      ├─ HeroSection
      ├─ MenuOverviewSection
      ├─ RecipesSection ── recipes (ordered) ── ingredient_groups ── ingredients
      │                                      └─ steps
      ├─ GroceryListSection ── grocery_groups ── grocery_items
      ├─ AllergenSwapSection ── swap_groups ── swaps
      │                      └─ swap_recipes
      └─ OutroSection
```

Use Rails **`delegated_type`**: a shared `sections` table holds ordering and common fields, and each type has its own table with real columns and validations. (Alternative: one `sections` table with a `type` column and a JSON `settings` column. It's simpler to migrate but harder to validate and edit. Use delegated types unless the host app already uses the JSON pattern.)

### Issue
| Column | Type | Notes |
|---|---|---|
| title | string | internal/admin name and `<title>`, e.g. "oct 19–23"; required |
| slug | string | unique; default from `starts_on` (e.g. `2026-10-19`); editable while draft, **locked once `published_at` is set** so shared links never break |
| starts_on / ends_on | date | required; `ends_on >= starts_on` |
| status | enum | `draft`, `published`; default `draft` |
| published_at | datetime | set on first publish; kept when unpublished and republished |

`has_many :sections, -> { order(:position) }, dependent: :destroy`

Convenience readers:
- `recipes`: all recipes across **all** Recipes sections, in page order (section position, then recipe position).
- `primary_title_page`: the first visible Title Page section, used for the archive card and Open Graph tags. If there is none, fall back to the issue title and the first recipe's hero image.

Scopes: `published`.

### Section (shared fields)
| Column | Type | Notes |
|---|---|---|
| issue_id | ref | |
| sectionable_type / sectionable_id | delegated type | one of the nine types below |
| position | integer | order on the page; drag-to-reorder |
| visible | boolean | default true; hidden sections are kept but not rendered |
| theme | enum | background: `cream`, `sage`; extendable (`dark`, `photo`, …) |
| anchor | string | URL fragment, unique within issue **across section anchors and recipe slugs** (they share the page's `id` space); defaulted from type/heading (e.g. `grocery-list`), with a numeric suffix when taken (`recipes-2`) |
| show_in_toc | boolean | whether the Table of Contents lists this section |
| toc_label | string | label in the Table of Contents, e.g. "let's party!"; defaults to the heading |

### Section types

**No restrictions:** an issue may contain any number of sections of any type, in any order, including zero of a type (e.g. ten Recipes sections, three Grocery Lists, no Title Page). Do not add validations that limit section types or counts. Every type is always available in the admin's "Add section" menu. Features that look across sections (the Table of Contents, Menu Overview, content checks) must work with any number of each type.

**1. TitlePageSection** (cover)
| Column | Type | Notes |
|---|---|---|
| heading | string | "the lemon drop" |
| tagline | string | "your weekly meal plan" |
| date_label | string | "oct 19–23"; defaults from issue dates |
| cover_image | attachment | required to publish |

**2. IntroSection** (the "hello!" letter)
| Column | Type | Notes |
|---|---|---|
| heading | string | "hello!" |
| body_html | text | rich text (Tiptap HTML, sanitized on render) |
| signoff | string | "xx beth" |
| icon | attachment | optional decorative image (lemon slice) |

**3. TableOfContentsSection**
| Column | Type | Notes |
|---|---|---|
| heading | string | "this week's drop" |

Entries are **generated** from the issue's other visible sections with `show_in_toc = true`, in page order, using `toc_label` and linking to `#anchor`. Nothing to keep in sync by hand.

**4. HeroSection** (full-bleed banner, e.g. "let's cook")
| Column | Type | Notes |
|---|---|---|
| heading | text | one line per row of large text ("let's" / "cook") |
| background_image | attachment | required |
| background_focus | string | CSS `object-position`; preset choices (top/center/bottom) |
| overlay_image | attachment | optional (fork & knife), rendered between heading lines |
| text_color | enum | `light`, `dark` |
| min_height | enum | `medium`, `tall` |

**5. MenuOverviewSection** ("your menu")
| Column | Type | Notes |
|---|---|---|
| heading | string | "your menu" |
| icon | attachment | optional (mortar & pestle) |
| category_order | string array / text | order of category columns; default `entree, soup, salad, snack, breakfast, side, dessert` |

Contents are **generated** from **all** of the issue's recipes in visible Recipes sections, in page order, grouped by `category`, showing `menu_title` and `menu_blurb`, each linking to the recipe's anchor. Empty categories are omitted. If there are no recipes, the admin shows a warning and the public page skips this section. (Decided: no per-section recipe scope in v1. Adding one later means a `recipe_scope` column and an optional import key.)

**6. RecipesSection**
| Column | Type | Notes |
|---|---|---|
| heading | string | optional; usually blank (recipes start immediately) |

`has_many :recipes, -> { order(:position) }, dependent: :destroy`

**7. GroceryListSection**
| Column | Type | Notes |
|---|---|---|
| heading | string | "your grocery list" |
| icon | attachment | optional (bowl) |

`has_many :grocery_groups` (`name`: Produce, Pantry, Dairy/Eggs, Meat & Seafood…, `position`) → `has_many :grocery_items` (`text`, `position`). Edited and imported by hand; not derived from recipes.

**8. AllergenSwapSection**
| Column | Type | Notes |
|---|---|---|
| heading | string | "allergen swaps" |
| icon | attachment | optional (stacked bowls) |
| disclaimer | text | defaults to a standard allergen disclaimer (§9) |

- `has_many :swap_groups` (`name`: Gluten-free swaps, Dairy-free swaps…, `position`) → `has_many :swaps` (`from_text`, `to_text`, `position`), rendered as "**parm** → nutritional yeast".
- `has_many :swap_recipes` (`title`, `yield_label` e.g. "Makes ~1½ cups", `ingredients` text one per line, `steps` text one per line, `use_for` string, `position`). These are the small companion recipes (cashew ricotta, cashew cream…). They're simpler than main recipes and don't appear in the menu.

**9. OutroSection** (closing content, e.g. "book your holiday party!")
| Column | Type | Notes |
|---|---|---|
| heading | string | |
| body_html | text | rich text (Tiptap HTML, sanitized on render) |
| images | attachments (many) | optional photo grid, 0–6 |
| cta_label / cta_url | string | optional button, e.g. "reach out" → mailto or booking link |

### Recipe (belongs to one issue)
| Column | Type | Notes |
|---|---|---|
| recipes_section_id | ref | required; a recipe never exists outside an issue |
| position | integer | order within its Recipes section; drag-to-reorder |
| title | string | required, e.g. "chickpea stew" |
| slug | string | unique **within the issue, across all its Recipes sections and all section anchors** (they share the page's `id` space); used as the anchor and in the recipe URL; numeric suffix when taken |
| kicker | string | optional label above title, e.g. "easy freeze" |
| category | enum | `entree`, `soup`, `salad`, `snack`, `breakfast`, `side`, `dessert` |
| menu_title | string | optional menu name if different, e.g. "One Pan Harissa Chicken" |
| menu_blurb | text | one-line description on the menu |
| prep_minutes / cook_minutes | integer | optional |
| time_note | string | optional free text, e.g. "+ marinating" |
| total_label | string | optional override, e.g. "1 hour 20 mins"; otherwise computed |
| serves | integer | |
| tip | text | the yellow callout box |
| hero_image | attachment | required to publish |
| hero_focus | string | CSS `object-position`, preset choices |

- `has_many :ingredient_groups, -> { order(:position) }` (`name`: Produce, Pantry, Dairy, Meat…) → `has_many :ingredients` (`text`, `position`).
- `has_many :steps, -> { order(:position) }` (`body`, `position`).
- Ingredients are intentionally **free text**, e.g. "2 cans chickpeas (15 oz each), drained and rinsed". Do not parse quantities in v1.
- Because recipes are unique to an issue, editing one never affects any other issue. No cross-issue versioning is required.

---

## 4. Public site

| Route | Content |
|---|---|
| `GET /drops` | Archive of published issues, newest first, 12 per page (Kaminari) (cover image, title page heading, date label) |
| `GET /drops/:slug` | Full issue page: visible sections rendered in `position` order |
| `GET /drops/:slug/recipes/:recipe_slug` | Standalone recipe page (same recipe partial), linkable and printable. 404 if the recipe's Recipes section is hidden. |

Public URLs use **`/drops`**. The model stays `Issue`; map it in routes, e.g. `resources :drops, controller: "lemon_drop/issues", param: :slug, only: [:index, :show]`. Pages render in the self-contained `lemon_drop` layout (§1).

All published issues and recipes are **public**: no login, indexable by search engines, with the SEO items below.

**Rendering**
- The issue view loops over `issue.sections.visible` and renders `sections/_<type>` for each one, wrapped in an element with `id="<anchor>"` and the theme class. No section order is hard-coded.
- Each recipe renders with `id="<recipe slug>"` so Table of Contents and Menu Overview links work.
- Default order for a new issue matches the reference: Title Page → Intro → Table of Contents → Hero → Menu Overview → Recipes → Grocery List → Allergen Swap → Outro.
- The dashed running header ("the lemon drop") is hard-coded in the partials, not a field. The footer reads "the lemon drop · <date>", where the date is the first visible Title Page's `date_label`, falling back to the issue's dates.

**Requirements**
- Responsive at phone widths (single column under ~760px), no horizontal scroll.
- Image variants: hero/cover ~1600w, grid/thumbnail ~600w; serve WebP where supported; lazy-load below the fold.
- Images are served from a **public S3 bucket** at plain S3 URLs (`public: true` in `storage.yml`), so URLs are permanent and cacheable. They work for Open Graph and don't route through Heroku. No custom image domain in v1 (ADR 0005).
- Print stylesheet: grocery list and individual recipes print cleanly.
- `schema.org/Recipe` JSON-LD on recipe pages and for each recipe on issue pages.
- Open Graph tags from `primary_title_page` (cover image, heading, date label), with the fallback in §3.
- Unpublished issues return 404 to the public; admins can view them via preview.

---

## 5. Admin panel

All routes require the existing admin role, enforced by `Admin::LemonDrop::BaseController` (§1). Lives in the app's `/admin` area with a "Lemon Drop" sidebar link shown to admins only.

**Issues list**
- Columns: title, dates, status, published_at; status filter.
- **Delete issue** is only available for drafts; a published issue must be unpublished first.
- **New issue** creates a draft with the nine sections in the default order, prefilled with default headings ("hello!", "this week's drop", "your menu", "your grocery list", "allergen swaps"…).
- **Duplicate issue** opens a small form asking for the new title, `starts_on` and `ends_on` (prefilled with the original's dates + 7 days), then deep-copies every section, recipe, grocery list and swap (including image attachments) into a new draft with a fresh slug. This replaces recipe sharing: to reuse last week's recipe, duplicate the issue or copy a single recipe (below).

**Issue editor** (the main screen)
- Left: the section list in page order. Each row shows the type, heading, visibility toggle and a drag handle. Drag-to-reorder (sections, recipes, groups, swap recipes) uses SortableJS in a Stimulus controller that posts new positions with `@rails/request.js`, stored in `position` columns (ADR 0007). Sections can be reordered (drag), added (any type, any number of times, inserted at a chosen position), duplicated within the issue, hidden, or deleted. Deleting a Recipes section that still has recipes asks whether to delete them or move them to another Recipes section in the issue.
- Right: the selected section's form. Each section type has its own form with the fields in §3 plus the shared fields (theme, anchor, show in TOC, TOC label).
- Issue settings: title, slug, dates.
- **Preview** button renders the public page for any status, in a new tab.
- **Publish** and **Unpublish** buttons; publishing is always manual. Publishing runs the checks in §7.
- **Published issues stay editable, and saved changes go live immediately**, including edits to recipes and sections. There is no separate "republish" step or draft copy. Because of this:
  - Saving a published issue runs the publish-blocking checks in §7; a save that would fail them is rejected with errors, so the live page never ends up broken. The checks consider **visible sections only** (ADR 0006): to add new content to a live issue, add the section hidden, build it up, then make it visible (that save runs the checks). Recipes added to a visible Recipes section must be complete when saved, so the recipe form takes the hero image in the same save.
  - The editor shows a clear "Live: changes are public when saved" banner on published issues.
  - Keep a change history for issues and everything in them with `paper_trail` (whodunnit = the admin). The history screen lists an issue's changes. Reverting works one record at a time: restore a single record's earlier version, or recreate a deleted record along with its children where feasible. There are no whole-issue snapshots. **Image changes can't be reverted in v1**: paper_trail versions rows, not files, and Active Storage purges replaced images. To undo an image change, re-upload the old image.

**Recipes (inside the Recipes section form)**
- Sortable list of that section's recipes; add, edit, delete.
- **Move recipe** to another Recipes section in the same issue.
- Recipe form: fields in §3, hero image upload with focus presets.
- Ingredient groups: group name + textarea, **one ingredient per line**; add, rename and reorder groups.
- Steps: textarea, **one step per line**, or a sortable list.
- **Copy recipe to another issue** action: creates an independent copy in the chosen issue's Recipes section. Later edits to either copy don't affect the other.

**Grocery List and Allergen Swap forms**
- Groups with a name + textarea, one item per line. For swaps, one swap per line in the format `parm → nutritional yeast` (also accept `->`).
- Swap recipes: sortable list, each with title, yield, ingredients (one per line), steps (one per line), use for.

**Rich text fields** (Intro and Outro bodies) use the Tiptap editor, limited to paragraphs, bold, italic, links and lists.

**Images**: uploaded through the section and recipe forms. Accept JPEG/PNG/WebP up to 15 MB (no HEIC in v1); strip EXIF location data **on upload, before the file is stored**, so originals in the public bucket never contain it; in the same step, scale originals down to at most 2400px on the longest side.

---

## 6. Import from Claude

### Flow
1. Admin opens **Admin → Import**, pastes JSON (or uploads a `.json` file).
2. The app validates it against the schema below (`json_schemer` gem). Errors are shown with their JSON path.
3. **Preview screen** shows the issue as a list of sections in order, with counts (e.g. "Recipes: 7 recipes", "Grocery List: 4 groups, 62 items") and expandable details, plus the warnings from §7.
4. Admin chooses **Create new issue** or **Replace sections of an existing draft issue** (never a published one), then confirms. Replacing shows exactly what will be deleted (e.g. "Replaces 9 sections, 7 recipes and 14 images") and requires explicit confirmation; paper_trail keeps the deleted records so they can be recovered.
5. Everything is created in one DB transaction **as a draft**. Import never publishes.
6. The admin lands on the issue editor with a checklist of missing images (from `image_hint` fields).

Store every import (`Import` record: raw JSON, admin, resulting issue, timestamp) for audit and re-run.

### JSON format (v1)
The issue is an ordered `sections` array; each element has a `type` and that type's fields. Array order becomes `position`.

```json
{
  "schema_version": 1,
  "issue": {
    "title": "oct 19-23",
    "starts_on": "2026-10-19",
    "ends_on": "2026-10-23"
  },
  "sections": [
    {
      "type": "title_page",
      "heading": "the lemon drop",
      "tagline": "your weekly meal plan",
      "date_label": "oct 19-23",
      "image_hint": "overhead shot of the chickpea stew"
    },
    {
      "type": "intro",
      "heading": "hello!",
      "body_markdown": "it's mid october and i'm fully in it...\n\ni find myself drawn to...",
      "signoff": "xx beth"
    },
    { "type": "table_of_contents", "heading": "this week's drop" },
    {
      "type": "hero",
      "heading_lines": ["let's", "cook"],
      "text_color": "light",
      "image_hint": "crispy chickpeas on a sheet pan"
    },
    { "type": "menu_overview", "heading": "your menu" },
    {
      "type": "recipes",
      "toc_label": "recipes",
      "recipes": [
        {
          "title": "chickpea stew",
          "kicker": null,
          "category": "soup",
          "menu_title": "Chickpea Stew",
          "menu_blurb": "chickpeas, spinach, turmeric, garlic, ginger, ...",
          "prep_minutes": 15,
          "cook_minutes": 30,
          "time_note": null,
          "serves": 5,
          "ingredient_groups": [
            { "name": "Produce", "items": ["4 garlic cloves, thinly sliced", "1 inch fresh ginger, grated"] },
            { "name": "Pantry", "items": ["good olive oil", "2 cans chickpeas (15 oz each), drained and rinsed"] }
          ],
          "steps": ["Set aside about 1/2 c of the chickpeas for crisping...", "In the same pot reduce heat..."],
          "tip": "When you want something warming and nourishing...",
          "image_hint": "the stew in a glass bowl with cilantro"
        }
      ]
    },
    {
      "type": "grocery_list",
      "heading": "your grocery list",
      "theme": "sage",
      "groups": [
        { "name": "Produce", "items": ["1 large delicata squash", "3 medium acorn squash"] }
      ]
    },
    {
      "type": "allergen_swap",
      "heading": "allergen swaps",
      "theme": "sage",
      "swap_groups": [
        { "name": "Gluten-free swaps", "swaps": [{ "from": "pappardelle", "to": "gf pasta" }] }
      ],
      "swap_recipes": [
        {
          "title": "Cashew ricotta",
          "yield_label": "Makes ~1½ cups",
          "ingredients": ["1c raw cashews", "2 tbsp lemon juice"],
          "steps": ["Soak cashews in hot water for 30 mins...", "Add all ingredients to a blender..."],
          "use_for": null
        }
      ]
    },
    {
      "type": "outro",
      "heading": "book your holiday party!",
      "toc_label": "let's party!",
      "body_markdown": "our dinner party calendar is filling up...",
      "cta_label": null,
      "cta_url": null,
      "image_hints": ["garden table with tomatoes", "dining room set for dinner", "family style spread"]
    }
  ]
}
```

Rules:
- Required: `schema_version`, `issue.title`, `issue.starts_on`, `sections`, and each section's `type`. Per recipe: `title`, `category`, `ingredient_groups`, `steps`. Everything else is optional and falls back to the defaults in §3.
- Shared section fields (`theme`, `visible`, `anchor`, `show_in_toc`, `toc_label`) are allowed on any section.
- Any number of sections of any type is valid, in any order (§3).
- `body_markdown` is converted to HTML on import with `kramdown` (already in the app), then sanitized with the same allowlist as the editor.
- Unknown keys are rejected so typos surface instead of being silently dropped.
- Keep the JSON Schema in the repo (e.g. `config/schemas/issue_import.v1.json`); bump `schema_version` for breaking changes.

### Claude-side instructions
Provide a "Claude export instructions" text on the admin Import page (and keep it in the repo) that admins paste into a Claude Project's instructions. It should contain the JSON Schema, the example above, and rules such as: output only one fenced `json` block; keep sections in the intended page order; use `null` for unknown values and never invent quantities; keep ingredient lines as written; list every ingredient a step uses.

---

## 7. Content checks (warnings, shown on import preview and before publishing)

Warnings never block import. **Bold** items block publishing.

Checks look across **all** sections of each type (e.g. every Grocery List against every recipe in the issue). Missing section types are never errors. **Publish-blocking checks consider visible sections only** (ADR 0006); warnings also report on hidden sections.

- **Issue has no visible sections.**
- **A Title Page section has no cover image.**
- **Recipe has no hero image, no steps, or no ingredients.**
- **Hero section has no background image.**
- No visible Title Page section (the archive and link previews will use the fallback).
- Menu Overview present but the issue has no recipes.
- Table of Contents present but no sections are marked `show_in_toc`.
- Empty sections (e.g. a Recipes section with no recipes, a Grocery List with no items).
- Grocery item doesn't match any ingredient in the issue's recipes (simple normalized word match), e.g. "crushed tomatoes" when no recipe uses them.
- Recipe ingredient has no similar grocery item in any of the issue's Grocery Lists (skipped if the issue has no Grocery List).
- A step mentions an ingredient-like word not in the ingredient list (best effort; e.g. "chicken thighs" in steps but not in ingredients).
- Duplicate recipe titles within the issue.
- Issue dates overlap another issue.

The matching checks are heuristics; implement simply and tune later.

---

## 8. Future: direct push from Claude (not v1)

Build v1 so the import logic is a reusable service object (`LemonDrop::Importer.new(json, admin:).preview` / `.commit!`). Later options call the same service:
1. **API-based import:** admin pastes raw notes; the app calls the Claude API with the schema as a tool definition to get JSON back, then shows the normal preview.
2. **MCP connector:** a remote MCP endpoint (official Ruby `mcp` gem) with tools like `create_draft_issue` and `add_section`, added as a custom connector in claude.ai. Requires a public HTTPS endpoint and OAuth; tools may only create or change drafts.

---

## 9. Security & content concerns

- All admin and import routes are restricted to the existing admin role, enforced server-side in every controller via `Admin::LemonDrop::BaseController` (not just hidden in navigation). (Note: the app's existing `Admin::PagesController` lacks this server-side check; fixing it is out of scope here.)
- Any future token-based import endpoint uses per-admin, revocable, scoped tokens (drafts only), with rate limiting.
- Sanitize rich text on save and on render with an allowlist matching the Tiptap toolbar (paragraphs, bold, italic, links, lists); Markdown from imports is converted with kramdown and sanitized the same way. Validate `cta_url` schemes (`https`, `mailto` only).
- Validate upload content type by file contents, not extension.
- **Allergen content:** the Allergen Swap section always renders its disclaimer. There is no review or confirmation step for allergen content.
- Claude-generated recipes are drafts until reviewed; the checks in §7 exist because the reference issue shipped with a missing ingredient and an unused grocery item.
- Duplicating an issue copies image attachments; make sure copies are independent (`blob` reuse is fine, but purging one issue must not delete images still used by another).

---

## 10. Implementation phases & acceptance criteria

**Phase 1: Models & public page**
- Migrations, models (delegated types), validations (no limits on section types or counts), factories, and seeds that recreate the Oct 19–23 issue from `index.html` (text + images) as nine sections. The seeds (`db/seeds/lemon_drop.rb`) run in **development and test only, never in production**: some reference photos are cropped from third-party sites and two don't match their dish. Production content arrives through Import with the business's own photos.
- Section partials ported from `index.html`; issue view renders sections in `position` order.
- ✅ Seeded issue renders visually equivalent to `index.html` on desktop and phone.
- ✅ Changing section positions in the console changes the page order; hiding a section removes it from the page and the Table of Contents.
- ✅ An issue with several sections of the same type (e.g. three Recipes sections and two Grocery Lists) renders correctly, with unique anchors, and the Table of Contents and Menu Overview include all of them.
- ✅ Unpublished issue returns 404 publicly.

**Phase 2: Admin**
- Issue editor with section list (add/reorder/hide/delete), per-type section forms, recipe management, grocery and swap editors, image uploads, preview, publish/unpublish, live editing of published issues with change history, duplicate issue, copy recipe to another issue.
- ✅ An admin can build the full Oct 19–23 issue from a blank new issue without touching the console.
- ✅ Editing a published issue updates the public page on save; an edit that would break a publish-blocking check is rejected; the previous version can be restored from history.
- ✅ Users without the host app's admin role can't reach any admin or import route.
- ✅ Editing a recipe in one issue never changes another issue (including after duplicate/copy).

**Phase 3: JSON import**
- Schema file, `LemonDrop::Importer` service, import UI with preview, create-new / replace-draft choice, `Import` audit records, Claude instructions text.
- ✅ Pasting the JSON for the reference issue produces a draft matching the seeded issue, sections in the same order.
- ✅ Invalid JSON shows path-specific errors; JSON with repeated section types (e.g. ten `recipes` sections) imports successfully; nothing is published by import.

**Phase 4: Checks & polish**
- §7 warnings, publish blocking, JSON-LD, Open Graph, print styles.
- ✅ The reference issue's real problems (missing chicken thighs/couscous in the harissa chicken ingredients, unused crushed tomatoes in the grocery list) are flagged.

Tests (three seams; assert observable behavior, not internals):
- **HTTP request specs (primary):** public rendering, ordering and visibility under `/drops` (Hidden sections, Draft 404s, Recipes in Hidden sections 404, repeated/missing Section types, anchor/slug uniqueness); admin-role authorization (a signed-in non-admin is turned away); publish/unpublish and Publish-blocking checks, including saves to Published Issues and Hidden sections being exempt; slug lock; draft-only delete; duplicate and copy-recipe independence; revert; rich text sanitization.
- **`LemonDrop::Importer` (`preview` / `commit!`):** valid reference JSON, path-specific errors, unknown keys, repeated Section types, Markdown → sanitized HTML, replace-draft (refused for Published), transaction rollback, never publishes, Import record, reference-issue warnings.
- **Feature specs (`spec/features`, Capybara + Firefox, `js: true`)** only for JavaScript flows: reorder Sections → preview, Tiptap saves formatted text, import → preview → commit.
- **Content check matching heuristics** get direct tests for their edge cases only.
