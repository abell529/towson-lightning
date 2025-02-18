/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 7/25/17.
 */
({
	doInit: function(component, event, helper) {
		$A.get("e.c:ss_cart_button_event").setParams({'buttonMode': 'cart'}).fire();

		helper.doCallout(component, 'c.getProductsById',
			{
				pageSize: 1,
				currentPage: 1,
				ids : [component.get('v.recordId')]
			}, false, 'Get Products by ID', true)
			.then(function (listModel) {
				component.set('v.optionsQuantity', listModel.quantityList);
				component.set('v.products', listModel);
				component.set('v.product',  listModel.items[0]);
			});
	}
})
