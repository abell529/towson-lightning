/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/27/18.
 */
({
    init: function (component, event, helper) {
        if (component.get('v.skipPayment')) {
            component.set('v.labelCheckout', component.get('v.labelPlaceOrder'));
        }

        var params = {
            rsvpToken : helper.getUrlParameter('token'),
            orderToken : helper.getUrlParameter('orderToken')
        };

        helper.doCallout(component, 'c.getPlaceOrder', params)
            .then(function (model) {
                component.set('v.model',     model);
                component.set('v.cartItems', model.items);
                component.set('v.usePoints', model.usePoints);
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
            helper.gotoUrl(component, component.get('v.checkoutUrl'));
        }

        $A.get("e.c:ss_cart_button_event").setParams({'buttonMode': 'cart'}).fire();
    }
})