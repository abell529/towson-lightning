/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 3/26/18.
 */

public without sharing class TU_CommunitiesSelfRegController {

    private static User user;
    private static Boolean invitedContact = false;
    private static Id networkId = TU_Utilities.getCommunityNetworkId();
    private static Community_Setup_Id__mdt setupId;
    private static Savepoint savePoint;

    @AuraEnabled
    public static Contact getContact(String contactId) {
        Contact contactInfo = new Contact();

        if(contactId == null){
            contactId = ApexPages.currentPage().getParameters().get('id');
        }
        String userId = UserInfo.getUserId();

        if (contactId != null) {
            contactInfo = [SELECT Id, FirstName, LastName, TU_Home_Email__c, GradYear_TU__c, LastNameatGraduation_TU__c,
                    TU_EmplID__c, AccountId, Advance_ID__c, TU_Use_Social_Sign_On__c FROM Contact WHERE Id = :contactId LIMIT 1];
        } else if (userId != null) {
            user = [SELECT Contact.Id, Contact.FirstName, Contact.LastName, Contact.TU_Home_Email__c,
                    Contact.GradYear_TU__c, Contact.LastNameatGraduation_TU__c, Contact.TU_EmplID__c,
                    Contact.Advance_ID__c, Contact.TU_Use_Social_Sign_On__c FROM User WHERE Id = :userId LIMIT 1];
            if (user.Contact.Id != null) {
                contactInfo = user.Contact;
            }
        }
        return contactInfo;
    }

    @AuraEnabled
    public static Contact getUserContact(String userId) {
        Contact contactInfo = new Contact();
        user = new User();

        user = [SELECT Contact.Id, Contact.FirstName, Contact.LastName, Contact.TU_Home_Email__c,
                    Contact.GradYear_TU__c, Contact.LastNameatGraduation_TU__c, Contact.TU_EmplID__c,
                    Contact.Advance_ID__c, Contact.TU_Use_Social_Sign_On__c FROM User WHERE Id = :userId LIMIT 1];
        if (user.Contact.Id != null) {
           contactInfo = user.Contact;
        }

        return contactInfo;
    }

    @AuraEnabled
    public static Peak_Response registerUser(String contactInfo, String regConfirmUrl, String newUserUrl) {
        Peak_Response peakResponse = new Peak_Response();
        Contact newContact = (Contact)JSON.deserialize(contactInfo, Contact.class);
        setupId = getSetupId();
        String userId = UserInfo.getUserId();

        savePoint = Database.setSavepoint();
        Contact foundContact = new Contact();

        newContact.Email = newContact.TU_Home_Email__c;
        newContact.LastUpdatedbyAlumniUser_TU__c = Datetime.now();

        if (newContact.Id == null) {
            foundContact = TU_Utilities.findContact(newContact);
            if (foundContact.Id != null) {
                newContact.Id = foundContact.Id;
                mergeContact(foundContact, newContact);
            }

        } else {

            if (newContact.AccountId == setupId.Self_Registration_Account_Id__c &&
                    UserInfo.getProfileId() != setupId.Self_Registration_Social_Profile_Id__c) {
                invitedContact = true;
            }
        }

        newContact.AccountId = setupId.Self_Registration_Account_Id__c;
        if (UserInfo.getProfileId() == setupId.Self_Registration_Social_Profile_Id__c) {
            newContact.Additional_Details_for_SSO_Completed__c = true;
        }

        try {
            upsert newContact;

            PageReference page;

            if (invitedContact) {
                createUser(newContact);
                page = new PageReference(newUserUrl);
            } else {
                createCase(newContact);
                String url = Site.getBaseUrl() + '/s' + regConfirmUrl.remove('.');
                page = new PageReference(url);
            }

            if (page != null && !Test.isRunningTest()) {
                aura.redirect(page);
            }

            peakResponse.success = true;

        } catch (Exception e) {
            System.debug(newContact);
            System.debug(e);
            Database.rollback(savePoint);
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
        }

        return peakResponse;

    }

    private static void createCase(Contact contact) {

        Case regCase = new Case();
        regCase.AccountId = contact.AccountId;
        regCase.ContactId = contact.Id;
        regCase.Current_Department_TU__c = 'Alumni Relations';
        regCase.Originating_Department_TU__c = 'Alumni Relations';
        regCase.Division_TU__c = 'Univ. Advancement';
        regCase.Origin = 'Self Registration';
        regCase.Case_Private_TU__c = true;
        regCase.Description =  'Self Registration Approval - Alumni';
        regCase.Subject = 'Self Registration Approval - Alumni';

        if (setupId.Registration_Case_Queue_Id__c != null) {
            regCase.OwnerId = setupId.Registration_Case_Queue_Id__c;
        } else {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            regCase.setOptions(dmo);
        }

        insert regCase;

    }

    private static void createUser(Contact contact) {
        User newUser = TU_Utilities.formatUserFromContact(Contact, null);

        if (contact.AccountId == null) {
            contact.AccountId = setupId.Self_Registration_Account_Id__c;
        }

        String alias = newUser.Email;
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }

        newUser.alias = alias;
        String userId = Site.createExternalUser(newUser, setupId.Self_Registration_Account_Id__c);

        System.debug(newUser);

    }

    private static Community_Setup_Id__mdt getSetupId() {
        return TU_Utilities.getCommunitySetupIds(networkId);
    }

    private static Contact mergeContact(Contact oldContact, Contact newContact) {

        if (oldContact.Advance_ID__c != null) {
            newContact.Advance_ID__c = oldContact.Advance_ID__c;
        }

        if (oldContact.TU_EMPLID__c != null) {
            newContact.TU_EMPLID__c = oldContact.TU_EMPLID__c;
        }

        return newContact;
    }
}