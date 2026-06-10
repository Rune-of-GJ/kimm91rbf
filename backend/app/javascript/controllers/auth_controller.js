import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loginHeader", "signupHeader", "loginPanel", "signupPanel", "status", "submit"]
  static values = {
    initialMode: String,
    loginUrl: String,
    signupUrl: String,
    returnTo: { type: String, default: "/" }
  }

  connect() {
    this.show(this.initialModeValue === "signup" ? "signup" : "login")
  }

  showLogin(event) {
    event?.preventDefault()
    this.show("login")
  }

  showSignup(event) {
    event?.preventDefault()
    this.show("signup")
  }

  async submit(event) {
    event.preventDefault()

    const form = event.target
    if (!form.reportValidity()) return

    const mode = form.dataset.mode
    const url = mode === "signup" ? this.signupUrlValue : this.loginUrlValue
    const data = Object.fromEntries(new FormData(form).entries())

    Object.keys(data).forEach((key) => {
      if (typeof data[key] === "string") data[key] = data[key].trim()
    })

    this.setBusy(true)
    this.renderStatus("", "")

    try {
      const response = await fetch(url, {
        method: "POST",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          "Accept": "application/json"
        },
        body: JSON.stringify(data)
      })

      if (response.ok) {
        window.location.href = this.returnToValue || "/"
        return
      }

      const body = await response.json().catch(() => ({}))
      const message = body.error || body.errors?.join(", ") || "요청을 처리하지 못했어요."
      this.renderStatus(message, "is-error")
    } catch (_error) {
      this.renderStatus("네트워크 오류가 발생했어요. 잠시 후 다시 시도해 주세요.", "is-error")
    } finally {
      this.setBusy(false)
    }
  }

  show(mode) {
    if (this.hasLoginHeaderTarget) this.loginHeaderTarget.hidden = mode !== "login"
    if (this.hasSignupHeaderTarget) this.signupHeaderTarget.hidden = mode !== "signup"
    if (this.hasLoginPanelTarget) this.loginPanelTarget.hidden = mode !== "login"
    if (this.hasSignupPanelTarget) this.signupPanelTarget.hidden = mode !== "signup"
    this.renderStatus("", "")
  }

  setBusy(busy) {
    this.submitTargets.forEach((button) => {
      button.disabled = busy
      if (busy) {
        button.dataset.originalText = button.textContent
        button.textContent = "처리 중..."
      } else if (button.dataset.originalText) {
        button.textContent = button.dataset.originalText
        delete button.dataset.originalText
      }
    })
  }

  renderStatus(message, klass) {
    if (!this.hasStatusTarget) return

    this.statusTarget.textContent = message
    this.statusTarget.className = ["status-banner", klass].filter(Boolean).join(" ")
    this.statusTarget.hidden = message.length === 0
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }
}
