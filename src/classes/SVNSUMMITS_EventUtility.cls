/* Copyright ©2016-2017 7Summits Inc. All rights reserved. */

/*
    Name : SVNSUMMITS_EventUtility
    Description : Utilty class for test data creation
    Date : 25/5/2016
*/
@isTest
global with sharing class SVNSUMMITS_EventUtility {
    /*
         Method Name : createTopic
         Discription : Method for creating topics
    */

	public static List<Topic> createTopic(Integer noOfEvents) {
		List<topic> topicList = new List<topic>();

		for (Integer i = 0; i < noOfEvents; i++) {
			Topic topicObj = new Topic(Name = 'Test00' + i, Description = 'Test');
			topicList.add(topicObj);
		}
		insert topicList;

		return topicList;
	}
    /*
         Method Name : createEventsRecords
         Discription : Method for creating event records
    */
	public static List<Event__c> createEventsRecords(Integer noOfEvents) {
		List<Event__c> eventList = new List<Event__c>();
		String networkId = TU_Utilities.getCommunityNetworkId();

		for (Integer i = 0; i < noOfEvents; i++) {
			Event__c objEvent = new Event__c();

			objEvent.Name = 'event' + i;
			objEvent.Start_DateTime__c = Date.today();
			objEvent.End_DateTime__c = Date.today();
			objEvent.Details__c = 'Event Details is here.';
			objEvent.Location_Name__c = 'Location' + i;
			objEvent.Enable_RSVP__c = false;
			objEvent.NetworkId__c = networkId;

			eventList.add(objEvent);
		}
		insert eventList;

		return eventList;
	}
	/*
         Method Name : createUnlistedEventsRecords
         Description : Method for creating event records
    */
	public static List<Event__c> createUnlistedEventsRecords(Integer noOfEvents) {
		List<Event__c> eventList = new List<Event__c>();

		for (Integer i = 0; i < noOfEvents; i++) {
			Event__c objEvent = new Event__c();

			objEvent.Name = 'event' + i;
			objEvent.Start_DateTime__c = Date.today();
			objEvent.End_DateTime__c = Date.today();
			objEvent.Details__c = 'Event Details is here.';
			objEvent.Location_Name__c = 'Location' + i;
			objEvent.Enable_RSVP__c = false;
			objEvent.UnlistedEvent_TU__c = true;

			eventList.add(objEvent);
		}
		insert eventList;

		return eventList;
	}
    /*
         Method Name : createTopicAssignment
         Discription : Method for creating topic assignments
    */
	public static TopicAssignment createTopicAssignment(String strTopicId, String strEntityId) {
		TopicAssignment topicAssigmnt = new TopicAssignment(EntityId = strEntityId, TopicId = strTopicId);

		insert topicAssigmnt ;
		return topicAssigmnt ;
	}
    /*
         Method Name : createRSVPRecords
         Discription : Method for creating RSVP records
    */
	public static List<Event_RSVP__c> createRSVPRecords(Integer noOfEvents, List<Event__c> eventList) {
		List<Event_RSVP__c> eventRSVPList = new List<Event_RSVP__c>();

		for (Integer i = 0; i < noOfEvents; i++) {
			Event_RSVP__c objEvent = new Event_RSVP__c();

			objEvent.Name = 'event' + i;
			objEvent.Event__c = eventList[0].Id;
			objEvent.Response__c = 'YES';
			objEvent.User__c = UserInfo.getUserId();

			eventRSVPList.add(objEvent);
		}
		insert eventRSVPList;

		return eventRSVPList;
	}
    /*
         Method Name : deleteRSVPRecords
         Discription : Method for deleting RSVP records
    */
	public static List<Event_RSVP__c> deleteRSVPRecords(Integer noOfEvents, List<Event_RSVP__c> eventRSVPList) {
		delete eventRSVPList;
		return eventRSVPList;
	}

	static final global String COMPANY_COMMUNITY_PROFILE_NAME = 'Tiger Connect Community User';

	static global Id COMPANY_COMMUNITY_PROFILE_Id {
		get {
			if (COMPANY_COMMUNITY_PROFILE_Id == null) {

				List<Profile> profiles = [SELECT Id from Profile where Name = :COMPANY_COMMUNITY_PROFILE_NAME];
				COMPANY_COMMUNITY_PROFILE_Id = profiles[0].id;
			}
            system.assert(COMPANY_COMMUNITY_PROFILE_Id != null);
			return COMPANY_COMMUNITY_PROFILE_Id;
		}
		set {
			COMPANY_COMMUNITY_PROFILE_Id = value;
			system.assertEquals(value, COMPANY_COMMUNITY_PROFILE_Id);
		}
	}

	static global String THIS_COMMUNITY_NAME {
		get {
			String commName = '';
			commName = [SELECT Id,Name from Network][0].Name;
			system.assertNotEquals(null, commName);
			return commName;
		}
	}

	//Create User with given Profile name
	global static List<User> createUsers(Integer howMany, String profileName) {
		Account a = new Account(name = 'TestAccount123') ;
		insert a;

		List<Contact> listOfContacts = new List<Contact>();
		Map<Integer, Contact> mapCont = new Map<Integer, Contact>();

		for (Integer i = 0; i < howMany; i++) {
			Contact c = new Contact(LastName = 'testCon' + i, AccountId = a.Id);
			listOfContacts.add(c);
			mapCont.put(i, c);
		}
		insert listOfContacts;

		// by default bidders
		Id profileId;
		// to make user unique
		String type;
		if (profileName == COMPANY_COMMUNITY_PROFILE_NAME) {
			profileId = COMPANY_COMMUNITY_PROFILE_Id;
			type = 'com';
		}

		List<User> listOfUsers = new List<User>();

		for (Integer key : mapCont.keySet()) {
			User u = new User(alias = type + key,
					email = key + 'testtest@test.com',
					communitynickname = key + mapCont.get(key).LastName,
					emailencodingkey = 'UTF-8',
					lastname = 'Test' + type + key,
					languagelocalekey = 'en_US',
					localesidkey = 'en_US',
					profileid = profileId,
					ContactId = mapCont.get(key).Id,
					timezonesidkey = 'America/Los_Angeles',
					username = key + type + '@test.com');

			listOfUsers.add(u);
		}

		insert listOfUsers;
		return listOfUsers;
	}

	//Create Community User
	//As we are using custom object Events, created a user with the custom Community Profile,
	//As standard community profiles do not allow to give permissions to such custom objects.
	global static User createCommunityUsers(String profileName) {
		Account a = new Account(name = 'TestAccount123') ;
		insert a;

		Contact c = new Contact(LastName = 'testCon', AccountId = a.Id);
		insert c;

		Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];

		User u = new User(alias = 'Com',
				email = 'testtestCommunity@test.com',
				communitynickname = c.LastName,
				emailencodingkey = 'UTF-8',
				lastname = 'Test',
				languagelocalekey = 'en_US',
				localesidkey = 'en_US',
				profileid = p.Id,
				ContactId = c.Id,
				timezonesidkey = 'America/Los_Angeles',
				username = 'testtestCommunity@test.com');

		insert u;

		return u;
	}

	global static Id createTestGroup(String groupName) {
		CollaborationGroup myGroup = new CollaborationGroup();

		myGroup.Name=groupName;
		myGroup.CollaborationType='Public'; //can be 'Public' or 'Private'
		system.assertNotEquals(null, myGroup);

		insert myGroup;

		return myGroup.Id;
	}


	global static void addTestGroupMember(String groupId, String userId) {
		CollaborationGroupMember groupMember = new CollaborationGroupMember();

		groupMember.CollaborationGroupId = groupId;
		groupMember.memberid = userId;
		systeM.assertNotEquals(null, groupMember);

		insert groupMember;
	}
}