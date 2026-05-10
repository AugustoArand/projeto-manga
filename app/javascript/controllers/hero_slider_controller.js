import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "slide", "dots"]
  static values = { interval: { type: Number, default: 6000 } }

  connect() {
    this.currentIndex = 0
    this.totalSlides = this.slideTargets.length
    if (this.totalSlides > 1) {
      this.startAutoPlay()
    }
  }

  disconnect() {
    this.stopAutoPlay()
  }

  next() {
    this.goToIndex((this.currentIndex + 1) % this.totalSlides)
  }

  prev() {
    this.goToIndex((this.currentIndex - 1 + this.totalSlides) % this.totalSlides)
  }

  goTo(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.goToIndex(index)
  }

  goToIndex(index) {
    // Remove active from current
    this.slideTargets[this.currentIndex].classList.remove("active")
    this.dotsTarget.children[this.currentIndex].classList.remove("active")

    // Set new index
    this.currentIndex = index

    // Add active to new
    this.slideTargets[this.currentIndex].classList.add("active")
    this.dotsTarget.children[this.currentIndex].classList.add("active")

    // Reset autoplay timer
    this.restartAutoPlay()
  }

  startAutoPlay() {
    this.timer = setInterval(() => this.next(), this.intervalValue)
  }

  stopAutoPlay() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  restartAutoPlay() {
    this.stopAutoPlay()
    this.startAutoPlay()
  }
}
