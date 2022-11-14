//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/sortable
//= require jquery-ui/widgets/datepicker
//= require vendor/calendar.min
//= require vendor/jquery.autocomplete.min
//= require unpoly
//= require admin/calendar

$(function() {
  $('.datepicker').datepicker({
    dateFormat: 'm/d/yy'
  });

  $(document).on('click', '[data-modal-open]', function(event) {
    event.preventDefault();
    const id = $(this).data('modal-open');

    $(`[data-modal-id="${id}"]`).show();
  });

  $(document).on('click', '[data-modal-overlay], [data-modal-close]', function(event) {
    event.preventDefault();

    $('.modal').hide();
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
  })
});
