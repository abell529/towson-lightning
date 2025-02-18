/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/24/18.
 */
({
    receiveMessage: function (component, event, helper) {

        if (event.origin !== "https://test.protectedpayments.net" &&
            event.origin !== "https://live.protectedpayments.net")
            return;

        component.set('v.loading',true);
        var rsvpToken = helper.getUrlParameter('token');
        var orderToken = helper.getUrlParameter('orderToken');

        var URL;
        if(event.data == "asp--exit-screen" || event.data == "asp--complete") {
            URL = component.get('v.paymentConfirmURL');
        } else if (event.data == "asp--cancel") {
            URL = component.get('v.paymentCancelURL');
        } else if (event.data == "asp--error") {
            URL = component.get('v.paymentErrorURL');
        }

        if (URL != null) {
            if (rsvpToken != null) {
                URL = URL + '?token=' + rsvpToken;
            } else if (orderToken != null) {
                URL = URL + '?orderToken=' + orderToken;
            }

            helper.gotoUrl(component, URL);
        }
    }
})