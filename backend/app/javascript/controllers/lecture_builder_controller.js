import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rows", "template"]

  connect() {
    this.renumber()
  }

  addRow(event) {
    event.preventDefault()
    this.rowsTarget.insertAdjacentHTML("beforeend", this.templateTarget.innerHTML.trim())
    this.renumber()
  }

  removeRow(event) {
    event.preventDefault()
    const row = event.currentTarget.closest("[data-lecture-builder-row]")
    if (!row) return

    const rows = this.rowsTarget.querySelectorAll("[data-lecture-builder-row]")
    if (rows.length === 1) {
      row.querySelectorAll("input").forEach((input) => {
        input.value = ""
      })
    } else {
      row.remove()
    }

    this.renumber()
  }

  renumber() {
    this.rowsTarget.querySelectorAll("[data-lecture-builder-row]").forEach((row, index) => {
      const badge = row.querySelector("[data-lecture-builder-index]")
      if (badge) badge.textContent = `강의편 ${index + 1}`
    })
  }
}
