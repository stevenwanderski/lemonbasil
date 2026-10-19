import { Controller } from "@hotwired/stimulus"
import { Editor } from "@tiptap/core"
import Document from "@tiptap/extension-document"
import Paragraph from "@tiptap/extension-paragraph"
import Text from "@tiptap/extension-text"
import HardBreak from "@tiptap/extension-hard-break"
import Bold from "@tiptap/extension-bold"
import Italic from "@tiptap/extension-italic"
import Link from "@tiptap/extension-link"
import { BulletList, OrderedList, ListItem } from "@tiptap/extension-list"
import { UndoRedo } from "@tiptap/extensions"

// A Tiptap editor for Intro and Outro bodies (ADR 0004). It knows only
// paragraphs, bold, italic, links and lists, so anything else pasted in
// (headings, images, colours) is dropped. Its HTML goes into the hidden
// input the form submits; the server sanitizes it again on save.
export default class extends Controller {
  static targets = ["editor", "input", "button", "linkForm", "linkInput"]

  connect() {
    this.editor = new Editor({
      element: this.editorTarget,
      extensions: [
        Document, Paragraph, Text, HardBreak, Bold, Italic, BulletList, OrderedList, ListItem, UndoRedo,
        Link.configure({ openOnClick: false, autolink: false, protocols: ["mailto"], HTMLAttributes: { rel: null, target: null } })
      ],
      content: this.inputTarget.value,
      onUpdate: () => this.save(),
      onTransaction: () => this.refreshButtons()
    })
    this.refreshButtons()
  }

  disconnect() {
    this.editor.destroy()
  }

  toggleBold() {
    this.editor.chain().focus().toggleBold().run()
  }

  toggleItalic() {
    this.editor.chain().focus().toggleItalic().run()
  }

  toggleBulletList() {
    this.editor.chain().focus().toggleBulletList().run()
  }

  toggleOrderedList() {
    this.editor.chain().focus().toggleOrderedList().run()
  }

  showLink() {
    this.linkFormTarget.hidden = false
    this.linkInputTarget.value = this.editor.getAttributes("link").href || ""
    this.linkInputTarget.focus()
  }

  hideLink() {
    this.linkFormTarget.hidden = true
    this.editor.commands.focus()
  }

  applyLink() {
    const href = this.linkInputTarget.value.trim()
    const chain = this.editor.chain().focus().extendMarkRange("link")
    href ? chain.setLink({ href }).run() : chain.unsetLink().run()
    this.linkFormTarget.hidden = true
  }

  removeLink() {
    this.editor.chain().focus().extendMarkRange("link").unsetLink().run()
    this.linkFormTarget.hidden = true
  }

  save() {
    this.inputTarget.value = this.editor.isEmpty ? "" : this.editor.getHTML()
  }

  refreshButtons() {
    this.buttonTargets.forEach(button => {
      button.classList.toggle("is-active", this.editor.isActive(button.dataset.activeName))
    })
  }
}
