/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 4/27/18.
 */

@IsTest
private class TU_FormAssemblyCompletionControllerTest {

    @TestSetup
    static void setupTestData() {
        List<User> users = TU_TestUtilities.createRegUser(1,true);
        List<Event__c> events = TU_TestUtilities.createEventsRecords(false,1,true);
    }

    @IsTest
    static void testGetRSVPNextStepFreeEvent() {
        List<User> users = new List<User>([SELECT Id FROM User WHERE FirstName = 'First']);
        List<Event__c> events = new List<Event__c>([SELECT Id FROM Event__c]);

        Test.startTest();
        System.runAs(users[0]) {
            Peak_Response createResponse = TU_EventRSVPController.getRSVPForEvent(events[0].Id, null);
            createResponse = TU_EventRSVPController.updateSingleRSVP((Event_RSVP__c) createResponse.results[0], '/test', '/test');
            System.assert(createResponse.success);

            Event_RSVP__c thisRsvp = (Event_RSVP__c) createResponse.results[0];

            String nextStepURL = TU_FormAssemblyCompletionController.getRSVPNextStep(thisRsvp.Id, '/event-products',
                    '/event/', '/rsvp-error' );
            System.assertEquals('/event/' + thisRsvp.Event__c + '?token=' + thisRsvp.RSVPToken_TU__c,nextStepURL);

            nextStepURL = TU_FormAssemblyCompletionController.getRSVPNextStep('123', '/event-products',
                    '/event/', '/rsvp-error' );
            System.assertEquals('/rsvp-error',nextStepURL);

        }
        Test.stopTest();


    }

    @IsTest
    static void testGetRSVPNextStepWaitlist() {
        List<User> users = new List<User>([SELECT Id FROM User WHERE FirstName = 'First']);
        List<Event__c> events = new List<Event__c>([SELECT Id, EventFull_TU__c, Enable_Pricing_Payment__c, WaitlistAllowed_TU__c FROM Event__c]);

        events[0].EventFull_TU__c = true;
        events[0].Enable_Pricing_Payment__c = true;
        events[0].WaitlistAllowed_TU__c = true;
        update events;

        Test.startTest();
        System.runAs(users[0]) {
            Peak_Response createResponse = TU_EventRSVPController.getRSVPForEvent(events[0].Id, null);
            createResponse = TU_EventRSVPController.updateSingleRSVP((Event_RSVP__c) createResponse.results[0], '/test', '/test');
            System.assert(createResponse.success);

            Event_RSVP__c thisRsvp = (Event_RSVP__c) createResponse.results[0];

            String nextStepURL = TU_FormAssemblyCompletionController.getRSVPNextStep(thisRsvp.Id, '/event-products',
                    '/event/', '/rsvp-error' );
            System.assertEquals('/event/' + thisRsvp.Event__c + '?token=' + thisRsvp.RSVPToken_TU__c,nextStepURL);

        }
        Test.stopTest();


    }

    @IsTest
    static void testGetRSVPNextStepWithProducts() {
        List<User> users = new List<User>([SELECT Id FROM User WHERE FirstName = 'First']);
        List<Event__c> events = new List<Event__c>([SELECT Id, EventFull_TU__c, Enable_Pricing_Payment__c,
                WaitlistAllowed_TU__c, AssociatedProductCode_TU__c  FROM Event__c]);

        events[0].EventFull_TU__c = false;
        events[0].Enable_Pricing_Payment__c = true;
        events[0].WaitlistAllowed_TU__c = false;
        events[0].AssociatedProductCode_TU__c = 'Unit Test';

        update events;

        Id pricebookId = Test.getStandardPricebookId();
        Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product',
                ProductCode = events[0].AssociatedProductCode_TU__c, Family = 'Events',
                isActive = true), true);
        system.assertNotEquals(null, testProduct);

        PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(
                Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = true), true);
        system.assertNotEquals(null, testEntry);

        Test.startTest();
        System.runAs(users[0]) {
            Peak_Response createResponse = TU_EventRSVPController.getRSVPForEvent(events[0].Id, null);
            createResponse = TU_EventRSVPController.updateSingleRSVP((Event_RSVP__c) createResponse.results[0], '/test', '/test');
            System.assert(createResponse.success);

            Event_RSVP__c thisRsvp = (Event_RSVP__c) createResponse.results[0];

            String nextStepURL = TU_FormAssemblyCompletionController.getRSVPNextStep(thisRsvp.Id, '/event-products',
                    '/event/', '/rsvp-error' );
            System.assertEquals('/event-products' + '?token=' + thisRsvp.RSVPToken_TU__c,nextStepURL);
        }

        Test.stopTest();

    }

    @IsTest
    static void testGetRSVPNextStepWithProductsError() {
        List<User> users = new List<User>([SELECT Id FROM User WHERE FirstName = 'First']);
        List<Event__c> events = new List<Event__c>([SELECT Id, EventFull_TU__c, Enable_Pricing_Payment__c,
                WaitlistAllowed_TU__c, AssociatedProductCode_TU__c  FROM Event__c]);

        events[0].EventFull_TU__c = false;
        events[0].Enable_Pricing_Payment__c = true;
        events[0].WaitlistAllowed_TU__c = false;
        events[0].AssociatedProductCode_TU__c = 'Unit Test';

        update events;

        Id pricebookId = Test.getStandardPricebookId();
        Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product',
                ProductCode = events[0].AssociatedProductCode_TU__c, Family = 'Events',
                isActive = true), true);
        system.assertNotEquals(null, testProduct);

        PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(
                Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = false), true);
        system.assertNotEquals(null, testEntry);

        Test.startTest();
        System.runAs(users[0]) {
            Peak_Response createResponse = TU_EventRSVPController.getRSVPForEvent(events[0].Id, null);
            createResponse = TU_EventRSVPController.updateSingleRSVP((Event_RSVP__c) createResponse.results[0], '/test', '/test');
            System.assert(createResponse.success);

            Event_RSVP__c thisRsvp = (Event_RSVP__c) createResponse.results[0];

            String nextStepURL = TU_FormAssemblyCompletionController.getRSVPNextStep('123', '/event-products',
                    '/event/', '/rsvp-error' );
            System.assertEquals('/rsvp-error',nextStepURL);
        }

        Test.stopTest();
    }
}