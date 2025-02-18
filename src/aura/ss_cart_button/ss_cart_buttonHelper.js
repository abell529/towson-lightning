/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francoiskorb on 11/15/17.
 */
({
	getOrder : function (component, helper) {
        var params = {
            rsvpToken : helper.getUrlParameter('token'),
            orderToken : helper.getUrlParameter('orderToken')
        };

        helper.doCallout(component, 'c.getOrder', params)
			.then(function (model) {
				component.set('v.model',     model);
				component.set('v.usePoints', model.usePoints);
				component.set('v.itemCount', model.totalItems);
				component.set('v.itemTotal', model.subTotal);
			});
	}
})
