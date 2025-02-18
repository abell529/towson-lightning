// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	debug: function (component, msg, variable) {

		var debugMode = component.get("v.debugMode");

		if (debugMode) {
			if (msg) {
				console.log(msg);
			}

			if (variable) {
				console.log(variable);
			}
		}

	},

	//Method Used to Fetch all topic URL's
	FetchTopicUrl: function (component) {
		var action = component.get("c.getSitePrefix");

		action.setCallback(this, function (actionResult) {
			var sitePath = actionResult.getReturnValue();
			component.set("v.sitePath", sitePath);

			var topicNameToIdMap = component.get("v.topicNameToId");
			var topicName = component.get("v.topicName");
			var linkCmp = component.find("topicLink");
			var topicId = topicNameToIdMap[topicName];
			var url = sitePath + "/topic/" + topicId + "/" + encodeURIComponent(topicName);

			if (topicName && topicId) {
				linkCmp.set("v.label", topicName);
				linkCmp.set("v.value", url);
				//linkCmp.set("v.value", sitePath + "/topic/" + topicId + "/" + topicName);
				//linkCmp.set("v.topicId", topicId);
			}
			else if (topicName && !topicId) {
				linkCmp.set("v.label", topicName);
				linkCmp.set("v.value", "#");
			}

		});

		$A.enqueueAction(action);
	},
})