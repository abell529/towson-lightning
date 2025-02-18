/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 3/30/18.
 */

public without sharing class TU_CreateConnectUserExtension {

    private Id caseId;
    private ApexPages.StandardController controller;
    private static Community_Setup_Id__mdt setupId;

    public TU_CreateConnectUserExtension(ApexPages.StandardController controller) {
        caseId = ApexPages.currentPage().getParameters().get('id');
        setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
    }

    public PageReference processRegistrationCase() {

        Case userCase = new Case();
        Boolean closeCase = false;

        userCase = [SELECT Id, Status, ContactId, Contact.TU_Home_Email__c, Contact.Email, Contact.FirstName,
                Originating_Department_TU__c, Contact.LastName, Contact.AccountId, Contact.GradYear_TU__c,
                Contact.LastNameatGraduation_TU__c, Contact.Advance_ID__c, Contact.TU_EMPLID__c,
                Contact.MajorAlumni_TU__c FROM Case WHERE Id = :caseId];

        if (userCase.ContactId != null && validateCase(userCase)) {
            List<User> users = new List<User>([SELECT Id, ProfileId, ContactId FROM User WHERE
                    ContactId=:userCase.ContactId]);

            if (users.isEmpty()) {
                closeCase = createConnectUser(userCase.Contact);
            } else {
                updateUserProfile(users[0].Id);
                closeCase = true;
            }
        }

        if (closeCase) {
            userCase.Status = 'Resolved';
            update userCase;
        }

        return new PageReference('/' + caseId);
    }

    public Boolean validateCase(Case currentCase) {
        Boolean valid = true;

        if (currentCase.Status == 'Resolved') {
            valid = false;
        } else if (currentCase.Originating_Department_TU__c != 'Alumni Relations') {
            valid = false;
        }

        return valid;
    }

    public Boolean createConnectUser(Contact contact) {
        User newUser = TU_Utilities.formatUserFromContact(Contact, null);

        String alias = newUser.Email;
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }

        newUser.alias = alias;
        newUser.languagelocalekey = UserInfo.getLocale();
        newUser.localesidkey = UserInfo.getLocale();
        newUser.emailEncodingKey = 'UTF-8';
        newUser.timeZoneSidKey = 'America/New_York';

        String accountId = contact.AccountId;
        if (accountId == null) {
            accountId = setupId.Self_Registration_Account_Id__c;
        }

        if (newUser.ProfileId == null) {
            newUser.ProfileId = setupId.Self_Registration_Profile_Id__c;
        }

        try {
            insert newUser;
            return true;
        } catch (Exception e) {
            System.debug(e);
            return false;
        }
    }

    @Future
    public static void updateUserProfile(String userId) {
        User user = new User();
        user = [SELECT Id, ProfileId FROM User WHERE Id = :userId];
        setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());

        if (user.ProfileId == setupId.Self_Registration_Social_Profile_Id__c) {
            user.ProfileId = setupId.Self_Registration_Profile_Id__c;
            update user;
        }
    }
}