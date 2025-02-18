// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	setSitePrefix: function (component) {
		var action = component.get("c.getSitePrefix");

		action.setCallback(this, function (actionResult) {
			var sitePath = actionResult.getReturnValue();
			component.set("v.sitePrefix", sitePath.replace("/s", ""));
		});
		$A.enqueueAction(action);
	},

	sortByUpcoming: function (component) {
		var appEvent = $A.get("e.c:SVNSUMMITS_Events_SortBy_Filter_Event");

		appEvent.setParams({
			"sortBy": "Upcoming",
			"sortByLabel": component.get("v.sortByUpcoming"),
			"listViewMode": component.get('v.listViewMode'),
		});
		appEvent.fire();
	},


	sortByTopAttendees: function (component) {
		var appEvent = $A.get("e.c:SVNSUMMITS_Events_SortBy_Filter_Event");

		appEvent.setParams({
			"sortBy": "TopAttendees",
			"sortByLabel": component.get("v.sortByAttendance"),
			"listViewMode": component.get('v.listViewMode'),
		});
		appEvent.fire();
	}
})