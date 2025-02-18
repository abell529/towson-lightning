// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	doInit: function (component, event, helper) {
		helper.getSitePrefix(component);

		var appEvent = $A.get("e.c:SVNSUMMITS_Events_SortBy_Filter_Event");

		appEvent.setParams({
			"sortBy": component.get("v.sortBy"),
			"listViewMode": component.get("v.defaultView"),
			"sortByLabel": component.get("v.sortByLabel"),
		});

		appEvent.fire();
	},

	setHeaderValues: function (component, event, helper) {
		var totalResults = event.getParam("totalResults");
		component.set("v.numberOfResults", totalResults);

		var sortByLabel = event.getParam("sortByLabel");

		if (sortByLabel) {
			component.set("v.sortByLabel", sortByLabel);
		}

		helper.hideSpinner(component);
	},

	setParameters: function (component, event, helper) {
		var appEvent = $A.get("e.c:SVNSUMMITS_Events_SortBy_Filter_Event");

		appEvent.setParams({
			"sortBy": component.get("v.sortBy"),
			"listViewMode": component.get("v.defaultView"),
			"sortByLabel": component.get("v.sortByLabel"),
		});

		appEvent.fire();
	},

	setSitePrefix: function (component, event, helper) {
		helper.getSitePrefix(component);
		helper.debug(component, "Method called", null);
	},

	//Changed due to resolve the java script Error of Renderer/afterRender
	afterScriptsLoaded: function (component, event, helper) {
		svg4everybody();
	},

	gotoUrl: function (component, event, helper) {
		var createUrl = component.get('v.createButtonURL');
		var urlEvent = $A.get("e.force:navigateToURL");

		urlEvent.setParams({
			"url": createUrl
		});

		urlEvent.fire();
	},

	onSortChange: function (component, event, helper) {
		helper.showSpinner(component);
		// get the current selection
		var selection = event.target.value;

		component.set('v.currentOption', selection);
		component.set('v.sortBy', selection);
		component.set('v.sortByLabel', selection === 'Upcoming' ?
			$A.get('$Label.c.ss_label_Upcoming') : $A.get('$Label.c.ss_label_TopAttendance'));

		var appEvent = $A.get("e.c:SVNSUMMITS_Events_SortBy_Filter_Event");

		appEvent.setParams({
			"sortBy": selection,
			"sortByLabel": component.get('v.sortByLabel'),
			"listViewMode": component.get("v.listViewMode")
		});

		appEvent.fire();
	},

	setListView: function (component, event, helper) {
		helper.showSpinner(component);

		$('.CCEVENTSLCSVNSUMMITS_Events_Date_Filter').show();
		$A.util.removeClass(component.find('calendarBTN'), 'btnActive');
		$A.util.addClass(component.find('listBTN'), 'btnActive');

		// make sure we show the sort
		var dropDown = component.find('sortDropdown');
		$A.util.removeClass(dropDown, 'slds-hide');

		var appEvent = $A.get("e.c:SVNSUMMITS_Events_SortBy_Filter_Event");
		appEvent.setParams({
			"sortBy": component.get("v.sortBy"),
			"listViewMode": component.find("List").get("v.value"),
		});
		appEvent.fire();
	},

	setCalendarView: function (component, event, helper) {
		helper.showSpinner(component);

		$('.CCEVENTSLCSVNSUMMITS_Events_Date_Filter').hide();

		$A.util.addClass(component.find('calendarBTN'), 'btnActive');
		$A.util.removeClass(component.find('listBTN'), 'btnActive');

		var dropDown = component.find('sortDropdown');
		$A.util.addClass(dropDown, 'slds-hide');

		var appEvent = $A.get("e.c:SVNSUMMITS_Events_SortBy_Filter_Event");

		// Calendar view is always in 'Upcoming'

		appEvent.setParams({
			"sortBy": 'Upcoming',
			"listViewMode": component.find("Calendar").get("v.value"),
		});

		appEvent.fire();
	},

	setDisplayMode: function (component, event, helper) {
		var listViewMode = event.getParam("listViewMode");
		component.set("v.listViewMode", listViewMode);
	}
})