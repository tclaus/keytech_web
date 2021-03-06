var app = new Vue({
  el: '#data-list',
  data: {
    items: [],
    searchterm: ""
  },
  created: function() {
    fetch('/engine/classes.json')
    .then(function(response){
      return response.json();
    })
    .then(function(json){
      app.items = json;
    });
  },
  methods: {
    click_class: function(event) {
      var classkey = $(event.target).data('classkey');
      // Open new modal window with element properties
      $.get("/engine/newelement?classkey=" + classkey, function(data) {
        // Loads a new modal??
        $('body').append(data);

        $('#modal').modal();

        // Remove htmlcode after close
        $('#modal').on('hidden.bs.modal', function (e) {
            $('#modal').remove();
        });

      });

    }
  }
});
