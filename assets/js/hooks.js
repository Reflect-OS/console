let Hooks = {}

Hooks.HideFlash = {
    mounted() {
        setTimeout(() => {
            this.pushEvent("lv:clear-flash", { key: this.el.dataset.key })
        }, 3000)
    }
}

export default Hooks