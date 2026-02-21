import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["page", "pagesContainer", "currentPage", "progressBar"]
    static values = { total: Number, current: Number }

    connect() {
        this.setupIntersectionObserver()
        this.updateProgress(1)
    }

    disconnect() {
        if (this.observer) this.observer.disconnect()
    }

    setupIntersectionObserver() {
        const options = {
            root: null,
            rootMargin: "-40% 0px -40% 0px",
            threshold: 0
        }

        this.observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const pageNumber = parseInt(entry.target.dataset.pageNumber)
                    if (pageNumber) {
                        this.updateProgress(pageNumber)
                    }
                }
            })
        }, options)

        this.pageTargets.forEach(page => {
            this.observer.observe(page)
        })
    }

    updateProgress(pageNumber) {
        this.currentValue = pageNumber

        if (this.hasCurrentPageTarget) {
            this.currentPageTarget.textContent = pageNumber
        }

        if (this.hasProgressBarTarget) {
            const percent = Math.min((pageNumber / this.totalValue) * 100, 100)
            this.progressBarTarget.style.width = `${percent}%`
        }
    }

    // Navigate when chapter select changes
    jumpChapter(event) {
        const url = event.target.value
        if (url) {
            window.location.href = url
        }
    }

    onScroll() {
        // handled by intersection observer
    }
}
