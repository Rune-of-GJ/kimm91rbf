import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "image", "empty"]

  preview() {
    const file = this.inputTarget.files?.[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = () => {
      this.imageTarget.src = reader.result
      this.imageTarget.hidden = false
      if (this.hasEmptyTarget) this.emptyTarget.hidden = true
    }
    reader.readAsDataURL(file)
  }
}
