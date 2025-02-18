/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 4/19/18.
 */
({
    init: function (component, event, helper) {
        $A.get("e.c:ss_cart_button_event")
            .setParams({'buttonMode': 'cart'})
            .fire();

        // default alignment is start but cannot be specified - rip it out
        var align = component.get('v.headerAlignment');

        if (align === 'start') {
            $A.util.removeClass(component.find('headerAlign'), 'horizontalAlign');
        }

        var url = window.location.href;
        var pos = url.indexOf('?');

        var filter = '';

        if (pos !== -1) {
            var query = decodeURI(url.substring(pos + 1));
            var parts = query.split('=');

            if (parts[0] === helper.filter.FAMILY) {
                filter = parts[1];

                component.set('v.filterString', filter);
                component.set('v.familyTitle',  filter);
            }
        }

        helper.getEventProducts(component,helper);
    }
})