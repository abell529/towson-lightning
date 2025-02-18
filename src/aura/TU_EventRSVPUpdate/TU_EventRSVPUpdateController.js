/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/12/18.
 */
({
    initRSVPUpdate: function (component,event,helper) {
        var params = {
            eventIDString : component.get("v.recordId"),
            rsvpToken : helper.getUrlParameter('token')
        };

        // If this cmp is embedded by another and that parent component passes along peakResponseRSVP, don't bother getting it again!
        if (component.get("v.peakResponseRSVP") == null){
            helper.getEventRSVP(component,event,helper,params);
        } else {
            component.set("v.isInit",true);
        }
    },
    updateRSVP: function  (component,event,helper) {
        component.set("v.isLoading",true);
        // Get the current RSVP and change to NO - remember, this RSVP is first one in list
        var peakResponseRSVP = component.get("v.peakResponseRSVP");
        // Set params
        var params = {
            eventRSVP: peakResponseRSVP.results[0],
            inviteURL: helper.getUrlParameter('inviteURL'),
            productsURL: component.get("v.eventProductsUrl")
        };

        helper.doCallout(component,'c.updateSingleRSVP',params,false).then(function(response){
            component.set("v.isLoading",false);
            if (response.success){
                // Update the view's reference to the RSVP list
                component.set("v.peakResponseRSVP",response);
                // helper.showToast('Success',response.messages[0]);
                // component.set("v.status",response);
            } else {
                console.log(response.messages[0]);
                helper.showToast('Error',response.messages[0]);
            }
        });
    }
})