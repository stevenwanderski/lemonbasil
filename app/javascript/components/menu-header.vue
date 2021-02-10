<template>
  <div>
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
          <a href="" @click="clickEdit($event)">Edit</a>
          <a href="">Copy</a>
        </div>
      </div>
    </div>

    <modal v-if="showingModal" :onClose="closeModal">
      <h2>Edit Client Menu</h2>
      <form @submit="checkForm">
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

        <div class="form-actions">
          <button class="button button--submit">
            Submit
          </button>

          <button @click="closeModal" class="link">Cancel</button>
        </div>
      </form>
    </modal>
  </div>
</template>

<script>
  import Datepicker from 'vuejs-datepicker';
  import Modal from './modal';

  export default {
    components: {
      Datepicker,
      Modal
    },

    data() {
      return {
        dueAt: null,
        navOpen: false,
        showingModal: false
      }
    },

    methods: {
      checkForm() {

      },

      clickEdit(event) {
        event.preventDefault();
        this.showingModal = true;
      },

      closeModal() {
        this.showingModal = false;
      },

      toggleNav() {
        this.navOpen = !this.navOpen;
      }
    },

    props: [
      'menu'
    ]
  }
</script>
