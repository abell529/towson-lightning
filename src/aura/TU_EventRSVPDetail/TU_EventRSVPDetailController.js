/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/12/18.
 */
({
    initRSVPDetail: function (component,event,helper) {
        var faComplete = helper.getUrlParameter('fa');

        if (faComplete === 'true') {
            window.console.log(faComplete);
            window.close();
        }
        var params = {
            eventIDString : component.get("v.recordId"),
            rsvpToken : helper.getUrlParameter('token'),
        };

        // If this cmp is embedded by another and that parent component passes along peakResponseRSVP, don't bother getting it again!
        if (component.get("v.peakResponseRSVP") == null){
            helper.getEventRSVP(component,event,helper,params);
        } else {
            component.set("v.isInit",true);
        }
    }
})