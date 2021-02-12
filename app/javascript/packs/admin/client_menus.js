import Vue from 'vue/dist/vue.esm'
import ClientMenusApp from '../../apps/admin/client-menus-app.vue'

Vue.use(require('vue-moment'));

document.addEventListener('DOMContentLoaded', () => {
  const clientMenusApp = new Vue({
    el: '#client-menus-app',
    components: { ClientMenusApp }
  })
})
