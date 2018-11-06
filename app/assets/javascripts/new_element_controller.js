// Catch clicks on the 'edit_' element
$('div.input-group-append button').click(function(event) {

  // url: /engine/editfield?type=string,text,number,
  var attribute_element = $(this).parent();

  var attribute = attribute_element.data("attribute");
  var dataDictionaryID = attribute_element.data("data-dictionary-id");
  var oldID = $('#dd_table').data('data-dictionary-id');

  $('#dd_table').remove(); // Remove any existing data dictionary table

  // Toggle table visibility
  if (oldID != dataDictionaryID) {
    field_container = attribute_element.parent().parent().parent();
    field_container.append('<i class="fas fa-spinner fa-pulse" id="spinner"></i>');

    $.get("/engine/value_form?" +
      "attribute=" + attribute + "&" +
      "dataDictionaryID=" + dataDictionaryID,
      function(data) {

        $('#spinner').remove();

        field_container.append(data);

      });
  }
});
