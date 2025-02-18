/*
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Joe Callin on 3/27/18.
*/
({
    getUrlParam: function(component, name) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
        var results = regex.exec(location.search);
        return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
    },
    getContactInfo: function(component, event, helper, contactId) {
        var params = {
            contactId: contactId
        };
        helper.doCallout(component,'c.getContact',params).then(function(response){
            console.log(response);
            component.set('v.regContact', response);
            component.set('v.isInit', true);
        });
    },
    getUserContact: function(component, event, helper, userId) {
        var params = {
            userId: userId
        };
        helper.doCallout(component,'c.getUserContact',params).then(function(response){
            console.log(response);
            component.set('v.regContact', response);
            component.set('v.isInit', true);
        });
    },

    validateForm: function(component, event, helper) {
        var requiredFields = component.get('v.requiredFields');
        var formValid = true;
        for(var i = 0; i < requiredFields.length; i++){
            var fieldValid = helper.validateField(component, null, requiredFields[i]);
            if(!fieldValid){
                formValid = fieldValid;
            }
        }
        if(formValid){
            component.set('v.isLoading', true);
            this.registerUser(component, event, helper);
        }
    },
    registerUser: function(component, event, helper) {
        var self = this;
        var regContact = component.get('v.regContact');
        var regConfirmUrl = component.get('v.regConfirmUrl');
        var newUserUrl = component.get('v.newUserUrl');
        var params = {
            contactInfo: JSON.stringify(regContact),
            regConfirmUrl: regConfirmUrl,
            newUserUrl: newUserUrl
        };
        helper.doCallout(component,'c.registerUser',params).then(function(response){
            if(response){
                // self.navToUrl(component, event, helper);
            }else{
                var message = 'An occurred please contact your Salesforce Admin';
                helper.showMessage('error', message);
            }
            component.set('v.isLoading', false);
        });
    },
    navToUrl: function(component, event, helper) {
        var url = component.get('v.newUserUrl');
        var action = $A.get('e.force:navigateToURL');
        action.setParams({
            url: url,
            isredirect: true
        });
        action.fire();
    }
})