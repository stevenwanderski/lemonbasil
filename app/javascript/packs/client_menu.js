import Vue from 'vue/dist/vue.esm'
import ClientMenuApp from '../client-menu-app.vue'

document.addEventListener('DOMContentLoaded', () => {
  const clientMenuApp = new Vue({
    el: '#client-menu-app',
    components: { ClientMenuApp }
  })
})


// If the project is using turbolinks, install 'vue-turbolinks':
//
// yarn add vue-turbolinks
//
// Then uncomment the code block below:
//
// import TurbolinksAdapter from 'vue-turbolinks'
// import Vue from 'vue/dist/vue.esm'
// import App from '../app.vue'
//
// Vue.use(TurbolinksAdapter)
//
// document.addEventListener('turbolinks:load', () => {
//   const app = new Vue({
//     el: '#hello',
//     data: () => {
//       return {
//         message: "Can you say hello?"
//       }
//     },
//     components: { App }
//   })
// })
