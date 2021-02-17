<template>
  <div class="client-menu__category-section">
    <div class="client-menu__category">
      <h2 class="client-menu__category-name">
        {{ category.name }}
      </h2>

      <div class="client-menu__category-description" v-if="category.description">
        {{ category.description }}
      </div>
    </div>

    <div v-for="item in items" class="client-menu-item">
      <input
        :id="`item-${item.id}`"
        type="checkbox"
        @change="clickItem(item, $event)">

      <div class="client-menu-item__section">
        <div class="client-menu-item__row">
          <label
            class="client-menu-item__label"
            :for="`item-${item.id}`">
            {{ item.name }}
          </label>

          <div class="client-menu-item__cost">
            ${{ item.cost }}
          </div>
        </div>

        <div class="client-menu-item__row">
          <div class="client-menu-item__description" v-if="item.description">
            {{ item.description }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios';

  export default {
    data() {
      return {
        items: null
      }
    },

    methods: {
      clickItem(item, event) {
        this.onClickItem(item, event.target.checked);
      },

      fetchMenuItems() {
        const options = {
          headers: {
            'Authorization': `Token token=${this.token}`
          },
          params: {
            client_menu_category_id: this.category.id
          }
        }

        return axios.get(`/api/client_menu_items`, options)
          .then((response) => {
            this.items = response.data;
          });
      }
    },

    mounted() {
      this.fetchMenuItems();
    },

    props: [
      'category',
      'onClickItem',
      'token'
    ]
  }
</script>
