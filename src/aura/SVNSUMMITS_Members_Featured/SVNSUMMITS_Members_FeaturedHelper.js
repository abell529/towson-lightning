// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	getFeaturedMembers: function (component) {

		var action = component.get("c.getFeaturedMembers");
		action.setParams({
			recordNickName1: component.get("v.recordNickName1"),
			recordNickName2: component.get("v.recordNickName2"),
			recordNickName3: component.get("v.recordNickName3"),
			recordNickName4: component.get("v.recordNickName4"),
			recordNickName5: component.get("v.recordNickName5"),
			recordNickName6: component.get("v.recordNickName6"),
			recordNickName7: component.get("v.recordNickName7"),
			recordNickName8: component.get("v.recordNickName8"),
		});

		action.setCallback(this, function (response) {
			var state = response.getState();

			if (component.isValid() && state === "SUCCESS") {
				var membersListWrapper = response.getReturnValue();

				for (var i = 0; i < membersListWrapper.membersList.length; i++) {
					// am I following this member
					membersListWrapper.membersList[i].isFollowing = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).isFollowing;

					// Store the number of followers to display on the component
					membersListWrapper.membersList[i].intNumberOfFollowers = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).intNumberOfFollowers;

					// Store the number of like received to display on the component
					membersListWrapper.membersList[i].intLikeReceived = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).intLikeReceived;

					// number of posts made
					membersListWrapper.membersList[i].intPostsMade = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).intPostsMade;

					// Store the topics name for displaying on component
					membersListWrapper.membersList[i].strKnowledgeTopics = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopics;

					// Store the topics name for displaying on component
					membersListWrapper.membersList[i].strKnowledgeTopics1 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopics1;

					// Store the topics name for displaying on component
					membersListWrapper.membersList[i].strKnowledgeTopics2 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopics2;

					// Store the topics Id for displaying on component
					membersListWrapper.membersList[i].strKnowledgeTopicId = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopicId;

					// Store the topics Id for displaying on component
					membersListWrapper.membersList[i].strKnowledgeTopicId1 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopicId1;

					// Store the topics Id for displaying on component
					membersListWrapper.membersList[i].strKnowledgeTopicId2 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopicId2;
				}

				component.set("v.membersListWrapper", membersListWrapper);
			}
		});

		$A.enqueueAction(action);
	},

	get_SitePrefix: function (component) {
		var action = component.get("c.getSitePrefix");
		action.setCallback(this, function (actionResult) {
			var sitePath = actionResult.getReturnValue();
			component.set("v.sitePath", sitePath);
			component.set("v.sitePrefix", sitePath.replace("/s", ""));
		});
		$A.enqueueAction(action);
	},

	initializeSlider: function (component) {
		var recordIds = [];

		if (component.get("v.recordNickName1").length > 0) {
			recordIds.push(component.get("v.recordNickName1"));
		}
		if (component.get("v.recordNickName2").length > 0) {
			recordIds.push(component.get("v.recordNickName2"));
		}
		if (component.get("v.recordNickName3").length > 0) {
			recordIds.push(component.get("v.recordNickName3"));
		}
		if (component.get("v.recordNickName4").length > 0) {
			recordIds.push(component.get("v.recordNickName4"));
		}
		if (component.get("v.recordNickName5").length > 0) {
			recordIds.push(component.get("v.recordNickName5"));
		}
		if (component.get("v.recordNickName6").length > 0) {
			recordIds.push(component.get("v.recordNickName6"));
		}
		if (component.get("v.recordNickName7").length > 0) {
			recordIds.push(component.get("v.recordNickName7"));
		}
		if (component.get("v.recordNickName8").length > 0) {
			recordIds.push(component.get("v.recordNickName8"));
		}

		var itemNum;

		if (recordIds.length === 3) {
			itemNum = 3;
		} else if (recordIds.length >= 4) {
			itemNum = 4;
		} else {
			itemNum = recordIds.length;
		}

		window.setTimeout(
			$A.getCallback(function () {
				$('.responsive').lightSlider({
					item: itemNum,
					loop: false,
					slideMove: 2,
					easing: 'cubic-bezier(0.25, 0, 0.25, 1)',
					speed: 600,
					responsive: [
						{
							breakpoint: 800,
							settings: {
								item: 3,
								slideMove: 1,
								slideMargin: 6,
							}
						},
						{
							breakpoint: 600,
							settings: {
								item: 2,
								slideMove: 1
							}
						},
						{
							breakpoint: 480,
							settings: {
								item: 1,
								slideMove: 1
							}
						}]
				});
			}), 1000
		);
	}
})