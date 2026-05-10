import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["courseSelect", "lectureSelect"]

  connect() {
    this.filterLectures()
  }

  filterLectures() {
    const selectedCourseId = this.courseSelectTarget.value
    const selectedLectureId = this.lectureSelectTarget.value
    let hasVisibleSelected = false

    this.lectureSelectTarget.querySelectorAll("option").forEach((option) => {
      const courseId = option.dataset.courseId

      if (!courseId) {
        option.hidden = false
        return
      }

      const matches = selectedCourseId.length > 0 && courseId === selectedCourseId
      option.hidden = !matches

      if (!matches && option.selected) {
        option.selected = false
      }

      if (matches && option.value === selectedLectureId) {
        hasVisibleSelected = true
      }
    })

    if (!hasVisibleSelected) {
      this.lectureSelectTarget.value = ""
    }

    this.lectureSelectTarget.disabled = selectedCourseId.length === 0
  }
}
