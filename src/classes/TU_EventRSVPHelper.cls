/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 4/10/18.
 */

public with sharing class TU_EventRSVPHelper {

    public static final String rsvpConfirm  = 'Confirmed';
    public static final String rsvpConfirmPayment  = 'ConfirmPayment';
    public static final String rsvpPending  = 'Pending';
    public static final String rsvpPayment = 'Payment';
    public static final String rsvpWaitlist = 'Wait-listed';
    public static final String rsvpWaitCancel = 'WaitlistRemove';
    public static final String rsvpCancelled = 'Cancelled';
    public static final String rsvpInvited = 'Invited';
    public static final String rsvpFull = 'Full';

    public static String [] EventRSVPFields = new String [] {
            'RSVPToken_TU__c', 'Email_TU__c', 'Event__c', 'FirstName_TU__c', 'Id', 'LastName_TU__c', 'Name',
            'LastNameatGraduation_TU__c', 'Response__c', 'User__c', 'ParentRSVP_TU__c', 'CreatedDate', 'FAComplete_TU__c',
            'City_TU__c', 'Country_TU__c', 'Zip_TU__c', 'State_TU__c', 'Street_TU__c', 'Contact_TU__c',
            'Event__r.Name','Event__r.Start_DateTime__c','Event__r.End_DateTime__c','Event__r.EventFull_TU__c',
            'Event__r.RSVP_URL_TU__c','Event__r.Location_URL__c','Event__r.WaitlistAllowed_TU__c',
            'Event__r.Payment_URL__c','Event__r.Details__c', 'Event__r.Enable_Pricing_Payment__c',
            '(Select Id from X7S_Event_Guest_RSVPs__r)'

    };

    /*
    Get List of RSVPs, related Event info, and subquery of their self lookups
    */
    public static List<Event_RSVP__c> getRSVP(String eventId, String userId, String token) {
        List<Event_RSVP__c> eventRSVPS = new List<Event_RSVP__c>();

        if (userId != null || token != null) {

            String whereClause;
            if (eventId != null) {
                whereClause = ' Event__c = \'' + eventId + '\'' + ' AND ParentRSVP_TU__c = null AND';
            }

            if (Peak_Utils.isGuestUser()) {
                 whereClause = whereClause + ' RSVPToken_TU__c = \'' + token + '\'';
            } else {
                if (token != null) {
                    whereClause = whereClause + ' RSVPToken_TU__c = \'' + token + '\'';
                } else {
                    whereClause = whereClause + ' User__c = \'' + userId + '\'';
                }
            }

            for (Event_RSVP__c eventRSVP : Database.query(TU_Utilities.buildSOQL('Event_RSVP__c',false,
                    String.join(EventRSVPFields, ','),whereClause,null))) {

                eventRSVP.Response__c = nextResponse(eventRSVP.Event__r, eventRSVP.Response__c,eventRSVP);
                eventRSVPS.add(eventRSVP);
            }
        }

        return eventRSVPS;
    }

    public static Event_RSVP__c createRSVPFromUser(String eventId, Event_RSVP__c eventRSVP, String userId) {
        User user = new User();

        if (!Peak_Utils.isGuestUser()) {
            user = [SELECT Contact.Id, FirstName, LastName, Email, GraduationYear_TU__c, LastNameatGraduation_TU__c,
                    AlumniID_TU__c, TU_ID_TU__c, Birthday_TU__c, Street, City, State, PostalCode, Country, Gender_TU__c,
                    Major_TU__c, Phone FROM User WHERE Id = :userId LIMIT 1];

            eventRSVP.FirstName_TU__c = user.FirstName;
            eventRSVP.LastName_TU__c = user.LastName;
            eventRSVP.AlumniID_TU__c = user.AlumniID_TU__c;
            eventRSVP.TUID_TU__c = user.TU_ID_TU__c;
            eventRSVP.LastNameatGraduation_TU__c = user.LastNameatGraduation_TU__c;
            eventRSVP.User__c = userId;
            eventRSVP.Contact_TU__c = user.Contact.Id;
            eventRSVP.BirthdateTU__c = user.Birthday_TU__c;
            eventRSVP.Street_TU__c = user.Street;
            eventRSVP.City_TU__c = user.City;
            eventRSVP.State_TU__c = user.State;
            eventRSVP.Zip_TU__c = user.PostalCode;
            eventRSVP.Country_TU__c = user.Country;
            eventRSVP.Email_TU__c = user.Email;
            eventRSVP.Gender_TU__c = user.Gender_TU__c;
            eventRSVP.GraduationYear_TU__c = user.GraduationYear_TU__c;
            eventRSVP.Major_TU__c = user.Major_TU__c;
            eventRSVP.Phone_TU__c = user.Phone;
        }

        if (eventId != null) {
            Event__c event = new Event__c();
            event = [SELECT Id, EventFull_TU__c, WaitlistAllowed_TU__c, Enable_Pricing_Payment__c FROM Event__c WHERE Id = :eventId];
            eventRSVP.FAComplete_TU__c = false;
            eventRSVP.Response__c = nextResponse(event, null, eventRSVP);
            eventRSVP.Event__c = event.Id;
        }

        eventRSVP.MasterRSVP_TU__c = true;
        eventRSVP.RSVPToken_TU__c = TU_Utilities.generateRandomString(18);

        return eventRSVP;
    }

    public static String nextResponse(Event__c thisEvent, String currentResponse, Event_RSVP__c eventRSVP) {
        String response;

        if (currentResponse == null || currentResponse == rsvpCancelled) {
            if (thisEvent.EventFull_TU__c && !thisEvent.WaitlistAllowed_TU__c) {
                response = rsvpFull;
            } else if (thisEvent.EventFull_TU__c && thisEvent.WaitlistAllowed_TU__c) {
                response = rsvpWaitlist;
            } else if (!thisEvent.EventFull_TU__c && thisEvent.Enable_Pricing_Payment__c) {
                response = rsvpConfirmPayment;
            } else if (!thisEvent.EventFull_TU__c) {
                response = rsvpPending;
            }
        } else if (currentResponse == rsvpConfirm) {
            response = rsvpCancelled;
        } else if (currentResponse == rsvpWaitlist) {
            response = rsvpWaitCancel;
        } else if (currentResponse == rsvpPending && eventRSVP.FAComplete_TU__c) {
            response = rsvpConfirm;
        } else {
            response = currentResponse;
        }

        return response;
    }

    public static void updateResponse(String rsvpId, String response) {
        Event_RSVP__c rsvp = new Event_RSVP__c();

        rsvp = [SELECT Id, Response__c FROM Event_RSVP__c WHERE Id = :rsvpId LIMIT 1];
        rsvp.Response__c = response;
        update rsvp;

        updateChildRSVPs(rsvpId, response);
    }

    public static void updateChildRSVPs(String rsvpId, String response) {
        List<Event_RSVP__c> childRsvps = new List<Event_RSVP__c>();

        for (Event_RSVP__c eventRSVP : [SELECT Id, Response__c FROM Event_RSVP__c WHERE ParentRSVP_TU__c = :rsvpId]) {
            eventRSVP.Response__c = response;
            childRsvps.add(eventRSVP);
        }

        if (!childRsvps.isEmpty()) {
            update childRsvps;
        }

    }
}