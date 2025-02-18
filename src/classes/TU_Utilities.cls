/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 3/26/18.
 */

public with sharing class TU_Utilities {

    public static Community_Setup_Id__mdt getCommunitySetupIds(Id networkId) {
        return [SELECT Id, Self_Registration_Account_Id__c, Self_Registration_Social_Profile_Id__c,
                Self_Registration_Profile_Id__c, Guest_Event_Account_Id__c, Registration_Case_Queue_Id__c FROM Community_Setup_Id__mdt WHERE
                Network_Id__c = :networkId LIMIT 1];
    }

    public static Id getCommunityNetworkId() {
        Id networkId = System.Network.getNetworkId();

        if (networkId == null) {
            networkId = [SELECT Id FROM Network WHERE Name = 'Tiger Connect'].Id;
        }

        return networkId;
    }

    public static Boolean userExists(String email, String profileId) {
        List<User> users = new List<User>([SELECT Id FROM User WHERE Email = :email AND ProfileId = :profileId]);
        if (users.isEmpty()) {
            return false;
        }
        return true;
    }

    public static Contact findContact(Contact contact) {
        String fields = 'Id, TU_Home_Email__c, GradYear_TU__c, LastNameatGraduation_TU__c, TU_EMPLID__c, Advance_ID__c, ' +
                'FirstName, LastName, LastModifiedDate ';
        String whereClause;
        if (contact.TU_Home_Email__c != null) {
            whereClause=' TU_Home_Email__c = \'' + contact.TU_Home_Email__c + '\'';
        }
        if (contact.LastNameatGraduation_TU__c != null) {
            whereClause += whereClause != null ? ' AND ' : '';
            whereClause += ' LastNameatGraduation_TU__c = \'' + contact.LastNameatGraduation_TU__c + '\'';
        }
        if (contact.GradYear_TU__c != null) {
            String likeGradYear = '%' + contact.GradYear_TU__c + '%';
            whereClause += whereClause != null ? ' AND ' : '';
            whereClause += ' Alumni_Graduation_Years_TU__c like \'' + likeGradYear + '\'';
        }
        if (contact.TU_EMPLID__c != null) {
            whereClause += whereClause != null ? ' AND ' : '';
            whereClause += ' TU_EMPLID__c = \'' + contact.TU_EMPLID__c + '\'';
        }
        if (contact.Advance_ID__c != null) {
            whereClause += whereClause != null ? ' AND ' : '';
            whereClause += ' Advance_ID__c = \'' + contact.Advance_ID__c + '\'';
        }
        if (contact.FirstName != null) {
            whereClause += whereClause != null ? ' AND ' : '';
            whereClause += ' FirstName = \'' + contact.FirstName + '\'';
        }
        if (contact.LastName != null) {
            whereClause += whereClause != null ? ' AND ' : '';
            whereClause += ' LastName = \'' + contact.LastName + '\'';
        }

        List<Contact> contacts = new List<Contact>();
        contacts = database.query(buildSOQL('Contact', false, fields, whereClause,'LastModifiedDate DESC'));

        if (!contacts.isEmpty()) {
            return contacts[0];
        }

        return new Contact();
    }

    public static String createDefaultNickname(String nickName) {
        String likeNickname = nickName + '%';
        List<User> users = new List<User>([SELECT Id, CommunityNickname FROM User WHERE
                CommunityNickname LIKE :likeNickname]);

        if (!users.isEmpty()) {
           nickName = nickName + String.valueOf(users.size() + 1);
        }

        return nickName;
    }

    public static String buildSOQL(String sObjectString, Boolean allFields, String fields, String whereString,
            String orderBy) {

        String returnString;
        if (allFields) {
            fields = selectAllFields(sObjectString);
        }

        returnString = 'SELECT ' + fields + ' FROM ' + sObjectString;

        if (whereString != null) {
            returnString = returnString + ' WHERE ' + whereString;
        }

        if (orderBy != null) {
            returnString = returnString + ' ORDER BY ' + orderBy;
        }

        return returnString;
    }

    public static String selectAllFields(String sObjectString) {
        String allFields;
        Boolean first = true;
        Map<String, Schema.SObjectField> objectFieldMap =
                Schema.getGlobalDescribe().get(sObjectString).getDescribe().fields.getMap();

        for (String fields : objectFieldMap.keySet()) {
            if (allFields == null) {
                allFields = fields;
            } else {
                allFields += ', ' + fields;
            }
        }

        return allFields;
    }

    public static User formatUserFromContact(Contact contact, Id profileId) {
        User newUser = new User();
        newUser.Username = contact.TU_Home_Email__c;
        newUser.Email = contact.TU_Home_Email__c;
        newUser.FirstName = contact.FirstName;
        newUser.LastName = contact.LastName;
        newUser.CommunityNickname = String.valueOf(contact.FirstName + '.' + contact.LastName).left(37);
        newUser.CommunityNickname = TU_Utilities.createDefaultNickname(newUser.CommunityNickname);
        if (profileId != null) {
            newUser.ProfileId = profileId;
        }

        newUser.ContactId = contact.Id;
        newUser.GraduationYear_TU__c = contact.GradYear_TU__c;
        newUser.LastNameatGraduation_TU__c = contact.LastNameatGraduation_TU__c;
        newUser.AlumniID_TU__c = contact.Advance_ID__c;
        newUser.TU_ID_TU__c = contact.TU_EMPLID__c;
        newUser.Major_TU__c = contact.MajorAlumni_TU__c;

        return newUser;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
}