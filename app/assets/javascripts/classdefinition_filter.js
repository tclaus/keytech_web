var app = new Vue({
  el: '#data-list',
  data: {
    items: [],
    searchterm: ""
  },
  created() {
    fetch('/engine/classes.json')
    .then(response => response.json())
    .then(json => {
      this.items = json
    })
  },
  methods: {
    click_class: function(event) {

      console.log("Open a new element dialog for class: ", $(event.target).data('classkey'));
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
