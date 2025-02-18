/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 11/1/17.
 */
({
	addToCart: function (component, helper) {
		var self = this;

		var productId   = component.get("v.productId");
		var productName = component.get('v.productName');
		var unitPrice   = component.get('v.unitPrice');
		var quantity    = component.get('v.quantity');
		var rsvpToken   = helper.getUrlParameter('token');
		var orderToken  = helper.getUrlParameter('orderToken');

		console.log("Add to cart: " + productId);

		$A.get("e.c:ss_cart_event").setParams({
			'action'    : this.action.ADD,
			'itemId'    : productId,
			'name'      : productName,
			'unitPrice' : unitPrice,
			'quantity'  : quantity,
            'rsvpToken' : rsvpToken,
			'orderToken' : orderToken
		}).fire();

		component.set('v.quantity', 1);

		// Toggle the button label for a while
		component.set('v.buttonAdd', component.get('v.buttonLabelAdded'));
		component.set('v.buttonVariant', this.custom.BUTTON_SUCCESS);

		window.setTimeout(function() {
			component.set('v.buttonAdd', component.get('v.buttonLabelAdd'));
			component.set('v.buttonVariant', self.custom.BUTTON_BRAND);
		}, this.custom.BUTTON_DELAY);
	}
})
