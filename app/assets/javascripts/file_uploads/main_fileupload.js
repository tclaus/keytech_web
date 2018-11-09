$(document).on('turbolinks:load',function(){
    // jshint nomen:false
    'use strict';

  // Initialize the jQuery File Upload widget:
  $('#fileupload').fileupload({
    url: '/files',
    dataType: 'json',
    send: function(e, data) {
      $('#filename').html('Laden...');
      $('#filesize').html('');
      $('span.fileinput-button').hide();
    },
    done: function(e, data) {
      var file = data.result;
      if (file.success) {
        $('#filename').html('<i class="fas fa-file-download"></i>&nbsp;' + file.name);
        $('span.fileinput-button').show();

        // force reload of thumbnail - cache
        loadPreview(file.elementkey);

      } else {
        $('#filename').html('Fehler beim Upload');
        $('#filename').append('<div>' + file.error + '</div>');
      }
    },
    progressall: function(e, data) {
      var progress = parseInt(data.loaded / data.total * 100, 10);
      $('#progress .bar').css(
        'width',
        progress + '%'
      );

      if (progress >= 100) {
        $('#progress .bar').css(
          'width', '0%'
        );

        $('#filename').html('Verarbeitung...');
      }
    }
  });

function loadPreview(element_key) {
  var preview_url = '/element/' + element_key + '/preview?_=' +  randomNumber();
  $('#thumbnail').fadeOut();
  $('#thumbnail').attr("src",preview_url);
  $('#thumbnail').fadeIn();

  // Modal window
  $('#thumbnail-modal').attr("src",preview_url);
}

function randomNumber() {
  return Math.floor((Math.random() * 100000) + 1);
}

});
