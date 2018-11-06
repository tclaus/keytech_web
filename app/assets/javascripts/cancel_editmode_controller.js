// Handle cancel event in edit mode- restore field
$('#cancel-attributes').click(function(e) {

  $('#attribute-edit-form').siblings().fadeIn();
  $('#attribute-edit-form').remove();

});
