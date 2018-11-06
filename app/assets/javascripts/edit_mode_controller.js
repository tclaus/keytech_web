$(document).on('turbolinks:load', function() {

  var timing;

  // Catch clicks on the 'edit_' element
  $('div.attribute-field').click(function(event) {

    $(this).attr("disabled", "disabled");

    // url: /engine/editfield?type=string,text,number,
    var attribute_element = $(this).parent();
    var isWritable = attribute_element.data("isWritable");

    if (isWritable) {
      var attribute = attribute_element.data("attribute");
      var type = attribute_element.data("attribute-type");
      var elementKey = attribute_element.data("element-key");
      var dataDictionaryID = attribute_element.data("data-dictionary-id");

      // Hover
      attribute_element.append('<i class="fas fa-spinner fa-pulse" id="spinner"></i>');
      $.get("/engine/value_form?elementKey=" + elementKey +
        "&attribute=" + attribute +
        "&attributeType=" + type +
        "&dataDictionaryID=" + dataDictionaryID,
        function(data) {

          $('#spinner').remove();

          // Click in the icon - add form to parent
          attribute_element.contents().hide();
          attribute_element.append(data);

        });
    }
  });

  // Show edit button with hover effect
  $("div.attribute-field").hover(function(event) {
      // Hover in
      // Wait a time
      var currentelement = this;
      clearTimeout(timing);
      timing = setTimeout(function() {
        $('i.edit-icon').css("opacity", 0);
        $(currentelement).children('i.edit-icon').animate({
          opacity: 1
        });
      }, 150);
    },
    // Hover out
    function(event) {
      $(this).children('i.edit-icon').animate({
        opacity: 0
      });
    });
});
