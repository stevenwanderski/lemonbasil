<template>
  <div class="menu-header">
    <div class="menu-header__name">
      {{menu.client_full_name}}
    </div>

    <div class="menu-header__date">
      {{menu.due_at | moment('MMMM D, Y')}}
    </div>

    <div class="menu-header__nav hamburger-nav">
      <button class="hamburger-nav__control" @click="toggleNav">
        <span></span>
        <span></span>
        <span></span>
      </button>

      <div class="hamburger-nav__body" v-if="navOpen">
        <a :href="menu.url">Menu</a>
        <a href="">Results</a>
        <a href="">Edit</a>
        <a href="">Copy</a>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        navOpen: false
      }
    },

    methods: {
      toggleNav() {
        this.navOpen = !this.navOpen;
      }
    },

    props: [
      'menu'
    ]
  }
</script>
