<template>
  <div>
    <div class="menu-item-category__header">
      <h2>{{category.name}}</h2>

      <button class="button" @click="clickAdd(category)">+ Add Item</button>
    </div>

    <draggable
      @change="saveWeights"
      class="sortable-list"
      handle=".sortable-item__move"
      :list="items"
    >
      <div v-for="item in items" class="sortable-item">
        <div class="sortable-item__move">
          <span></span>
          <span></span>
          <span></span>
        </div>

        <a href="" @click="clickEdit(item, $event)">
          {{item.name}}
        </a>
      </div>
    </draggable>

    <modal v-if="showingModal" :onClose="closeModal">
      <h2>Menu Item</h2>
      <form @submit="checkForm">
        <div class="form-item">
          <label for="name" class="label">Name</label>
          <input type="text" class="input--text" name="name" v-model="name">
        </div>

        <div class="form-item">
          <label for="name" class="label">Description</label>
          <textarea class="input--textarea" name="description" v-model="description"></textarea>
        </div>

        <div class="form-actions">
          <button class="button button--submit">
            Submit
          </button>

          <button @click="clickCancel" class="link">Cancel</button>

          <button @click="clickDelete(model, $event)" class="link link--danger">Delete</button>
        </div>
      </form>
    </modal>
  </div>
</template>

<script>
  import axios from 'axios';
  import draggable from 'vuedraggable'
  import Modal from './modal';

  export default {
    components: {
      draggable,
      Modal
    },

    data() {
      return {
        showingModal: false,
        items: null,
        name: null,
        description: null
      }
    },

    methods: {
      checkForm(event) {
        event.preventDefault();

        if (!this.name || !this.description) {
          alert('Name and Description are required');
          return;
        }

        this.submit();
      },

      clickAdd(category) {
        this.showingModal = true;
      },

      clickCancel() {
        this.name = '';
        this.showingModal = false;
      },

      clickEdit(item, event) {
        event.preventDefault();
        this.model = item;
        this.name = item.name;
        this.description = item.description;
        this.showingModal = true;
      },

      closeModal() {
        this.showingModal = false;
      },

      fetchMenuItems() {
        return axios.get(`/api/client_menu_items`, {
          headers: {
            'Authorization': `Token token=${this.token}`
          },
          params: {
            client_menu_category_id: this.category.id
          }
        }).then((response) => {
          this.items = response.data;
        });
      },

      saveMenuItem() {
        const data = {
          name: this.name,
          description: this.description,
          client_menu_category_id: this.category.id
        };

        const options = {
          headers: {
            'Authorization': `Token token=${this.token}`
          }
        };

        if (this.model) {
          return axios.put(`/api/client_menu_items/${this.model.id}`, data, options);
        }

        return axios.post(`/api/client_menu_items`, data, options);
      },

      saveWeights(event, originalEvent) {
        const weights = this.items.map((item, index) => {
          return [item.id, index];
        });

        const data = {
          weights: weights
        };

        const options = {
          headers: {
            'Authorization': `Token token=${this.token}`
          }
        };

        return axios.post(`/api/client_menu_items/weights`, data, options);
      },

      submit() {
        this.loading = true;
        this.saveMenuItem()
          .then(() => {
            return this.fetchMenuItems(this.activeCategory);
          })
          .then(() => {
            this.closeModal();
            this.loading = false;
            this.name = '';
          });
      }
    },

    mounted() {
      this.fetchMenuItems();
    },

    props: [
      'category',
      'token'
    ]
  }
</script>
