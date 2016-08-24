// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require 'bootstrap'
//= require turbolinks
//= require_tree .

function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+ d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i = 0; i <ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length,c.length);
        }
    }
    return "";
}

function delete_cookie( cname ) {
    var name = cname;
    var ca = document.cookie.split(';');
    for(var i = 0; i <ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            document.cookie = c + '=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
        }
    }
}

function update_total_value(element_id){
  ids = element_id.split('-')
  total_product_quantity = 0;
  total_product_price = 0.0;
  $('.product-'+ids[2]).each(function(index, element) {
    e_value = parseInt($(element).val());
    e_price = parseFloat($(element).attr('product_price'));
    if(e_value >= 0){
      total_product_quantity = total_product_quantity + e_value;
      total_product_price = total_product_price + (e_value*e_price);
    }
  });
  total_distributor_quantity = 0;
  total_distributor_price = 0;
  $('.distributor-'+ids[1]).each(function(index, element) {
    e_value = parseInt($(element).val());
    e_price = parseFloat($(element).attr('product_price'));
    if(e_value >= 0){
      total_distributor_quantity = total_distributor_quantity + e_value;
      total_distributor_price = total_distributor_price + (e_value*e_price);
    }
  });
  $('.distributor-total-quantity-'+ids[1]).html(total_distributor_quantity);
  $('.distributor-total-amount-'+ids[1]).html(total_distributor_price);
  $('.product-total-quantity-'+ids[2]).html(total_product_quantity);
  $('.product-total-amount-'+ids[2]).html(total_product_price);
}

$( document ).ready(function() {
	$( ".order-quantity" ).keyup(function() {
    current_value = parseInt($(this).val())
		if(current_value >= 0){
	    setCookie($(this).attr('id'), $(this).val(), 1)
    }else{
    	setCookie($(this).attr('id'), '', 1)
    }
    update_total_value($(this).attr('id'));
	});
	$( ".clear-cacheing" ).click(function() {
	  $( ".order-quantity" ).each(function() {
        setCookie($(this).attr('id'), '', 1)
	  });
	});

	$( ".order-quantity" ).each(function() {
    cacheing_value = getCookie($(this).attr('id'))
    $(this).val(cacheing_value)
    update_total_value($(this).attr('id'));
  });
  var ca = document.cookie.split(';');
  for(var i = 0; i <ca.length; i++) {
      if(ca.indexOf('order-' == 0)){
          var c = ca[i].split('=')[0];
          console.log(c);
          if($('#'+c.trim()).length == 0){
            document.cookie = c + '=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
          }

      }
  }
});