// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.cookie
//= require jquery.url
//= require moment
//= require bootstrap
//= require underscore
//= require backbone
//= require hamlcoffee
//= require common
//= require backbone_rails_sync
//= require backbone_datalink
//= require backbone/playlists
//= require soundmanager2
//= require_tree .

window.debug = 1

window.l = function(a, b) {
  if(!a || arguments.length == 0) return 'not arguments';
  if(arguments.length > 2) {
    console.log(arguments);
  } else {
    if(b) {
      console.log(a, b);
    } else {
      console.log(a);
    }
  }
}

if (!debug) {
	console.log = function(){}
  console.warn = function(){}
  console.info = function(){}
	window.l = function(){}
}

function bind_urls() {
  $('a').click( function(event) {
    event.preventDefault();
    url = $(this).attr('href');
    if(url) {
      current_url = $.url().attr().relative;
      if(url != current_url) {
        loading();
        /* чтобы не мазолило глаза, если запрос будет ооочень долгий */
        //setTimeout( function() { loading('off'); }, 15000 );
      }    
      App.navigate(url, true);
    }
  } );
}