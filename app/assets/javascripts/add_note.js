
$(document).on('turbolinks:load',function(){
  $('#add_note').on('click', function (event) {
    event.preventDefault();
    var element_key = $('#add_note').data('element-key');

    // Load modal window for new element step 1
    $.get("/engine/new_note?element_key=" + element_key, function(data) {
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
