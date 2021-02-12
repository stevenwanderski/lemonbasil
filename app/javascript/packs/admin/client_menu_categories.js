import Vue from 'vue/dist/vue.esm'
import ClientMenuCategoriesApp from '../../apps/admin/client-menu/categories.vue'

Vue.use(require('vue-moment'));

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#client-menu-categories-app',
    components: { ClientMenuCategoriesApp }
  })
})
