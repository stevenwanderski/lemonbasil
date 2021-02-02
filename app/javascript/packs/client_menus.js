import Vue from 'vue/dist/vue.esm'
import ClientMenusApp from '../client-menus-app.vue'

document.addEventListener('DOMContentLoaded', () => {
  const clientMenusApp = new Vue({
    el: '#client-menus-app',
    components: { ClientMenusApp }
  })
})
