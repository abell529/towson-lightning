// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
		setSitePrefix : function(component) {
				var action = component.get("c.getSitePrefix");
				action.setCallback(this, function(actionResult) {
						var sitePath = actionResult.getReturnValue();
						component.set("v.sitePrefix", sitePath.replace("/s",""));
				});
				$A.enqueueAction(action);
		},

		setListButtonActive : function(component) {
				$A.util.removeClass(component.find('calendarBTN'), 'btnActive');
				$A.util.addClass(component.find('listBTN'), 'btnActive');
				$A.util.removeClass(component.find('tileBTN'), 'btnActive');
		},

		setTileButtonActive : function(component) {
				$A.util.removeClass(component.find('calendarBTN'), 'btnActive');
				$A.util.removeClass(component.find('listBTN'), 'btnActive');
				$A.util.addClass(component.find('tileBTN'), 'btnActive');
		},

		setCalendarButtonActive : function(component) {
				$A.util.addClass(component.find('calendarBTN'), 'btnActive');
				$A.util.removeClass(component.find('listBTN'), 'btnActive');
				$A.util.removeClass(component.find('tileBTN'), 'btnActive');
		}
})