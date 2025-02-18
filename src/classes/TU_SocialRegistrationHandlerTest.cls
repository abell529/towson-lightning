/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 3/26/18.
 */

@IsTest
private class TU_SocialRegistrationHandlerTest {

    @TestSetup
    static void testSetupUser() {
        List<User> newUsrs = TU_TestUtilities.createRegUser(1, true);
        Contact contact = Peak_TestUtils.createTestContact();
        Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
//        contact.AccountId = setupId.Self_Registration_Account_Id__c;
        contact.TU_Home_Email__c = contact.Email;
        update contact;
    }

    @IsTest
    static void testCreateExternalUser() {

        TU_SocialRegistrationHandler handler = new TU_SocialRegistrationHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
                null, new Map<String, String>{'sfdc_networkid' => TU_Utilities.getCommunityNetworkId()});
        User user = handler.createUser(null, sampleData);
        insert user;

        System.assertNotEquals(null, user.Id);
    }

    @IsTest
    static void testCreateInternalUser() {
        TU_SocialRegistrationHandler handler = new TU_SocialRegistrationHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
                null, new Map<String, String>{'language' => 'en_US'});
        User user = handler.createUser(null, sampleData);
        insert user;

        System.assertNotEquals(null, user.Id);
    }

    @IsTest
    static void testUpdateUser() {
        Id userId = [SELECT Id FROM User WHERE FirstName = 'First' LIMIT 1].Id;
        TU_SocialRegistrationHandler handler = new TU_SocialRegistrationHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
                null, new Map<String, String>{'sfdc_networkid' => TU_Utilities.getCommunityNetworkId()});

        try {
            handler.updateUser(userId, null, sampleData);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.assertEquals(null, e.getMessage());
        }
    }

    @IsTest
    static void testInvitedUser() {
        Contact contact = new Contact();
        contact = [SELECT TU_Home_Email__c FROM Contact WHERE LastName = :Peak_TestConstants.LASTNAME LIMIT 1];

        TU_SocialRegistrationHandler handler = new TU_SocialRegistrationHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                'testFirst testLast', contact.TU_Home_Email__c, null, 'testuserlong', 'en_US', 'facebook',
                null, new Map<String, String>{'sfdc_networkid' => TU_Utilities.getCommunityNetworkId()});

        Boolean successError = false;

        User user = handler.createUser(null, sampleData);
        insert user;

        System.assertNotEquals(null, user.Id);
    }

}