// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	toggleMembership : function (component) {
		var userId   = component.get('v.wrapperGroupsObj.currentUserId')
		var group    = component.get('v.group');
		var isMember = group.isMember;
		var action   = isMember ? component.get('c.leaveGroup') : component.get('c.joinGroup');

		action.setParams({
			'groupId': group.Id,
			'userId': userId
		});

		action.setCallback(this, function (actionResult) {
			var state = actionResult.getState();

			if (state === "SUCCESS") {
				$A.get('e.c:SVNSUMMITS_Groups_Load_Event').fire();
			}
		});

		$A.enqueueAction(action);
	},
    getIsGuest: function(component) {
        // Create the action
        var action = component.get("c.isGuestUser");

        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.isGuest", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
            // component.set("v.isInit", true);
        });
        component.set("v.isGuestInit", true);

        // Send action off to be executed
        $A.enqueueAction(action);
    }
})
