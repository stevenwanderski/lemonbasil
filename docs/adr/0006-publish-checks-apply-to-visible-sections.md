# Publish-blocking checks apply only to visible Sections, and are enforced on every save of a Published Issue

Saving a Published Issue runs the publish-blocking checks, and a save that fails them is rejected, so the live page can't end up broken. The checks look only at visible Sections. Otherwise there would be no way to add content to a live Issue: a new Recipe or Hero is incomplete (no image yet) at the moment it's created. New work on a live Issue therefore starts in a hidden Section. Making that Section visible is itself a save, so the checks run then.

## Considered Options

- **Warn only**: simpler, but lets a published page break on save.
- **Reject, checking all Sections**: blocks every incremental addition to a live Issue.
