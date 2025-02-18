/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 5/3/18.
 */
({
    onRemoveItem : function (component, event, helper) {
        helper.fireCartEvent(component, helper.action.DELETE, helper);
    },

    onQuantityChanged: function(component, event, helper){
        var item = component.get('v.cartItem');
        var quantity  = item.quantity;

        if (quantity > 0) {
            helper.fireCartEvent(component, helper.action.UPDATE, helper);
        }
    },

    gotoProduct : function (component, event, helper) {
        helper.gotoRecord(component, component.get('v.cartItem').productId);
    },

    onSpecialInformationChange : function (component, event, helper) {
        var item = component.get('v.cartItem');

        var params = {
            orderItemId : item.id,
            recipientName : item.recipientName,
            specialInstructions : item.specialInstructions,
            specialMessage : item.specialMessage
        };

        console.log(params);
        helper.doCallout(component, 'c.updateOrderCart', params, true, '')
            .then(function (result) {
                if (result) {
                }
        });
    },

    onUnitPriceChanged: function(component, event, helper){
        var item = component.get('v.cartItem');
        var unitPrice  = item.unitPrice;

        if (unitPrice > 0) {
            helper.fireCartEvent(component, helper.action.UPDATE, helper);
        }
    }

})