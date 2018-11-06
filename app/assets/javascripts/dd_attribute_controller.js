// Capture row click in dd table and sets a hidden form field
$('.clickable-row').click(function(e) {
  // e.preventDefault();
  var json = $(this).data('json');
  var attribute = $('#dd_table').data('attribute');
  $('#datadictionary_field_' + attribute).val(JSON.stringify(json));
  // Set name to input field
  setPrimaryData(this);

  // Show Selected table
  $(this).siblings().removeClass('table-primary');
  $(this).addClass('table-primary');
});

// Place primary data dictionary attribute immediatly to input field
// Store 'hidden' DD attribute in hidden input field
function setPrimaryData(row) {
  $(row).children().each(function(index, element) {
    var attribute = $(element).data('target_attribute');
    if (attribute) {
      $('input[name=' + attribute + ']').val($(this).text().trim());
    }
  });
}
