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
});
