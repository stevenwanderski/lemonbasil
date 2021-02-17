<template>
  <div>
    <loading v-if="loading"></loading>

    <div v-if="loaded">
      <menu-header
        :menu="menu"
        :on-menu-submit="saveMenu"
      ></menu-header>

      <menu-nav
        :active-page="activePage"
        :menu-id="menu.id"
      ></menu-nav>

      <div class="menu-body">
        <p>Hi.</p>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import Loading from '../../../components/loading';
import MenuHeader from '../../../components/menu-header';
import MenuItemCategory from '../../../components/menu-item-category';
import MenuNav from '../../../components/menu-nav';

export default {
  components: {
    Loading,
    MenuHeader,
    MenuItemCategory,
    MenuNav
  },

  computed: {
    categoriesPath() {
      return `/admin/client_menus/${this.menuId}/categories`;
    }
  },

  data() {
    return {
      menu: null,
      submission: null,
      loaded: false,
      loading: true,
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

    fetchSubmission() {
      return axios.get(`/api/client_menus/${this.menuId}/submission`, {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      }).then((response) => {
        this.submission = response.data;
      });
    },

    saveMenu(values) {
      const data = {
        due_at: values.dueAt,
        message: values.message
      };

      const options = {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      };

      this.loading = true;

      return axios.put(`/api/client_menus/${this.menuId}`, data, options)
        .then((response) => {
          this.menu = response.data;
          this.loading = false;
        });
    }
  },

  mounted() {
    Promise.all([
      this.fetchMenu(),
      this.fetchSubmission(),
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
