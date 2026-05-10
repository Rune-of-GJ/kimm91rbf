import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "name",
    "email",
    "password",
    "categoryId",
    "courseId",
    "lectureId",
    "watched",
    "response"
  ]

  clear() {
    this.responseTarget.textContent = "버튼을 누르면 응답이 여기에 표시됩니다."
  }

  signup() {
    this.request("POST /api/v1/auth/signup", "/api/v1/auth/signup", {
      method: "POST",
      body: {
        name: this.nameTarget.value.trim(),
        email: this.emailTarget.value.trim(),
        password: this.passwordTarget.value
      }
    })
  }

  login() {
    this.request("POST /api/v1/auth/login", "/api/v1/auth/login", {
      method: "POST",
      body: {
        email: this.emailTarget.value.trim(),
        password: this.passwordTarget.value
      }
    })
  }

  refresh() {
    this.request("POST /api/v1/auth/refresh", "/api/v1/auth/refresh", { method: "POST" })
  }

  logout() {
    this.request("POST /api/v1/auth/logout", "/api/v1/auth/logout", { method: "POST" })
  }

  categoriesIndex() {
    this.request("GET /api/v1/categories", "/api/v1/categories")
  }

  categoriesShow() {
    this.request(
      `GET /api/v1/categories/${this.categoryIdTarget.value}`,
      `/api/v1/categories/${this.categoryIdTarget.value}`
    )
  }

  coursesIndex() {
    this.request(
      `GET /api/v1/courses?category_id=${this.categoryIdTarget.value}`,
      `/api/v1/courses?category_id=${this.categoryIdTarget.value}`
    )
  }

  coursesShow() {
    this.request(
      `GET /api/v1/courses/${this.courseIdTarget.value}`,
      `/api/v1/courses/${this.courseIdTarget.value}`
    )
  }

  lecturesIndex() {
    this.request(
      `GET /api/v1/courses/${this.courseIdTarget.value}/lectures`,
      `/api/v1/courses/${this.courseIdTarget.value}/lectures`
    )
  }

  lectureShow() {
    this.request(
      `GET /api/v1/lectures/${this.lectureIdTarget.value}`,
      `/api/v1/lectures/${this.lectureIdTarget.value}`
    )
  }

  progressSave() {
    this.request(
      `POST /api/v1/lectures/${this.lectureIdTarget.value}/progress`,
      `/api/v1/lectures/${this.lectureIdTarget.value}/progress`,
      {
        method: "POST",
        body: {
          watched: this.watchedTarget.value === "true"
        }
      }
    )
  }

  myCourses() {
    this.request("GET /api/v1/users/me/courses", "/api/v1/users/me/courses")
  }

  myProgress() {
    this.request("GET /api/v1/users/me/progress", "/api/v1/users/me/progress")
  }

  async request(label, url, options = {}) {
    const fetchOptions = {
      credentials: "same-origin",
      headers: {
        "X-CSRF-Token": this.csrfToken(),
        Accept: "application/json"
      },
      ...options
    }

    if (options.body) {
      fetchOptions.headers["Content-Type"] = "application/json"
      fetchOptions.body = JSON.stringify(options.body)
    }

    try {
      const response = await fetch(url, fetchOptions)
      const rawBody = await response.text()
      let parsedBody

      try {
        parsedBody = rawBody ? JSON.parse(rawBody) : null
      } catch (_error) {
        parsedBody = rawBody
      }

      this.responseTarget.textContent = JSON.stringify(
        {
          request: label,
          status: response.status,
          ok: response.ok,
          body: parsedBody
        },
        null,
        2
      )
    } catch (error) {
      this.responseTarget.textContent = JSON.stringify(
        {
          request: label,
          ok: false,
          error: error.message
        },
        null,
        2
      )
    }
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }
}
