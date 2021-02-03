<template>
  <div>
    <modal v-if="showingModal" :onClose="closeModal">
      <h2>New Client Menu</h2>
      <form @submit="submit">
        <div class="form-item">
          <label for="client" class="label">Client</label>
          <select name="client" v-model="client" class="input--select">
            <option value="">- Select -</option>
            <option v-for="client in clients" v-bind:value="client.id">
              {{client.full_name}}
            </option>
          </select>
        </div>

        <div class="form-item">
          <label for="due_at" class="label">Prep Date</label>
          <datepicker
            name="due_at"
            format="MM/dd/yyyy"
            input-class="input--text"
            :typeable="true"
            v-model="dueAt"
          ></datepicker>
        </div>

        <button class="button">
          Submit
        </button>

        <button @click="closeModal">Cancel</button>
      </form>
    </modal>

    <loading v-if="loading"></loading>

    <div class="admin-header">
      <h1>Client Menus</h1>
      <button class="button" @click="clickAdd" v-if="clientsAny">
        Add Client Menu
      </button>
    </div>

    <div v-if="!clientsAny">
      Please <a href="/admin/clients/new" class="link">add a client</a> before creating a menu!
    </div>

    <div v-else-if="loaded">
      <div class="rows" v-if="menus.length">
        <div class="row" v-for="menu in menus">
          <div class="row__name">
            <a :href="menu.url">
              {{menu.client_full_name}}: <strong>{{ menu.due_at | moment('MMMM D, Y') }}</strong>
            </a>
          </div>
        </div>
      </div>

      <div v-else>
        No menus yet.
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import moment from 'moment';
import Datepicker from 'vuejs-datepicker';
import Loading from './components/loading';
import Modal from './components/modal';

export default {
  components: {
    Datepicker,
    Loading,
    Modal
  },

  computed: {
    clientsAny() {
      return this.clients.length;
    }
  },

  data() {
    return {
      client: '',
      dueAt: '',
      loaded: false,
      loading: true,
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
        client_id: this.client,
        due_at: this.dueAt
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

      this.loading = true;
      this.saveMenu()
        .then(() => {
          return this.fetchMenus();
        })
        .then(() => {
          this.closeModal();
          this.loading = false;
        });
    }
  },

  mounted() {
    this.fetchMenus().then(() => {
      this.loading = false;
      this.loaded = true;
    })
  },

  props: [
    'clients',
    'token'
  ]
}
</script>
