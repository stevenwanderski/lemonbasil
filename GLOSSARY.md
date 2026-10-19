# Lemon & Basil

A meal prep and personal chef business. This app runs its client menus and public site, and publishes **the lemon drop**, a weekly meal plan.

## The lemon drop

**The lemon drop**:
The weekly meal plan publication, made up of a series of Issues.
_Avoid_: newsletter, blog

**Issue**:
One week's edition of the lemon drop: a single scrolling page made entirely of Sections. The public calls it a "drop" (its URLs are under `/drops`).
_Avoid_: post, edition, week, drop (except in public URLs)

**Section**:
One block of an Issue's page, of one Section type, at one position. An Issue may hold any number of Sections of any type, in any order.
_Avoid_: block, slide, page

**Section type**:
The kind of a Section: Title Page, Intro, Table of Contents, Hero, Menu Overview, Recipes, Grocery List, Allergen Swap or Outro.

**Recipe**:
A dish published in an Issue, belonging to exactly one Recipes Section of that Issue. Recipes are never shared between Issues; reusing one means copying it.
_Avoid_: meal, dish, instructions (Meal and Instructions are the chefs' separate cooking notes)

**Swap recipe**:
A small companion recipe inside an Allergen Swap Section (e.g. cashew ricotta). Not a Recipe and never on the menu.

**Draft**:
An Issue not yet visible to the public.

**Published**:
An Issue visible to the public. Saved edits to a Published Issue go live immediately.
_Avoid_: live (in code), released

**Content check**:
An automatic review of an Issue's content that reports a problem (e.g. a grocery item no Recipe uses). Most only warn.

**Publish-blocking check**:
A Content check that must pass for an Issue to be Published or for a Published Issue to be saved.

**Import**:
Turning a week's content, written as JSON in a Claude chat, into a Draft Issue. An Import never publishes.

**Admin**:
A user with the admin role. Only Admins can manage the lemon drop.
