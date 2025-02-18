/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/27/18.
 */
({
    submitted: function (component, event, helper) {
        var peakResponseRSVP = component.get("v.peakResponseRSVP");
        var eventProductsUrl = component.get("v.eventProductsUrl");
        var eventUrl = component.get("v.eventUrl");

        var URL = component.get("v.nextURL");
        // if (peakResponseRSVP.results[0].Event__r.Enable_Pricing_Payment__c) {
        //     URL = eventProductsUrl + '?token=' +  peakResponseRSVP.results[0].RSVPToken_TU__c;
        // } else {
        //     URL = eventUrl + peakResponseRSVP.results[0].Event__c + '?token=' +
        //         peakResponseRSVP.results[0].RSVPToken_TU__c;
        // }

        // var params = {
        //     rsvpId : helper.getUrlParameter(component.get('v.variable')),
        //     eventProductsURL : eventProductsUrl,
        //     eventURL : eventUrl,
        //     errorURL : eventUrl
        // };
        //
        // console.log(params);
        // helper.doCallout(component,'c.getRSVPNextStep',params).then(function(response){
        //     console.log(response);
        //     if (response.success){
        //         URL = response;
        //         console.log(URL);
        //     } else {
        //         URL = eventUrl;
        //     }
        // });

        helper.gotoUrl(component, URL);
    },



    showToast: function (type, message) {
        // types: error, warning, success, info
        var toastEvent = $A.get('e.force:showToast');
        if (toastEvent) {
            toastEvent.fire({
                type: type,
                message: message
            });
        }
    },

    gotoUrl: function (component, url) {
        $A.get("e.force:navigateToURL")
            .setParams({
                'url'       : url,
                'isredirect': true
            }).fire();
    }

})