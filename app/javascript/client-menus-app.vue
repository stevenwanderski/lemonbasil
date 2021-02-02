<template>
  <div>
    <modal v-if="showingModal" :onClose="closeModal">
      <form @submit="submit">
        <div class="form-item">
          <label for="client">Client</label>
          <select name="client" v-model="client">
            <option v-for="client in clients" v-bind:value="client.id">
              {{client.full_name}}
            </option>
          </select>
        </div>

        <button class="button">
          Submit
        </button>
      </form>
    </modal>

    <div class="admin-header">
      <h1>Client Menus</h1>
      <button class="button" @click="clickAdd">
        Add Client Menu
      </button>
    </div>

    <div class="rows" v-for="menu in menus">
      <div class="row">
        <div class="row__name">
          <a :href="menu.url">
            {{menu.client_full_name}}
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import Modal from './components/modal';

export default {
  data() {
    return {
      client: this.clients[0].id,
      menus: [],
      showingModal: false
    }
  },

  methods: {
    clickAdd() {
      this.showingModal = !this.showingModal;
    },

    closeModal() {
      this.showingModal = false;
    },

    fetchMenus() {
      return axios.get('/api/client_menus', {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      }).then((response) => {
        this.menus = response.data;
      });
    },

    saveMenu() {
      const data = {
        client_id: this.client
      };

      const options = {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      };

      return axios.post('/api/client_menus', data, options)
        .then((response) => {
          console.log(response);
        });
    },

    submit(event) {
      event.preventDefault();

      this.saveMenu()
        .then(() => {
          return this.fetchMenus();
        })
        .then(() => {
          this.closeModal();
        });
    }
  },

  mounted() {
    this.fetchMenus();
  },

  props: [
    'clients',
    'token'
  ],

  components: {
    Modal
  }
}
</script>
