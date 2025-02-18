/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/27/18.
 */
({
    init: function (component, event, helper) {
        var params = {
            rsvpToken : helper.getUrlParameter('token'),
            orderToken: helper.getUrlParameter('orderToken')
        };

        console.log(params);
        helper.doCallout(component, 'c.getOrder', params)
            .then(function (model) {
                component.set('v.optionsQuantity', model.quantityList);

                console.log(model.items);
                component.set('v.model',     model);
                component.set('v.cartItems', model.items);
                component.set('v.usePoints', model.usePoints);
            });
    },

    updateOrderCart : function (component, event, helper) {
        var rsvpToken  =  helper.getUrlParameter('token');
        var orderToken =  helper.getUrlParameter('orderToken');

        console.log(rsvpToken + ' ' + orderToken);
        var URL = component.get('v.cartReviewUrl');
        if (rsvpToken !== null) {
            URL = URL + '?token=' + rsvpToken;
        } else if (orderToken !== null) {
            URL = URL + '?orderToken=' + orderToken;
        }

        console.log(URL);
        helper.gotoUrl(component, URL);
    }
})