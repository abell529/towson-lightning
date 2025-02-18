// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({

	doInit: function (component, event, helper) {
		helper.setSitePrefix(component);
		if (component.get('v.sortBy') === 'Upcoming') {
			var selectLabel = $("#label-holder").attr("data-Upcoming");
			helper.sortByUpcoming(component);
		} else if (component.get('v.sortBy') === 'TopAttendees') {
			var selectLabel = $("#label-holder").attr("data-TopAttendees");
			helper.sortByTopAttendees(component);
		}
	},

	setSortOption: function (component, event, helper) {

		if (component.get('v.sortBy') === 'Upcoming') {
			//var selectLabel = component.find('SortSelect').get("v.value");
			//var thisSelect = component.find('SortSelect');
			var selectLabel = $("#label-holder").attr("data-Upcoming");
			//var thisParent = thisSelect.parentElement;
			//var selectLabel = document.getElementById('label-holder').getAttribute('data-Upcoming');
			//var thisSelected = thisParent.getAttribute('data-Upcoming');
			//console.log("selectLabel = " + selectLabel );

			//component.set('v.sortByLabel', selectLabel);

			helper.sortByUpcoming(component);
		} else if (component.get('v.sortBy') === 'TopAttendees') {
			//var selectLabel = component.find('SortSelect').get("v.value");
			var selectLabel = $("#label-holder").attr("data-TopAttendees");
			//component.set('v.sortByLabel', selectLabel);
			//console.log("selectLabel = " + selectLabel );

			helper.sortByTopAttendees(component);
		}
	}


})