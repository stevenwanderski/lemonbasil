<template>
  <div>
    <loading v-if="loading"></loading>

    <div v-if="loaded">
      <menu-header
        :menu="menu"
      ></menu-header>

      <menu-nav
        :active-page="activePage"
        :menu-id="menu.id"
      ></menu-nav>

      <div class="menu-body">
        <div v-if="!categories.length" class="empty">
          <div class="empty__text">
            No categories. Add one now!
          </div>

          <div class="empty__control">
            <button class="button button--light">+ Add Category</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import Loading from '../../components/loading';
import MenuHeader from '../../components/menu-header';
import MenuNav from '../../components/menu-nav';

export default {
  components: {
    Loading,
    MenuHeader,
    MenuNav
  },

  data() {
    return {
      categories: null,
      loaded: false,
      loading: true,
      menu: null,
      navOpen: false
    }
  },

  methods: {
    fetchCategories() {
      return axios.get(`/api/client_menus/${this.menuId}/categories`, {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      }).then((response) => {
        this.categories = response.data;
      });
    },

    fetchMenu() {
      return axios.get(`/api/client_menus/${this.menuId}`, {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      }).then((response) => {
        this.menu = response.data;
      });
    },

    toggleNav() {
      this.navOpen = !this.navOpen;
    }
  },

  mounted() {
    Promise.all([
      this.fetchMenu(),
      this.fetchCategories()
    ]).then((results) => {
      this.loading = false;
      this.loaded = true;
    })
  },

  props: [
    'activePage',
    'menuId',
    'token'
  ]
}
</script>
