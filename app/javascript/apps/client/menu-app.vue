<template>
  <div class="client-menu">
    <header>
      <div class="client-menu__meta" v-if="loaded">
        <div class="client-menu__client-name">
          {{ menu.client_full_name }}
        </div>

        <div class="client-menu__due-at">
          Submit by: {{ menu.due_at | moment('MMMM D, Y') }}
        </div>
      </div>

      <a href="/" class="logo">
        Lemon&amp;Basil
      </a>
    </header>

    <div class="content" v-if="loaded">
      <p class="client-menu__message">{{ menu.message }}</p>

      <div class="client-menu__categories">
        <client-menu-category
          v-for="category in categories"
          :category="category"
          :key="category.id"
          :on-click-item="clickItem"
          :token="token"
        ></client-menu-category>
      </div>

      <div class="client-menu-actions">
        <div class="client-menu-actions__inner">
          <div>
            <div class="client-menu-actions__total">
              Total Estimate: <strong>${{ totalCost }}</strong>
            </div>

            <div class="client-menu-actions__count">
              Selected items: {{ totalCount }}
            </div>
          </div>

          <button
            class="button button--submit"
            :disabled="isDisabled"
            @click="clickSubmit($event)">
            Submit Order
          </button>
        </div>
      </div>
    </div>

    <loading v-if="loading"></loading>
  </div>
</template>

<script>
import axios from 'axios';
import ClientMenuCategory from '../../components/client/menu-category';
import Loading from '../../components/loading';

export default {
  components: {
    ClientMenuCategory,
    Loading
  },

  computed: {
    isDisabled() {
      return this.selectedItems.length === 0;
    },

    totalCost() {
      return this.selectedItems.reduce((total, item) => {
        return parseInt(total) + parseInt(item.cost);
      }, 0);
    },

    totalCount() {
      return this.selectedItems.length;
    }
  },

  data() {
    return {
      loaded: false,
      loading: true,
      menu: null,
      selectedItems: []
    }
  },

  methods: {
    addSelectedItem(item) {
      console.log('hi!');
      this.selectedItems.push(item);
    },

    clickItem(item, checked) {
      if (checked) {
        this.addSelectedItem(item);
        return;
      }

      this.removeSelectedItem(item);
    },

    clickSubmit(event) {
      event.preventDefault();

      const ids = this.selectedItems.map(item => item.id);

      const data = {
        client_menu_id: this.menuId,
        client_menu_item_ids: ids
      };

      const options = {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      };

      this.loading = true;

      return axios.post('/api/client_menu_submissions', data, options)
        .then(() => {
          this.loading = false;
          console.log('yay');
        });
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
    },

    removeSelectedItem(item) {
      const index = this.selectedItems.indexOf(item);

      this.$delete(this.selectedItems, index);
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
    'menuId',
    'token'
  ]
}
</script>
