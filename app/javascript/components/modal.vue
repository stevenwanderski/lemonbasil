<template>
  <div class="modal">
    <div class="modal__overlay" @click="onClose()"></div>
    <div class="modal__body">
      <slot></slot>
    </div>
  </div>
</template>

<script>
  export default {
    methods: {
      close() {
        onClose();
      }
    },

    props: [
      'onClose'
    ]
  }
</script>
