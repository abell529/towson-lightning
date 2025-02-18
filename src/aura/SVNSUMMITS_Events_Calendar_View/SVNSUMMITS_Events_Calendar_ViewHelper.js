// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	// Initialize the calendar events
	initializeCalendar: function (component) {
		var sitePath = component.get("v.sitePath");
		var action = component.get("c.getEvents");

		action.setParams({
			eventListFlag: component.get("v.titletext") === 'Recommended For You' ? false : true,
			numberofresults: component.get("v.numberofresults"),
			listSize: component.get("v.listSize"),
			strfilterType: component.get("v.filterType"),
			strRecordId: component.get("v.topicValue"),
			networkId: '',
			sortBy: component.get("v.sortBy"),
			filterByTopic: component.get("v.filterByTopic"),
			topicName: component.get("v.filterByTopic"),
			filterBySearchTerm: '',
			searchTerm: component.get("v.searchstr"),
			filterOn: component.get("v.filterOn"),
			fromDate: '',
			toDate: '',
			listViewMode: component.get("v.listViewMode")
		});

		action.setCallback(this, function (response) {
			var state = response.getState();

			if (component.isValid() && state === "SUCCESS") {
				var eventsListWrapper = this.parseNamespace(component, response.getReturnValue());
				var events = [];

				var appEvent = $A.get("e.c:SVNSUMMITS_Events_Header_Event");
				appEvent.setParams({
					"totalResults": eventsListWrapper.totalResults,
				});
				appEvent.fire();

				for (var i = 0; i < eventsListWrapper.objEventList.length; i++) {
					// Note:
					//   add 1 day to end date - full calendar needs an 'exclusive' end date (next day at 0:00:00)
					events.push({
						'Id': eventsListWrapper.objEventList[i].Id,
						'title': eventsListWrapper.objEventList[i].Name,
						'allDay': eventsListWrapper.objEventList[i].All_Day_Event__c,
						'start': moment(eventsListWrapper.objEventList[i].Start_DateTime__c),
						'end': eventsListWrapper.objEventList[i].All_Day_Event__c
							? moment(eventsListWrapper.objEventList[i].End_DateTime__c).add(1, 'days')
							: moment(eventsListWrapper.objEventList[i].End_DateTime__c),
						'url': '/event/' + eventsListWrapper.objEventList[i].Id
					});
				}

				component.set('v.eventCalendarValues', events);
				this.initializeCalendarJQ(component);
			}
		});

		$A.enqueueAction(action);
	},

	// Initialize the calendar
	initializeCalendarJQ: function (component) {
		$('#calendar').fullCalendar('destroy');
		$('#calendar').fullCalendar({
			header: {
				left: 'month,agendaWeek,agendaDay',
				center: 'title',
				right: 'prev,today,next'
			},
			events: component.get('v.eventCalendarValues'),
			eventClick: function (event) {
				if (event.url) {
					var urlEvent = $A.get("e.force:navigateToURL");
					urlEvent.setParams({
						"url": event.url
					});
					urlEvent.fire();
					return false;
				}
			},
			eventLimit: true,
			views: {
				agenda: {
					eventLimit: 5
				}
			}
		});
	},

	// Re-Initialize the calendar and refresh on basis of topics selected
	CalendarViewTopicFilter: function (component, event) {
		var filterByTopic = event.getParam("filterByTopic");

		var action = component.get("c.getEvents");
		action.setParams({
			eventListFlag: component.get("v.titletext") == 'Recommended For You' ? false : true,
			numberofresults: component.get("v.numberofresults"),
			listSize: component.get("v.listSize"),
			strfilterType: component.get("v.filterType"),
			strRecordId: component.get("v.topicValue"),
			networkId: '',
			sortBy: component.get("v.sortBy"),
			filterByTopic: filterByTopic,
			topicName: filterByTopic,
			filterBySearchTerm: '',
			searchTerm: component.get("v.searchstr"),
			filterOn: component.get("v.filterOn"),
			fromDate: null,
			toDate: null,
			listViewMode: component.get("v.listViewMode")
		});

		action.setCallback(this, function (response) {
			var state = response.getState();

			if (component.isValid() && state === "SUCCESS") {
				var eventsListWrapper = this.parseNamespace(response.getReturnValue());
				var events = [];

				for (var i = 0; i < eventsListWrapper.objEventList.length; i++) {
					var startDate = moment(eventsListWrapper.objEventList[i].Start_DateTime__c).format('YYYY-MM-DD');
					var endDate = moment(eventsListWrapper.objEventList[i].End_DateTime__c).format('YYYY-MM-DD');

					events.push({
						'title': eventsListWrapper.objEventList[i].Name,
						'start': startDate,
						'end': endDate,
						'Id': eventsListWrapper.objEventList[i].Id,
						'url': '/event/' + eventsListWrapper.objEventList[i].Id
					});
				}

				component.set('v.eventCalendarValues', events);
				this.initializeCalendarJQ(component);
			}
		});

		$A.enqueueAction(action);
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