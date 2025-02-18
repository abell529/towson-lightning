/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/27/18.
 */
({
    doInit: function (component, event, helper) {
        var params = {
                rsvpId : helper.getUrlParameter(component.get('v.variable')),
                eventProductsURL : component.get("v.eventProductsUrl"),
                eventURL : component.get("v.eventUrl"),
                errorURL : component.get("v.errorUrl")
        };

        console.log(params);
        helper.doCallout(component,'c.getRSVPNextStep',params).then(function(response){
            console.log(response);
            if (response !== null){
                console.log(response);
                component.set("v.nextURL",response);
                component.set('v.isInit', true);
            } else {
                component.set("v.nextURL",component.get("v.errorUrl"));
            }
            component.set('v.isLoading', false);
        });
    },

    continue: function (component, event, helper) {
        var peakResponseRSVP = component.get("v.peakResponseRSVP");
        var eventProductsUrl = component.get("v.eventProductsUrl");
        var eventUrl = component.get("v.eventUrl");

        var URL;
        if (peakResponseRSVP.results[0].Event__r.Enable_Pricing_Payment__c) {
            URL = eventProductsUrl + '?token=' +  peakResponseRSVP.results[0].RSVPToken_TU__c;
        } else {
            URL = eventUrl + peakResponseRSVP.results[0].Event__c + '?token=' +
                peakResponseRSVP.results[0].RSVPToken_TU__c;
        }

        helper.gotoUrl(component, URL);
    }
})