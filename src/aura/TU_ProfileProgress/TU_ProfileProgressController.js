/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen on 5/23/18.
 */
({
    init : function(component, event, helper) {
        helper.getProfileInfo(component);
    },
    linkClick : function(component, event, helper) {
        helper.goToPath(component, event);
    }
})