class AdminCalendar {
  constructor(events) {
    const element = document.getElementById('calendar');

    this.initializeCalendar(element);
  }

  initializeCalendar(element, events) {
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
