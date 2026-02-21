import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "menuIcon", "closeIcon"]

  toggle() {
    const isHidden = this.mobileMenuTarget.classList.contains("hidden")

    if (isHidden) {
      this.mobileMenuTarget.classList.remove("hidden")
      this.menuIconTarget.classList.add("hidden")
      this.closeIconTarget.classList.remove("hidden")
    } else {
      this.mobileMenuTarget.classList.add("hidden")
      this.menuIconTarget.classList.remove("hidden")
      this.closeIconTarget.classList.add("hidden")
    }
  }

  // Close menu when clicking outside
  connect() {
    this.handleOutsideClick = (event) => {
      if (!this.element.contains(event.target)) {
        this.close()
      }
    }
    document.addEventListener("click", this.handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
  }

  close() {
    if (!this.mobileMenuTarget.classList.contains("hidden")) {
      this.mobileMenuTarget.classList.add("hidden")
      this.menuIconTarget.classList.remove("hidden")
      this.closeIconTarget.classList.add("hidden")
    }
  }
}
