import { Controller } from "@hotwired/stimulus"
import { get, post } from "@rails/request.js"

// The live editor: the Issue page in an iframe (same origin, so its
// document is reachable from here) and a drawer beside it. A click on a
// Section in the page posts its id here (lemon_drop/issues/show) and its
// form loads into the drawer. As the form changes, the page shows the
// Section with those changes, unsaved; Save stores them, and Close (or
// opening another Section) puts the saved Section back. Sections the server
// renders are swapped into the page by data-section-id.
export default class extends Controller {
  static targets = ["page", "drawer"]
  static values = { formUrl: String }

  pick(event) {
    if (event.origin !== window.location.origin || event.source !== this.pageTarget.contentWindow) return

    this.open(event.data.sectionId)
  }

  async open(id) {
    this.close()
    const response = await get(this.formUrlValue.replace(":id", id), { responseKind: "html" })
    if (!response.ok) return

    this.saved = this.findSection(id)?.cloneNode(true)
    this.drawerTarget.innerHTML = await response.html
    this.drawerTarget.hidden = false
  }

  // Leaves without saving: the page goes back to the saved Section.
  close() {
    if (this.saved) this.findSection(this.saved.dataset.sectionId)?.replaceWith(this.saved)
    this.hide()
  }

  hide() {
    clearTimeout(this.previewTimer)
    this.previews = (this.previews || 0) + 1 // so a preview still on its way is ignored
    this.saved = null
    this.drawerTarget.hidden = true
    this.drawerTarget.innerHTML = ""
  }

  // Waits for a pause in typing, then shows the form's values on the page.
  preview(event) {
    const form = event.currentTarget
    clearTimeout(this.previewTimer)
    this.previewTimer = setTimeout(() => this.showPreview(form), 250)
  }

  async showPreview(form) {
    const body = new FormData(form)
    body.delete("_method")
    // Images only show once saved; don't upload them on every keystroke.
    for (const [name, value] of Array.from(body.entries())) {
      if (value instanceof File) body.delete(name)
    }

    const number = this.previews = (this.previews || 0) + 1
    const response = await post(form.dataset.previewUrl, { body, responseKind: "html" })
    if (!response.ok) return

    const html = await response.html
    if (number === this.previews) this.replaceSections(html)
  }

  async save(event) {
    event.preventDefault()
    const form = event.target
    clearTimeout(this.previewTimer)
    this.previews = (this.previews || 0) + 1
    form.querySelectorAll("[type=submit]").forEach(button => button.disabled = true)

    // The form's hidden _method field makes this the PATCH it asks for.
    const response = await post(form.action, { body: new FormData(form), responseKind: "html" })
    const html = await response.html

    if (response.ok) {
      this.replaceSections(html)
      this.hide()
    } else {
      this.drawerTarget.innerHTML = html
    }
  }

  findSection(id) {
    return this.pageTarget.contentDocument.querySelector(`[data-section-id="${id}"]`)
  }

  replaceSections(html) {
    const template = this.pageTarget.contentDocument.createElement("template")
    template.innerHTML = html
    Array.from(template.content.children).forEach(section => {
      this.findSection(section.dataset.sectionId)?.replaceWith(section)
    })
  }
}
