// RbrunUi::Ui::Menu sidecar — keyboard navigation across menu items.
//
// Items declare themselves with `data-ui-menu-target="item"`. We
// implement the WAI-ARIA roving tabindex pattern: the menu has tabindex
// behavior delegated to one child at a time, and Arrow/Home/End move
// the active index. Enter/Space activate the focused item by clicking
// it (so it works for both <a> links and <button> form items).
//
// Focus resets to the first item every time the menu becomes visible
// in the viewport (IntersectionObserver). This is what makes a menu
// inside a popover always start at the top when the popover opens.
//
// Markup contract (rendered by RbrunUi::Ui::Menu::Component):
//   <div data-controller="ui-menu" data-action="keydown->ui-menu#navigate">
//     <a   data-ui-menu-target="item" tabindex="-1">…</a>
//     <button data-ui-menu-target="item" tabindex="-1">…</button>
//     ...
//   </div>
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body", "item", "search", "static"]
  static values  = { index: Number }

  #observer

  initialize() {
    this.#observer = new IntersectionObserver(this.#onVisible.bind(this))
  }

  connect() {
    this.#observer.observe(this.element)
  }

  disconnect() {
    this.#observer.disconnect()
  }

  navigate(event) {
    if (event.target instanceof HTMLInputElement) {
      switch (event.key) {
        case "ArrowDown":
          this.#cancel(event)
          this.#first()
          break
        case "End":
          this.#cancel(event)
          this.#last()
          break
      }
      return
    }

    switch (event.key) {
      case " ":
      case "Enter":
        this.#cancel(event)
        this.#activate(event.target)
        break
      case "ArrowUp":
        this.#cancel(event)
        this.#prev()
        break
      case "ArrowDown":
        this.#cancel(event)
        this.#next()
        break
      case "Home":
        this.#cancel(event)
        this.#first()
        break
      case "End":
        this.#cancel(event)
        this.#last()
        break
    }
  }

  #cancel(event) {
    event.stopPropagation()
    event.preventDefault()
  }

  #activate(item) {
    item.click()
  }

  filter() {
    const query = this.hasSearchTarget ? this.searchTarget.value.trim().toLowerCase() : ""

    this.itemTargets.forEach(item => {
      const text = item.dataset.uiMenuFilterable || item.textContent.trim().toLowerCase()
      item.hidden = query.length > 0 && !text.includes(query)
    })

    if (this.hasStaticTarget) {
      this.staticTargets.forEach(element => {
        element.hidden = query.length > 0
      })
    }

    this.#first()
  }

  #onVisible([entry]) {
    if (!entry.isIntersecting) return

    if (this.hasSearchTarget) {
      this.searchTarget.focus()
      this.searchTarget.select?.()
    } else {
      this.#first()
    }
  }

  #prev() {
    if (this.indexValue > 0) {
      this.indexValue--
      this.#update()
    }
  }

  #next() {
    if (this.indexValue < this.#lastIndex) {
      this.indexValue++
      this.#update()
    }
  }

  #first() {
    if (this.#visibleItems.length === 0) {
      this.indexValue = -1
      this.#update()
      return
    }

    this.indexValue = 0
    this.#update()
  }

  #last() {
    if (this.#visibleItems.length === 0) {
      this.indexValue = -1
      this.#update()
      return
    }

    this.indexValue = this.#lastIndex
    this.#update()
  }

  #update() {
    const visibleItems = this.#visibleItems

    this.itemTargets.forEach(item => {
      item.tabIndex = -1
    })

    visibleItems.forEach((item, index) => {
      item.tabIndex = index === this.indexValue ? 0 : -1
    })

    visibleItems[this.indexValue]?.focus()
  }

  get #visibleItems() {
    return this.itemTargets.filter(item => !item.hidden)
  }

  get #lastIndex() {
    return this.#visibleItems.length - 1
  }
}
