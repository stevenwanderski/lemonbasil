# Rich text is Tiptap HTML, not Action Text or Markdown

Intro and Outro bodies are edited with Tiptap (a headless ProseMirror editor wired up with a Stimulus controller) and stored as sanitized HTML in a plain `text` column. The admins want a WYSIWYG editor, and they didn't like Trix, so Action Text's default editor was out. The rest of the app stores Markdown rendered with kramdown, so this is a deliberate exception to that convention. The editor allows only paragraphs, bold, italic, links and lists. Output is sanitized against the same allowlist on render. Claude imports still send `body_markdown`, which the importer converts to HTML once with kramdown.

## Considered Options

- **Action Text + Trix**: rejected because the admins don't like Trix; it also needs Action Text tables we don't otherwise use.
- **Action Text + Rhino Editor** (Tiptap inside Action Text): worth it only for inline image attachments in bodies, which we don't need.
- **Markdown textarea**: matches the rest of the app, but admins want WYSIWYG.
- **Quill, TinyMCE, CKEditor**: less control over output, or heavier with GPL/commercial licensing.
