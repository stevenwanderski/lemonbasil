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
      <div v-for="item in items" class="sortable-item menu-item">
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
          <label for="name" class="label" ref="name">Name</label>
          <input type="text" class="input--text" name="name" v-model="name">
        </div>

        <div class="form-item">
          <label for="description" class="label">Description</label>
          <textarea
            class="input--textarea"
            name="description"
            v-model="description"
          ></textarea>
        </div>

        <div class="form-item--flex">
          <div class="form-item">
            <label for="cost" class="label">Cost</label>
            <input type="text" class="input--text" name="cost" v-model="cost">
          </div>

          <div class="form-item">
            <label for="quantity" class="label">Quantity</label>
            <input type="text" class="input--text" name="quantity" v-model="quantity">
          </div>
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
        description: null,
        cost: null,
        quantity: null
      }
    },

    methods: {
      checkForm(event) {
        event.preventDefault();

        if (!this.name || !this.cost) {
          alert('Name and Cost are required');
          return;
        }

        this.submit();
      },

      clickAdd(category) {
        this.model = null;
        this.name = null;
        this.description = null;
        this.cost = null;
        this.quantity = null;
        this.openModal();
      },

      clickCancel() {
        this.closeModal();
      },

      clickDelete(item, event) {
        event.preventDefault();

        if (!confirm('Are you sure?')) {
          return;
        }

        this.deleteMenuItem(item)
          .then(() => {
            return this.fetchMenuItems();
          })
          .then(() => {
            this.closeModal();
            this.loading = false;
          });
      },

      clickEdit(item, event) {
        event.preventDefault();

        this.model = item;
        this.name = item.name;
        this.description = item.description;
        this.cost = item.cost;
        this.quantity = item.quantity;
        this.openModal();
      },

      closeModal() {
        this.showingModal = false;
      },

      deleteMenuItem(item) {
        const options = {
          headers: {
            'Authorization': `Token token=${this.token}`
          }
        };

        return axios.delete(`/api/client_menu_items/${item.id}`, options);
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
      },

      openModal() {
        this.showingModal = true;
      },

      saveMenuItem() {
        const data = {
          name: this.name,
          description: this.description,
          cost: this.cost,
          quantity: this.quantity,
          weight: 0,
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
