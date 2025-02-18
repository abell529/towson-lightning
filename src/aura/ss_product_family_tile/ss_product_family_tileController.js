/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francoiskorb on 11/22/17.
 */
({
	init: function (component, event, helper) {
		var item = component.get('v.familyItem');
		var label = component.get('v.labelBrowse').replace('{0}', item.name);
		component.set('v.browse', label);
	},

	gotoFamily : function (component, event, helper) {
		var filterEvent  = $A.get("e.c:ss_product_filter_event");

		filterEvent.setParams({
			'searchProductCode'  : '',
			'searchProductFamily': component.get('v.familyItem').name,
			'sortOrder'          : ''
		});

		filterEvent.fire();

		var url = component.get('v.productListUrl');
		url += '?family=' + encodeURIComponent(component.get('v.familyItem').name);
		helper.gotoUrl(component, url);
	}
})
