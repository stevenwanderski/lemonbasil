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
// attaches it. A Recipe inside a Recipes Section opens and previews the same
// way, on its own. What the server renders is swapped into the page by
// data-section-id or data-recipe-id.
export default class extends Controller {
  static targets = ["page", "canvas", "outline", "drawer", "widthButton"]
  static values = { formUrl: String, recipeFormUrl: String, newRecipeUrl: String }

  pick(event) {
    if (event.origin !== window.location.origin || event.source !== this.pageTarget.contentWindow) return

    const { sectionId, recipeId } = event.data
    recipeId ? this.openRecipe(sectionId, recipeId) : this.open(sectionId)
  }

  // From the panel's Section list: open it, and bring it into view.
  async choose(event) {
    const id = event.currentTarget.dataset.sectionId
    await this.open(id)
    this.find(sectionKey(id))?.scrollIntoView({ block: "start", behavior: "smooth" })
  }

  // From a Recipes Section's Recipe list, in the drawer.
  async chooseRecipe(event) {
    const { sectionId, recipeId } = event.currentTarget.dataset
    await this.openRecipe(sectionId, recipeId)
    this.find(recipeKey(recipeId))?.scrollIntoView({ block: "start", behavior: "smooth" })
  }

  // A blank Recipe form: nothing on the page yet, so nothing to select.
  newRecipe(event) {
    this.load(this.newRecipeUrlValue.replace(":section_id", event.currentTarget.dataset.sectionId), null)
  }

  open(id) {
    return this.load(this.formUrlValue.replace(":id", id), sectionKey(id))
  }

  openRecipe(sectionId, id) {
    return this.load(this.recipeFormUrlValue.replace(":section_id", sectionId).replace(":id", id), recipeKey(id))
  }

  // Loads a form into the drawer for the page element the key selects.
  async load(url, key) {
    this.close()
    const response = await get(url, { responseKind: "html" })
    if (!response.ok) return

    const element = key && this.find(key)
    this.saved = element?.cloneNode(true)
    this.selected = key
    element?.setAttribute("data-selected", "")
    this.drawerTarget.innerHTML = await response.html
    this.drawerTarget.hidden = false
    this.outlineTarget.hidden = true
    this.element.classList.add("is-editing")
  }

  // Leaves without saving: the page goes back to the saved Section or Recipe.
  close() {
    if (this.saved) this.find(this.selected)?.replaceWith(this.saved)
    this.hide()
  }

  hide() {
    clearTimeout(this.previewTimer)
    this.previews = (this.previews || 0) + 1 // so a preview still on its way is ignored
    this.saved = null
    if (this.selected) this.find(this.selected)?.removeAttribute("data-selected")
    this.selected = null
    this.drawerTarget.hidden = true
    this.drawerTarget.innerHTML = ""
    this.outlineTarget.hidden = false
    this.element.classList.remove("is-editing")
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
    this.showThumbnails(input)
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

  // The drawer's thumbnails show the new pick straight from the files. One
  // image replaces the saved thumbnail; several go beside the kept ones.
  showThumbnails(input) {
    if (!input.multiple) {
      const saved = input.closest(".form-item")?.querySelector(".image-field__preview:not([data-uploaded-for])")
      if (saved) saved.style.display = input.files.length ? "none" : ""
    }
    Array.from(input.files).forEach(file => {
      const thumbnail = Object.assign(document.createElement("img"), { className: "image-field__preview", src: URL.createObjectURL(file), alt: "" })
      thumbnail.dataset.uploadedFor = input.id
      input.before(thumbnail)
    })
  }

  directUpload(file, url) {
    return new Promise((resolve, reject) => {
      new DirectUpload(file, url).create((error, blob) => error ? reject(error) : resolve(blob.signed_id))
    })
  }

  async showPreview(form) {
    if (!form.dataset.previewUrl) return // a new Recipe shows on Save

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
      this.updateOutline(form)
      this.hide()
    } else {
      this.drawerTarget.innerHTML = html
    }
  }

  // Deletes the open Section or Recipe: it leaves the page (and the Section
  // list), and the Sections it fed (contents, menu) come back from the server.
  async destroy(event) {
    event.preventDefault()
    const form = event.target
    if (!confirm(form.dataset.deleteConfirm)) return

    // The form's hidden _method field makes this the DELETE it asks for.
    const response = await post(form.action, { body: new FormData(form), responseKind: "html" })
    if (!response.ok) return

    this.find(this.selected)?.remove()
    this.outlineTarget.querySelector(this.selected)?.closest("li")?.remove()
    this.saved = null
    this.replaceSections(await response.html)
    this.hide()
  }

  // From a Recipes Section's Recipe list, in the drawer: deletes the Recipe,
  // then reopens the Section's form so the list shows it gone.
  async destroyRecipe(event) {
    const link = event.currentTarget
    if (!confirm(link.dataset.turboConfirm)) return

    const body = new FormData()
    body.append("_method", "delete")
    const response = await post(link.dataset.deleteUrl, { body, responseKind: "html" })
    if (!response.ok) return

    this.saved = null
    this.replaceSections(await response.html)
    this.open(link.dataset.sectionId)
  }

  // The Section list shows the saved heading.
  updateOutline(form) {
    const heading = form.querySelector('[name="lemon_drop_section[sectionable_attributes][heading]"]')
    const row = this.selected && this.outlineTarget.querySelector(`${this.selected} [data-live-editor-heading]`)
    if (heading && row) row.textContent = heading.value.replace(/\s+/g, " ").trim()
  }

  // Desktop fills the canvas; Phone shows the page at a phone's width.
  setWidth(event) {
    const width = event.currentTarget.dataset.width
    this.canvasTarget.classList.toggle("is-phone", width === "phone")
    this.widthButtonTargets.forEach(button => {
      const active = button.dataset.width === width
      button.classList.toggle("is-active", active)
      button.setAttribute("aria-pressed", active)
    })
  }

  find(key) {
    return this.pageTarget.contentDocument.querySelector(key)
  }

  // Each top-level element the server sent replaces its match on the page.
  replaceSections(html) {
    const template = this.pageTarget.contentDocument.createElement("template")
    template.innerHTML = html
    Array.from(template.content.children).forEach(element => {
      const key = element.dataset.recipeId ? recipeKey(element.dataset.recipeId) : sectionKey(element.dataset.sectionId)
      if (key === this.selected) element.setAttribute("data-selected", "")
      this.find(key)?.replaceWith(element)
    })
  }
}

const sectionKey = id => `[data-section-id="${id}"]`
const recipeKey = id => `[data-recipe-id="${id}"]`
