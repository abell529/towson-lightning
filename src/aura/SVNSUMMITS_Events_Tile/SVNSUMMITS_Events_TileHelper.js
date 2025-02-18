// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	get_SitePrefix : function(component) {
    	var action = component.get("c.getSitePrefix");
        action.setCallback(this, function(actionResult) {
            var sitePath = actionResult.getReturnValue();
            component.set("v.sitePath", sitePath);
            component.set("v.sitePrefix", sitePath.replace("/s",""));
		});
        $A.enqueueAction(action);
    }
})