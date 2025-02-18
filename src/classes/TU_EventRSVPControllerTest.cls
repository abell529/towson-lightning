/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 4/10/18.
 */

@IsTest
private class TU_EventRSVPControllerTest {

    @TestSetup
    static void setupTestData() {
        List<User> users = TU_TestUtilities.createRegUser(1,true);
        List<Event__c> events = TU_TestUtilities.createEventsRecords(false,1,true);
    }

    @IsTest
    static void testGetRSVPForEvent() {
        List<User> users = new List<User>([SELECT Id FROM User WHERE FirstName = 'First']);
        List<Event__c> events = new List<Event__c>([SELECT Id FROM Event__c]);

        Test.setCurrentPageReference(new PageReference('https://alumni-towsonuniversity.cs23.force.com/events/' +
                events[0].Id));

        System.runAs(users[0]) {
            Peak_Response peakResponse = TU_EventRSVPController.getRSVPForEvent(events[0].Id, null);
            System.debug(peakResponse.results);
            System.debug(ApexPages.currentPage().getParameters().get('token'));
            System.assert(peakResponse.success);
            // Test error catch
            peakResponse = TU_EventRSVPController.getRSVPForEvent(null, null);
            System.assert(!peakResponse.success);
        }
    }

    @IsTest
    static void testConfirmRSVP() {
        List<User> users = new List<User>([SELECT Id FROM User WHERE FirstName = 'First']);
        List<Event__c> events = new List<Event__c>([SELECT Id FROM Event__c]);

        Test.setCurrentPageReference(new PageReference('https://alumni-towsonuniversity.cs23.force.com/events/' +
                events[0].Id));

        Event_RSVP__c rsvp = new Event_RSVP__c();
        System.runAs(users[0]) {
            Peak_Response peakResponse = TU_EventRSVPController.getRSVPForEvent(events[0].Id, null);
            String token = ApexPages.currentPage().getParameters().get('token');
            System.assert(peakResponse.success);

            peakResponse = TU_EventRSVPController.updateSingleRSVP((Event_RSVP__c) peakResponse.results[0], '/test', '/test');
            rsvp = (Event_RSVP__c) peakResponse.results[0];
            System.assertEquals(TU_EventRSVPHelper.rsvpPending, rsvp.Response__c);
            System.assert(peakResponse.success);

            peakResponse = TU_EventRSVPController.getRSVPForEvent(events[0].Id, rsvp.RSVPToken_TU__c);
            peakResponse = TU_EventRSVPController.updateSingleRSVP(rsvp, '/test', '/test');
            rsvp = (Event_RSVP__c) peakResponse.results[0];
            System.assertEquals(TU_EventRSVPHelper.rsvpPending, rsvp.Response__c);

            rsvp.Response__c = TU_EventRSVPHelper.rsvpInvited;
            peakResponse = TU_EventRSVPController.updateSingleRSVP(rsvp, '/test', '/test');
            rsvp = (Event_RSVP__c) peakResponse.results[0];
            System.assertEquals(TU_EventRSVPHelper.rsvpCancelled, rsvp.Response__c);

            rsvp.Response__c = TU_EventRSVPHelper.rsvpConfirm;
            Event__c event = events[0];
            event.Enable_Pricing_Payment__c = true;
            update event;

            peakResponse = TU_EventRSVPController.getRSVPForEvent(events[0].Id, rsvp.RSVPToken_TU__c);
            peakResponse = TU_EventRSVPController.updateSingleRSVP((Event_RSVP__c) peakResponse.results[0], '/test', '/test');
            rsvp = (Event_RSVP__c) peakResponse.results[0];
            System.assertEquals(TU_EventRSVPHelper.rsvpConfirmPayment, rsvp.Response__c);

            peakResponse = TU_EventRSVPController.updateSingleRSVP(rsvp, '/test', '/test');
            rsvp = (Event_RSVP__c) peakResponse.results[0];
            System.assertEquals(TU_EventRSVPHelper.rsvpPayment, rsvp.Response__c);

            peakResponse = TU_EventRSVPController.updateSingleRSVP(rsvp, '/test', '/test');
            rsvp = (Event_RSVP__c) peakResponse.results[0];
            System.assertEquals(TU_EventRSVPHelper.rsvpPayment, rsvp.Response__c);

            rsvp.Response__c = TU_EventRSVPHelper.rsvpInvited;
            peakResponse = TU_EventRSVPController.updateSingleRSVP(rsvp, '/test', '/test');
            rsvp = (Event_RSVP__c) peakResponse.results[0];
            System.assertEquals(TU_EventRSVPHelper.rsvpPayment, rsvp.Response__c);

            rsvp.Response__c = TU_EventRSVPHelper.rsvpWaitlist;
            peakResponse = TU_EventRSVPController.updateSingleRSVP(rsvp, '/test', '/test');
            rsvp = (Event_RSVP__c) peakResponse.results[0];
            System.assertEquals(TU_EventRSVPHelper.rsvpWaitCancel, rsvp.Response__c);

            rsvp.Response__c = TU_EventRSVPHelper.rsvpWaitCancel;
            peakResponse = TU_EventRSVPController.updateSingleRSVP(rsvp, '/test', '/test');
            rsvp = (Event_RSVP__c) peakResponse.results[0];
            System.assertEquals(TU_EventRSVPHelper.rsvpConfirmPayment, rsvp.Response__c);

            // Test Error trape
            Event_RSVP__c errorRsvp;
            peakResponse = TU_EventRSVPController.updateSingleRSVP(errorRsvp, '/test', '/test');
            System.assert(!peakResponse.success);

        }
    }

