/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/27/18.
 */
({
    onClearCart: function (component, event, helper) {
        $A.get("e.c:ss_cart_event").setParams({
            'action'    : helper.action.CLEAR,
            'name'      : 'All Items',
            'productId' : '',
            'quantity'  : 0
        }).fire();
    }
})