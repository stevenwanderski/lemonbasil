# Publish-blocking checks apply only to visible Sections, and are enforced on every save of a Published Issue

**Superseded in part (2026-10-19):** Sections can no longer be hidden; an unwanted Section is deleted instead. The rest of this ADR (rejecting a save that fails the checks) still stands, but the hidden-Section route for building new content on a live Issue is gone. How a new, still-incomplete Section on a Published Issue gets past the checks is open, to be settled when the checks are built.

Saving a Published Issue runs the publish-blocking checks, and a save that fails them is rejected, so the live page can't end up broken. The checks look only at visible Sections. Otherwise there would be no way to add content to a live Issue: a new Recipe or Hero is incomplete (no image yet) at the moment it's created. New work on a live Issue therefore starts in a hidden Section. Making that Section visible is itself a save, so the checks run then.

## Considered Options

- **Warn only**: simpler, but lets a published page break on save.
- **Reject, checking all Sections**: blocks every incremental addition to a live Issue.
