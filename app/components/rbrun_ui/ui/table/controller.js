import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame", "checkbox", "toggleAll", "batchDock", "batchBar", "selectedCount"]

  connect() {
    this.#syncBatchPosition()
    this.#updateSelectionState()
    window.addEventListener("resize", this.#syncBatchPosition)
    window.addEventListener("scroll", this.#syncBatchPosition, true)
  }

  disconnect() {
    window.removeEventListener("resize", this.#syncBatchPosition)
    window.removeEventListener("scroll", this.#syncBatchPosition, true)
  }

  toggleAll() {
    if (!this.hasToggleAllTarget) return

    const checked = this.toggleAllTarget.checked
    this.checkboxTargets.forEach(checkbox => {
      if (!checkbox.disabled) checkbox.checked = checked
    })

    this.#updateSelectionState()
  }

  selectionChanged() {
    this.#updateSelectionState()
  }

  #updateSelectionState() {
    const selectable = this.checkboxTargets.filter(checkbox => !checkbox.disabled)
    const selected = selectable.filter(checkbox => checkbox.checked)

    if (this.hasToggleAllTarget) {
      this.toggleAllTarget.checked = selectable.length > 0 && selected.length === selectable.length
      this.toggleAllTarget.indeterminate = selected.length > 0 && selected.length < selectable.length
    }

    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = String(selected.length)
    }

    if (this.hasBatchDockTarget) {
      const active = selected.length > 0
      this.batchDockTarget.classList.toggle("hidden", !active)
      this.batchDockTarget.setAttribute("aria-hidden", active ? "false" : "true")
      if (active) this.#syncBatchPosition()
    }
  }

  #syncBatchPosition = () => {
    if (!this.hasBatchDockTarget || !this.hasFrameTarget) return

    const rect = this.frameTarget.getBoundingClientRect()

    this.batchDockTarget.style.left = `${rect.left}px`
    this.batchDockTarget.style.width = `${rect.width}px`
  }
}
