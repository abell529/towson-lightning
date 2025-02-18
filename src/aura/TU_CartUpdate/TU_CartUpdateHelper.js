/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/27/18.
 */
({
    fireCartEvent: function (component, action) {
        var item = component.get('v.cartItem');

        var productId = item.productId;
        var quantity  = item.quantity;
        var unitPrice = item.unitPrice;
        var name       = item.name;
        var rsvpToken   = helper.getUrlParameter('token')
        var orderToken  = helper.getUrlParameter('orderToken');

        $A.get("e.c:ss_cart_event").setParams({
            'action'    : action,
            'itemId'    : productId,
            'name'      : name,
            'unitPrice' : unitPrice,
            'quantity'  : quantity,
            'rsvpToken' : rsvpToken,
            'orderToken' : orderToken
        }).fire();
    }
})