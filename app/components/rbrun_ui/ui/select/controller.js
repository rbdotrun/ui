// RbrunUi::Ui::Select sidecar — form integration on top of RbrunUi::Ui::Popover + RbrunUi::Ui::Menu.
//
// Supports single-select and multi-select modes. Search/filtering and
// list keyboard navigation come from `ui-menu`; this controller owns
// value state, trigger label updates, hidden input syncing, and
// single-select close behavior.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "inputs", "trigger", "label", "option"]
  static values  = {
    inputName: String,
    multiple: Boolean,
    placeholder: String
  }

  choose(event) {
    const optionEl = event.currentTarget

    if (this.multipleValue) {
      this.#toggleOption(optionEl)
      this.#syncMultipleInputs()
      this.#updateTriggerLabel()
      this.#dispatchChange(this.inputsTarget)
      return
    }

    this.#selectSingleOption(optionEl)
    this.#dispatchChange(this.inputTarget)
    this.element.dispatchEvent(new CustomEvent("ui-popover:close", { bubbles: true }))
  }

  #selectSingleOption(optionEl) {
    const value = optionEl.dataset.value

    this.inputTarget.value = value
    this.labelTarget.textContent = optionEl.dataset.label
    this.labelTarget.classList.remove("text-stone-500")

    this.optionTargets.forEach(el => {
      const selected = el === optionEl
      this.#setOptionState(el, selected)
    })
  }

  #toggleOption(optionEl) {
    const selected = optionEl.getAttribute("aria-selected") !== "true"
    this.#setOptionState(optionEl, selected)
  }

  #setOptionState(optionEl, selected) {
    optionEl.setAttribute("aria-selected", selected)
    optionEl.classList.toggle("bg-secondary", selected)
    optionEl.classList.toggle("text-stone-900", selected)

    const icon = optionEl.querySelector('[data-ui-select-indicator]')
    if (icon) {
      icon.classList.toggle("opacity-100", selected)
      icon.classList.toggle("opacity-0", !selected)
    }
  }

  #syncMultipleInputs() {
    const selectedValues = this.#selectedOptions.map(option => option.dataset.value)

    const inputs = selectedValues.map(value => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = this.#multipleInputName
      input.value = value
      return input
    })

    this.inputsTarget.replaceChildren(...inputs)
  }

  #updateTriggerLabel() {
    const selectedOptions = this.#selectedOptions

    if (selectedOptions.length === 0) {
      this.labelTarget.textContent = this.placeholderValue
      this.labelTarget.classList.add("text-stone-500")
      return
    }

    const labels = selectedOptions.map(option => option.dataset.label)
    const text = labels.length <= 2 ? labels.join(", ") : `${labels.length} selected`

    this.labelTarget.textContent = text
    this.labelTarget.classList.remove("text-stone-500")
  }

  #dispatchChange(target) {
    target.dispatchEvent(new Event("change", { bubbles: true }))
  }

  get #selectedOptions() {
    return this.optionTargets.filter(option => option.getAttribute("aria-selected") === "true")
  }

  get #multipleInputName() {
    const existingInput = this.inputsTarget.querySelector('input[type="hidden"]')
    return existingInput?.name || this.inputNameValue
  }
}
