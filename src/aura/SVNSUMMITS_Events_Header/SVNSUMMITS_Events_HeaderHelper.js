// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	getSitePrefix: function (component) {
		var action = component.get("c.getSitePrefix");
		action.setCallback(this, function (actionResult) {
			var sitePath = actionResult.getReturnValue();
			component.set("v.sitePath", sitePath);
			component.set("v.sitePrefix", sitePath.replace("/s", ""));
		});
		$A.enqueueAction(action);

		var action1 = component.get("c.isObjectCreatable");
		action1.setCallback(this, function (actionResult1) {
			var isObjectCreatable = actionResult1.getReturnValue();
			component.set("v.isObjectCreatable", isObjectCreatable);
		});
		$A.enqueueAction(action1);
	},

	showSpinner: function (component, event, helper) {
		var spinner = component.find("spinner");
		$A.util.removeClass(spinner, 'slds-hide');
		//$A.util.toggleClass(spinner, "slds-hide");
	},

	hideSpinner: function (component, event, helper) {
		var spinner = component.find("spinner");
		$A.util.addClass(spinner, 'slds-hide');
		//$A.util.toggleClass(spinner, "slds-hide");
	},

	debug: function (component, msg, variable) {

		var debugMode = component.get("v.debugMode");

		if (debugMode) {
			if (msg) {
				console.log(msg);
			}
			if (variable) {
				console.log(variable);
			}
		}
	}

})