
// Capture row click in dd dtable and sets a hidden form field
  $('.clickable-row').click(function(e) {
      // e.preventDefault();
      json = $(this).data('json');
      $('#datadictionary_field').val(JSON.stringify(json));

  });
