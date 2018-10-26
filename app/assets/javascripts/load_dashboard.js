
$.ajax({
    url: "/dashboard",
    cache: false,
    success: function(html){

      $("#dashboard").empty();
      $("#dashboard").append(html);
      
      $("#dashboard").children().hide();
      $("#dashboard").children().fadeIn();
    },
    failure: function(error) {
      console.log('Could not load dashboard');
    }
});
