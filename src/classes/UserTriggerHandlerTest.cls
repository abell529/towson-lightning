/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 3/28/18.
 */

@IsTest
private class UserTriggerHandlerTest {

    @TestSetup
    static void testSetup() {
        User user = Peak_TestUtils.createStandardUser();
        Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
        user.ProfileId = setupId.Self_Registration_Profile_Id__c;
        insert user;
    }

    @IsTest
    static void testUpdateRelatedContact() {

        User user = new User();
        user = [SELECT Id, Birthday_TU__c, ContactId FROM User WHERE LastName=:Peak_TestConstants.LASTNAME];

        Test.startTest();
        user.Birthday_TU__c = Date.today().addYears(-30);
        update user;
        Test.stopTest();

        Contact contact = new Contact();
        contact = [SELECT Id, Birthdate, LastUpdatedbyAlumniUser_TU__c FROM Contact WHERE Id = :user.ContactId];
        System.assertNotEquals(null, contact.LastUpdatedbyAlumniUser_TU__c);
    }
}