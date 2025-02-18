/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 4/11/18.
 */

@IsTest
public class TU_TestUtilities {

    public static String TU_TestEmailSuffix = '@unitTest.com';

    /*
     Method Name : createRegUser
     Description : Method for creating Registered Users and their contact records.
    */

    public static List<User> createRegUser(Integer numberUsers, Boolean insertUsers) {
        List<User> users = new List<User>();
        List<Contact> contacts = new List<Contact>();

        Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());

        for (Integer con=0;con<numberUsers;con+=1) {
            Contact contact = new Contact();
            contact.FirstName = 'First';
            contact.LastName = 'Last' + String.valueOf(con+1);
            contact.TU_Home_Email__c = contact.FirstName + '.' + contact.LastName + TU_TestEmailSuffix;
            contact.GradYear_TU__c=String.valueOf(Date.today().addYears((con+10)*-1).year());

            if (Math.mod(con,2) == 0) {
                contact.LastNameatGraduation_TU__c= 'Madidan' + String.valueOf(con);
            } else {
                contact.LastNameatGraduation_TU__c = contact.LastName;
            }

            contact.TU_EmplID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0));
            contact.Advance_ID__c = String.valueOf(Decimal.valueOf(Math.random() * 1000000).setScale(0));
            contact.AccountId = Peak_TestUtils.createTestAccount().Id;
            contacts.add(contact);
        }

        insert contacts;

        for (Contact thisContact : contacts) {
            User user = TU_Utilities.formatUserFromContact(thisContact, setupId.Self_Registration_Social_Profile_Id__c);
            String alias = user.Email;
            //Alias must be 8 characters or less
            if(alias.length() > 8) {
                alias = alias.substring(0, 8);
            }

            user.alias = alias;
            user.languagelocalekey = UserInfo.getLocale();
            user.localesidkey = UserInfo.getLocale();
            user.emailEncodingKey = 'UTF-8';
            user.timeZoneSidKey = 'America/New_York';
            users.add(user);
        }

        if (insertUsers) {
            insert users;
        }

        return users;
    }

    /*
     Method Name : createEventsRecords
     Description : Method for creating event records
    */
    public static List<Event__c> createEventsRecords(Boolean unlisted, Integer numberEvents, Boolean insertEvents) {
        List<Event__c> eventList = new List<Event__c>();

        for (Integer i = 0; i < numberEvents; i++) {
            Event__c objEvent = new Event__c();

            objEvent.Name = 'event' + i;
            objEvent.Start_DateTime__c = Date.today();
            objEvent.End_DateTime__c = Date.today();
            objEvent.Details__c = 'Event Details is here.';
            objEvent.Location_Name__c = 'Location' + i;
            objEvent.Enable_RSVP__c = true;
            objEvent.UnlistedEvent_TU__c = unlisted;
            objEvent.EventFull_TU__c = false;
            objEvent.MaxAttendees_TU__c = (i+1) *10;
            objEvent.RSVP_Count_Threshold__c = objEvent.MaxAttendees_TU__c;
            objEvent.NumberofGuestsperRegistrantTU__c = Integer.valueOf(objEvent.MaxAttendees_TU__c / 5);
            objEvent.GuestAllowed_TU__c = true;
            objEvent.RSVP_URL_TU__c = '/event/' + objEvent.Name;
            objEvent.Enable_Pricing_Payment__c = false;

            eventList.add(objEvent);
        }

        if (insertEvents) {
            insert eventList;
        }

        return eventList;
    }
    /*
     Method Name : createRSVPRecords
     Description : Method for creating RSVP records
    */
    public static List<Event_RSVP__c> createRSVPRecords(Integer rsvpPerEvent, List<Event__c> eventList,
            List<Contact> contacts, List<User> users, Boolean insertRSVP, String response) {

        List<Event_RSVP__c> eventRSVPList = new List<Event_RSVP__c>();

        for (Event__c event : eventList) {
            for (Integer i = 0; i < rsvpPerEvent; i++) {
                Event_RSVP__c objEvent = new Event_RSVP__c();

                objEvent.Name = 'event' + i;
                objEvent.Event__c = event.Id;
                objEvent.Response__c = response;
                objEvent.RSVPToken_TU__c = null;
                objEvent.Phone_TU__c = '410-555-1212';
                objEvent.Major_TU__c = 'ITEC - Information Technology';
                objEvent.BirthdateTU__c = Date.today().addYears((i+32)*-1);
                objEvent.MasterRSVP_TU__c = true;
                if ((contacts.isEmpty() && users.isEmpty()) || (contacts.size() < i+1 && users.size() < i+1)) {
                    objEvent.FirstName_TU__c = 'First';
                    objEvent.LastName_TU__c = 'Last' + String.valueOf(i+1);
                    objEvent.Email_TU__c = objEvent.FirstName_TU__c + '.' + objEvent.LastName_TU__c + TU_TestEmailSuffix;
                    if (Math.mod(i, 2) == 0) {
                        objEvent.LastNameatGraduation_TU__c = 'Madidan' + String.valueOf(i);
                        objEvent.Gender_TU__c = 'Female';
                    } else {
                        objEvent.LastNameatGraduation_TU__c = objEvent.LastName_TU__c;
                        objEvent.Gender_TU__c = 'Male';
                    }
                    objEvent.GraduationYear_TU__c = String.valueOf(Date.today().addYears((i+10)*-1).year());
                } else if (!users.isEmpty() && users.size() >= i+1) {
                    objEvent.FirstName_TU__c = users[i].FirstName;
                    objEvent.LastName_TU__c = users[i].LastName;
                    objEvent.Email_TU__c = users[i].Email;
                    objEvent.LastNameatGraduation_TU__c = users[i].LastNameatGraduation_TU__c;
                    objEvent.GraduationYear_TU__c = users[i].GraduationYear_TU__c;
                    objEvent.Contact_TU__c = users[i].ContactId;
                    objEvent.User__c = users[i].Id;
                } else if (!contacts.isEmpty() && contacts.size() >= i+1) {
                    objEvent.FirstName_TU__c = contacts[i].FirstName;
                    objEvent.LastName_TU__c = contacts[i].LastName;
                    objEvent.Email_TU__c = contacts[i].Email;
                    objEvent.LastNameatGraduation_TU__c = contacts[i].LastNameatGraduation_TU__c;
                    objEvent.GraduationYear_TU__c = contacts[i].GradYear_TU__c;
//                    objEvent.Contact_TU__c = contacts[i].Id;
                }

                eventRSVPList.add(objEvent);
            }
        }

        if (insertRSVP) {
            insert eventRSVPList;
        }

        return eventRSVPList;
    }

    public static List<Event_RSVP__c> createChildRSVPRecords(Integer numberChildren, List<Event_RSVP__c> eventRSVPs,
            Boolean insertRSVP, String response) {

        List<Event_RSVP__c> eventRSVPList = new List<Event_RSVP__c>();

        for (Event_RSVP__c rsvp : eventRSVPs) {
            for (Integer i = 0; i < numberChildren; i++) {
                Event_RSVP__c objEvent = new Event_RSVP__c();

                objEvent.Name = 'event' + i;
                objEvent.Event__c = rsvp.Event__c;
                objEvent.Response__c = response;
                objEvent.FirstName_TU__c = 'First';
                objEvent.LastName_TU__c = rsvp.LastName_TU__c + 'Guest' + String.valueOf(i);
                objEvent.Email_TU__c = objEvent.FirstName_TU__c + '.' + objEvent.LastName_TU__c + TU_TestEmailSuffix;
                if (Math.mod(i, 2) == 0) {
                    objEvent.LastNameatGraduation_TU__c = 'Madidan' + String.valueOf(i);
                } else {
                    objEvent.LastNameatGraduation_TU__c = objEvent.LastName_TU__c;
                }
                objEvent.GraduationYear_TU__c = String.valueOf(Date.today().addYears((i+10)*-1).year());
                objEvent.ParentRSVP_TU__c = rsvp.Id;

                eventRSVPList.add(objEvent);
            }
        }

        if (insertRSVP) {
            insert eventRSVPList;
        }

        return eventRSVPList;
    }


}