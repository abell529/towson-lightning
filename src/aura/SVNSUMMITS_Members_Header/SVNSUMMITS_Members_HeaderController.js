// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	setNoOfMembers: function (component, event, helper) {
		var numberOfMembers = event.getParam("totalResults");
		component.set("v.numberOfMembers", numberOfMembers);
	},

	selectSortBy: function (component, event, helper) {
		var appEvent = $A.get("e.c:SVNSUMMITS_Members_SortBy_Event");

		appEvent.setParams({
			"sortBy": component.get('v.sortBy')
		});

		appEvent.fire();
	}
})