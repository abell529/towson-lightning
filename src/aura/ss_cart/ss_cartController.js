/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 8/9/17.
 */
({
	init: function (component, event, helper) {
        var params = {
            rsvpToken : helper.getUrlParameter('token'),
            orderToken: helper.getUrlParameter('orderToken')
        };

        helper.doCallout(component, 'c.getOrder', params)
			.then(function (model) {
				component.set('v.optionsQuantity', model.quantityList);

				console.log(model.items);
				component.set('v.model',     model);
				component.set('v.cartItems', model.items);
				component.set('v.usePoints', model.usePoints);
			});

		$A.get("e.c:ss_cart_button_event").setParams({'buttonMode': 'return'}).fire();
	},

	handleCartUpdate : function (component, event, helper) {
		var action    = event.getParam('action');
		var productId = event.getParam('itemId');
		var quantity  = event.getParam('quantity');
		var name      = event.getParam('name');
        var rsvpToken = event.getParam('rsvpToken');
        var orderToken = event.getParam('orderToken');
        var unitPrice  = event.getParam('unitPrice');

		helper.doCallout(component, 'c.updateOrder', {
			'action'    : action,
			'productId' : productId,
			'quantity'  : quantity,
		    'rsvpToken' : rsvpToken,
		    'orderToken' : orderToken,
		    'unitPrice' : unitPrice})
			.then(function(model) {
				component.set('v.model',     model);
				component.set('v.cartItems', model.items);

				switch(action) {
					case helper.action.DELETE:
						helper.showMessage(
							helper.action.SUCCESS,
							component.get('v.titleDeleted'),
							component.get('v.labelDeleted').replace('{0}', name));
						break;
					case helper.action.CLEAR:
						helper.showMessage(
							helper.action.SUCCESS,
							component.get('v.titleClear'),
							component.get('v.labelCleared'));
						break;
				}
			});
	}
})
