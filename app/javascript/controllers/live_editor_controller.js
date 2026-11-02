import { Controller } from "@hotwired/stimulus"
import { get, post } from "@rails/request.js"

// The live editor: the Issue page in an iframe (same origin, so its
// document is reachable from here) and a drawer beside it. A click on a
// Section in the page posts its id here (lemon_drop/issues/show) and its
// form loads into the drawer; saving sends the form and swaps the Sections
// the server renders back into the page, by data-section-id.
export default class extends Controller {
  static targets = ["page", "drawer"]
  static values = { formUrl: String }

  pick(event) {
    if (event.origin !== window.location.origin || event.source !== this.pageTarget.contentWindow) return

    this.open(event.data.sectionId)
  }

  async open(id) {
    const response = await get(this.formUrlValue.replace(":id", id), { responseKind: "html" })
    if (!response.ok) return

    this.drawerTarget.innerHTML = await response.html
    this.drawerTarget.hidden = false
  }

  close() {
    this.drawerTarget.hidden = true
    this.drawerTarget.innerHTML = ""
  }

  async save(event) {
    event.preventDefault()
    const form = event.target
    form.querySelectorAll("[type=submit]").forEach(button => button.disabled = true)

    // The form's hidden _method field makes this the PATCH it asks for.
    const response = await post(form.action, { body: new FormData(form), responseKind: "html" })
    const html = await response.html

    if (response.ok) {
      this.replaceSections(html)
      this.close()
    } else {
      this.drawerTarget.innerHTML = html
    }
  }

  replaceSections(html) {
    const page = this.pageTarget.contentDocument
    const template = page.createElement("template")
    template.innerHTML = html
    Array.from(template.content.children).forEach(section => {
      page.querySelector(`[data-section-id="${section.dataset.sectionId}"]`)?.replaceWith(section)
    })
  }
}
