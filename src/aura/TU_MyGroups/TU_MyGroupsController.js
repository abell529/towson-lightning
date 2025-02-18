/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 5/23/18.
 */
({
    initPeakMyGroups : function(component, event, helper) {
        helper.isInAGroup(component);
        component.set('v.extended', true);
    },
    linkClick: function(component, event, helper) {
        helper.goToUrl(component, event);
    }
});