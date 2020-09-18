$(document).on('ajax:beforeSend', function(jqXhr, state, params) {
  $('.loading').show();
});

$(document).on('ajax:complete', (event) => {
  $('.loading').hide();
});
