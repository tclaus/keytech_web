/*
 * jQuery File Upload Plugin JS Example
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * https://opensource.org/licenses/MIT
 formData: [
              { name: 'elementKey', value: $('meta[name="csrf-token"]').attr('content') }
            ],
 */

/* global $, window */

$(function () {
    'use strict';

    // Initialize the jQuery File Upload widget:
    $('#fileupload').fileupload({
        url: '/files',
        dataType: 'json',
        send: function (e, data) {
          $('#filename').html('Laden...');
          $('#filesize').html('');
          $('span.fileinput-button').hide();
        },
        done: function (e, data) {
               $.each(data.result.files, function (index, file) {
                 if (file == undefined) {
                   $('#filename').html('Fehler beim Upload');
                 } else {
                   $('#filename').html('<i class="fas fa-file-download"></i>&nbsp;' + file.name);
                   $('span.fileinput-button').show();
                 }
               });
         },
        progressall: function (e, data) {
                    var progress = parseInt(data.loaded / data.total * 100, 10);
                    $('#progress .bar').css(
                        'width',
                        progress + '%'
                    );

                    if (progress >= 100) {
                      $('#progress .bar').css(
                          'width','0%'
                      );

                      $('#filename').html('Verarbeitung...');
                    }
                  }
    });

});
