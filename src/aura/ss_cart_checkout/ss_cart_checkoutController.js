/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 8/9/17.
 */
({

	init: function (component, event, helper) {
        // var params = {
         //    rsvpToken : helper.getUrlParameter('token')
        // };
        //
        // helper.doCallout(component, 'c.getOrder', params)
		//   .then(function (model) {
		// 	component.set('v.model', model);
		// 	component.set('v.usePoints', model.usePoints);
		// 	component.set('v.itemCount', model.items.length);
		// 	component.set('v.itemTotal', model.subTotal);
		// });
		helper.getOrder(component, helper);
	},

	goBack : function(component, event, helper){
		window.history.back();
	}
})
