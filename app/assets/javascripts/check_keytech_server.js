
$.ajax({
    url: "/engine/checkserver",
    cache: false,
    success: function(response){
      // $("#dashboard").empty();
      // $("#dashboard").append(html);
      console.log('keytech server checked');
      if (response.available == true) {
        // Server OK
      } else {
        $("#servercheck_failed_alert").slideDown();
      }
    },
    failure: function(error) {
      console.log('Could not check server');
    }
});
