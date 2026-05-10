// Shared base controller for dialog + drawer. Both extend this; only
// difference is the panel's transition class composition (slide-in
// from right vs. fade-in centered) which the components themselves
// emit on the markup. The behavior — open/close lifecycle, body-scroll
// lock, Esc handling, focus restore — is identical, so it lives here
// once and the two sidecars subclass.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "backdrop", "panel", "initialFocus"]
  static values = {
    duration: { type: Number, default: 200 }
  }

  #open = false
  #restoreFocusTo = null
  #previousBodyOverflow = null
  #hideTimer = null

  connect() {
    this.#hide()
  }

  disconnect() {
    this.#clearHideTimer()
    this.close()
  }

  toggle(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    if (this.#open) {
      this.close()
    } else {
      this.open(this.#resolveTriggerControl(event))
    }
  }

  open(source = this.triggerTarget) {
    if (this.#open) return

    this.#clearHideTimer()
    this.#open = true
    this.#restoreFocusTo = source
    this.#showForAnimation()
    document.addEventListener("keydown", this.#handleKeyDown, true)
    requestAnimationFrame(() => {
      this.#setState("open")
      this.#focusInitialControl()
    })
  }

  close() {
    if (!this.#open) return

    this.#open = false
    document.removeEventListener("keydown", this.#handleKeyDown, true)
    this.#setState("closed")
    this.#hideTimer = window.setTimeout(() => {
      this.#hide()
      this.#restoreFocus()
    }, this.durationValue)
  }

  backdropPointerDown(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  #handleKeyDown = (event) => {
    if (event.key === "Escape") {
      event.stopPropagation()
      this.close()
    }
  }

  #showForAnimation() {
    this.#lockBodyScroll()
    this.backdropTarget.hidden = false
    this.backdropTarget.setAttribute("aria-hidden", "false")
    this.backdropTarget.dataset.state = "closed"
    this.panelTarget.dataset.state = "closed"
    this.#setExpanded("true")
  }

  #hide() {
    this.#clearHideTimer()
    this.#unlockBodyScroll()
    this.backdropTarget.hidden = true
    this.backdropTarget.setAttribute("aria-hidden", "true")
    this.backdropTarget.dataset.state = "closed"
    this.panelTarget.dataset.state = "closed"
    this.#setExpanded("false")
  }

  #focusInitialControl() {
    if (!this.#open) return

    if (this.hasInitialFocusTarget) {
      this.initialFocusTarget.focus()
      this.initialFocusTarget.select?.()
      return
    }

    const firstFocusable = this.panelTarget.querySelector(
      'button:not([disabled]), [href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
    )

    if (firstFocusable instanceof HTMLElement) {
      firstFocusable.focus()
      return
    }

    this.panelTarget.focus()
  }

  #restoreFocus() {
    if (this.#restoreFocusTo instanceof HTMLElement && document.contains(this.#restoreFocusTo)) {
      this.#restoreFocusTo.focus()
    }
    this.#restoreFocusTo = null
  }

  #resolveTriggerControl(event) {
    const target = event?.target

    if (target instanceof Element) {
      return target.closest("button, a, [tabindex]") || this.triggerTarget
    }

    return this.triggerTarget.querySelector("button, a, [tabindex]") || this.triggerTarget
  }

  #setExpanded(value) {
    this.triggerTarget.setAttribute("aria-expanded", value)
    this.#resolveTriggerControl()?.setAttribute("aria-expanded", value)
  }

  #setState(value) {
    this.backdropTarget.dataset.state = value
    this.panelTarget.dataset.state = value
  }

  #lockBodyScroll() {
    if (this.#previousBodyOverflow !== null) return

    this.#previousBodyOverflow = document.body.style.overflow
    document.body.style.overflow = "hidden"
  }

  #unlockBodyScroll() {
    if (this.#previousBodyOverflow === null) return

    document.body.style.overflow = this.#previousBodyOverflow
    this.#previousBodyOverflow = null
  }

  #clearHideTimer() {
    if (this.#hideTimer === null) return

    window.clearTimeout(this.#hideTimer)
    this.#hideTimer = null
  }
}
