import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progress"]
  static values = {
    duration: { type: Number, default: 1500 }
  }

  connect() {
    if (this.hasProgressTarget) {
      this.progressTarget.style.animationDuration = `${this.durationValue}ms`
    }

    this.timeout = window.setTimeout(() => {
      this.element.classList.add("is-hiding")
      window.setTimeout(() => this.element.remove(), 220)
    }, this.durationValue)
  }

  disconnect() {
    if (this.timeout) window.clearTimeout(this.timeout)
  }
}
