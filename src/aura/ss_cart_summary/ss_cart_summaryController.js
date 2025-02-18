/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 9/29/17.
 */
({
	init: function (component, event, helper) {
		if (component.get('v.skipPayment')) {
			component.set('v.labelCheckout', component.get('v.labelPlaceOrder'));
		}

		console.log('summaryInit');
        var params = {
            rsvpToken : helper.getUrlParameter('token'),
			orderToken : helper.getUrlParameter('orderToken')
        };

        helper.doCallout(component, 'c.getOrder', params)
			.then(function (model) {
				console.log(model);
				component.set('v.model',     model);
				component.set('v.cartItems', model.items);
				component.set('v.usePoints', model.usePoints);
				component.set('v.enoughTickets', model.enoughTickets);
			});

	},

	gotoCheckout : function (component, event, helper) {
		if (component.get('v.skipPayment')) {
			var model   = component.get('v.model');

			helper.doCallout(component, 'c.placeOrder',
				{
					'orderId' : model.orderId
				}, true, '')
				.then(function (result) {
					if (result) {
						var message   = component.get('v.toastPlacedOrder').replace('{0}', model.orderNumber);
						var detailUrl = component.get('v.orderDetailUrl');

						helper.showMessage(helper.action.SUCCESS, component.get('v.labelPlaceOrder'), message);

						if (detailUrl) {
							helper.gotoUrl(component, detailUrl);
						}
						else {
							helper.gotoRecord(component, model.orderId);
						}
					}
			});
		} else {
            var rsvpToken = helper.getUrlParameter('token');
            var orderToken = helper.getUrlParameter('orderToken');

            var URL = component.get('v.checkoutUrl');
            if (rsvpToken != null) {
                URL = URL + '?token=' + rsvpToken;
            } else if (orderToken != null) {
                URL = URL + '?orderToken=' + orderToken;
            }
            helper.gotoUrl(component, URL);
		}

		$A.get("e.c:ss_cart_button_event").setParams({'buttonMode': 'cart'}).fire();
	},

    gotoProducts : function (component, event, helper) {
        var rsvpToken = helper.getUrlParameter('token');
        var orderToken = helper.getUrlParameter('orderToken');

        var URL = component.get('v.backToProductsUrl');
        if (rsvpToken != null) {
            URL = URL + '?token=' + rsvpToken;
        } else if (orderToken != null) {
            URL = URL + '?orderToken=' + orderToken;
        }
        helper.gotoUrl(component, URL);

        $A.get("e.c:ss_cart_button_event").setParams({'buttonMode': 'cart'}).fire();
    }

})
