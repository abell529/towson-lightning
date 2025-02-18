/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 9/29/17.
 */
({
	onRemoveItem : function (component, event, helper) {
		helper.fireCartEvent(component, helper.action.DELETE, helper);
	},

	onQuantityChanged: function(component, event, helper){
		var item = component.get('v.cartItem');
		var quantity  = item.quantity;

		if (quantity > 0) {
			helper.fireCartEvent(component, helper.action.UPDATE, helper);
		}
	},

	gotoProduct : function (component, event, helper) {
		helper.gotoRecord(component, component.get('v.cartItem').productId);
	}
})
