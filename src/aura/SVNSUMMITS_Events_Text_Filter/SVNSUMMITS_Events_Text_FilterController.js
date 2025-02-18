// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
		doInit : function(component, event, helper) {
				helper.setSitePrefix(component);
		},

		performSearch : function(component, event, helper) {
				helper.sendFilterEvent(component);
		}
})