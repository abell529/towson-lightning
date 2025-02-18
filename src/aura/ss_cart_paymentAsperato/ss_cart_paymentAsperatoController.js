/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/24/18.
 */
({
    doInit: function (component, event, helper) {
        var params = {
            rsvpToken : helper.getUrlParameter('token'),
            orderToken : helper.getUrlParameter('orderToken')
        };

        helper.doCallout(component, 'c.getECommerceURL', params, false, 'Get Event RSVP', false)
            .then(function (response) {
                component.set('v.isInit', true);
                component.set("v.asperatoURL",response);
            });
    },

    onLoadHandler: function (component, event, helper) {
        var loading =  component.get('v.loading');
        if (loading) {
            component.set('v.loading',false);
        } else {
            component.set('v.loading',true);
        }
    }

});