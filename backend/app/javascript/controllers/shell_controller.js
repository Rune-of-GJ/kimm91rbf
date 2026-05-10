import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nav", "panel", "overlay"]
  static values = { logoutUrl: String }

  connect() {
    this.boundEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.boundEscape)
    this.syncOverlay()
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundEscape)
  }

  toggleNav() {
    if (!this.hasNavTarget) return

    this.navTarget.classList.toggle("is-open")
    if (this.hasPanelTarget) this.panelTarget.classList.remove("is-open")
    this.syncOverlay()
  }

  togglePanel() {
    if (!this.hasPanelTarget) return

    this.panelTarget.classList.toggle("is-open")
    if (this.hasNavTarget) this.navTarget.classList.remove("is-open")
    this.syncOverlay()
  }

  closePanel() {
    if (!this.hasPanelTarget) return

    this.panelTarget.classList.remove("is-open")
    this.syncOverlay()
  }

  closeAll() {
    if (this.hasNavTarget) this.navTarget.classList.remove("is-open")
    if (this.hasPanelTarget) this.panelTarget.classList.remove("is-open")
    this.syncOverlay()
  }

  async logout(event) {
    event.preventDefault()

    try {
      await fetch(this.logoutUrlValue, {
        method: "POST",
        credentials: "same-origin",
        headers: {
          "X-CSRF-Token": this.csrfToken(),
          "Accept": "application/json"
        }
      })
    } finally {
      window.location.href = "/"
    }
  }

  handleEscape(event) {
    if (event.key === "Escape") this.closeAll()
  }

  syncOverlay() {
    if (!this.hasOverlayTarget) return

    const visible =
      (this.hasNavTarget && this.navTarget.classList.contains("is-open")) ||
      (this.hasPanelTarget && this.panelTarget.classList.contains("is-open"))

    this.overlayTarget.classList.toggle("is-visible", visible)
    document.documentElement.classList.toggle("is-locked", visible)
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }
}
