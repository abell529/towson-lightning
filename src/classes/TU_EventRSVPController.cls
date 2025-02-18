/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 4/10/18.
 */

public with sharing class TU_EventRSVPController {

    /*
    Update a list of RSVPs
 */
    @AuraEnabled
    public static Peak_Response updateRSVPList(List<Event_RSVP__c> rsvpList){
        Peak_Response peakResponse = new Peak_Response();
        try{
            update rsvpList;
            peakResponse.results = rsvpList;
        } catch (Exception e) {
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
        }
        return peakResponse;
    }

    /*
        Update a single RSVP, but require the creation token in order to securely change RSVPs for guest users (they'll need the token from email to match the record's token
     */
    @AuraEnabled
    public static Peak_Response updateSingleRSVP(Event_RSVP__c eventRSVP, String inviteURL, String productsURL){
        Peak_Response peakResponse = new Peak_Response();

        // Check for matching token
        try {
            if (eventRSVP.Response__c == TU_EventRSVPHelper.rsvpPending) {
                formAssemblyRSVP(eventRSVP);
            } else if (eventRSVP.Response__c == TU_EventRSVPHelper.rsvpConfirmPayment) {
                eventRSVP.Response__c = TU_EventRSVPHelper.rsvpPayment;
                formAssemblyRSVP(eventRSVP);
            } else if (eventRSVP.Response__c == TU_EventRSVPHelper.rsvpWaitlist) {
                formAssemblyRSVP(eventRSVP);
            } else if (eventRSVP.Response__c == TU_EventRSVPHelper.rsvpPayment) {
                if (productsURL != null) {
                    PageReference page = new PageReference(Site.getBaseUrl() + '/s' + productsURL + '?token=' + eventRSVP.RSVPToken_TU__c);
                    if (!Test.isRunningTest()) {
                        aura.redirect(page);
                    }
                }
            } else if (eventRSVP.Response__c == TU_EventRSVPHelper.rsvpInvited) {
                if (eventRSVP.Event__r.Enable_Pricing_Payment__c) {
                    eventRSVP.Response__c = TU_EventRSVPHelper.rsvpPayment;
                } else {
                    eventRSVP.Response__c = TU_EventRSVPHelper.rsvpConfirm;
                }
                TU_EventRSVPHelper.updateChildRSVPs(eventRSVP.Id, eventRSVP.Response__c);
                if (productsURL != null && eventRSVP.Event__r.Enable_Pricing_Payment__c) {
                    PageReference page = new PageReference(Site.getBaseUrl() + '/s' + productsURL + '?token=' + eventRSVP.RSVPToken_TU__c);
                    if (!Test.isRunningTest()) {
                        aura.redirect(page);
                    }
                }
            } else if (eventRSVP.Response__c == TU_EventRSVPHelper.rsvpWaitCancel) {
                eventRSVP.Response__c = TU_EventRSVPHelper.rsvpCancelled;
            }

            update eventRSVP;
            TU_EventRSVPHelper.updateChildRSVPs(eventRSVP.Id, eventRSVP.Response__c);

            List<Event_RSVP__c> rsvpList = TU_EventRSVPHelper.getRSVP(eventRSVP.Event__c, UserInfo.getUserId(),
                    eventRSVP.RSVPToken_TU__c);
            if (!rsvpList.isEmpty()) {
                eventRSVP = rsvpList[0];
            }

            peakResponse.success = true;
            peakResponse.messages.add(Label.TU_Update_AttendeeSuccess);
            peakResponse.results.add(eventRSVP);
        } catch (Exception e) {

            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
        }

        return peakResponse;
    }
    /*
        Delete a single RSVP, but require the creation token in order to securely delete RSVPs for guest users (they'll need the token from email to match the record's token
     */
    @AuraEnabled
    public static Peak_Response deleteSingleRSVPwithToken(Event_RSVP__c eventRSVP,String rsvpToken ){
        Peak_Response peakResponse = new Peak_Response();

        // Check for matching token
        if (rsvpToken == eventRSVP.RSVPToken_TU__c){
            try{
                delete eventRSVP;
                peakResponse.success = true;
                peakResponse.messages.add(Label.TU_Cancel_AttendeeSuccess);
            } catch (Exception e) {
                peakResponse.success = false;
                peakResponse.messages.add(e.getMessage());
            }
        } else {
            peakResponse.success = false;
            peakResponse.messages.add(Label.TU_RSVP_Token);
        }

        return peakResponse;
    }

    /*
        Get an RSVP and also get any RSVPs related to it (as in when a User/Guest signs up other users)
     */
    @AuraEnabled
    public static Peak_Response getRSVPForEvent(String eventIDString, String rsvpToken){
        Peak_Response peakResponse = new Peak_Response();
        try{

            List<Event_RSVP__c> rsvpList = TU_EventRSVPHelper.getRSVP(eventIDString,UserInfo.getUserId(),rsvpToken);

            if (rsvpList.isEmpty()) {
                Event_RSVP__c eventRSVP = new Event_RSVP__c();
                eventRSVP = TU_EventRSVPHelper.createRSVPFromUser(eventIDString, eventRSVP, UserInfo.getUserId());
                rsvpList.add(eventRSVP);
            }

            System.debug(rsvpList);
            peakResponse.success = true;
            peakResponse.results = rsvpList;

        } catch (Exception e){
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
        }

        return peakResponse;
    }

    @AuraEnabled
    public static List<String> getPicklistOptions(String objectString, String fieldString){
        Peak_Utils peakUtils = new Peak_Utils();
        return peakUtils.getPicklistValues(objectString,fieldString);
    }

    private static void formAssemblyRSVP(Event_RSVP__c eventRSVP) {

        System.debug(eventRSVP.Response__c);
        upsert eventRSVP;

        String formAssemblyURL;
        if (eventRSVP.Event__r.RSVP_URL_TU__c == null) {
            formAssemblyURL = [SELECT RSVP_URL_TU__c FROM Event__c WHERE Id = :eventRSVP.Event__c LIMIT 1].RSVP_URL_TU__c;
        } else {
            formAssemblyURL = eventRSVP.Event__r.RSVP_URL_TU__c;
        }

        if (formAssemblyURL != null) {
            PageReference formAssemblyPage = new PageReference(formAssemblyURL);
            formAssemblyPage.getParameters().put('rsvp', eventRSVP.Id);

            if (!Test.isRunningTest()) {
                aura.redirect(formAssemblyPage);
            }
        }
    }
}