<template>
  <div>
    <modal v-if="showingModal" :onClose="closeModal">
      <h2>New Client Menu</h2>
      <menu-form
        :clients="clients"
        :onCancel="closeModal"
        :onSubmit="saveMenu"
      ></menu-form>
    </modal>

    <loading v-if="loading"></loading>

    <div class="admin-header">
      <h1>Client Menus</h1>
      <button class="button" @click="clickAdd" v-if="clientsAny">
        + Add Client Menu
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
import Loading from './components/loading';
import Modal from './components/modal';
import MenuForm from './components/menu-form';

export default {
  components: {
    Loading,
    Modal,
    MenuForm
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

    saveMenu(values) {
      const data = {
        client_id: values.client,
        due_at: values.dueAt
      };

      const options = {
        headers: {
          'Authorization': `Token token=${this.token}`
        }
      };

      this.loading = true;

      return axios.post('/api/client_menus', data, options)
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
