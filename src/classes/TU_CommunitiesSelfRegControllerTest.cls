/**
 * Created by Kaj Petersen, 7Summits on 3/26/18.
 */

@IsTest
private class TU_CommunitiesSelfRegControllerTest {

    @IsTest
    static void testSocialSelfRegistration() {

        Test.startTest();
        Contact newContact = TU_CommunitiesSelfRegController.getContact(null);
        TU_SocialRegistrationHandler handler = new TU_SocialRegistrationHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
                null, new Map<String, String>{'sfdc_networkid' => TU_Utilities.getCommunityNetworkId()});
        User user = handler.createUser(null, sampleData);
        insert user;

        Contact contact = new Contact();

        System.runAs(user) {
            contact = TU_CommunitiesSelfRegController.getUserContact(user.Id);
            Peak_Response peakResponse = new Peak_Response();
            String contactInfo = JSON.serialize(contact);
            peakResponse = TU_CommunitiesSelfRegController.registerUser(contactInfo, '/test', '/test');
            System.assert(peakResponse.success);
        }
        newContact = [SELECT Additional_Details_for_SSO_Completed__c FROM Contact WHERE Id = :contact.Id];
        System.assert(newContact.Additional_Details_for_SSO_Completed__c);

        Test.stopTest();
    }

    @IsTest
    static void testInvitedSelfRegistration() {

        User user = Peak_TestUtils.createGuestUser();
        insert user;

        Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());

        Contact contact = new Contact(firstName=Peak_TestConstants.FIRSTNAME, lastName=Peak_TestConstants.LASTNAME,
                email=Peak_TestConstants.STANDARD_EMAIL, TU_Home_Email__c=Peak_TestConstants.STANDARD_EMAIL,
                GradYear_TU__c=String.valueOf(Date.today().addYears(-12).year()),
                Alumni_Graduation_Years_TU__c=String.valueOf(Date.today().addYears(-12).year()) + ',' +
                        String.valueOf(Date.today().addYears(-8).year()),
                LastNameatGraduation_TU__c= Peak_TestConstants.LASTNAME,
                TU_EmplID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0)),
                Advance_ID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0)),
                AccountId = setupId.Self_Registration_Account_Id__c);
        insert contact;

        Test.setCurrentPageReference(new PageReference('https://alumni-towsonuniversity.cs23.force.com/Register?id=' +
                contact.Id));

        Test.startTest();
        System.runAs(user) {
            Contact contact2 = TU_CommunitiesSelfRegController.getContact(contact.Id);
            String contactInfo = JSON.serialize(contact2);
            Peak_Response peakResponse = TU_CommunitiesSelfRegController.registerUser(contactInfo, '/test', '/test');
            System.assert(peakResponse.success);
        }
        Test.stopTest();
    }

    @IsTest
    static void testNormalSelfRegistration() {
        Test.setCurrentPageReference(new PageReference('https://alumni-towsonuniversity.cs23.force.com/Register'));

        Test.startTest();
        Contact contact = TU_CommunitiesSelfRegController.getContact(null);
        contact = new Contact(firstName=Peak_TestConstants.FIRSTNAME, lastName=Peak_TestConstants.LASTNAME,
                TU_Home_Email__c=Peak_TestConstants.STANDARD_EMAIL,
                GradYear_TU__c=String.valueOf(Date.today().addYears(-12).year()),
                LastNameatGraduation_TU__c= Peak_TestConstants.LASTNAME,
                TU_EmplID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0)),
                Advance_ID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0)));

        String contactInfo = JSON.serialize(contact);
        Peak_Response peakResponse = TU_CommunitiesSelfRegController.registerUser(contactInfo, '/test', '/test');
        System.assert(peakResponse.success);
        Test.stopTest();
    }

    @IsTest
    static void testNormalSelfRegistrationWithContact() {
        Test.setCurrentPageReference(new PageReference('https://alumni-towsonuniversity.cs23.force.com/Register'));

        Test.startTest();
        Contact contact = TU_CommunitiesSelfRegController.getContact(null);
        contact = new Contact(firstName=Peak_TestConstants.FIRSTNAME, lastName=Peak_TestConstants.LASTNAME,
                TU_Home_Email__c=Peak_TestConstants.STANDARD_EMAIL,
                GradYear_TU__c=String.valueOf(Date.today().addYears(-12).year()),
                LastNameatGraduation_TU__c= Peak_TestConstants.LASTNAME);

        String contactInfo = JSON.serialize(contact);

        contact.Alumni_Graduation_Years_TU__c=String.valueOf(Date.today().addYears(-12).year()) + ',' +
                String.valueOf(Date.today().addYears(-8).year());
        contact.TU_EmplID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0));
        contact.Advance_ID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0));
        insert contact;


        Peak_Response peakResponse = TU_CommunitiesSelfRegController.registerUser(contactInfo, '/test', '/test');
        System.assert(peakResponse.success);
        Test.stopTest();
    }

    @IsTest
    static void testNormalSelfRegistrationErrors() {
        Test.setCurrentPageReference(new PageReference('https://alumni-towsonuniversity.cs23.force.com/Register'));

        Test.startTest();
        Contact contact = TU_CommunitiesSelfRegController.getContact(null);
        contact = new Contact(firstName=Peak_TestConstants.FIRSTNAME, lastName=Peak_TestConstants.LASTNAME,
                TU_Home_Email__c=Peak_TestConstants.STANDARD_EMAIL,
                GradYear_TU__c=String.valueOf(Date.today().addYears(-12).year()),
                Alumni_Graduation_Years_TU__c=String.valueOf(Date.today().addYears(-12).year()) + ',' +
                        String.valueOf(Date.today().addYears(-8).year()),
                LastNameatGraduation_TU__c= Peak_TestConstants.LASTNAME,
                TU_EmplID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000000)),
                Advance_ID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000000)));

        String contactInfo = JSON.serialize(contact);
        Peak_Response peakResponse = TU_CommunitiesSelfRegController.registerUser(contactInfo, '/test', '/test');
        System.assert(!peakResponse.success);
        Test.stopTest();
    }


}