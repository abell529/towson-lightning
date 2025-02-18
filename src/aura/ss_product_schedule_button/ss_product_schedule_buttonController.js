/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 5/2/18.
 */
({
    addToSchedule : function (component, event, helper) {
        var params = {
            quantity : component.get("v.quantity"),
            unitPrice : component.get("v.unitPrice"),
            frequency : component.get("v.frequency"),
            nextPaymentDateIn : component.get("v.nextPaymentDate"),
            finalPaymentDateIn : component.get("v.finalPaymentDate"),
            productId : component.get("v.productId")
        };

        console.log(params);
        helper.doCallout(component,'c.createPaymentSchedule',params).then(function(response){
            if (response.success){
                component.set("v.peakResponsePS",response);
                var orderToken = response.results[0].OrderToken_TU__c;
                var URL = component.get("v.checkoutUrl") + '?orderToken=' + orderToken;
                helper.gotoUrl(component, URL);
            } else {
                helper.showToast('Error',response.messages[0]);
            }
            component.set('v.isLoading', false);
        });

    }
})