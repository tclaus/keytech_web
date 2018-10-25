
$.ajax({
    url: "/dashboard",
    cache: false,
    success: function(html){
      $("#dashboard").empty();
      $("#dashboard").append(html);
    },
    failure: function(error) {
      console.log('Could not load dashboard');
    }
});
