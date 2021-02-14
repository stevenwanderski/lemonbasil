<template>
  <div class="client-menu">
    <header>
      <a href="/" class="logo">
        Lemon&amp;Basil
      </a>

      <div class="client-menu__meta" v-if="loaded">
        <div class="client-menu__due-at">
          Submit by: <strong>{{ menu.due_at | moment('MMMM D, Y') }}</strong>
        </div>

        <div class="client-menu__client-name">
          Prepared for: {{ menu.client_full_name }}
        </div>
      </div>
    </header>

    <div class="content" v-if="loaded">
      <p class="client-menu__message">{{ menu.message }}</p>
    </div>

    <loading v-if="loading"></loading>
  </div>
</template>

<script>
import axios from 'axios';
import Loading from '../../components/loading';

export default {
  components: {
    Loading
  },

  data() {
    return {
      loaded: false,
      loading: true,
      menu: null
    }
  },

  methods: {
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
    this.fetchMenu().then(() => {
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
