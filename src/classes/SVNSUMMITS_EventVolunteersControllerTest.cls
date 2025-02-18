@isTest
public with sharing class SVNSUMMITS_EventVolunteersControllerTest {
    static final String CUSTOMER_COMMUNITY_USER = 'Tiger Connect Community User';

    @testSetup static void methodName(){
        // Test Event
        List<Event__c> testEvents = SVNSUMMITS_EventUtility.createEventsRecords(1);

        // Test volunteer Need
        Volunteer_Need__c testNeed = new Volunteer_Need__c(
                Event__c = testEvents[0].Id,
                Volunteers_Needed__c = 10
        );
        insert testNeed;

        // Test users
        List<User> testUsers =  SVNSUMMITS_EventUtility.createUsers(2,CUSTOMER_COMMUNITY_USER);

        // Test registrations
        Volunteer_Registration__c testRegistration = new Volunteer_Registration__c(
                Volunteer_Need__c = testNeed.Id,
                User__c = testUsers[0].Id
        );
        insert testRegistration;

    }

    @isTest
    public static void testGetEventVolunteerNeeds() {
        List<Event__c> testEvents = [Select Id from Event__c];
        List<User> testUsers =  [Select Id from User limit 1];

        // Test by specifying user id
        List<SVNSUMMITS_EventVolunteerWrapper> testNeeds = SVNSUMMITS_EventVolunteersController.getEventVolunteerNeeds(testEvents[0].Id,testUsers[0].Id);
        System.assertEquals(testNeeds[0].volunteerNeed.Volunteers_Needed__c, 10);

        // Now test with run as user
        System.runAs(testUsers[0]){
            testNeeds = SVNSUMMITS_EventVolunteersController.getEventVolunteerNeeds((String)testEvents[0].Id);
            System.assertEquals(testNeeds[0].volunteerNeed.Volunteers_Needed__c, 10);

            // Make sure user is picked up as registered... first create a new registration
            Volunteer_Registration__c testRegistration = new Volunteer_Registration__c(
                    Volunteer_Need__c = testNeeds[0].volunteerNeed.Id,
                    User__c = testUsers[0].Id
            );
            insert testRegistration;

            // Query again... current user should now be registered
            testNeeds = SVNSUMMITS_EventVolunteersController.getEventVolunteerNeeds((String)testEvents[0].Id);
            system.assertEquals(testNeeds[0].currentUserRegistered, true);
        }
    }

    @isTest
    public static void testRegisterAndDelete() {
        List<Volunteer_Need__c> testNeeds = [Select Id from Volunteer_Need__c];

        // New list of test users
        List<User> testUsers =  [Select Id from User limit 1];
        System.assertEquals(true,SVNSUMMITS_EventVolunteersController.registerVolunteer(testNeeds[0].Id,testUsers[0].Id));

        // There was one registration in set up, and we just made another, so there should now be two
        Volunteer_Need__c testNeed = [Select Volunteers_Registered__c from Volunteer_Need__c where Id = :testNeeds[0].Id];
        System.assertEquals(testNeed.Volunteers_Registered__c,2);

        // Now remove
        System.assertEquals(true,SVNSUMMITS_EventVolunteersController.removeVolunteer(testNeeds[0].Id,testUsers[0].Id));

        // New test in current running user
        System.runAs(testUsers[0]){
            System.assert(true,SVNSUMMITS_EventVolunteersController.registerVolunteerSingle((String)testNeeds[0].Id));
            System.assert(true,SVNSUMMITS_EventVolunteersController.removeVolunteerSingle((String)testNeeds[0].Id));
        }

    }

    @isTest
    public static void testGetUser() {
        List<User> testUsers =  [Select Id from User limit 1];

        System.runAs(testUsers[0]){
            System.assertEquals(testUsers[0].Id,SVNSUMMITS_EventVolunteersController.getCurrentUser().Id);
        }
    }

    @isTest
    public static void testDuplicationTrigger() {
        List<User> testUsers =  [Select Id from User limit 1];
        List<Volunteer_Need__c> testNeeds = [Select Id from Volunteer_Need__c];

        // Create two duplicates
        Volunteer_Registration__c testRegistration = new Volunteer_Registration__c(
                Volunteer_Need__c = testNeeds[0].Id,
                User__c = testUsers[0].Id
        );

        Volunteer_Registration__c testRegistration2 = new Volunteer_Registration__c(
                Volunteer_Need__c = testNeeds[0].Id,
                User__c = testUsers[0].Id
        );

        String errorMessage = '';

        // Attempt to create duplicate
        try{
            insert testRegistration;
            insert testRegistration2;
        } catch (Exception e){
            errorMessage = e.getMessage();
        }

        // There was a problem! Make sure errorMessage is not blank
        System.assert(errorMessage != '');
    }

    @isTest
    public static void testCreateVolunteerNeeds() {
        // Get test event
        List<Event__c> testEvents = [Select Id from Event__c];

        // Create a need
        Volunteer_Need__c testNeed = new Volunteer_Need__c(
                Event__c = testEvents[0].Id,
                Volunteers_Needed__c = 10
        );

        // Add it to list
        List<Volunteer_Need__c> volunteerNeeds = new List<Volunteer_Need__c>();
        volunteerNeeds.add(testNeed);

        List<String> resultStrings = SVNSUMMITS_EventVolunteersController.createVolunteerNeeds(testEvents[0],volunteerNeeds,new List<Volunteer_Need__c>());

        System.assertEquals(0,resultStrings.size());
    }

    @isTest
    public static void testInitVolunteerNeeds() {
        // Get test event
        List<Event__c> testEvents = [Select Id from Event__c];

        System.assertEquals(SVNSUMMITS_EventVolunteersController.initVolunteerNeeds((String)testEvents[0].id).Volunteer_Needs__r.size(),1);
    }
    

}