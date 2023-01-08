//= require jquery
//= require jquery_ujs

import "controllers"
import "@hotwired/turbo-rails"

$(document).on('click', '#staples-control', function(e) {
  e.preventDefault();

  $('.staples__control').hide();
  $('.staples__body').show();
});

$(document).on('click', '#staples-close', function(e) {
  e.preventDefault();

  $('.staples__control').show();
  $('.staples__body').hide();
});
