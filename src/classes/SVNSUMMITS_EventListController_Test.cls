/* Copyright ©2016-2017 7Summits Inc. All rights reserved. */

/*
     Name : SVNSUMMITS_EventListController_Test
    Description : Test class for SVNSUMMITS_EventListController class
    Date : 25/5/2016
*/

@isTest
global class SVNSUMMITS_EventListController_Test {
	static final String CUSTOMER_COMMUNITY_USER       = 'Tiger Connect Community User';
	static final String CUSTOMER_COMMUNITY_USER_CLONE = 'Tiger Connect Community User';


	static testMethod void test_EventsFeatures() {
		SVNSUMMITS_EventListWrapper eventWrapper = new SVNSUMMITS_EventListWrapper();
		system.assertNotEquals(null, eventWrapper);

		List<Event__c> eventList = SVNSUMMITS_EventUtility.createEventsRecords(1001);
		system.assertEquals(eventList.size(), 1001);

		List<Event__c> eventUnlistedList = SVNSUMMITS_EventUtility.createEventsRecords(50);
		system.assertEquals(eventUnlistedList.size(), 50);

		List<Topic> topics = SVNSUMMITS_EventUtility.createTopic(1001);
		system.assertEquals(topics.size(), 1001);

		List<Event_RSVP__c> eventRSVPlst = SVNSUMMITS_EventUtility.createRSVPRecords(7, eventList);
		system.assertEquals(eventRSVPlst.size(), 7);

		eventRSVPlst = SVNSUMMITS_EventUtility.deleteRSVPRecords(3, eventRSVPlst);

		TopicAssignment topicAssignment = SVNSUMMITS_EventUtility.createTopicAssignment(topics[0].id, eventList[0].id);

		Boolean eventListFlag = true;
		Integer numberofresults = 1001;
		Integer listSize = 1001;
		Integer pageNumber = 1;
		String strfilterType = null;
		String strRecordId = 'event-list-view-page';
		String networkId = '';
		String allDayEventStartDate = '';
		String allDayEventEndDate = '';
		String sortBy = null;
		String filterByTopic = null;
		String topicName = null;
		Boolean filterBySearchTerm = false;
		String searchTerm = null;
		String filterOn = 'None';
		String fromDate = null;
		String toDate = null;
		String listViewMode = 'List';

		SVNSUMMITS_EventListController.getSitePrefix();
		SVNSUMMITS_EventListController.getSessionId();

		//Create Community user
		List<user> lstOfUser = SVNSUMMITS_EventUtility.createUsers(1, CUSTOMER_COMMUNITY_USER);

		//Create Community User
		//As we are using custom object News, we have created user with the custom Community Profile,
		//Because standard community profile do not allow to give permissions to such custom objects.
		User communityUser = SVNSUMMITS_EventUtility.createCommunityUsers(CUSTOMER_COMMUNITY_USER_CLONE);

		System.runAs(communityUser) {
			test.startTest();
			//check with date filter on list view with topic filter and sort by filter

			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			fromDate = String.valueOf(system.today());
			toDate = String.valueOf(system.today().addDays(5));
			filterByTopic = topics[0].id;
			topicName = 'Test000';
			sortBy = 'Upcoming';

			SVNSUMMITS_EventListController.deleteAttachment(strRecordId);
			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			fromDate = String.valueOf(system.today());
			toDate = null;
			filterByTopic = topics[0].Id;
			topicName = 'Test000';
			sortBy = 'Top Attendees';

			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			fromDate = null;
			toDate = String.valueOf(system.today().addDays(5));
			filterByTopic = topics[0].Id;
			topicName = 'Test000';
			sortBy = '';
			system.assertEquals(numberofresults, 1001);

			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			//check with pagination next previous
			SVNSUMMITS_EventListController.nextPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
			SVNSUMMITS_EventListController.previousPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
			system.assertEquals(pageNumber, 1);

			//check for search page
			filterOn = 'Search Term';
			searchTerm = 'event';
			sortBy = 'Upcoming';
			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			filterOn = 'Search Term';
			searchTerm = 'event';
			sortBy = 'Top Attendees';
			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			//check with pagination next previous
			SVNSUMMITS_EventListController.nextPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
			SVNSUMMITS_EventListController.previousPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
			system.assertEquals(numberofresults, 1001);

			//check for topic page
			filterOn = 'Topic Value';
			topicName = 'Test000';
			sortBy = 'Upcoming';
			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			topicName = 'Test000';
			sortBy = 'Top Attendees';
			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			//check for recommended on detail page
			eventListFlag = false;
			filterOn = 'None';
			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, '', networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

//			//check for calendar mode
//			listViewMode = 'Calendar';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			sortBy = 'Top Attendees';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			listViewMode = 'Calendar';
//			sortBy = 'Upcoming';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, '', filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check save event
//			Event__c eventObj = new Event__c(Name = 'Test Event', Start_DateTime__c = system.today().addDays(2), End_DateTime__c = system.today().adddays(5));
//			SVNSUMMITS_EventListController.saveEvents(eventObj, topics[0].Id, allDayEventStartDate, allDayEventEndDate);
//			system.assertEquals(eventObj.Id, null);
//
//			allDayEventStartDate = String.valueOf(system.today());
//			allDayEventEndDate = String.valueOf(system.today().addDays(3));
//			Event__c eventObjNew = new Event__c(Name = 'Test Event', All_Day_Event__c = true, End_DateTime__c = system.today().adddays(5));
//			SVNSUMMITS_EventListController.isObjectEditable();
// 			SVNSUMMITS_EventListController.saveEvents(eventObjNew, topics[0].Id, allDayEventStartDate, allDayEventEndDate);
//			system.assertEquals(eventObjNew.Id, null);

			test.stopTest();
		}
	}

	static testMethod void test_EventsCalendarFeatures() {
		SVNSUMMITS_EventListWrapper eventWrapper = new SVNSUMMITS_EventListWrapper();
		system.assertNotEquals(null, eventWrapper);

		List<Event__c> eventList = SVNSUMMITS_EventUtility.createEventsRecords(1001);
		system.assertEquals(eventList.size(), 1001);

		List<Event__c> eventUnlistedList = SVNSUMMITS_EventUtility.createEventsRecords(50);
		system.assertEquals(eventUnlistedList.size(), 50);

		List<Topic> topics = SVNSUMMITS_EventUtility.createTopic(1001);
		system.assertEquals(topics.size(), 1001);

		List<Event_RSVP__c> eventRSVPlst = SVNSUMMITS_EventUtility.createRSVPRecords(7, eventList);
		system.assertEquals(eventRSVPlst.size(), 7);

		eventRSVPlst = SVNSUMMITS_EventUtility.deleteRSVPRecords(3, eventRSVPlst);

		TopicAssignment topicAssignment = SVNSUMMITS_EventUtility.createTopicAssignment(topics[0].id, eventList[0].id);

		Boolean eventListFlag = true;
		Integer numberofresults = 1001;
		Integer listSize = 1001;
		Integer pageNumber = 1;
		String strfilterType = null;
		String strRecordId = 'event-list-view-page';
		String networkId = '';
		String allDayEventStartDate = '';
		String allDayEventEndDate = '';
		String sortBy = null;
		String filterByTopic = null;
		String topicName = null;
		Boolean filterBySearchTerm = false;
		String searchTerm = null;
		String filterOn = 'None';
		String fromDate = null;
		String toDate = null;
		String listViewMode = 'List';

		SVNSUMMITS_EventListController.getSitePrefix();
		SVNSUMMITS_EventListController.getSessionId();

		//Create Community user
		List<user> lstOfUser = SVNSUMMITS_EventUtility.createUsers(1, CUSTOMER_COMMUNITY_USER);

		//Create Community User
		//As we are using custom object News, we have created user with the custom Community Profile,
		//Because standard community profile do not allow to give permissions to such custom objects.
		User communityUser = SVNSUMMITS_EventUtility.createCommunityUsers(CUSTOMER_COMMUNITY_USER_CLONE);

		System.runAs(communityUser) {
			test.startTest();
			//check with date filter on list view with topic filter and sort by filter

			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			fromDate = String.valueOf(system.today());
			toDate = String.valueOf(system.today().addDays(5));
			filterByTopic = topics[0].id;
			topicName = 'Test000';
			sortBy = 'Upcoming';

//			SVNSUMMITS_EventListController.deleteAttachment(strRecordId);
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			fromDate = String.valueOf(system.today());
//			toDate = null;
//			filterByTopic = topics[0].Id;
//			topicName = 'Test000';
//			sortBy = 'Top Attendees';
//
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			fromDate = null;
//			toDate = String.valueOf(system.today().addDays(5));
//			filterByTopic = topics[0].Id;
//			topicName = 'Test000';
//			sortBy = '';
//			system.assertEquals(numberofresults, 1001);
//
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check with pagination next previous
//			SVNSUMMITS_EventListController.nextPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			SVNSUMMITS_EventListController.previousPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			system.assertEquals(pageNumber, 1);
//
//			//check for search page
//			filterOn = 'Search Term';
//			searchTerm = 'event';
//			sortBy = 'Upcoming';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			filterOn = 'Search Term';
//			searchTerm = 'event';
//			sortBy = 'Top Attendees';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check with pagination next previous
//			SVNSUMMITS_EventListController.nextPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			SVNSUMMITS_EventListController.previousPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			system.assertEquals(numberofresults, 1001);
//
//			//check for topic page
//			filterOn = 'Topic Value';
//			topicName = 'Test000';
//			sortBy = 'Upcoming';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			topicName = 'Test000';
//			sortBy = 'Top Attendees';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check for recommended on detail page
//			eventListFlag = false;
//			filterOn = 'None';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, '', networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check for calendar mode
//			listViewMode = 'Calendar';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			sortBy = 'Top Attendees';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			listViewMode = 'Calendar';
			sortBy = 'Upcoming';
			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, '', filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

			//check save event
			Event__c eventObj = new Event__c(Name = 'Test Event', Start_DateTime__c = system.today().addDays(2), End_DateTime__c = system.today().adddays(5));
			SVNSUMMITS_EventListController.saveEvents(eventObj, topics[0].Id, allDayEventStartDate, allDayEventEndDate);
			system.assertEquals(eventObj.Id, null);

			allDayEventStartDate = String.valueOf(system.today());
			allDayEventEndDate = String.valueOf(system.today().addDays(3));
			Event__c eventObjNew = new Event__c(Name = 'Test Event', All_Day_Event__c = true, End_DateTime__c = system.today().adddays(5));
			SVNSUMMITS_EventListController.isObjectEditable();
			SVNSUMMITS_EventListController.saveEvents(eventObjNew, topics[0].Id, allDayEventStartDate, allDayEventEndDate);
			system.assertEquals(eventObjNew.Id, null);

			test.stopTest();
		}
	}

//	static testMethod void test_EventsFeaturesGuestUser() {
//		SVNSUMMITS_EventListWrapper eventWrapper = new SVNSUMMITS_EventListWrapper();
//		system.assertNotEquals(null, eventWrapper);
//
//		List<Event__c> eventList = SVNSUMMITS_EventUtility.createEventsRecords(1001);
//		system.assertEquals(eventList.size(), 1001);
//
//		List<Event__c> eventUnlistedList = SVNSUMMITS_EventUtility.createEventsRecords(50);
//		system.assertEquals(eventUnlistedList.size(), 50);
//
//		List<Topic> topics = SVNSUMMITS_EventUtility.createTopic(1001);
//		system.assertEquals(topics.size(), 1001);
//
//		List<Event_RSVP__c> eventRSVPlst = SVNSUMMITS_EventUtility.createRSVPRecords(7, eventList);
//		system.assertEquals(eventRSVPlst.size(), 7);
//
//		eventRSVPlst = SVNSUMMITS_EventUtility.deleteRSVPRecords(3, eventRSVPlst);
//
//		TopicAssignment topicAssignment = SVNSUMMITS_EventUtility.createTopicAssignment(topics[0].id, eventList[0].id);
//
//		Boolean eventListFlag = true;
//		Integer numberofresults = 1001;
//		Integer listSize = 1001;
//		Integer pageNumber = 1;
//		String strfilterType = null;
//		String strRecordId = 'event-list-view-page';
//		String networkId = '';
//		String allDayEventStartDate = '';
//		String allDayEventEndDate = '';
//		String sortBy = null;
//		String filterByTopic = null;
//		String topicName = null;
//		Boolean filterBySearchTerm = false;
//		String searchTerm = null;
//		String filterOn = 'None';
//		String fromDate = null;
//		String toDate = null;
//		String listViewMode = 'List';
//
//		SVNSUMMITS_EventListController.getSitePrefix();
//		SVNSUMMITS_EventListController.getSessionId();
//
//		//Create Guest user
//		User guestUser = Peak_TestUtils.createGuestUser();
//		insert guestUser;
//
//		System.runAs(guestUser) {
//			test.startTest();
//			//check with date filter on list view with topic filter and sort by filter
//
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			fromDate = String.valueOf(system.today());
//			toDate = String.valueOf(system.today().addDays(5));
//			filterByTopic = topics[0].id;
//			topicName = 'Test000';
//			sortBy = 'Upcoming';
//
//			SVNSUMMITS_EventListController.deleteAttachment(strRecordId);
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			fromDate = String.valueOf(system.today());
//			toDate = null;
//			filterByTopic = topics[0].Id;
//			topicName = 'Test000';
//			sortBy = 'Top Attendees';
//
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			fromDate = null;
//			toDate = String.valueOf(system.today().addDays(5));
//			filterByTopic = topics[0].Id;
//			topicName = 'Test000';
//			sortBy = '';
//			system.assertEquals(numberofresults, 1001);
//
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check with pagination next previous
//			SVNSUMMITS_EventListController.nextPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			SVNSUMMITS_EventListController.previousPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			system.assertEquals(pageNumber, 1);
//
//			//check for search page
//			filterOn = 'Search Term';
//			searchTerm = 'event';
//			sortBy = 'Upcoming';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			filterOn = 'Search Term';
//			searchTerm = 'event';
//			sortBy = 'Top Attendees';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check with pagination next previous
//			SVNSUMMITS_EventListController.nextPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			SVNSUMMITS_EventListController.previousPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			system.assertEquals(numberofresults, 1001);
//
//			//check for topic page
//			filterOn = 'Topic Value';
//			topicName = 'Test000';
//			sortBy = 'Upcoming';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			topicName = 'Test000';
//			sortBy = 'Top Attendees';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check for recommended on detail page
//			eventListFlag = false;
//			filterOn = 'None';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, '', networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check for calendar mode
////			listViewMode = 'Calendar';
////			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
////
////			sortBy = 'Top Attendees';
////			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
////
////			listViewMode = 'Calendar';
////			sortBy = 'Upcoming';
////			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
////			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, '', filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
////
////			//check save event
////			Event__c eventObj = new Event__c(Name = 'Test Event', Start_DateTime__c = system.today().addDays(2), End_DateTime__c = system.today().adddays(5));
////			SVNSUMMITS_EventListController.saveEvents(eventObj, topics[0].Id, allDayEventStartDate, allDayEventEndDate);
////			system.assertEquals(eventObj.Id, null);
////
////			allDayEventStartDate = String.valueOf(system.today());
////			allDayEventEndDate = String.valueOf(system.today().addDays(3));
////			Event__c eventObjNew = new Event__c(Name = 'Test Event', All_Day_Event__c = true, End_DateTime__c = system.today().adddays(5));
////			SVNSUMMITS_EventListController.isObjectEditable();
////			SVNSUMMITS_EventListController.saveEvents(eventObjNew, topics[0].Id, allDayEventStartDate, allDayEventEndDate);
////			system.assertEquals(eventObjNew.Id, null);
//
//			test.stopTest();
//		}
//	}
//
//	static testMethod void test_EventsFeaturesCalendarGuestUser() {
//		SVNSUMMITS_EventListWrapper eventWrapper = new SVNSUMMITS_EventListWrapper();
//		system.assertNotEquals(null, eventWrapper);
//
//		List<Event__c> eventList = SVNSUMMITS_EventUtility.createEventsRecords(1001);
//		system.assertEquals(eventList.size(), 1001);
//
//		List<Event__c> eventUnlistedList = SVNSUMMITS_EventUtility.createEventsRecords(50);
//		system.assertEquals(eventUnlistedList.size(), 50);
//
//		List<Topic> topics = SVNSUMMITS_EventUtility.createTopic(1001);
//		system.assertEquals(topics.size(), 1001);
//
//		List<Event_RSVP__c> eventRSVPlst = SVNSUMMITS_EventUtility.createRSVPRecords(7, eventList);
//		system.assertEquals(eventRSVPlst.size(), 7);
//
//		eventRSVPlst = SVNSUMMITS_EventUtility.deleteRSVPRecords(3, eventRSVPlst);
//
//		TopicAssignment topicAssignment = SVNSUMMITS_EventUtility.createTopicAssignment(topics[0].id, eventList[0].id);
//
//		Boolean eventListFlag = true;
//		Integer numberofresults = 1001;
//		Integer listSize = 1001;
//		Integer pageNumber = 1;
//		String strfilterType = null;
//		String strRecordId = 'event-list-view-page';
//		String networkId = '';
//		String allDayEventStartDate = '';
//		String allDayEventEndDate = '';
//		String sortBy = null;
//		String filterByTopic = null;
//		String topicName = null;
//		Boolean filterBySearchTerm = false;
//		String searchTerm = null;
//		String filterOn = 'None';
//		String fromDate = null;
//		String toDate = null;
//		String listViewMode = 'List';
//
//		SVNSUMMITS_EventListController.getSitePrefix();
//		SVNSUMMITS_EventListController.getSessionId();
//
//		//Create Guest user
//		User guestUser = Peak_TestUtils.createGuestUser();
//		insert guestUser;
//		System.debug(guestUser);
//
//		System.runAs(guestUser) {
//			test.startTest();
//			//check with date filter on list view with topic filter and sort by filter
//
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			fromDate = String.valueOf(system.today());
//			toDate = String.valueOf(system.today().addDays(5));
//			filterByTopic = topics[0].id;
//			topicName = 'Test000';
//			sortBy = 'Upcoming';
//
//			SVNSUMMITS_EventListController.deleteAttachment(strRecordId);
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			fromDate = String.valueOf(system.today());
//			toDate = null;
//			filterByTopic = topics[0].Id;
//			topicName = 'Test000';
//			sortBy = 'Top Attendees';
//
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			fromDate = null;
//			toDate = String.valueOf(system.today().addDays(5));
//			filterByTopic = topics[0].Id;
//			topicName = 'Test000';
//			sortBy = '';
//			system.assertEquals(numberofresults, 1001);
//
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check with pagination next previous
//			SVNSUMMITS_EventListController.nextPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			SVNSUMMITS_EventListController.previousPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			system.assertEquals(pageNumber, 1);
//
//			//check for search page
//			filterOn = 'Search Term';
//			searchTerm = 'event';
//			sortBy = 'Upcoming';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			filterOn = 'Search Term';
//			searchTerm = 'event';
//			sortBy = 'Top Attendees';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check with pagination next previous
//			SVNSUMMITS_EventListController.nextPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			SVNSUMMITS_EventListController.previousPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			system.assertEquals(numberofresults, 1001);
//
//			//check for topic page
//			filterOn = 'Topic Value';
//			topicName = 'Test000';
//			sortBy = 'Upcoming';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			topicName = 'Test000';
//			sortBy = 'Top Attendees';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check for recommended on detail page
//			eventListFlag = false;
//			filterOn = 'None';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, '', networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check for calendar mode
//			listViewMode = 'Calendar';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			sortBy = 'Top Attendees';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			listViewMode = 'Calendar';
//			sortBy = 'Upcoming';
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//			SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, '', filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
//
//			//check save event
//			Event__c eventObj = new Event__c(Name = 'Test Event', Start_DateTime__c = system.today().addDays(2), End_DateTime__c = system.today().adddays(5));
//			SVNSUMMITS_EventListController.saveEvents(eventObj, topics[0].Id, allDayEventStartDate, allDayEventEndDate);
//			system.assertEquals(eventObj.Id, null);
//
//			allDayEventStartDate = String.valueOf(system.today());
//			allDayEventEndDate = String.valueOf(system.today().addDays(3));
//			Event__c eventObjNew = new Event__c(Name = 'Test Event', All_Day_Event__c = true, End_DateTime__c = system.today().adddays(5));
//			SVNSUMMITS_EventListController.isObjectEditable();
//			SVNSUMMITS_EventListController.saveEvents(eventObjNew, topics[0].Id, allDayEventStartDate, allDayEventEndDate);
//			system.assertEquals(eventObjNew.Id, null);
//
//			test.stopTest();
//		}
//	}

	static testMethod void test_SaveEventsFeatures() {
		SVNSUMMITS_EventListWrapper eventWrapper = new SVNSUMMITS_EventListWrapper();
		system.assertNotEquals(null, eventWrapper);

		List<Event__c> eventList = SVNSUMMITS_EventUtility.createEventsRecords(1001);
		system.assertEquals(eventList.size(), 1001);

		List<Event__c> eventUnlistedList = SVNSUMMITS_EventUtility.createEventsRecords(50);
		system.assertEquals(eventUnlistedList.size(), 50);

		List<Topic> topics = SVNSUMMITS_EventUtility.createTopic(1001);
		system.assertEquals(topics.size(), 1001);

		List<Event_RSVP__c> eventRSVPlst = SVNSUMMITS_EventUtility.createRSVPRecords(7, eventList);
		system.assertEquals(eventRSVPlst.size(), 7);

		eventRSVPlst = SVNSUMMITS_EventUtility.deleteRSVPRecords(3, eventRSVPlst);

		TopicAssignment topicAssignment = SVNSUMMITS_EventUtility.createTopicAssignment(topics[0].id, eventList[0].id);

		Boolean eventListFlag = true;
		Integer numberofresults = 1001;
		Integer listSize = 1001;
		Integer pageNumber = 1;
		String strfilterType = null;
		String strRecordId = 'event-list-view-page';
		String networkId = '';
		String allDayEventStartDate = '';
		String allDayEventEndDate = '';
		String sortBy = null;
		String filterByTopic = null;
		String topicName = null;
		Boolean filterBySearchTerm = false;
		String searchTerm = null;
		String filterOn = 'None';
		String fromDate = null;
		String toDate = null;
		String listViewMode = 'List';

		SVNSUMMITS_EventListController.getSitePrefix();
		SVNSUMMITS_EventListController.getSessionId();

		test.startTest();
		//check with date filter on list view with topic filter and sort by filter

		SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

		fromDate = String.valueOf(system.today());
		toDate = String.valueOf(system.today().addDays(5));
		filterByTopic = topics[0].id;
		topicName = 'Test000';
		sortBy = 'Upcoming';

		SVNSUMMITS_EventListController.deleteAttachment(strRecordId);
		SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

		fromDate = String.valueOf(system.today());
		toDate = null;
		filterByTopic = topics[0].Id;
		topicName = 'Test000';
		sortBy = 'Top Attendees';

		SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

		fromDate = null;
		toDate = String.valueOf(system.today().addDays(5));
		filterByTopic = topics[0].Id;
		topicName = 'Test000';
		sortBy = '';
		system.assertEquals(numberofresults, 1001);

		SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

		//check with pagination next previous
		SVNSUMMITS_EventListController.nextPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
		SVNSUMMITS_EventListController.previousPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
		system.assertEquals(pageNumber, 1);

		//check for search page
		filterOn = 'Search Term';
		searchTerm = 'event';
		sortBy = 'Upcoming';
		SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

		filterOn = 'Search Term';
		searchTerm = 'event';
		sortBy = 'Top Attendees';
		SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

		//check with pagination next previous
		SVNSUMMITS_EventListController.nextPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
		SVNSUMMITS_EventListController.previousPage(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
		system.assertEquals(numberofresults, 1001);

		//check for topic page
		filterOn = 'Topic Value';
		topicName = 'Test000';
		sortBy = 'Upcoming';
		SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

		topicName = 'Test000';
		sortBy = 'Top Attendees';
		SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

		//check for recommended on detail page
		eventListFlag = false;
		filterOn = 'None';
		//SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

		//check for calendar mode
		listViewMode = 'Calendar';
		SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

		listViewMode = 'Calendar';
		sortBy = 'Upcoming';
		SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
		SVNSUMMITS_EventListController.getEvents(eventListFlag, numberofresults, listSize, pageNumber, strfilterType, strRecordId, networkId, '', filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);

		//check save event
		Event__c eventObj = new Event__c(Name = 'Test Event', Start_DateTime__c = system.today().addDays(2), End_DateTime__c = system.today().adddays(5));
		SVNSUMMITS_EventListController.saveEvents(eventObj, topics[0].Id, allDayEventStartDate, allDayEventEndDate);
		system.assertNotEquals(eventObj.Id, null);
		SVNSUMMITS_EventListController.saveEvents(eventObj, topics[0].Id, allDayEventStartDate, allDayEventEndDate);

		allDayEventStartDate = String.valueOf(system.today());
		allDayEventEndDate = String.valueOf(system.today().addDays(3));
		Event__c eventObjNew = new Event__c(Name = 'Test Event', All_Day_Event__c = true, End_DateTime__c = system.today().adddays(5));
		SVNSUMMITS_EventListController.isObjectEditable();
		//SVNSUMMITS_EventListController.saveEvent(eventObjNew, topics[0].Id);
		SVNSUMMITS_EventListController.saveEvents(eventObjNew, topics[0].Id, allDayEventStartDate, allDayEventEndDate);
		system.assertNotEquals(eventObjNew.Id, null);

		test.stopTest();

	}

	@isTest
	static void test_eventObjAccessAdmin(){
		List<Event__c> eventList = SVNSUMMITS_EventUtility.createEventsRecords(1001);
		system.assertEquals(eventList.size(), 1001);

		test.startTest();

		//fetch Event Record
		SVNSUMMITS_EventListController.getEventRecord(eventList[0].Id);
		SVNSUMMITS_EventListController.getEventName(eventList[0].Id);

		//call method to check if object is creatable to show hide "Add new" button on header in list view page
		SVNSUMMITS_EventListController.isObjectCreatable();
		SVNSUMMITS_EventListController.isRecordEditable(eventList[0].Id);

		//fetch Featured Event Records
		SVNSUMMITS_EventListController.getFeaturedEvents(eventList[0].Id, eventList[1].Id, eventList[2].Id, eventList[3].Id, eventList[4].Id);
		try {
			//create RSVP Event record
			SVNSUMMITS_EventListController.createRSVPevents(eventList[0].Id, 'Test Response');
		} catch (Exception e) {
		}

		//Delete RSVP Event
		SVNSUMMITS_EventListController.deleteRSVPevents(eventList[0].Id);
		Event_RSVP__c objhere ;
		for (Event_RSVP__c obj: [Select Id from Event_RSVP__c where Id = :eventList[0].Id]) {
			objhere = obj;
		}
		system.assertEquals(objhere, null);

		// get the RSVP count
		Decimal rsvpCount = SVNSUMMITS_EventListController.getRSVPAttendeeCount(eventList[0].Id);
		system.assertEquals(0, rsvpCount);

		//check if Event is RSVP or not
		SVNSUMMITS_EventListController.checkRSVPevents(eventList[0].Id);
		system.assertNotEquals(SVNSUMMITS_EventListController.checkRSVPevents(eventList[0].Id), null);

		//SVNSUMMITS_EventListController.isRecordEditable(eventList[0].Id);
		SVNSUMMITS_EventListController.getRSVPMemberAttendes(eventList[0].Id);
	}

	@isTest
	static void test_eventObjAccess(){
		List<Event__c> eventList = SVNSUMMITS_EventUtility.createEventsRecords(1001);
		system.assertEquals(eventList.size(), 1001);

		//Create Community user
		List<user> lstOfUser = SVNSUMMITS_EventUtility.createUsers(1, CUSTOMER_COMMUNITY_USER);

		//Create Community User
		//As we are using custom object News, we have created user with the custom Community Profile,
		//Because standard community profile do not allow to give permissions to such custom objects.
		User communityUser = SVNSUMMITS_EventUtility.createCommunityUsers(CUSTOMER_COMMUNITY_USER_CLONE);

		System.runAs(communityUser) {
			test.startTest();

			//fetch Event Record
			SVNSUMMITS_EventListController.getEventRecord(eventList[0].Id);
			SVNSUMMITS_EventListController.getEventName(eventList[0].Id);

			//call method to check if object is creatable to show hide "Add new" button on header in list view page
			SVNSUMMITS_EventListController.isObjectCreatable();
			SVNSUMMITS_EventListController.isRecordEditable(eventList[0].Id);

			//fetch Featured Event Records
			SVNSUMMITS_EventListController.getFeaturedEvents(eventList[0].Id, eventList[1].Id, eventList[2].Id, eventList[3].Id, eventList[4].Id);
			try {
				//create RSVP Event record
				SVNSUMMITS_EventListController.createRSVPevents(eventList[0].Id, 'Test Response');
			} catch (Exception e) {
			}

			//Delete RSVP Event
			SVNSUMMITS_EventListController.deleteRSVPevents(eventList[0].Id);
			Event_RSVP__c objhere ;
			for (Event_RSVP__c obj: [Select Id from Event_RSVP__c where Id = :eventList[0].Id]) {
				objhere = obj;
			}
			system.assertEquals(objhere, null);

			// get the RSVP count
			Decimal rsvpCount = SVNSUMMITS_EventListController.getRSVPAttendeeCount(eventList[0].Id);
			system.assertEquals(0, rsvpCount);

			//check if Event is RSVP or not
			SVNSUMMITS_EventListController.checkRSVPevents(eventList[0].Id);
			system.assertNotEquals(SVNSUMMITS_EventListController.checkRSVPevents(eventList[0].Id), null);

			//SVNSUMMITS_EventListController.isRecordEditable(eventList[0].Id);
			SVNSUMMITS_EventListController.getRSVPMemberAttendes(eventList[0].Id);

			test.stopTest();
		}
	}

	@isTest
	static void test_Topics() {
		List<user> users = SVNSUMMITS_EventUtility.createUsers(1, CUSTOMER_COMMUNITY_USER);
		if (!users.isEmpty()) {
			system.runAs(users[0]) {
				//Create Topic Record
				List<Topic> topics1 = SVNSUMMITS_EventUtility.createTopic(2000);
				system.assertEquals(topics1.size(), 2000);

				//Get Topics for Topic dropdown in List view of news
				Map<string, string> topicMap1 = SVNSUMMITS_EventListController.getTopics();

				SVNSUMMITS_EventListWrapper wrapper = new SVNSUMMITS_EventListWrapper('field1', 'message1');
				system.assertEquals('field1', wrapper.field);
				system.assertEquals('message1', wrapper.errorMsg);
			}
		}
	}

	@isTest
	static void test_getAllGroups() {
		List<user> users = SVNSUMMITS_EventUtility.createUsers(1, CUSTOMER_COMMUNITY_USER);

		if (!users.isEmpty()) {
			system.runAs(users[0]) {
				Map<string, string> groupList = SVNSUMMITS_EventListController.getAllGroups();

				system.assertNotEquals(null, groupList);
			}
		}
	}

	@isTest
	static void test_getGroups() {
		UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];

		Profile adminProfile = [
				SELECT Id
				FROM profile
				WHERE Name = 'System Administrator'
				LIMIT 1
		];

		User admin = new User(LastName = 'test user 1',
				Username = 'test.user.1@example.com',
				Email = 'test.1@example.com',
				Alias = 'testu1',
				TimeZoneSidKey = 'GMT',
				LocaleSidKey = 'en_US',
				EmailEncodingKey = 'ISO-8859-1',
				ProfileId = adminProfile.Id,
				UserRoleId = portalRole.Id,
				LanguageLocaleKey = 'en_US');

		System.runAs(admin) {
			Test.startTest();

			Id testGroupId = SVNSUMMITS_EventUtility.createTestGroup('Test group');
			String testGroupIdStr = (String) testGroupId;

			Map<String, String> groupList = SVNSUMMITS_EventListController.getGroups();
			system.assertNotEquals(null, groupList);
			Test.stopTest();
		}
	}

	@isTest
	static void test_userAuthorizedToPost() {
		Boolean canPost = SVNSUMMITS_EventListController.userAuthorizedToPost();
		System.debug('test_userAuthorizedToPost = ' + canPost);
		System.assertNotEquals(null, canPost);
	}

	@isTest
	static void test_getNameSpacePrefix() {
		SVNSUMMITS_EventBaseController.BaseModel model = SVNSUMMITS_EventBaseController.getModel();
		System.assertNotEquals(null, model);
	}

	@IsTest
	static void test_EventsPickList() {
		String location = 'Location_Name__c';
		Integer testSize = 11;

		List<Event__c> eventList = SVNSUMMITS_EventUtility.createEventsRecords(testSize);
		system.assertEquals(testSize, eventList.size());

		List<String> locations = SVNSUMMITS_EventListController.getEventsPicklist(location, '');
		System.assertNotEquals(null, locations);
		System.assertEquals(testSize, locations.size());

		locations = SVNSUMMITS_EventListController.getEventsPicklist(location, '1');
		System.assertEquals(2, locations.size());
	}

	@IsTest
	static void testGetSitePrefix() {
		SVNSUMMITS_EventBaseController controller = new SVNSUMMITS_EventBaseController();

		String sitePrefix = SVNSUMMITS_EventBaseController.getSitePrefix();
		System.assertEquals('',sitePrefix);
	}
}