/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 4/27/18.
 */

public with sharing class TU_FormAssemblyCompletionController {

    @AuraEnabled
    public static String getRSVPNextStep(String rsvpId, String eventProductsURL, String eventURL, String errorURL) {

        try {
            List<Event_RSVP__c> rsvpList = new List<Event_RSVP__c>([
                    SELECT Id, Event__c, FAComplete_TU__c, RSVPToken_TU__c,
                            Event__r.Enable_Pricing_Payment__c, Response__c, ParentRSVP_TU__c,
                            Event__r.AssociatedProductCode_TU__c
                    FROM Event_RSVP__c
                    WHERE Id = :rsvpId OR ParentRSVP_TU__c = :rsvpId ORDER BY ParentRSVP_TU__c
            ]);

            Event_RSVP__c thisEventRSVP = rsvpList[0];
            if (!thisEventRSVP.Event__r.Enable_Pricing_Payment__c ||
                    thisEventRSVP.Response__c == TU_EventRSVPHelper.rsvpWaitlist) {
                return eventUrl + thisEventRSVP.Event__c + '?token=' + thisEventRSVP.RSVPToken_TU__c;
            } else {
                return eventProductsURL + '?token=' + thisEventRSVP.RSVPToken_TU__c;
            }

        } catch (Exception e) {
            return errorURL;
        }

    }
}
