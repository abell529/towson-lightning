/*
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Joe Callin on 3/27/18.
*/
({
    init: function (component, event, helper) {
        var regContact = {};
        regContact.FirstName = '';
        regContact.LastName = '';
        regContact.TU_Home_Email__c = '';
        regContact.GradYear_TU__c = '';
        regContact.LastNameatGraduation_TU__c = '';
        regContact.TU_EmplID__c = null;
        regContact.Advance_Id__c = null;
        component.set('v.regContact', regContact);
        var _uid = $A.get("$SObjectType.CurrentUser.Id");
        if ($A.util.isUndefinedOrNull(_uid) && $A.util.isEmpty(_uid)) {
            var contactId = helper.getUrlParam(component, 'id');
            if (!$A.util.isUndefinedOrNull(contactId) && !$A.util.isEmpty(contactId)) {
                helper.getContactInfo(component, event, helper, contactId);
            } else {
                component.set('v.isInit', true);
            }
        } else {
            helper.getUserContact(component, event, helper, _uid);
        }
    },
    registerClick: function (component, event, helper) {
        helper.validateForm(component, event, helper);
    }
});