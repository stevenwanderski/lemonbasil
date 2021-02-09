import Vue from 'vue/dist/vue.esm'
import ClientMenuItemsApp from '../apps/client-menu/items.vue'

Vue.use(require('vue-moment'));

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#client-menu-items-app',
    components: { ClientMenuItemsApp }
  })
})
