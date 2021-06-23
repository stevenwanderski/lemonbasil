<template>
  <div>
    <loading v-if="loading"></loading>

    <div v-if="loaded">
      <menu-header
        :clients="clients"
        :menu="menu"
        :on-dupe-submit="saveDupe"
        :on-menu-submit="saveMenu"
      ></menu-header>

      <menu-nav
        :active-page="activePage"
        :menu-id="menu.id"
      ></menu-nav>

      <div class="menu-body">
        <div v-if="!categories.length" class="empty">
          <div class="empty__text">
            Please add a category first 🤗
          </div>

          <div class="empty__control">
            <a
              :href="categoriesPath"
              class="button">
              Go to categories page
            </a>
          </div>
        </div>

        <div v-else>
          <menu-item-category
            class="menu-item-category"
            :category="category"
            :data-category-id="category.id"
            :key="category.id"
            :token="token"
            v-for="category in categories"
          ></menu-item-category>
        </div>
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
      categories: null,
      loaded: false,
      loading: true,
    }
  },

  methods: {
    fetchCategories() {
      return axios.get(`/api/client_menu_categories`, {
        headers: {
          'Authorization': `Token token=${this.token}`
        },
        params: {
          client_menu_id: this.menuId
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

    saveDupe(values) {
      const data = {
        client_id: values.clientId,
        due_at: values.dueAt,
        job_date: values.jobDate
      };

      const options = {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      };

      this.loading = true;

      return axios.post(`/api/client_menus/${this.menuId}/duplicate`, data, options)
        .then((response) => {
          window.location.href = `/admin/client_menus/${response.data.id}`
        });
    },

    saveMenu(values) {
      const data = {
        due_at: values.dueAt,
        job_date: values.jobDate,
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
      this.fetchCategories()
    ]).then((results) => {
      this.loading = false;
      this.loaded = true;
    })
  },

  props: [
    'activePage',
    'clients',
    'menuId',
    'token'
  ]
}
</script>
