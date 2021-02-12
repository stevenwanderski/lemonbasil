import Vue from 'vue/dist/vue.esm'
import ClientMenuApp from '../../apps/admin/client-menu-app.vue'

Vue.use(require('vue-moment'));

document.addEventListener('DOMContentLoaded', () => {
  const clientMenuApp = new Vue({
    el: '#client-menu-app',
    components: { ClientMenuApp }
  })
})
