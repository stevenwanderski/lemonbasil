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
            Please add a category first 🤗
          </div>

          <div class="empty__control">
            <a :href="`/admin/client_menus/${this.menuId}/categories`" class="button">Go to categories page</a>
          </div>
        </div>

        <div v-else>
          <menu-item-category
            class="menu-item-category"
            :category="category"
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
import draggable from 'vuedraggable'
import Loading from '../../components/loading';
import MenuHeader from '../../components/menu-header';
import MenuItemCategory from '../../components/menu-item-category';
import MenuNav from '../../components/menu-nav';

export default {
  components: {
    draggable,
    Loading,
    MenuHeader,
    MenuItemCategory,
    MenuNav
  },

  data() {
    return {
      categories: null,
      loaded: false,
      loading: true,
      model: null,
      name: null,
      description: null,
      showingModal: false
    }
  },

  methods: {
    clickDelete(category, event) {
      event.preventDefault();

      if (!confirm('Are you sure?')) {
        return;
      }

      this.deleteCategory(category)
        .then(() => {
          return this.fetchCategories();
        })
        .then(() => {
          this.closeModal();
          this.loading = false;
          this.name = '';
        });
    },

    clickEdit(category, event) {
      event.preventDefault();
      this.model = category;
      this.name = category.name;
      this.showingModal = true;
    },

    deleteCategory(category) {
      const options = {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      };

      console.log('hi?')

      return axios.delete(`/api/client_menus/${this.menuId}/categories/${category.id}`, options);
    },

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
