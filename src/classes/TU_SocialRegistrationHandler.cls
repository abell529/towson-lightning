/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 3/26/18.
 */

global class TU_SocialRegistrationHandler implements Auth.RegistrationHandler {

    class RegHandlerException extends Exception {}

    global User createUser(Id portalId, Auth.UserData data) {
        User newUser = new User();

        if(data.attributeMap.containsKey('sfdc_networkid')) {
            Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(data.attributeMap.get('sfdc_networkid'));

            if (TU_Utilities.userExists(data.email,setupId.Self_Registration_Profile_Id__c) ||
                    TU_Utilities.userExists(data.email,setupId.Self_Registration_Social_Profile_Id__c)) {
                throw new RegHandlerException('We already have an Alumni user for this email address. ' +
                        'Please verify you do not already have a user.');
            } else {
                Contact contact = TU_Utilities.findContact(new Contact(TU_Home_Email__c = data.email));

                contact.TU_Home_Email__c = data.email;
                contact.FirstName = data.firstName;
                contact.LastName = data.lastName;
                newUser.username = data.email;
                newUser.email = data.email;
                newUser.lastName = data.lastName;
                newUser.firstName = data.firstName;
                String alias = data.email;
                //Alias must be 8 characters or less
                if (alias.length() > 8) {
                    alias = alias.substring(0, 8);
                }
                newUser.alias = alias;
                newUser.languagelocalekey = UserInfo.getLocale();
                newUser.localesidkey = UserInfo.getLocale();
                newUser.emailEncodingKey = 'UTF-8';
                newUser.timeZoneSidKey = 'America/New_York';
                newUser.CommunityNickname = newUser.FirstName + '.' + newUser.LastName;
                newUser.CommunityNickname = TU_Utilities.createDefaultNickname(newUser.CommunityNickname);
                newUser.profileId = setupId.Self_Registration_Social_Profile_Id__c;

                if (contact.Id == null) {
                    contact.AccountId = setupId.Self_Registration_Account_Id__c;
                    insert contact;
                } else {
                    if (contact.AccountId == setupId.Self_Registration_Account_Id__c) {
                        newUser.profileId = setupId.Self_Registration_Profile_Id__c;
                    } else {
                        contact.AccountId = setupId.Self_Registration_Account_Id__c;
                    }
                    update contact;
                }

                newUser.ContactId = contact.Id;
            }

        } else {
            //This is not a community, so create a regular standard user
            Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
            newUser.username = data.username + '@myorg.com';
            newUser.email = data.email;
            newUser.lastName = data.lastName;
            newUser.firstName = data.firstName;
            String alias = data.username;
            //Alias must be 8 characters or less
            if(alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            newUser.alias = alias;
            newUser.languagelocalekey = UserInfo.getLocale();
            newUser.localesidkey = UserInfo.getLocale();
            newUser.emailEncodingKey = 'UTF-8';
            newUser.timeZoneSidKey = 'America/New_York';
            newUser.profileId = p.Id;

        }

        return newUser;
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        User u = new User(id=userId);
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        update(u);
    }


}