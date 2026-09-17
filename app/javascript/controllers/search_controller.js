import { Controller } from "@hotwired/stimulus"

// Debounced auto-submit for live search/filter forms.
export default class extends Controller {
  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.element.requestSubmit(), 250)
  }
}
