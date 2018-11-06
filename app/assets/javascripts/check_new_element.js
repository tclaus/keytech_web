
$('#create_element_form').submit(function(e) {
    
    // Remove htmlcode after close
    $('#modal').on('hidden.bs.modal', function (e) {
        $('#modal').remove();
    });

    $('#modal').modal('hide');
});
