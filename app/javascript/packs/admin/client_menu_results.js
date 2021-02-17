import Vue from 'vue/dist/vue.esm'
import ClientMenuResultsApp from '../../apps/admin/client-menu/results.vue'

Vue.use(require('vue-moment'));

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#client-menu-results-app',
    components: { ClientMenuResultsApp }
  })
})
