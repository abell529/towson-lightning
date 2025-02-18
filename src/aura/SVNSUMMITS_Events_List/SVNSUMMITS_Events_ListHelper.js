// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
    getEventsHelper: function(component, event) {
        var self = this;

        // Load  Events data
        var action = component.get("c.getEvents");

        this.dumpEventRequest(component, 'getEventsHelper');

        action.setParams({
            eventListFlag: component.get("v.displayMode") == 'Compact' ? false : true,
            numberofresults: component.get("v.numberofresults"),
            listSize: component.get("v.listSize"),
            strfilterType: component.get("v.filterType"),
            strRecordId: component.get("v.topicValue"),
            networkId: '',
            sortBy: component.get("v.sortBy"),
            filterByTopic: component.get("v.filterByTopic"),
            topicName: component.get("v.topicValue"),
	        filterOn: component.get("v.filterOn"),
	        filterBySearchTerm: '',
	        searchTerm: component.get("v.searchstr"),
            fromDate: component.get("v.fromDate"),
            toDate: component.get("v.toDate"),
            listViewMode: component.get("v.listViewMode"),
            sortByLabel: component.get("v.sortByLabel")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            self.debug(component, "Event_ListHelper.js - getEventsHelper() callback response state: ", state);

            var sortLabel = component.get('v.sortByLabel');
            if (component.isValid() && state === "SUCCESS") {
                self.debug(component, "Return value:", response.getReturnValue());

                var eventsListWrapper = self.parseNamespace(component, response.getReturnValue());

                //updated code to hide recommended component if no records found
                if (component.get("v.displayMode") === 'Compact') {
                    if (eventsListWrapper.objEventList.length === 0) {
                        $('.CCEVENTSLCSVNSUMMITS_Events_List').hide();
                    }
                }
                component.set("v.totalEvents", eventsListWrapper.totalResults);

                var appEvent = $A.get("e.c:SVNSUMMITS_Events_Header_Event");
                appEvent.setParams({
                    "sortByLabel": sortLabel,
                    "totalResults": eventsListWrapper.totalResults

                });
                appEvent.fire();

				component.set("v.wrappedEvents", self.updateEventsWrapper(component, eventsListWrapper));
            }
            else if (state === "ERROR") {
                self.debug(component, "problem in getEventsHelper while calling getEvents");
                self.debug(component, response.getError());
            }
        });

        $A.enqueueAction(action);
    },

	updateEventsWrapper : function (component, eventsListWrapper) {

		//eventsListWrapper.strTimeZone = this.getTimeZone(eventsListWrapper);

		console.log('wrapper begin');
	    for (var i = 0; i < eventsListWrapper.objEventList.length; i++) {
	        eventsListWrapper.objEventList[i].showTo = false;
	        eventsListWrapper.objEventList[i].showEndDate = false;

	        var startDate, startTime;
	        var endDate, endTime;
			var localeStartDate, localeEndDate;
			var startDay, startMonth, startYear;
			var endDay, endMonth, endYear;

			if (eventsListWrapper.objEventList[i].GroupId__c) {
				eventsListWrapper.objEventList[i].groupName = eventsListWrapper.groupIdToName[eventsListWrapper.objEventList[i].GroupId__c];
			}
            console.log(eventsListWrapper);
	        if (eventsListWrapper.objEventList[i].Start_DateTime__c !== null) {
	            console.log('HI');
                if (typeof moment.tz === 'function') {
                    console.log('function');
                    localeStartDate = moment.tz(eventsListWrapper.objEventList[i].Start_DateTime__c,
                        eventsListWrapper.strTimeZone).format('YYYY-MM-DD HH:mm:ss');
                } else {
                    console.log('nonfunction');
                    localeStartDate = moment(eventsListWrapper.objEventList[i].Start_DateTime__c)
                        .format('YYYY-MM-DD HH:mm:ss');
                }
                console.log(localeStartDate);
	            // localeStartDate = moment.tz(eventsListWrapper.objEventList[i].Start_DateTime__c,
	            //                             eventsListWrapper.strTimeZone)
	            //                         .format('YYYY-MM-DD HH:mm:ss');

                eventsListWrapper.objEventList[i].localeStartDate = localeStartDate;

	            startDate = moment(eventsListWrapper.objEventList[i].Start_DateTime__c).format('YYYY-MM-DD HH:mm:ss');
	            startTime = moment(startDate).toDate();
	            eventsListWrapper.objEventList[i].strMinute = moment(startTime);
	            var days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
	            eventsListWrapper.objEventList[i].strDay = moment(startTime).format('ddd');
	        }


	        if (eventsListWrapper.objEventList[i].End_DateTime__c !== null) {
	            // localeEndDate = moment.tz(eventsListWrapper.objEventList[i].End_DateTime__c,
	            //                           eventsListWrapper.strTimeZone)
	            //                       .format('YYYY-MM-DD HH:mm:ss');
                if (typeof moment.tz === 'function') {
                    localeEndDate = moment.tz(eventsListWrapper.objEventList[i].End_DateTime__c,
                        eventsListWrapper.strTimeZone).format('YYYY-MM-DD HH:mm:ss');
                } else {
                    localeEndDate = moment(eventsListWrapper.objEventList[i].End_DateTime__c)
                        .format('YYYY-MM-DD HH:mm:ss');
                }

                eventsListWrapper.objEventList[i].localeEndDate = localeEndDate;

	            endDate = moment(eventsListWrapper.objEventList[i].End_DateTime__c).format('YYYY-MM-DD HH:mm:ss');
	            endTime = moment(endDate).toDate();
	            eventsListWrapper.objEventList[i].endMinute = moment(endTime);
	        }

	        if (startTime !== null && endTime !== null) {
	            // var diffDays = Math.round(Math.abs((endTime.getTime() - startTime.getTime()) / (24 * 60 * 60 * 1000)));
                var diffDays = moment.duration((moment(endTime) - moment(startTime)), days).days();
	            eventsListWrapper.objEventList[i].daysOfMultiDaysEvent = diffDays;
	            eventsListWrapper.objEventList[i].showTo = true;
	        }

	        startDay   = moment(eventsListWrapper.objEventList[i].Start_DateTime__c).format("DD");
	        startMonth = moment(eventsListWrapper.objEventList[i].Start_DateTime__c).format("MMM");
	        startYear  = moment(eventsListWrapper.objEventList[i].Start_DateTime__c).format("YYYY");

	        endDay     = moment(eventsListWrapper.objEventList[i].End_DateTime__c).format("DD");
	        endMonth   = moment(eventsListWrapper.objEventList[i].End_DateTime__c).format("MMM");
	        endYear    = moment(eventsListWrapper.objEventList[i].End_DateTime__c).format("YYYY");

	        eventsListWrapper.objEventList[i].strMonth = startMonth;
	        eventsListWrapper.objEventList[i].intDate  = startDay;
            eventsListWrapper.objEventList[i].strYear  = startYear;

			if (startDay !== endDay || startMonth !== endMonth || startYear !== endYear) {
				eventsListWrapper.objEventList[i].showEndDate = true;
			    eventsListWrapper.objEventList[i].endDay = endDay;
			    eventsListWrapper.objEventList[i].endMonth = endMonth;
			    eventsListWrapper.objEventList[i].endYear = endYear;
            }

	        if (component.get("v.titletext") === 'Recommended For You' ? true : false) {
	            if (eventsListWrapper.objEventList[i].Name.length > 80) {
	                eventsListWrapper.objEventList[i].Name = eventsListWrapper.objEventList[i].Name.substring(0, 77);
	                eventsListWrapper.objEventList[i].Name = eventsListWrapper.objEventList[i].Name + '...';
	            }
	        } else {
	            if (eventsListWrapper.objEventList[i].Name.length > 80) {
	                eventsListWrapper.objEventList[i].Name = eventsListWrapper.objEventList[i].Name.substring(0, 77);
	                eventsListWrapper.objEventList[i].Name = eventsListWrapper.objEventList[i].Name + '...';
	            }
	        }

	        eventsListWrapper.objEventList[i].topics1 = [];
	        eventsListWrapper.objEventList[i].topics1.push(eventsListWrapper.eventsToTopicsMap[eventsListWrapper.objEventList[i].Id]);
	        eventsListWrapper.objEventList[i].topics = [];

	        /* Logic for topics will be displayed till 27 characters only */
	        if (eventsListWrapper.objEventList[i].topics1 !== undefined) {
	            for (var j = 0; j < eventsListWrapper.objEventList[i].topics1.length; j++) {
	                var eventsname = '';
	                if (eventsListWrapper.objEventList[i].topics1[j] !== undefined) {
	                    for (var jj = 0; jj < eventsListWrapper.objEventList[i].topics1[j].length; jj++) {
	                        eventsname += eventsListWrapper.objEventList[i].topics1[j][jj].Topic.Name;
	                        if (eventsname.length <= 27 && eventsListWrapper.objEventList[i].topics !== undefined) {
	                            eventsListWrapper.objEventList[i].topics.push(eventsListWrapper.objEventList[i].topics1[j][jj]);
	                        }
	                    }
	                }
	            }
	        }
	    }
        console.log(eventsListWrapper);
        console.log('wrapper end');
        return eventsListWrapper;
    },

    getNextPage: function(component, event) {
        var action = component.get("c.nextPage");
        var self   = this;

	    this.dumpEventRequest(component, 'getNextPage');

	    action.setParams({
            eventListFlag: component.get("v.displayMode") == 'Compact' ? false : true,
            numberofresults: component.get("v.numberofresults"),
            listSize: component.get("v.listSize"),
            pageNumber: component.get("v.wrappedEvents").pageNumber,
            strfilterType: component.get("v.filterType"),
            strRecordId: component.get("v.topicValue"),
            networkId: '',
            sortBy: component.get("v.sortBy"),
            filterByTopic: component.get("v.filterByTopic"),
            topicName: component.get("v.filterByTopic"),
            filterBySearchTerm: component.get("v.filterOn"),
            searchTerm: component.get("v.searchstr"),
            filterOn: component.get("v.filterOn"),
            fromDate: component.get("v.fromDate"),
            toDate: component.get("v.toDate"),
            listViewMode: component.get("v.listViewMode")
        });

        action.setCallback(this, function(response) {
	        var eventsListWrapper = self.parseNamespace(component, response.getReturnValue());

			component.set("v.wrappedEvents", self.updateEventsWrapper(component, eventsListWrapper));

            var pageNumberComp = self.component.find("pageNumber");
            pageNumberComp.set("v.value", eventsListWrapper.pageNumber);
        });

        $A.enqueueAction(action);
    },

    getPreviousPage: function(component, event) {
        var action = component.get("c.previousPage");
        var self   = this;

	    this.dumpEventRequest(component, 'getPreviousPage');

	    action.setParams({
            eventListFlag: component.get("v.displayMode") == 'Compact' ? false : true,
            numberofresults: component.get("v.numberofresults"),
            listSize: component.get("v.listSize"),
            pageNumber: component.get("v.wrappedEvents").pageNumber,
            strfilterType: component.get("v.filterType"),
            strRecordId: component.get("v.topicValue"),
            networkId: '',
            sortBy: component.get("v.sortBy"),
            filterByTopic: component.get("v.filterByTopic"),
            topicName: component.get("v.filterByTopic"),
            filterBySearchTerm: '',
            searchTerm: component.get("v.searchstr"),
            filterOn: component.get("v.filterOn"),
            fromDate: component.get("v.fromDate"),
            toDate: component.get("v.toDate"),
            listViewMode: component.get("v.listViewMode")
        });

        action.setCallback(this, function(response) {
	        var eventsListWrapper = self.parseNamespace(component, response.getReturnValue());
			component.set("v.wrappedEvents", self.updateEventsWrapper(component, eventsListWrapper));

            var pageNumberComp = self.component.find("pageNumber");
            pageNumberComp.set("v.value", eventsListWrapper.pageNumber);
        });

        $A.enqueueAction(action);
    },

    get_SitePrefix: function(component) {
        var action = component.get("c.getSitePrefix");

        action.setCallback(this, function(response) {
            var sitePath = response.getReturnValue();
            component.set("v.sitePath", sitePath);
            component.set("v.sitePrefix", sitePath.replace("/s", ""));

        });
        $A.enqueueAction(action);
    },

    sortByShowHide: function(component) {
        $(window).click(function() {
            $('#dropDwnBtn_menu').hide();
        });

        $('#dropDwnBtn').click(function(even) {
            even.stopPropagation();
        });

        $('#dropDwnBtn').click(function() {
            $('#dropDwnBtn_menu').toggle();
        });

        $('#dropDwnBtn_menu').click(function() {
            if ($('#dropDwnBtn_menu').show()) {
                $('#dropDwnBtn_menu').hide();
            } else {
                $('#dropDwnBtn_menu').show();
            }
        });
    },

	// adjust for guest user
    getTimeZone : function(eventsListWrapper) {
        return !eventsListWrapper.strTimeZone || eventsListWrapper.strTimeZone === 'GMT'
            ? moment.tz.guess()
			: eventsListWrapper.strTimeZone;
    },

	dumpEventRequest : function (component, callerId) {
		var debugMode = component.get("v.debugMode");
		if (debugMode) {
			console.log(callerId);
			console.log('eventListFlag:     ' + component.get("v.displayMode") == 'Compact' ? false : true);
			console.log('numberofresults:   ' + component.get("v.numberofresults"));
			console.log('listSize:          ' + component.get("v.listSize"));
			console.log('strfilterType      ' + component.get("v.filterType"));
			console.log('strRecordId        ' + component.get("v.topicValue"));
			console.log('sortBy             ' + component.get("v.sortBy"));
			console.log('filterByTopic      ' + component.get("v.filterByTopic"));
			console.log('topicName          ' + component.get("v.topicValue"));
			console.log('filterBySearchTerm ' + '');
			console.log('searchTerm         ' + component.get("v.searchstr"));
			console.log('filterOn           ' + component.get("v.filterOn"));
			console.log('fromDate           ' + component.get("v.fromDate"));
			console.log('toDate             ' + component.get("v.toDate"));
			console.log('listViewMode       ' + component.get("v.listViewMode"));
			console.log('sortByLabel        ' + component.get("v.sortByLabel"));
		}
	},

    debug: function(component, msg, variable) {
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