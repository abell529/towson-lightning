/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 3/26/18.
 */

@IsTest
private class TU_UtilitiesTest {

    @TestSetup
    static void testSetupData() {
        List<User> users = TU_TestUtilities.createRegUser(1, true);
    }

    @IsTest
    static void testGetCommunitySetupIds() {

        Test.startTest();
        Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
        System.debug(setupId);
        Test.stopTest();

        System.assertNotEquals(null, setupId);
    }

    @IsTest
    static void testUserExists() {
        List<User> users = new List<User>([SELECT Id, Email, ProfileId FROM User LIMIT 2]);
        Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());

        Test.startTest();
        for (User user : users) {
            Boolean exists = TU_Utilities.userExists(user.Email, user.ProfileId);
            System.assert(exists);
        }

        Boolean exists = TU_Utilities.userExists(Peak_TestConstants.GUEST_EMAIL, setupId.Self_Registration_Profile_Id__c);
        System.assert(!exists);

        Test.stopTest();
    }

    @IsTest
    static void testFindContact() {
        Test.startTest();
        Contact contact = new Contact();
        contact.TU_Home_Email__c = 'First.Last1' + TU_TestUtilities.TU_TestEmailSuffix;
        contact.GradYear_TU__c =  String.valueOf(Date.today().addYears(10*-1).year());
        contact.LastNameatGraduation_TU__c = 'Madidan' + 1;
        contact.TU_EMPLID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0));
        contact.Advance_ID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0));
        contact.FirstName = 'First';
        contact.LastName = 'Last';

        Contact findContact = TU_Utilities.findContact(contact);
        System.assertNotEquals(null, findContact);
        findContact = contact;
        findContact.Alumni_Graduation_Years_TU__c = contact.GradYear_TU__c;
        insert findContact;

        Contact foundContact = TU_Utilities.findContact(contact);
        System.assertEquals(findContact.LastName, foundContact.LastName);

        Test.stopTest();

    }

    @IsTest
    static void testFormatUserFromContact() {
        Test.startTest();
        Contact contact = new Contact();
        contact.TU_Home_Email__c = 'First.Last1' + TU_TestUtilities.TU_TestEmailSuffix;
        contact.GradYear_TU__c =  String.valueOf(Date.today().addYears(10*-1).year());
        contact.LastNameatGraduation_TU__c = 'Madidan' + 1;
        contact.TU_EMPLID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0));
        contact.Advance_ID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0));

        User newUsr = TU_Utilities.formatUserFromContact(contact, null);
        System.assertEquals(contact.TU_Home_Email__c,newUsr.Email);

        Test.stopTest();

    }

    @IsTest
    static void testGenerateRandomString() {
        Test.startTest();
        String randomString = TU_Utilities.generateRandomString(18);
        System.assertEquals(18,randomString.length());
        Test.stopTest();

    }


    @IsTest
    static void testCreateDefaultNickname() {
        List<User> users = new List<User>([SELECT Id, CommunityNickname FROM User WHERE CommunityNickname != null LIMIT 2]);

        Test.startTest();
        for (User user : users) {
            String nickname = TU_Utilities.createDefaultNickname(user.CommunityNickname);
            System.assertNotEquals(null, nickname);
        }

        String nickname = TU_Utilities.createDefaultNickname('Test.UnitABC');
        System.assertEquals('Test.UnitABC', nickname);

        Test.stopTest();
    }

    @IsTest
    static void testBuildSOQL() {
        Test.startTest();
        String query = TU_Utilities.buildSOQL('Account', true, null, 'Name != null', 'Name');
        System.assertNotEquals(null, query);
        Test.stopTest();
    }

}