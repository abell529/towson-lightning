/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 4/10/18.
 */

trigger Event_RSVPTrigger on Event_RSVP__c (before insert, before update, after insert, after update) {

    TU_Event_RSVPTriggerHandler tuEventRSVPTriggerHandler = new TU_Event_RSVPTriggerHandler(Trigger.isExecuting);

    if (Trigger.isBefore && Trigger.isInsert) {
        tuEventRSVPTriggerHandler.IsBeforeInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        tuEventRSVPTriggerHandler.IsBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        tuEventRSVPTriggerHandler.IsAfterInsert(Trigger.new, Trigger.newMap);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        tuEventRSVPTriggerHandler.IsAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }

}