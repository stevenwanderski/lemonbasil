import "./controllers"
import "@hotwired/turbo-rails"

import Rails from '@rails/ujs';
Rails.start();

class AdminCalendar {
  constructor(args) {
    this.token = args.token;
    this.initializeCalendar();
  }

  initializeCalendar(events) {
    const element = document.getElementById('calendar');

    this.calendar = new FullCalendar.Calendar(element, {
      initialView: 'dayGridMonth',
      eventSources: [
        {
          url: '/api/events'
        }
      ],

      loading: (isLoading) => {
        if (isLoading) {
          $('.loading').show();
        } else {
          $('.loading').hide();
        }
      },

      dateClick: (info) => {
        const data = {
          date: info.dateStr
        }

        fetch('/api/events', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${this.token}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(data),
        })
        .then((response) => {
          this.calendar.refetchEvents();
        })
      }
    });

    this.calendar.render();
  }
}

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
