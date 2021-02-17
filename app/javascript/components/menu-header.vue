<template>
  <div>
    <div class="menu-header">
      <div class="menu-header__name">
        {{menu.client_full_name}}
      </div>

      <div class="menu-header__date">
        {{menu.job_date | moment('MMMM D, Y')}}
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
          <label for="due_at" class="label">Due Date</label>
          <datepicker
            name="due_at"
            format="MM/dd/yyyy"
            input-class="input--text"
            :typeable="true"
            v-model="dueAt"
          ></datepicker>
        </div>

        <div class="form-item">
          <label for="job_date" class="label">Prep Date</label>
          <datepicker
            name="job_date"
            format="MM/dd/yyyy"
            input-class="input--text"
            :typeable="true"
            v-model="jobDate"
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
        dueAt: this.menu.due_at,
        jobDate: this.menu.job_date,
        navOpen: false,
        showingModal: false
      }
    },

    methods: {
      checkForm(event) {
        event.preventDefault();

        if (!this.dueAt || !this.jobDate) {
          return alert('Due Date and Prep Date are required');
        }

        const values = {
          dueAt: this.dueAt,
          jobDate: this.jobDate,
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
