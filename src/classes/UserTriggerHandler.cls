/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 3/28/18.
 */


public without sharing class UserTriggerHandler {

    private static List<SObject> sObjectsToInsert = new List<SObject>();
    private static List<SObject> sObjectsToUpdate = new List<SObject>();
    private boolean executing = false;

    public UserTriggerHandler(boolean isExecuting) {
        executing = isExecuting;
    }

    // Trigger Interfaces to Handler
    public void IsBeforeInsert(List<User> newUser) {

    }

    public void IsAfterInsert(List<User> newUser, Map<Id, User> newUserMap) {
        Map<Id, User> oldUserMap = new Map<Id, User>();

    }

    public void IsBeforeUpdate(List<User> newUser, Map<Id, User> newUserMap,
            List<User> oldUser, Map<Id, User> oldUserMap) {

    }
    public void IsAfterUpdate(List<User> newUser, Map<Id, User> newUserMap,
            List<User> oldUser, Map<Id, User> oldUserMap) {
        retrieveUsersWithContacts(newUser, oldUserMap);
    }

    private void retrieveUsersWithContacts(List<User> users, Map<Id, User> oldUserMap) {
        Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());

        Set<Id> userIds = new Set<Id>();
        for (User user : users) {
            if (!String.isEmpty(user.ContactId)) {
                if (user.ProfileId == setupId.Self_Registration_Profile_Id__c) {
                    if (oldUserMap.get(user.Id).ProfileId != setupId.Self_Registration_Social_Profile_Id__c) {
                        userIds.add(user.Id);
                    }
                }
            }
        }

        if (!userIds.isEmpty()) {
            updateRelatedContact(userIds);
        }

    }

    @Future
    private static void updateRelatedContact(Set<Id> userIds) {

        for (User user : [SELECT ContactId, FirstName, LastName, LastNameatGraduation_TU__c, GraduationYear_TU__c, Email,
                Phone, Street, City, State, Country, PostalCode, CompanyName, Title, OtherGraduationYear_TU__c,
                OtherMajor_TU__c, Major_TU__c, CommunityNickname FROM User WHERE Id IN :userIds]) {
            if (!String.isEmpty(user.ContactId)) {
                Contact contact = new Contact(Id=user.ContactId);
                contact.FirstName = user.FirstName;
                contact.LastName = user.LastName;
                contact.LastNameatGraduation_TU__c = user.LastNameatGraduation_TU__c;
                contact.GradYear_TU__c = user.GraduationYear_TU__c;
                contact.TU_Home_Email__c = user.Email;
                contact.Phone = user.Phone;
                contact.MailingStreet = user.Street;
                contact.MailingCity = user.City;
                contact.MailingState = user.State;
                contact.MailingCountry = user.Country;
                contact.MailingPostalCode = user.PostalCode;
                contact.Employer_Organization__c = user.CompanyName;
                contact.Employer_Organization_Title__c = user.Title;
                contact.OtherGraduationYearAlumni_TU__c = user.OtherGraduationYear_TU__c;
                contact.OtherMajorAlumni_TU__c = user.OtherMajor_TU__c;
                contact.MajorAlumni_TU__c = user.Major_TU__c;
                contact.NicknameAlumni_TU__c = user.CommunityNickname;
                contact.LastUpdatedbyAlumniUser_TU__c = Datetime.now();
                sObjectsToUpdate.add(contact);

            }
        }

        update sObjectsToUpdate;
    }

}