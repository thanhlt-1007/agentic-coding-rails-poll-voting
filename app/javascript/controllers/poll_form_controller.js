import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["choicesContainer", "choiceField"]

  addChoice(event) {
    event.preventDefault()
    
    const timestamp = new Date().getTime()
    const newChoiceHtml = `
      <div class="flex gap-2 mb-3" data-poll-form-target="choiceField">
        <input type="text" name="poll[choices_attributes][${timestamp}][text]" class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" placeholder="Enter choice" />
        <input type="hidden" name="poll[choices_attributes][${timestamp}][position]" value="${this.choiceFieldTargets.length + 1}" />
        <button type="button" data-action="click->poll-form#removeChoice" class="px-4 py-2 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 transition">Remove</button>
      </div>
    `
    
    this.choicesContainerTarget.insertAdjacentHTML('beforeend', newChoiceHtml)
  }

  removeChoice(event) {
    event.preventDefault()
    
    const choiceField = event.target.closest('[data-poll-form-target="choiceField"]')
    const destroyInput = choiceField.querySelector('input[name*="_destroy"]')
    
    if (destroyInput) {
      // Existing record - mark for destruction
      destroyInput.value = "1"
      choiceField.style.display = "none"
    } else {
      // New record - just remove from DOM
      choiceField.remove()
    }
  }
}
