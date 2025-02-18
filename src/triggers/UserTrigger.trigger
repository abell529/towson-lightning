/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 3/28/18.
 */

trigger UserTrigger on User (before insert, before update, after insert, after update) {

    UserTriggerHandler userTriggerHandler = new UserTriggerHandler(Trigger.isExecuting);

    if (Trigger.isBefore && Trigger.isInsert) {
        userTriggerHandler.IsBeforeInsert(Trigger.new);
    } else if (Trigger.isBefore && Trigger.isUpdate) {
        userTriggerHandler.IsBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        userTriggerHandler.IsAfterInsert(Trigger.new, Trigger.newMap);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        userTriggerHandler.IsAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }

}