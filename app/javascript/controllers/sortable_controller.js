import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import { patch } from "@rails/request.js"
import Sortable from "sortablejs"

// Drag-to-reorder by the .drag-handle in each row (ADR 0007). With a url, a
// drop sends every row's data-id, top first, as the param, then reloads so
// the page shows the order as stored (the new one, or the old one if the
// save was refused). Without one, only the rows move: form fields inside them
// submit in their new order, and each row's [data-sortable-position] field
// is numbered 1, 2, 3… as the form submits.
export default class extends Controller {
  static values = { url: String, param: String, draggable: { type: String, default: ">*" } }

  connect() {
    this.sortable = Sortable.create(this.element, {
      handle: ".drag-handle",
      draggable: this.draggableValue,
      // Mouse and touch events rather than native drag and drop, so it
      // behaves the same on phones and in browser specs.
      forceFallback: true,
      onEnd: this.save.bind(this)
    })
    this.form = this.hasUrlValue ? null : this.element.closest("form")
    this.numberPositions = this.numberPositions.bind(this)
    this.form?.addEventListener("submit", this.numberPositions)
  }

  disconnect() {
    this.sortable.destroy()
    this.form?.removeEventListener("submit", this.numberPositions)
  }

  numberPositions() {
    this.element.querySelectorAll(":scope > * [data-sortable-position]").forEach((position, index) => {
      position.value = index + 1
    })
  }

  async save(event) {
    if (!this.hasUrlValue || event.oldIndex === event.newIndex) return

    const body = new FormData()
    this.sortable.toArray().forEach(id => body.append(this.paramValue, id))

    await patch(this.urlValue, { body })
    Turbo.visit(window.location.href, { action: "replace" })
  }
}
