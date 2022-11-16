import { Controller } from "@hotwired/stimulus"
import { post } from '@rails/request.js'

export default class extends Controller {
  static values = { url: String }

  async toggle() {
    const formData = new FormData(this.element);

    await post(this.urlValue, {
      body: formData,
      responseKind: 'turbo-stream'
    });
  }
}
