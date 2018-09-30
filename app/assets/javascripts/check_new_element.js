
$('#create_element_form').submit(function(e) {
    // e.preventDefault();
    // Coding

    // Remove htmlcode after close
    $('#modal').on('hidden.bs.modal', function (e) {
        $('#modal').remove();
    });

    $('#modal').modal('hide');
});
