/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 7/18/17.
 */
({
	init: function (component, event, helper) {
		$A.get("e.c:ss_cart_button_event")
			.setParams({'buttonMode': 'cart'})
			.fire();

		// default alignment is start but cannot be specified - rip it out
		var align = component.get('v.headerAlignment');

		if (align === 'start') {
			$A.util.removeClass(component.find('headerAlign'), 'horizontalAlign');
		}

		var url = window.location.href;
		var pos = url.indexOf('?');

		var filter = '';

		if (pos !== -1) {
			var query = decodeURI(url.substring(pos + 1));
			var parts = query.split('=');

			if (parts[0] === helper.filter.FAMILY) {
				filter = parts[1];

				component.set('v.filterString', filter);
				component.set('v.familyTitle',  filter);
			}
		}

		helper.getProducts(component);
	},

	handlePaginateEvent: function (component, event, helper) {
		helper.goToPage(component, event, event.getParam('buttonClicked'));
	},

	handleFilterEvent: function (component, event, helper) {
		component.set('v.searchString', event.getParam('searchProductCode'));
		component.set('v.filterString', event.getParam('searchProductFamily'));
		component.set('v.sortString',   event.getParam('sortOrder'));
		component.set('v.currentPage',  1);

		helper.getProducts(component);
	},

	updateFilter : function(component, event, helper) {
		var filter = component.get('v.familyTitle');

		if (filter) {
			var action = $A.get("e.c:ss_product_filter_update_event");
			action.setParams({'searchProductFamily': filter});
			action.fire();
		}
	}
})
