global with sharing class SVNSUMMITS_EventVolunteerWrapper {
    @AuraEnabled global Volunteer_Need__c volunteerNeed{get;set;}
    @AuraEnabled global boolean currentUserRegistered{get;set;}
}