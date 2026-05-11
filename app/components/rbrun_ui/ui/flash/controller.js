import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: Number }

  connect() {
    this.closing = false
    this.remaining = this.durationValue || 4200
    this.#open()
    this.resume()
  }

  disconnect() {
    this.#clearTimer()
    this.#clearFallback()
  }

  pause() {
    if (this.closing || !this.startedAt) return

    this.remaining = Math.max(0, this.remaining - (Date.now() - this.startedAt))
    this.startedAt = null
    this.#clearTimer()
  }

  resume() {
    if (this.closing || this.remaining === Infinity) return

    this.startedAt = Date.now()
    this.#clearTimer()
    this.timeout = window.setTimeout(() => this.close(), this.remaining)
  }

  close() {
    if (this.closing) return

    this.closing = true
    this.element.dataset.state = "closing"
    this.#clearTimer()
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
    this.fallback = window.setTimeout(() => this.element.remove(), 320)
  }

  removeImmediately() {
    this.#clearTimer()
    this.#clearFallback()
    this.element.remove()
  }

  #open() {
    requestAnimationFrame(() => {
      if (!this.closing) this.element.dataset.state = "open"
    })
  }

  #clearTimer() {
    if (this.timeout) window.clearTimeout(this.timeout)
  }

  #clearFallback() {
    if (this.fallback) window.clearTimeout(this.fallback)
  }
}
