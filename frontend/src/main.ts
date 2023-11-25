import "bulma/css/bulma.css"
import "bulma-helpers/css/bulma-helpers.min.css"
import "font-awesome-animation/css/font-awesome-animation.min.css"

import { library } from "@fortawesome/fontawesome-svg-core"
import {
  faArrowRight,
  faBarcode,
  faCheck,
  faEdit,
  faExclamation,
  faInfoCircle,
  faLightbulb,
  faPlus,
  faSearch,
  faSpinner,
  faTimes
} from "@fortawesome/free-solid-svg-icons"
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome"
import { createApp } from "vue"

import App from "@/App.vue"
import router from "@/router"

library.add(
  faArrowRight,
  faBarcode,
  faCheck,
  faEdit,
  faExclamation,
  faInfoCircle,
  faLightbulb,
  faPlus,
  faSearch,
  faSpinner,
  faTimes
)

const app = createApp(App)

app.component("font-awesome-icon", FontAwesomeIcon)

app.use(router).mount("#app")
