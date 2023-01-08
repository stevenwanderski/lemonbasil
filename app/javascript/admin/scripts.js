$(function() {
  $('.datepicker').datepicker({
    dateFormat: 'm/d/yy'
  });

  $(document).on('click', '[data-modal-overlay], [data-modal-close]', function(event) {
    event.preventDefault();

    hideModal();
  });

  $(document).on('click', '.hamburger-nav__control', function(event) {
    event.preventDefault();

    $('.hamburger-nav__body').toggle();
  });

  $(document).on('click', function(event) {
    if ($(event.target).is('.hamburger-nav') || $(event.target).parents('.hamburger-nav').length) {
      return;
    }

    $('.hamburger-nav__body').hide();
  });

  $(document).on('turbo:submit-end', function(event) {
    if (event.detail.success) {
      hideModal();
    }
  });
});

function hideModal() {
  $('#modal').get(0).removeAttribute('src');
  $('#modal .modal').get(0).remove();
}
