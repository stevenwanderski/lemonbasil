<template>
  <div>
    <loading v-if="loading"></loading>

    <div v-if="loaded">
      <div class="menu-header">
        <div class="menu-header__name">
          {{menu.client_full_name}}
        </div>

        <div class="menu-header__date">
          {{menu.due_at | moment('MMMM D, Y')}}
        </div>

        <div class="menu-header__nav hamburger-nav">
          <button class="hamburger-nav__control" @click="toggleNav">
            <span></span>
            <span></span>
            <span></span>
          </button>

          <div class="hamburger-nav__body" v-if="navOpen">
            <a :href="menu.url">Menu</a>
            <a href="">Results</a>
            <a href="">Edit</a>
            <a href="">Copy</a>
          </div>
        </div>
      </div>

      <div class="menu-nav">
        <div class="menu-nav__section">
          <a
            :class="activePage == 'categories' ? 'active' : null"
            :href="`/admin/client_menus/${menu.id}/categories`">
            Categories
          </a>

          <a
            :class="activePage == 'menu_items' ? 'active' : null"
            :href="`/admin/client_menus/${menu.id}/menu_items`">
            Menu Items
          </a>
        </div>

        <div class="menu-nav__section">
          <a
            :class="activePage == 'results' ? 'active' : null"
            :href="`/admin/client_menus/${menu.id}/results`">
            Results
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import Loading from '../../components/loading';

export default {
  components: {
    Loading
  },

  data() {
    return {
      loaded: false,
      loading: true,
      menu: null,
      navOpen: false
    }
  },

  methods: {
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
    this.fetchMenu().then(() => {
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
