
$(document).ready(function(){

var timing;

// Catch clicks on the 'edit_' element
$('div .attribute-field').click(function(event){

  // url: /engine/editfield?type=string,text,number,
  var attribute_element = $(this).parent();
  var isWritable = attribute_element.data("isWritable");

  if (isWritable) {
    var attribute = attribute_element.data("attribute");
    var type = attribute_element.data("attribute-type");
    var elementKey = attribute_element.data("element-key");
    var dataDictionaryID = attribute_element.data("data-dictionary-id");

    $.get("/engine/value_form?elementKey=" + elementKey +
          "&attribute=" + attribute +
          "&attributeType=" + type +
          "&dataDictionaryID=" + dataDictionaryID, function(data) {

      // Click in the icon - add form to parent
      attribute_element.contents().remove();
      attribute_element.append(data);
    });
  }
});

  $("div .attribute-field").hover(function(event){
      // Wait a time
      var currentelement = this;
      clearTimeout(timing);
      timing = setTimeout(function() {
          $(currentelement).children('i').animate({ opacity: 1 });
      }, 150);
    },
      function(event){
        $(this).children('i').animate({ opacity: 0 });
        leftElement = $(this).children('i');
      });

});
