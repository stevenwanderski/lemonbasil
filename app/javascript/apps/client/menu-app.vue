<template>
  <div class="client-menu">
    <header>
      <div class="client-menu__meta" v-if="loaded">
        <div class="client-menu__client-name">
          {{ menu.client_full_name }}
        </div>

        <div class="client-menu__due-at">
          Prep date: {{ menu.job_date | moment('M/D/Y') }}
        </div>

        <div class="client-menu__due-at">
          Submit by: {{ menu.due_at | moment('M/D/Y') }}
        </div>
      </div>

      <a href="/" class="logo">
        Lemon&amp;Basil
      </a>
    </header>

    <div class="content" v-if="loaded">
      <div class="client-menu__categories">
        <client-menu-category
          v-for="section in sections"
          :category="section.category"
          :menu-items="section.items"
          :key="section.category.id"
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
    const initialSelected = [];

    this.sections.forEach((section) => {
      section.items.forEach((item) => {
        if (item.selected) {
          initialSelected.push(item);
        }
      });
    });

    return {
      loaded: false,
      loading: true,
      menu: null,
      selectedItems: initialSelected
    }
  },

  methods: {
    addSelectedItem(item) {
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

      if (!confirm('Are you sure you want to submit your selections?')) {
        return;
      }

      const ids = this.selectedItems.map(item => item.id);

      const data = {
        client_menu_id: this.menuId,
        client_menu_item_ids: ids,
        total: this.totalCost
      };

      const options = {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      };

      this.loading = true;

      return axios.post('/api/client_menu_submissions', data, options)
        .then(() => {
          window.location.href = `${this.menu.slug_url}/success`
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
    ]).then((results) => {
      this.loading = false;
      this.loaded = true;
    })
  },

  props: [
    'sections',
    'menuId',
    'token'
  ]
}
</script>
