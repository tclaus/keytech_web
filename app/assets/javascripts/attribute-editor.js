
  // Capture row click in dd table and sets a hidden form field
  $('.clickable-row').click(function(e) {
      // e.preventDefault();
      json = $(this).data('json');
      $('#datadictionary_field').val(JSON.stringify(json));

      $(this).siblings().removeClass('table-primary');
      $(this).addClass('table-primary');
  });

  // Handle cancel event - restore field
  $('#cancel-attributes').click(function(e){

    $('#attribute-edit-form').siblings().fadeIn();
    $('#attribute-edit-form').remove();

  });
