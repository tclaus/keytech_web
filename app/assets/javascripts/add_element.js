
$(document).on('turbolinks:load',function(){
  $('#add_element').on('click', function (event) {
    event.preventDefault();

    // Load modal window for new element step 1
    $.get("/engine/new_element_class", function(data) {
      $('body').append(data);
      $('#modal').modal();

      // Focus on input field
      $('#modal').on('shown.bs.modal', function () {
        $('#data-search').trigger('focus');
      });

      // Remove htmlcode after close
      $('#modal').on('hidden.bs.modal', function (e) {
          $('#modal').remove();
      });
    });
  });
});
