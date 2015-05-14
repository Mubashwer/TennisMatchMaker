$(document).on('ajax:success', 'form[data-update-target]', function(evt, data) {
  //alert("got it.");
  var target = $(this).data('update-target');
  $('#' + target).html(data);

});


