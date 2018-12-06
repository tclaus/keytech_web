$(document).on('turbolinks:load',function(){

  $('a[data-remote]').on('ajax:before', function (event) {
    var note = event.target.parentElement.parentElement.parentElement;
    $(note).addClass("delete");
  });

  $('a[data-remote]').on('ajax:success', function (event) {
    var note = event.target.parentElement.parentElement.parentElement;
    $(note).remove();
  });

  $('a[data-remote]').on('ajax:error', function (event) {
    var note = event.target.parentElement.parentElement.parentElement;
    $(note).removeClass("delete");
  });
});
