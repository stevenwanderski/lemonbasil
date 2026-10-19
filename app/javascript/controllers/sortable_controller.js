import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import { patch } from "@rails/request.js"
import Sortable from "sortablejs"

// Drag-to-reorder by the .drag-handle in each row (ADR 0007). With a url, a
// drop sends every row's data-id, top first, as the param, then reloads so
// the page shows the order as stored (the new one, or the old one if the
// save was refused). Without one, only the rows move:
// form fields inside them submit in their new order.
export default class extends Controller {
  static values = { url: String, param: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      handle: ".drag-handle",
      // Mouse and touch events rather than native drag and drop, so it
      // behaves the same on phones and in browser specs.
      forceFallback: true,
      onEnd: this.save.bind(this)
    })
  }

  disconnect() {
    this.sortable.destroy()
  }

  async save(event) {
    if (!this.hasUrlValue || event.oldIndex === event.newIndex) return

    const body = new FormData()
    this.sortable.toArray().forEach(id => body.append(this.paramValue, id))

    await patch(this.urlValue, { body })
    Turbo.visit(window.location.href, { action: "replace" })
  }
}
