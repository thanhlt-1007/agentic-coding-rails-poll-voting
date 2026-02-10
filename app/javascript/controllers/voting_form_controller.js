import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit"]

  connect() {
    // Disable submit button on load if no answer is selected
    this.updateSubmitButton()
  }

  updateSubmitButton() {
    const radioButtons = this.element.querySelectorAll('input[type="radio"]')
    const anyChecked = Array.from(radioButtons).some(radio => radio.checked)
    
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !anyChecked
    }
  }
}
