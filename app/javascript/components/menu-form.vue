<template>
  <form @submit="checkForm">
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

      <button @click="onCancel" class="link">Cancel</button>
    </div>
  </form>
</template>

<script>
  import Datepicker from 'vuejs-datepicker';

  export default {
    components: {
      Datepicker
    },

    data() {
      return {
        client: null,
        dueAt: null,
        jobDate: null
      }
    },

    methods: {
      checkForm(event) {
        event.preventDefault();

        if (!this.client || !this.dueAt) {
          alert('Client and Prep Date are required');
          return;
        }

        this.onSubmit({
          client: this.client,
          dueAt: this.dueAt,
          jobDate: this.jobDate
        });
      },
    },

    props: [
      'clients',
      'onCancel',
      'onSubmit'
    ]
  }
</script>
