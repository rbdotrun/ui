// RbrunUi::Ui::Popover sidecar — controller-owned floating panel behavior using
// Floating UI for anchoring. The controller owns visibility, outside
// press dismissal, Escape handling, and focus return; Floating UI fills
// the positioning gap (CSS anchor positioning is not yet broadly
// supported).
//
// Markup contract (rendered by RbrunUi::Ui::Popover::Component):
//   <div data-controller="ui-popover"
//        data-ui-popover-placement-value="bottom-start"
//        data-ui-popover-offset-value="4">
//     <div data-ui-popover-target="trigger" data-action="click->ui-popover#toggle">…</div>
//     <div data-ui-popover-target="content" hidden>…</div>
//   </div>
import { Controller } from "@hotwired/stimulus"
import { computePosition, autoUpdate, offset, flip, shift } from "@floating-ui/dom"

export default class extends Controller {
  static targets = ["trigger", "content", "initialFocus"]
  static values  = {
    placement: { type: String, default: "bottom-start" },
    offset:    { type: Number, default: 4 }
  }

  #cleanup
  #open = false
  #restoreFocusTo = null

  connect() {
    this.#hideContent()
  }

  disconnect() {
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

    this.#open = true
    this.#restoreFocusTo = source
    this.#showContent()
    this.#cleanup = autoUpdate(this.triggerTarget, this.contentTarget, () => this.#position())
    this.#bindGlobalListeners()
    this.#position()
    requestAnimationFrame(() => this.#focusInitialControl())
  }

  close() {
    if (!this.#open) return

    this.#open = false
    this.#unbindGlobalListeners()
    this.#stopTracking()
    this.#hideContent()
    this.#restoreFocus()
  }

  #position() {
    computePosition(this.triggerTarget, this.contentTarget, {
      strategy: "fixed",
      placement: this.placementValue,
      middleware: [
        offset(this.offsetValue),
        flip(),
        shift({ padding: 8 })
      ]
    }).then(({ x, y }) => {
      Object.assign(this.contentTarget.style, {
        top:  `${y}px`,
        left: `${x}px`
      })
    })
  }

  #bindGlobalListeners() {
    document.addEventListener("pointerdown", this.#handlePointerDown, true)
    document.addEventListener("keydown", this.#handleKeyDown, true)
  }

  #unbindGlobalListeners() {
    document.removeEventListener("pointerdown", this.#handlePointerDown, true)
    document.removeEventListener("keydown", this.#handleKeyDown, true)
  }

  #handlePointerDown = (event) => {
    const target = event.target

    if (!(target instanceof Node)) return

    if (this.triggerTarget.contains(target) || this.contentTarget.contains(target)) {
      return
    }

    this.close()
  }

  #handleKeyDown = (event) => {
    if (event.key === "Escape") {
      event.stopPropagation()
      this.close()
    }
  }

  #showContent() {
    this.contentTarget.hidden = false
    this.contentTarget.setAttribute("aria-hidden", "false")
    this.#setExpanded("true")
  }

  #hideContent() {
    this.contentTarget.hidden = true
    this.contentTarget.setAttribute("aria-hidden", "true")
    this.#setExpanded("false")
  }

  #restoreFocus() {
    if (this.#restoreFocusTo instanceof HTMLElement && document.contains(this.#restoreFocusTo)) {
      this.#restoreFocusTo.focus()
    }
    this.#restoreFocusTo = null
  }

  #focusInitialControl() {
    if (!this.#open) return

    if (this.hasInitialFocusTarget) {
      this.initialFocusTarget.focus()
      this.initialFocusTarget.select?.()
      return
    }

    const firstItem = Array.from(this.contentTarget.querySelectorAll('[data-ui-menu-target="item"]'))
      .find(element => !element.hidden)

    if (firstItem instanceof HTMLElement) {
      firstItem.focus()
    }
  }

  #resolveTriggerControl(event) {
    const target = event?.target
    if (target instanceof Element) {
      return target.closest("button, a, [tabindex]") || this.triggerTarget
    }

    if (this.#restoreFocusTo instanceof Element) {
      return this.#restoreFocusTo
    }

    return this.triggerTarget.querySelector("button, a, [tabindex]") || this.triggerTarget
  }

  #setExpanded(value) {
    this.triggerTarget.setAttribute("aria-expanded", value)
    this.#resolveTriggerControl()?.setAttribute("aria-expanded", value)
  }

  #stopTracking() {
    if (this.#cleanup) {
      this.#cleanup()
      this.#cleanup = null
    }
  }
}
