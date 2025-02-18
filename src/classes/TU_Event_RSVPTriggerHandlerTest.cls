/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 4/10/18.
 */

@IsTest
private class TU_Event_RSVPTriggerHandlerTest {
    @IsTest
    static void testUnauthEventRSVPNoGuests() {
        List<User> users = TU_TestUtilities.createRegUser(2,true);
        List<Event__c> events = TU_TestUtilities.createEventsRecords(false,1,true);
        List<Event_RSVP__c> rsvps = TU_TestUtilities.createRSVPRecords(2,events,new List<Contact>(),new List<User>(),false,TU_EventRSVPHelper.rsvpConfirm);

        Test.startTest();
        List<Event_RSVP__c> eventRSVPS = TU_Event_RSVPTriggerHandler.completeEventRSVPS(rsvps);
        Test.stopTest();

        for (Event_RSVP__c rsvp : eventRSVPS ) {
            System.debug(rsvp);
            System.assertNotEquals(null,rsvp.RSVPToken_TU__c);
        }
    }

    @isTest
    static void testUnauthEventRSVPwithGuests() {
        List<User> users = TU_TestUtilities.createRegUser(6,true);
        List<Event__c> events = TU_TestUtilities.createEventsRecords(false,1,true);
        List<Event_RSVP__c> rsvps = TU_TestUtilities.createRSVPRecords(2,events,new List<Contact>(),new List<User>(),false, TU_EventRSVPHelper.rsvpConfirm);


        Test.startTest();
        insert rsvps;

        List<Event_RSVP__c> childrenRSVPs = TU_TestUtilities.createChildRSVPRecords(2, rsvps, true, null);
        Test.stopTest();

    }

    @isTest
    static void testUpdateContacts() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(Peak_TestUtils.createTestContact());
        List<Event__c> events = TU_TestUtilities.createEventsRecords(false,1,true);
        List<Event_RSVP__c> rsvps = TU_TestUtilities.createRSVPRecords(2,events,contacts,new List<User>(),false, TU_EventRSVPHelper.rsvpConfirm);
        insert rsvps;

        Event_RSVP__c rsvp = rsvps[0];
        rsvp.Contact_TU__c = contacts[0].Id;

        rsvp.BirthdateTU__c = Date.today().addYears(-20);
        rsvp.Gender_TU__c = 'Prefer Not to Say';
        rsvp.Street_TU__c = '555 5th Ave North';
        rsvp.City_TU__c = 'New City';
        rsvp.State_TU__c = 'MD';
        rsvp.Country_TU__c = 'United States';
        rsvp.Zip_TU__c = '21252';
        rsvp.Major_TU__c = 'ITEC - Information Technology';
        rsvp.Phone_TU__c = '410-555-1212';

        Test.startTest();
        update rsvp;
        Test.stopTest();
    }

}