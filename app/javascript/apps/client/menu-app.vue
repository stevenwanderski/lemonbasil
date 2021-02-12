<template>
  <div>
    <header>
      <a href="/" class="logo">
        Lemon&amp;Basil
      </a>
    </header>

    <loading v-if="loading"></loading>

    <div v-if="loaded">
      <div class="content">
        <p>{{ menu.message }}</p>
        <p>Submit by: {{ menu.due_at | moment('MMMM D, Y') }}</p>
        <p>Prepared for: {{ menu.client_full_name }}</p>
      </div>
    </div>
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
