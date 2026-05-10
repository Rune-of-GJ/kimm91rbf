import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "notes",
    "status",
    "audio",
    "recordButton",
    "stopButton",
    "playButton",
    "downloadButton",
    "watchButton"
  ]

  static values = {
    lectureId: Number,
    progressUrl: String
  }

  connect() {
    this.audioBlob = null
    this.audioUrl = null
    this.mediaRecorder = null
    this.audioChunks = []
    this.noteStorageKey = `lecture-${this.lectureIdValue}-notes`
    this.loadNotes()
  }

  disconnect() {
    if (this.audioUrl) URL.revokeObjectURL(this.audioUrl)
  }

  saveNotes() {
    localStorage.setItem(this.noteStorageKey, this.notesTarget.value)
    this.renderStatus("메모를 저장했어요.", "is-success")
  }

  clearNotes() {
    this.notesTarget.value = ""
    localStorage.removeItem(this.noteStorageKey)
    this.renderStatus("메모를 비웠어요.", "")
  }

  async startRecording() {
    if (!navigator.mediaDevices?.getUserMedia) {
      this.renderStatus("이 브라우저에서는 녹음 기능을 지원하지 않아요.", "is-error")
      return
    }

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      this.audioChunks = []
      this.mediaRecorder = new MediaRecorder(stream)

      this.mediaRecorder.ondataavailable = (event) => {
        this.audioChunks.push(event.data)
      }

      this.mediaRecorder.onstop = () => {
        this.audioBlob = new Blob(this.audioChunks, { type: "audio/webm" })
        if (this.audioUrl) URL.revokeObjectURL(this.audioUrl)
        this.audioUrl = URL.createObjectURL(this.audioBlob)
        this.audioTarget.src = this.audioUrl
        this.audioTarget.hidden = false
        this.playButtonTarget.disabled = false
        this.downloadButtonTarget.disabled = false
      }

      this.mediaRecorder.start()
      this.recordButtonTarget.disabled = true
      this.stopButtonTarget.disabled = false
      this.renderStatus("녹음을 시작했어요. 말하기 흐름을 천천히 확인해 보세요.", "")
    } catch (_error) {
      this.renderStatus("마이크 권한이 필요해요.", "is-error")
    }
  }

  stopRecording() {
    if (!this.mediaRecorder || this.mediaRecorder.state !== "recording") return

    this.mediaRecorder.stop()
    this.mediaRecorder.stream.getTracks().forEach((track) => track.stop())
    this.recordButtonTarget.disabled = false
    this.stopButtonTarget.disabled = true
    this.renderStatus("녹음을 마쳤어요. 바로 들어보거나 내려받을 수 있어요.", "is-success")
  }

  playRecording() {
    if (!this.audioTarget.src) return

    this.audioTarget.play()
  }

  downloadRecording() {
    if (!this.audioBlob) return

    const link = document.createElement("a")
    link.href = this.audioUrl
    link.download = `speaking-practice-${this.lectureIdValue}.webm`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  async markWatched() {
    if (!this.progressUrlValue) return

    try {
      const response = await fetch(this.progressUrlValue, {
        method: "POST",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          "Accept": "application/json"
        },
        body: JSON.stringify({ watched: true })
      })

      if (!response.ok) throw new Error("failed")

      if (this.hasWatchButtonTarget) {
        this.watchButtonTarget.textContent = "시청 완료됨"
        this.watchButtonTarget.disabled = true
      }

      const row = document.querySelector(`[data-lecture-row-id="${this.lectureIdValue}"]`)
      const badge = document.querySelector(`[data-lecture-badge-id="${this.lectureIdValue}"]`)

      row?.classList.add("is-complete")
      badge?.classList.add("is-complete")
      this.renderStatus("현재 강의를 시청 완료로 표시했어요.", "is-success")
    } catch (_error) {
      this.renderStatus("시청 완료 상태를 저장하지 못했어요.", "is-error")
    }
  }

  loadNotes() {
    this.notesTarget.value = localStorage.getItem(this.noteStorageKey) || ""
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
