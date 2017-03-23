// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui/effect
//= require jquery_ujs
//= require foundation

//= require_tree .

$(function(){ $(document).foundation(); });

$(document).on('change', '.autosubmitme', function() {
  $(this).parents('form').submit();
});

$(document).on('click', '.suites-fields-section .check-all', function() {
  set_checkbox_of_parent(this, '.suites-fields-section', true);
  return false; // prevent scrolling behavior
});

$(document).on('click', '.suites-fields-section .uncheck-all', function() {
  set_checkbox_of_parent(this, '.suites-fields-section', false);
  return false; // prevent scrolling behavior
});

function set_checkbox_of_parent(element, parent_class, checked) {
  var parent_div = $(element).parents(parent_class)[0];
  $(parent_div).find('input[type="checkbox"]').prop('checked', checked);
}
