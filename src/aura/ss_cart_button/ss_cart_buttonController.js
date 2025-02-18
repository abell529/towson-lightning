/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 9/29/17.
 */
({
	init: function (component, event, helper) {
		// default alignment is start but cannot be specified - rip it out
		var align = component.get('v.cartAlign');

		if (align === 'start') {
			$A.util.removeClass(component.find('cartControl'), 'horizontalAlign');
		}

		helper.getOrder(component, helper)
	},

	handleCartMode: function (component, event, helper) {
		component.set('v.buttonMode', event.getParam('buttonMode'));

		helper.getOrder(component, helper);
	},

	handleAddItemToCart: function (component, event, helper) {
		var action      = event.getParam('action');
		var itemId      = event.getParam('itemId');
		var quantity    = event.getParam('quantity');
		var productName = event.getParam('name');
		var rsvpToken   = event.getParam('rsvpToken');
		var orderToken  = event.getParam('orderToken');

		var title = component.get('v.toastTitle');

		if (action === helper.action.ADD) {
			helper.doCallout(component, 'c.updateOrder', {
				'action'   : helper.action.ADD,
				'productId': itemId,
				'quantity' : quantity,
				'rsvpToken' : rsvpToken,
				'orderToken' : orderToken
			}, false, title)
			.then(function (model) {
				var count = 0;
				for(var cnt=0; cnt < model.items.length; ++cnt) {
					count += model.items[cnt].quantity;
				}

				var total = model.subTotal;

				component.set('v.model',     model);
				component.set("v.itemCount", count);
				component.set('v.itemTotal', total);

				if (component.get('v.singleButton')) {
					var buttonText = component.get('v.singleButtonLabel');

					if (component.get('v.showCount')) {
						buttonText += ' (' + count + ')';
					}
					component.set('v.singleButtonText', buttonText);
				}

				helper.showMessage(
					helper.action.SUCCESS,
					title,
					component.get('v.toastMessage')
							 .replace('{0}', quantity)
							 .replace('{1}', productName));

				if (rsvpToken === null && orderToken === null && model.orderToken != null) {
					var URL = window.location.href;
                    URL = URL + '?orderToken=' + model.orderToken;
                    helper.gotoUrl(component, URL);
				}
			});
		}
		else {
			helper.getOrder(component);
		}
	},

	gotoCart: function (component, event, helper) {
        var model = component.get('v.model');

        var URL;
        if (model.specialItems) {
            URL = component.get('v.cartUpdateUrl');
            // helper.gotoUrl(component, component.get('v.cartUpdateUrl'));
        } else {
            URL = component.get('v.cartUrl');
            // helper.gotoUrl(component, component.get('v.cartUrl'));
        }

        if (model.rsvpToken != null) {
            URL = URL + '?token=' + model.rsvpToken;
        } else if (model.orderToken != null) {
            URL = URL + '?orderToken=' + model.orderToken;
        }

		helper.gotoUrl(component, URL);
	},

	gotoCatalog : function (component, event, helper) {
		helper.gotoUrl(component, component.get('v.catalogUrl'));
	}
})
