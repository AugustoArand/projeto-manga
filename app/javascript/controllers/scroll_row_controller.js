import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "prevBtn", "nextBtn"]

  connect() {
    this.updateButtons()
    this.containerTarget.addEventListener("scroll", () => this.updateButtons())
  }

  scrollLeft() {
    this.containerTarget.scrollBy({ left: -320, behavior: "smooth" })
  }

  scrollRight() {
    this.containerTarget.scrollBy({ left: 320, behavior: "smooth" })
  }

  updateButtons() {
    const { scrollLeft, scrollWidth, clientWidth } = this.containerTarget
    const atStart = scrollLeft <= 10
    const atEnd = scrollLeft + clientWidth >= scrollWidth - 10

    if (this.hasPrevBtnTarget) {
      this.prevBtnTarget.style.opacity = atStart ? "0" : "1"
      this.prevBtnTarget.style.pointerEvents = atStart ? "none" : "auto"
    }
    if (this.hasNextBtnTarget) {
      this.nextBtnTarget.style.opacity = atEnd ? "0" : "1"
      this.nextBtnTarget.style.pointerEvents = atEnd ? "none" : "auto"
    }
  }
}
