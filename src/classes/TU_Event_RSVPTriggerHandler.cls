/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 4/10/18.
 */

public without sharing class TU_Event_RSVPTriggerHandler {

    private static List<SObject> sObjectsToInsert = new List<SObject>();
    private static List<SObject> sObjectsToUpdate = new List<SObject>();
    private boolean executing = false;

    public TU_Event_RSVPTriggerHandler(boolean isExecuting) {
        executing = isExecuting;
    }

    // Trigger Interfaces to Handler
    public void IsBeforeInsert(List<Event_RSVP__c> newEvent_RSVP) {
        newEvent_RSVP = completeEventRSVPS(newEvent_RSVP);
    }

    public void IsAfterInsert(List<Event_RSVP__c> newEvent_RSVP, Map<Id, Event_RSVP__c> newEvent_RSVPMap) {
        Map<Id, Event_RSVP__c> oldEvent_RSVPMap = new Map<Id, Event_RSVP__c>();

    }

    public void IsBeforeUpdate(List<Event_RSVP__c> newEvent_RSVP, Map<Id, Event_RSVP__c> newEvent_RSVPMap,
            List<Event_RSVP__c> oldEvent_RSVP, Map<Id, Event_RSVP__c> oldEvent_RSVPMap) {
        newEvent_RSVP = completeEventRSVPS(newEvent_RSVP);
    }
    public void IsAfterUpdate(List<Event_RSVP__c> newEvent_RSVP, Map<Id, Event_RSVP__c> newEvent_RSVPMap,
            List<Event_RSVP__c> oldEvent_RSVP, Map<Id, Event_RSVP__c> oldEvent_RSVPMap) {

    }


    public static List<Event_RSVP__c> completeEventRSVPS(List<Event_RSVP__c> newEventRSVPS) {

        // Build up list of related Events
        List<Id> eventIds = new List<Id>();
        List<String> emails = new List<String>();
        List<String> lastNameatGraduations = new List<String>();
        List<String> gradYears = new List<String>();

        for (Event_RSVP__c thisEvent_RSVP : newEventRSVPS){
            eventIds.add(thisEvent_RSVP.Event__c);

            if(thisEvent_RSVP.User__c == null && thisEvent_RSVP.Contact_TU__c == null) {
                if (thisEvent_RSVP.Email_TU__c != null) {
                    emails.add(thisEvent_RSVP.Email_TU__c);
                }
                if (thisEvent_RSVP.LastNameatGraduation_TU__c != null) {
                    lastNameatGraduations.add(thisEvent_RSVP.LastNameatGraduation_TU__c);
                }
                if (thisEvent_RSVP.GraduationYear_TU__c != null) {
                    gradYears.add(thisEvent_RSVP.GraduationYear_TU__c);
                }
            }

        }

        Map<Id, Event__c> eventMap = new Map<Id, Event__c>([SELECT Id, EventFull_TU__c, MaxAttendees_TU__c,
                Number_of_Attendees__c, Enable_Pricing_Payment__c, WaitlistAllowed_TU__c FROM Event__c
                WHERE Id IN :eventIds]);
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, TU_Home_Email__c, LastNameatGraduation_TU__c,
                GradYear_TU__c FROM Contact WHERE (TU_Home_Email__c IN :emails AND
                LastNameatGraduation_TU__c IN :lastNameatGraduations AND GradYear_TU__c IN :gradYears)]);

        Map<Id, User> userContactMap = new Map<Id, User>();
        for (User user : [SELECT Id, ContactId FROM User WHERE ContactId IN :contactMap.keySet()]) {
            userContactMap.put(user.ContactId, user);
        }

        Map<String, Contact> contactKeyMap = new Map<String, Contact>();
        for (Contact thisContact :contactMap.values()) {
            contactKeyMap.put(thisContact.TU_Home_Email__c+thisContact.LastNameatGraduation_TU__c+thisContact.GradYear_TU__c,
                    thisContact);
        }

        Map<Id, Event_RSVP__c> eventRSVPContactMap = new Map<Id, Event_RSVP__c>();
        List<Event_RSVP__c> createContacts = new List<Event_RSVP__c>();

        for (Event_RSVP__c thisEventRSVP : newEventRSVPS) {
            Event__c relatedEvent = eventMap.get(thisEventRSVP.Event__c);

            if (String.isEmpty(thisEventRSVP.Response__c) || thisEventRSVP.Response__c == TU_EventRSVPHelper.rsvpPending) {
                thisEventRSVP.Response__c = TU_EventRSVPHelper.nextResponse(relatedEvent,thisEventRSVP.Response__c, thisEventRSVP);
                if (thisEventRSVP.Response__c == TU_EventRSVPHelper.rsvpWaitCancel) {
                    thisEventRSVP.Response__c = TU_EventRSVPHelper.rsvpCancelled;
                }
            }

            if (thisEventRSVP.User__c == null && thisEventRSVP.Contact_TU__c == null) {
                String keyString = thisEventRSVP.Email_TU__c + thisEventRSVP.LastNameatGraduation_TU__c +
                        thisEventRSVP.GraduationYear_TU__c;

                if (contactKeyMap.containsKey(keyString)) {
                    thisEventRSVP.Contact_TU__c = contactKeyMap.get(keyString).Id;
                    if (userContactMap.containsKey(thisEventRSVP.Contact_TU__c)) {
                        thisEventRSVP.User__c = userContactMap.get(thisEventRSVP.Contact_TU__c).Id;
                    }
                } else {
                    createContacts.add(thisEventRSVP);
                }
            }

            if (thisEventRSVP.Contact_TU__c != null && thisEventRSVP.User__c == null) {
                eventRSVPContactMap.put(thisEventRSVP.Contact_TU__c,thisEventRSVP);
            }

            if (thisEventRSVP.RSVPToken_TU__c == null) {
                thisEventRSVP.RSVPToken_TU__c = TU_Utilities.generateRandomString(18);
            }
        }

        if (!createContacts.isEmpty()) {
            Map<Id, Contact> createdContactsByRSVP = createContact(createContacts);
            for (Event_RSVP__c thisEventRSVP : newEventRSVPS) {
                if (createdContactsByRSVP.containsKey(thisEventRSVP.Id)) {
                    thisEventRSVP.Contact_TU__c = createdContactsByRSVP.get(thisEventRSVP.Id).Id;
                }
            }
        }

        if (!eventRSVPContactMap.isEmpty()) {
            updateContact(eventRSVPContactMap);
        }
        return newEventRSVPS;
    }

    private static void updateContact(Map<Id, Event_RSVP__c> eventRSVPContacts) {
        List<Contact> updateContacts = new List<Contact>([SELECT Id, BirthdayAlumni_TU__c, GenderAlumni_TU__c, MailingStreet,
                MailingCity, MailingState, MailingPostalCode, MailingCountry, MajorAlumni_TU__c, Phone
                FROM Contact WHERE Id IN :eventRSVPContacts.keySet()]);

        for (Contact contact : updateContacts) {
            Event_RSVP__c rsvp = eventRSVPContacts.get(contact.Id);
            sObjectsToUpdate.add(moveRSVPtoContact(rsvp,contact));
        }

        update sObjectsToUpdate;
        sObjectsToUpdate.clear();
    }

    private static Map<Id, Contact> createContact(List<Event_RSVP__c> eventRSVPS) {
        Map<Id, Contact> rsvpMap = new Map<Id, Contact>();

        try {
            Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());

            for (Event_RSVP__c eventRSVP : eventRSVPS) {
                if (eventRSVP.MasterRSVP_TU__c) {
                    Contact contact = moveRSVPtoContact(eventRSVP, new Contact());
                    contact.LastName = eventRSVP.LastName_TU__c;
                    contact.FirstName = eventRSVP.FirstName_TU__c;
                    contact.AccountId = setupId.Guest_Event_Account_Id__c;
                    contact.Email = eventRSVP.Email_TU__c;
                    contact.TU_Home_Email__c = eventRSVP.Email_TU__c;
                    contact.LastNameatGraduation_TU__c = eventRSVP.LastNameatGraduation_TU__c;
                    contact.GradYear_TU__c = eventRSVP.GraduationYear_TU__c;
                    contact.OwnerId = eventRSVP.CreatedById;
                    if (!String.isEmpty(contact.LastName) && !String.isEmpty(contact.FirstName)) {
                        rsvpMap.put(eventRSVP.Id, contact);
                    }

                }
            }

            insert rsvpMap.values();

        } catch (Exception e) {

        }

        return rsvpMap;
    }

    private static Contact moveRSVPtoContact(Event_RSVP__c rsvp, Contact contact) {

        if (rsvp.BirthdateTU__c != null && rsvp.BirthdateTU__c != contact.BirthdayAlumni_TU__c) {
            contact.BirthdayAlumni_TU__c = rsvp.BirthdateTU__c;
        }
        if (rsvp.Gender_TU__c != null && rsvp.Gender_TU__c != contact.GenderAlumni_TU__c) {
            contact.GenderAlumni_TU__c = rsvp.Gender_TU__c;
        }
        if (!String.isEmpty(rsvp.Street_TU__c) && rsvp.Street_TU__c != contact.MailingStreet) {
            contact.MailingStreet = rsvp.Street_TU__c;
        }
        if (!String.isEmpty(rsvp.City_TU__c) && rsvp.City_TU__c != contact.MailingCity) {
            contact.MailingCity = rsvp.City_TU__c;
        }
        if (!String.isEmpty(rsvp.State_TU__c) && rsvp.State_TU__c != contact.MailingState) {
            contact.MailingState = rsvp.State_TU__c;
        }
        if (!String.isEmpty(rsvp.Zip_TU__c) && rsvp.Zip_TU__c != contact.MailingPostalCode) {
            contact.MailingPostalCode = rsvp.Zip_TU__c;
        }
        if (!String.isEmpty(rsvp.Country_TU__c) && rsvp.Country_TU__c != contact.MailingCountry) {
            contact.MailingCountry = rsvp.Country_TU__c;
        }
        if (!String.isEmpty(rsvp.Major_TU__c) && rsvp.Major_TU__c != contact.MajorAlumni_TU__c) {
            contact.MajorAlumni_TU__c = rsvp.Major_TU__c;
        }
        if (!String.isEmpty(rsvp.Phone_TU__c) && rsvp.Phone_TU__c != contact.Phone) {
            contact.Phone = rsvp.Phone_TU__c;
        }

        return contact;
    }
}