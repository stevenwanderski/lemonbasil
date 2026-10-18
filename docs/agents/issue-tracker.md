# Issue tracker: Linear

Issues and specs for this repo live in Linear: workspace **Happy Code**, team **HAP**, project **Lemon & Basil**. Use the Linear MCP tools (`mcp__linear-server__*`) for all operations. Never create issues outside the Lemon & Basil project.

## Conventions

- **Create an issue**: `save_issue` with `team: "HAP"`, `project: "Lemon & Basil"`, a title, and a Markdown description (real newlines, no escape sequences). New issues start in **Backlog**; issues labelled `ready-for-agent` go to **Todo**.
- **Type label**: also apply exactly one of the team's type labels: `Feature`, `Bug`, or `Improvement`.
- **Read an issue**: `get_issue` with the identifier (e.g. `HAP-12`), `includeRelations: true` when blocking matters; `list_comments` for its comments.
- **List issues**: `list_issues` filtered by `project: "Lemon & Basil"` plus label/state filters as needed.
- **Sub-issues**: a spec is a parent issue; tickets broken out of it are created with `parentId` set to the spec's identifier.
- **Comment**: `save_comment` on the issue.
- **Apply / remove labels**: `save_issue` with `addLabels` / `removeLabels`.
- **Close**: set `state` to **Done** (completed) or **Canceled** (won't do), with a comment explaining why.
- **Blocking**: Linear's native relations, via `save_issue` `blockedBy` / `blocks`. A ticket is unblocked when every blocker is Done or Canceled.

## When a skill says "publish to the issue tracker"

Create a Linear issue in HAP / Lemon & Basil as above.

## When a skill says "fetch the relevant ticket"

Read it as in **Read an issue** above.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single parent issue; tickets are its sub-issues.

- **Map**: an issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body.
- **Child ticket**: a sub-issue of the map (`parentId`), labelled `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, assigned to the driving dev.
- **Blocking**: native `blockedBy` relations.
- **Frontier query**: the map's open sub-issues with no open blocker and no assignee; first in map order wins.
- **Claim**: `save_issue` with `assignee: "me"`, the session's first write.
- **Resolve**: comment the answer, set state to Done, then append a context pointer (gist + link) to the map's Decisions-so-far.
