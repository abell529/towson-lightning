/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 3/30/18.
 */

@IsTest
private class TU_CreateConnectUserExtensionTest {
    @IsTest
    static void testprocessRegistrationCaseWithoutUser() {
        Contact contact = new Contact(firstName=Peak_TestConstants.FIRSTNAME, lastName=Peak_TestConstants.LASTNAME,
                email=Peak_TestConstants.STANDARD_EMAIL, TU_Home_Email__c=Peak_TestConstants.STANDARD_EMAIL,
                GradYear_TU__c=String.valueOf(Date.today().addYears(-12).year()),
                LastNameatGraduation_TU__c= Peak_TestConstants.LASTNAME,
                TU_EmplID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0)),
                Advance_ID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0)));

        insert contact;
        String contactInfo = JSON.serialize(contact);
        Peak_Response created = TU_CommunitiesSelfRegController.registerUser(contactInfo,'/test','/test');

        if (created.success) {
            List<Case> cases = new List<Case>([SELECT Id FROM Case WHERE ContactId = :contact.Id LIMIT 1]);
            Test.setCurrentPageReference(new PageReference('https://alumni-towsonuniversity.cs23.force.com/Register?id=' +
                    cases[0].Id));
            ApexPages.StandardController controller = new ApexPages.StandardController(cases[0]);
            TU_CreateConnectUserExtension extension = new TU_CreateConnectUserExtension(controller);

            Test.startTest();
            extension.processRegistrationCase();
            List<User> users = new List<User>([SELECT Id, Name, ContactId FROM User WHERE ContactId = :contact.Id]);
            System.debug(users);
            Test.stopTest();
        }
    }

    @IsTest
    static void testProcessRegistrationCaseWithUser() {

        TU_SocialRegistrationHandler handler = new TU_SocialRegistrationHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
                null, new Map<String, String>{'sfdc_networkid' => TU_Utilities.getCommunityNetworkId()});
        User user = handler.createUser(null, sampleData);
        insert user;

        Contact contact = new Contact();
        System.runAs(user) {
            contact = TU_CommunitiesSelfRegController.getContact(null);
            System.debug(contact);
        }

        String contactInfo = JSON.serialize(contact);
        Peak_Response created = TU_CommunitiesSelfRegController.registerUser(contactInfo,'/test','/test');

        if (created.success) {
            List<Case> cases = new List<Case>([SELECT Id FROM Case WHERE ContactId = :contact.Id LIMIT 1]);
            Test.setCurrentPageReference(new PageReference('https://alumni-towsonuniversity.cs23.force.com/Register?id=' +
                    cases[0].Id));
            ApexPages.StandardController controller = new ApexPages.StandardController(cases[0]);
            TU_CreateConnectUserExtension extension = new TU_CreateConnectUserExtension(controller);

            Test.startTest();
            extension.processRegistrationCase();
            extension.processRegistrationCase();
            List<User> users = new List<User>([SELECT Id, Name, ContactId FROM User WHERE ContactId = :contact.Id]);
            System.debug(users);
            Test.stopTest();
        }
    }

}