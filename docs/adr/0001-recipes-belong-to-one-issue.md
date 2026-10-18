# Recipes belong to exactly one Issue

Each Recipe belongs to one Recipes Section of one Issue; there is no shared recipe library. Editing a Recipe can never change another Issue, so edits to a live Issue are safe and no cross-issue versioning is needed. Reuse happens by duplicating an Issue or copying a single Recipe into another Issue, which creates an independent copy.

## Consequences

- The same dish published twice exists as two rows that can drift apart. That is intended.
- Adding a recipe library later means a new model that Recipes are copied *from*, not a change to Recipe ownership.
