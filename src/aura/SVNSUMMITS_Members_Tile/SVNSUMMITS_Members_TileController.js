// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	handleFollowClick: function (component, event, helper) {
		var member = component.get('v.member');
		console.log('Follow clicked for ' + member.Name);
		console.log(member.isFollowing ? '    going to unfollow' : '    going to follow');

		var followEvent  = $A.get("e.c:SVNSUMMITS_Members_Follow_Event");

		followEvent.setParams({
			'follow'   : !member.isFollowing,
			'recordId' : member.Id
		});

		followEvent.fire();
	},

	goToRecord: function (component, event, helper) {
		$A.get("e.force:navigateToSObject")
			.setParams({
				"recordId": event.currentTarget.dataset.id,
				"slideDevName": "related"
			}).fire();
	}
})