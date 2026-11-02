import { Controller } from "@hotwired/stimulus"
import { get, post } from "@rails/request.js"
import { DirectUpload } from "@rails/activestorage"

// The live editor: the Issue page in an iframe (same origin, so its
// document is reachable from here) and a drawer beside it. A click on a
// Section in the page posts its id here (lemon_drop/issues/show) and its
// form loads into the drawer. As the form changes, the page shows the
// Section with those changes, unsaved; Save stores them, and Close (or
// opening another Section) puts the saved Section back. A picked image is
// uploaded at once (Active Storage direct upload) and the form carries its
// signed id instead of the file, so the preview can show it and Save only
// attaches it. Sections the server renders are swapped into the page by
// data-section-id.
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
    // A file field fires input and change for one pick; upload once.
    if (event.target.type === "file") return event.type === "change" && this.upload(event.target, form)

    clearTimeout(this.previewTimer)
    this.previewTimer = setTimeout(() => this.showPreview(form), 250)
  }

  async upload(input, form) {
    // A new pick replaces the last one in this field.
    form.querySelectorAll(`[data-uploaded-for="${input.id}"]`).forEach(element => element.remove())
    input.dataset.name ||= input.name
    input.name = input.dataset.name
    const buttons = form.querySelectorAll("[type=submit]")
    buttons.forEach(button => button.disabled = true)

    try {
      const signedIds = await Promise.all(Array.from(input.files).map(file => this.directUpload(file, input.dataset.directUploadUrl)))
      signedIds.forEach(signedId => {
        const field = Object.assign(document.createElement("input"), { type: "hidden", name: input.name, value: signedId })
        field.dataset.uploadedFor = input.id
        input.after(field)
      })
      // Uploaded already: the form sends the signed ids, not the files again.
      if (signedIds.length) input.removeAttribute("name")
    } catch (error) {
      const message = Object.assign(document.createElement("p"), { className: "form-errors", textContent: `Upload failed: ${error}` })
      message.dataset.uploadedFor = input.id
      input.after(message)
    } finally {
      buttons.forEach(button => button.disabled = false)
    }
    this.showPreview(form)
  }

  directUpload(file, url) {
    return new Promise((resolve, reject) => {
      new DirectUpload(file, url).create((error, blob) => error ? reject(error) : resolve(blob.signed_id))
    })
  }

  async showPreview(form) {
    const body = new FormData(form)
    body.delete("_method")
    // A file still here wasn't uploaded (its upload failed); don't send it on
    // every keystroke. It goes with the form on Save.
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
