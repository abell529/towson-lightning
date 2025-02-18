// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
    fetchUrl : function(component, event, helper) {
        helper.debug(component,"Header Called",null);

        var eventRecordId = component.get("v.recordId");
        var action = component.get("c.getEventName");
        action.setParams({
            eventRecordId: eventRecordId
        });
        action.setCallback(this, function(response) {
            var eventName= response.getReturnValue();
            component.set("v.wrappedEventsObj", eventName);
        });
        $A.enqueueAction(action);
        var action1 = component.get("c.getSitePrefix");
        action1.setCallback(this, function(actionResult) {
            var sitePath = actionResult.getReturnValue();
            component.set("v.sitePath", sitePath);
        });
        $A.enqueueAction(action1);
    }
})