    @IsTest
    static void testUpdateRSVPList() {
        Peak_Response peakResponse = new Peak_Response();
        List<User> users = new List<User>([SELECT Id, FirstName, LastName, Email, LastNameatGraduation_TU__c,
                GraduationYear_TU__c, ContactId FROM User WHERE FirstName = 'First']);
        List<Event__c> events = new List<Event__c>([SELECT Id FROM Event__c]);
        List<Event_RSVP__c> eventRSVPS = TU_TestUtilities.createRSVPRecords(1,events,new List<Contact>(),users,true,
                TU_EventRSVPHelper.rsvpConfirm);

        Test.startTest();
        peakResponse = TU_EventRSVPController.updateRSVPList(eventRSVPS);
        System.assert(peakResponse.success);

        List<Event_RSVP__c> errorRsvps;
        peakResponse = TU_EventRSVPController.updateRSVPList(errorRsvps);
        System.assert(!peakResponse.success);
        Test.stopTest();

    }

    @IsTest
    static void testDeleteRSVPList() {
        Peak_Response peakResponse = new Peak_Response();
        List<User> users = new List<User>([SELECT Id, FirstName, LastName, Email, LastNameatGraduation_TU__c,
                GraduationYear_TU__c, ContactId FROM User WHERE FirstName = 'First']);
        List<Event__c> events = new List<Event__c>([SELECT Id FROM Event__c]);
        List<Event_RSVP__c> eventRSVPS = TU_TestUtilities.createRSVPRecords(1,events,new List<Contact>(),users,true,
                TU_EventRSVPHelper.rsvpConfirm);

        Test.startTest();
        peakResponse = TU_EventRSVPController.deleteSingleRSVPwithToken(eventRSVPS[0],
                eventRSVPS[0].RSVPToken_TU__c);
        System.assert(peakResponse.success);

        Event_RSVP__c errorRsvp = new Event_RSVP__c();
        errorRsvp.RSVPToken_TU__c = '123';
        peakResponse = TU_EventRSVPController.deleteSingleRSVPwithToken(errorRsvp, '123');
        System.assert(!peakResponse.success);

        peakResponse = TU_EventRSVPController.deleteSingleRSVPwithToken(errorRsvp, '1234');
        System.assert(!peakResponse.success);

        Test.stopTest();
    }

    @IsTest
    static void testGetPicklistOptions() {
        List<String> options = TU_EventRSVPController.getPicklistOptions('Event_RSVP__c', 'Response__c');
        System.assertNotEquals(0, options.size());
    }
}