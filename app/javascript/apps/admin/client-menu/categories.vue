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
        <div v-if="!categories.length" class="empty">
          <div class="empty__text">
            No categories. Add one now!
          </div>

          <div class="empty__control">
            <button class="button button--light" @click="clickAdd">+ Add Category</button>
          </div>
        </div>

        <div v-else class="categories-list">
          <draggable
            @change="saveWeights"
            class="sortable-list"
            handle=".sortable-item__move"
            :list="categories"
          >
            <div v-for="category in categories" class="sortable-item">
              <div class="sortable-item__move">
                <span></span>
                <span></span>
                <span></span>
              </div>

              <a href="" @click="clickEdit(category, $event)">
                {{category.name}}
              </a>
            </div>
          </draggable>

          <button class="button button--light" @click="clickAdd">+ Add Category</button>
        </div>
      </div>
    </div>

    <modal v-if="showingModal" :onClose="closeModal">
      <h2>Category</h2>
      <form @submit="checkForm">
        <div class="form-item">
          <label for="name" class="label">Name</label>
          <input type="text" class="input--text" name="name" v-model="name">
        </div>

        <div class="form-item">
          <label for="description" class="label">Description</label>
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
import Loading from '../../../components/loading';
import MenuHeader from '../../../components/menu-header';
import MenuNav from '../../../components/menu-nav';
import Modal from '../../../components/modal';

export default {
  components: {
    draggable,
    Loading,
    MenuHeader,
    MenuNav,
    Modal
  },

  data() {
    return {
      categories: null,
      description: null,
      loaded: false,
      loading: true,
      model: null,
      name: null,
      showingModal: false
    }
  },

  methods: {
    checkForm(event) {
      event.preventDefault();

      if (!this.name) {
        alert('Name is required');
        return;
      }

      this.submit();
    },

    clickAdd() {
      this.name = '';
      this.description = '';
      this.showingModal = true;
    },

    clickCancel() {
      this.name = '';
      this.showingModal = false;
    },

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
      this.description = category.description;
      this.showingModal = true;
    },

    closeModal() {
      this.showingModal = false;
    },

    deleteCategory(category) {
      const options = {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      };

      return axios.delete(`/api/client_menu_categories/${category.id}`, options);
    },

    fetchCategories() {
      return axios.get(`/api/client_menu_categories`, {
        params: {
          client_menu_id: this.menuId
        },
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

    saveCategory() {
      const data = {
        client_menu_id: this.menuId,
        name: this.name,
        description: this.description,
        weight: 0
      };

      const options = {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      };

      if (this.model) {
        return axios.put(`/api/client_menu_categories/${this.model.id}`, data, options);
      }

      return axios.post(`/api/client_menu_categories`, data, options);
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
    },

    saveWeights(event, originalEvent) {
      const weights = this.categories.map((category, index) => {
        return [category.id, index];
      });

      const data = {
        weights: weights
      };

      const options = {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      };

      return axios.post(`/api/client_menu_categories/weights`, data, options);
    },

    submit() {
      this.loading = true;
      this.saveCategory()
        .then(() => {
          return this.fetchCategories();
        })
        .then(() => {
          this.closeModal();
          this.loading = false;
          this.name = '';
          this.description = '';
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
