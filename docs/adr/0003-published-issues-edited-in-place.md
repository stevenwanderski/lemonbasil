# Published Issues are edited in place

Saving an edit to a Published Issue (including its Sections and Recipes) changes the public page right away. There is no draft copy and no "republish" step. This keeps the model simple (one copy of each Issue) at the cost of a typo going live on save. The risk is handled by a live-editing banner in the editor and a change history that lets an Admin find and revert a bad edit.

Imports are the opposite: they only ever create or replace Drafts, so nothing from a Claude chat reaches the public without an Admin publishing it.
