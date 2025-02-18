// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
    getFeaturedFourEvents : function(component, event, helper) {
	    helper.get_SitePrefix(component);
	    helper.fetchFeaturedFourEvents(component, event);
    },

    gotoAllEventsUrl: function(component, event, helper) {
        helper.gotoUrl(component, component.get('v.allEventsUrl'));
    },

    gotoCreateEventsUrl: function(component, event, helper) {
        helper.gotoUrl(component, component.get('v.addNewEventUrl'));
    }
})