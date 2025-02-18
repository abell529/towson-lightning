// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	//Initialize method for list view component
	doInit: function (component, event, helper) {
		helper.debug(component, 'List Components called..', null);
		var appEvent = $A.get("e.c:SVNSUMMITS_Events_DisplayMode_Event");
		appEvent.setParams({
			"listViewMode": component.get("v.listViewMode")
		});
		appEvent.fire();

		var url = window.location.href;
		if (url.indexOf('?') != -1) {
			url = url.substring(0, url.indexOf('?'));
		}

		component.set("v.currentURL", encodeURIComponent(url));

		var urlID = url.split("/").pop();

		urlID = decodeURIComponent(urlID);
		urlID = urlID.replace(/#/g, "");

		var filterOn = component.get("v.filterOn");

		if (filterOn === "Search Term") {
			component.set("v.searchstr", urlID);
		}
		else if (filterOn === "Topic Value") {
			component.set("v.topicValue", urlID);
		}
		else if (filterOn === "Group") {
			component.set("v.topicValue", urlID);
		}
		else {
			component.set("v.filterByTopic", component.get("v.recordId"));
		}

        helper.get_SitePrefix(component);
		helper.getEventsHelper(component);
		helper.sortByShowHide(component);

		component.set("v.init", true);
	},

	//Get Next method for next page and pagination
	getNextPage: function (component, event, helper) {
		component.set("v.wrappedEvents.objEventList", null);
		helper.getNextPage(component, event);
	},

	//Get Previous method for Previous page and pagination
	getPreviousPage: function (component, event, helper) {
		component.set("v.wrappedEvents.objEventList", null);
		helper.getPreviousPage(component, event);
	},

	//Get Previous method for Previous page and pagination
	setDates: function (component, event, helper) {
		var fromDate = event.getParam("fromDate");
		var toDate = event.getParam("toDate");

		component.set("v.fromDate", fromDate);
		component.set("v.toDate", toDate);

		helper.getEventsHelper(component);
	},

	// Set topics method
	setTopic: function (component, event, helper) {
		var filterByTopic = event.getParam("filterByTopic");

		component.set("v.filterByTopic", filterByTopic);

		helper.getEventsHelper(component);
	},

	setLocation : function (component, event,helper) {
		var locationFilter = event.getParam('locationString');

		component.set('v.filterOn', 'LocationName');
		component.set('v.filterType', locationFilter);

		helper.getEventsHelper(component);
	},

	// Sort By lists method
	sortBy: function (component, event, helper) {
		if (!component.get("v.init")) {
			return;
		}

		var sortBy = event.getParam("sortBy");
		var sortByLabel = event.getParam('sortByLabel');
		var listViewMode = event.getParam("listViewMode");

		component.set("v.listViewMode", listViewMode);
		console.log('listViewMode before event = ' + component.get('v.listViewMode'));

		//if(sortBy != component.get("v.sortBy")){
		component.set("v.sortBy", sortBy);
		component.set("v.sortByLabel", sortByLabel);

		var appEvent = $A.get("e.c:SVNSUMMITS_Events_DisplayMode_Event");
		appEvent.setParams({
			"listViewMode": listViewMode
		});
		appEvent.fire();
		console.log('listViewMode = ' + component.get('v.listViewMode'));

		helper.getEventsHelper(component);
		//}
	},

	// Sort By Upcoming values
	sortByUpcoming: function (component, event, helper) {
		if (component.get("v.sortBy") !== 'Upcoming') {
			component.set("v.sortBy", component.find("Upcoming").get("v.value"));

			helper.getEventsHelper(component, event);

			var cmpTarget = component.find('upcommingImg');
			$A.util.removeClass(cmpTarget, 'hideImg');
			$A.util.addClass(cmpTarget, 'showImg');

			var cmpTarget1 = component.find('topAttendanceImg');
			$A.util.removeClass(cmpTarget1, 'showImg');
			$A.util.addClass(cmpTarget1, 'hideImg');
		}

	},

	//Sort by top attendees
	sortByTopAttendees: function (component, event, helper) {
		if (component.get("v.sortBy") !== 'TopAttendees') {
			component.set("v.sortBy", component.find("TopAttendees").get("v.value"));

			helper.getEventsHelper(component, event);

			var cmpTarget = component.find('topAttendanceImg');
			$A.util.removeClass(cmpTarget, 'hideImg');
			$A.util.addClass(cmpTarget, 'showImg');

			var cmpTarget1 = component.find('upcommingImg');
			$A.util.removeClass(cmpTarget1, 'showImg');
			$A.util.addClass(cmpTarget1, 'hideImg');
		}
	},
})