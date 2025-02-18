/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/12/18.
 */
({
    getEventRSVP: function(component, event, helper, params) {
        helper.doCallout(component,'c.getRSVPForEvent',params).then(function(response){
            if (response.success){
                component.set("v.peakResponseRSVP",response);
                component.set('v.isInit', true);
            } else {
                helper.showToast('Error',response.messages[0]);
            }
            component.set('v.isLoading', false);
        });
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
    }
})