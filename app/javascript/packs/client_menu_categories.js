import Vue from 'vue/dist/vue.esm'
import ClientMenuCategoriesApp from '../apps/client-menu/categories.vue'

Vue.use(require('vue-moment'));

document.addEventListener('DOMContentLoaded', () => {
  const clientMenuCategoryApp = new Vue({
    el: '#client-menu-categories-app',
    components: { ClientMenuCategoriesApp }
  })
})
