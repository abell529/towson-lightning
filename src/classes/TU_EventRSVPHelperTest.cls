/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 4/10/18.
 */

@IsTest
private class TU_EventRSVPHelperTest {

    @TestSetup
    static void setupTestData() {
        List<User> users = TU_TestUtilities.createRegUser(2,true);
        User user = Peak_TestUtils.createGuestUser();
        insert user;

        users.add(user);
        List<Event__c> events = TU_TestUtilities.createEventsRecords(false,1,true);
        List<Event_RSVP__c> rsvps = TU_TestUtilities.createRSVPRecords(3,events,new List<Contact>(), users,true,TU_EventRSVPHelper.rsvpConfirm);
        List<Event_RSVP__c> childRsvps = TU_TestUtilities.createChildRSVPRecords(2,rsvps,true,TU_EventRSVPHelper.rsvpConfirm);
    }

    @isTest
    static void testGetRSVP() {

        User user = new User();
        List<Event_RSVP__c> eventRSVPS = new List<Event_RSVP__c>();
        Boolean byUser = false;

        Test.startTest();
        for (Event_RSVP__c rsvp : [SELECT Id, Event__c, User__c, RSVPToken_TU__c FROM Event_RSVP__c WHERE
                MasterRSVP_TU__c = true]) {

            user = [SELECT Id, FirstName FROM User WHERE Id = :rsvp.User__c];
            System.runAs(user) {
                if (Peak_Utils.isGuestUser()) {
                    eventRSVPS = TU_EventRSVPHelper.getRSVP(rsvp.Event__c, rsvp.User__c,rsvp.RSVPToken_TU__c);
                } else if (byUser) {
                    eventRSVPS = TU_EventRSVPHelper.getRSVP(rsvp.Event__c, rsvp.User__c,rsvp.RSVPToken_TU__c);
                } else {
                    eventRSVPS = TU_EventRSVPHelper.getRSVP(rsvp.Event__c, rsvp.User__c,null);
                    byUser = true;
                }
                System.assertEquals(user.FirstName, eventRSVPS[0].FirstName_TU__c);
            }
        }
    }

    @isTest
    static void testCreateRSVPFromUser() {
        Event__c event = new Event__c();
        event = [SELECT Id FROM Event__c WHERE Name='event0' LIMIT 1];

        Test.startTest();
        for (User user : [SELECT Id, FirstName FROM User WHERE FirstName = 'First' OR LastName = :Peak_TestConstants.LASTNAME]) {
            System.runAs(user) {
                Event_RSVP__c thisRsvp = TU_EventRSVPHelper.createRSVPFromUser(event.Id, new Event_RSVP__c(), user.Id);
                if (Peak_Utils.isGuestUser()) {
                    System.assertEquals(null,thisRsvp.FirstName_TU__c);
                } else {
                    System.assertEquals(user.FirstName, thisRsvp.FirstName_TU__c);
                }
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testNextResponse() {
        Event__c event = new Event__c();
        event = [SELECT Id, EventFull_TU__c, WaitlistAllowed_TU__c, Enable_Pricing_Payment__c FROM Event__c WHERE Name='event0' LIMIT 1];

        Test.startTest();
        String currentResponse = null;

        Event_RSVP__c eventRSVP = new Event_RSVP__c();
        eventRSVP = TU_EventRSVPHelper.createRSVPFromUser(event.Id, eventRSVP, UserInfo.getUserId());

        event.EventFull_TU__c = true;
        event.WaitlistAllowed_TU__c = false;
        currentResponse = TU_EventRSVPHelper.nextResponse(event, currentResponse, eventRSVP);
        System.assertEquals(TU_EventRSVPHelper.rsvpFull, currentResponse);

        currentResponse = null;
        event.EventFull_TU__c = true;
        event.WaitlistAllowed_TU__c = true;
        currentResponse = TU_EventRSVPHelper.nextResponse(event, currentResponse, eventRSVP);
        System.assertEquals(TU_EventRSVPHelper.rsvpWaitlist, currentResponse);

        currentResponse = TU_EventRSVPHelper.nextResponse(event, currentResponse, eventRSVP);
        System.assertEquals(TU_EventRSVPHelper.rsvpWaitCancel, currentResponse);

        currentResponse = null;
        event.EventFull_TU__c = false;
        event.WaitlistAllowed_TU__c = true;
        event.Enable_Pricing_Payment__c = true;
        currentResponse = TU_EventRSVPHelper.nextResponse(event, currentResponse, eventRSVP);
        System.assertEquals(TU_EventRSVPHelper.rsvpConfirmPayment, currentResponse);

        currentResponse = null;
        event.EventFull_TU__c = false;
        event.WaitlistAllowed_TU__c = true;
        event.Enable_Pricing_Payment__c = false;
        currentResponse = TU_EventRSVPHelper.nextResponse(event, currentResponse, eventRSVP);
        System.assertEquals(TU_EventRSVPHelper.rsvpPending, currentResponse);

        event.EventFull_TU__c = false;
        event.WaitlistAllowed_TU__c = true;
        event.Enable_Pricing_Payment__c = false;
        eventRSVP.FAComplete_TU__c = true;
        currentResponse = TU_EventRSVPHelper.nextResponse(event, currentResponse, eventRSVP);
        System.assertEquals(TU_EventRSVPHelper.rsvpConfirm, currentResponse);

        event.EventFull_TU__c = false;
        event.WaitlistAllowed_TU__c = true;
        currentResponse = TU_EventRSVPHelper.nextResponse(event, currentResponse, eventRSVP);
        System.assertEquals(TU_EventRSVPHelper.rsvpCancelled, currentResponse);

        currentResponse = TU_EventRSVPHelper.rsvpInvited;
        currentResponse = TU_EventRSVPHelper.nextResponse(event, currentResponse, eventRSVP);
        System.assertEquals(TU_EventRSVPHelper.rsvpInvited, currentResponse);

    }

    @isTest
    static void testUpdateResponse() {
        Event_RSVP__c eventRSVP = new Event_RSVP__c();

        Test.startTest();
        for (Event_RSVP__c rsvp : [SELECT Id, Event__c, User__c, RSVPToken_TU__c FROM Event_RSVP__c WHERE
                MasterRSVP_TU__c = true]) {
            TU_EventRSVPHelper.updateResponse(rsvp.Id, TU_EventRSVPHelper.rsvpCancelled);
        }

        Test.stopTest();

        for (Event_RSVP__c parentEventRSVP : [SELECT Response__c FROM Event_RSVP__c WHERE MasterRSVP_TU__c=true]) {
            System.assertEquals(TU_EventRSVPHelper.rsvpCancelled, parentEventRSVP.Response__c);
        }


    }

    @isTest
    static void testUpdateChildRSVPs() {

        Test.startTest();
        for (Event_RSVP__c rsvp : [SELECT Id, Event__c, User__c, RSVPToken_TU__c FROM Event_RSVP__c WHERE
                MasterRSVP_TU__c = true]) {
            TU_EventRSVPHelper.updateChildRSVPs(rsvp.Id, TU_EventRSVPHelper.rsvpCancelled);
        }

        Test.stopTest();

        for (Event_RSVP__c childEventRSVP : [SELECT Response__c FROM Event_RSVP__c WHERE MasterRSVP_TU__c=false]) {
            System.assertEquals(TU_EventRSVPHelper.rsvpCancelled, childEventRSVP.Response__c);
        }
    }
}