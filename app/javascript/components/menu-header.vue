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
          <a href="" @click="clickCopyUrl($event)">Copy URL</a>
          <a :href="menu.slug_url" target="_blank">Public View</a>
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

        <div class="form-item">
          <label for="message" class="label">Message</label>
          <textarea
            class="input--textarea"
            name="message"
            id="message"
            v-model="message"
          ></textarea>
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
        dueAt: this.menu.due_at,
        message: this.menu.message,
        navOpen: false,
        showingModal: false
      }
    },

    methods: {
      checkForm(event) {
        event.preventDefault();

        if (!this.dueAt) {
          return alert('Prep Date is required');
        }

        const values = {
          dueAt: this.dueAt,
          message: this.message
        }

        this.onMenuSubmit(values).then(() => {
          this.closeModal();
        });
      },

      clickCopyUrl(event) {
        event.preventDefault();

        navigator.clipboard.writeText(this.menu.slug_url).then(() => {
          alert(`${this.menu.slug_url} was copied to your clipboard`);
        });
      },

      clickEdit(event) {
        event.preventDefault();
        this.showingModal = true;
        this.navOpen = false;
      },

      closeModal() {
        this.showingModal = false;
      },

      toggleNav() {
        this.navOpen = !this.navOpen;
      }
    },

    props: [
      'menu',
      'onMenuSubmit'
    ]
  }
</script>
