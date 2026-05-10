import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]
  static values = { initial: String }

  connect() {
    const fallback = this.buttonTargets[0]?.dataset.tabId
    this.activate(this.initialValue || fallback)
  }

  switch(event) {
    event.preventDefault()
    this.activate(event.currentTarget.dataset.tabId)
  }

  activate(id) {
    if (!id) return

    this.buttonTargets.forEach((button) => {
      const active = button.dataset.tabId === id
      button.classList.toggle("is-active", active)
      button.setAttribute("aria-selected", active)
    })

    this.panelTargets.forEach((panel) => {
      panel.hidden = panel.dataset.tabPanel !== id
    })
  }
}
