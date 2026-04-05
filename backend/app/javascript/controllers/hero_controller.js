import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.animateOnScroll()
    this.setupIntersectionObserver()
  }

  animateOnScroll() {
    const observerOptions = {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px'
    }

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate-fade-in')
        }
      })
    }, observerOptions)

    // Observe all feature cards
    this.element.querySelectorAll('.feature-card').forEach(card => {
      observer.observe(card)
    })
  }

  setupIntersectionObserver() {
    const statsObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.animateNumbers(entry.target)
        }
      })
    }, { threshold: 0.5 })

    const statsElement = this.element.querySelector('.stats-section')
    if (statsElement) {
      statsObserver.observe(statsElement)
    }
  }

  animateNumbers(element) {
    const counters = element.querySelectorAll('.counter')
    counters.forEach(counter => {
      const target = parseInt(counter.dataset.target)
      const duration = 2000
      const step = target / (duration / 16)
      let current = 0

      const timer = setInterval(() => {
        current += step
        if (current >= target) {
          counter.textContent = target.toLocaleString()
          clearInterval(timer)
        } else {
          counter.textContent = Math.floor(current).toLocaleString()
        }
      }, 16)
    })
  }
}