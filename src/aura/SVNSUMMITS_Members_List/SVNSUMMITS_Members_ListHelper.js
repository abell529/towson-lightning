// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	showSpinner: function (component) {
		console.log('Spinner on...');
		$A.util.removeClass(component.find('listSpinner'), 'slds-hidden');
	},

	hideSpinner: function (component) {
		console.log('Spinner off...');
		$A.util.addClass(component.find('listSpinner'), 'slds-hidden');
	},

	getExcludedIDs: function (excludedIds) {
		var idList = [];
		var splitChar = ',';

		if (excludedIds.indexOf(splitChar) !== -1) {
			var ids = excludedIds.split(splitChar);
			for (var pos = 0; pos < ids.length; ++pos) {
				if (ids[pos].length > 0) {
					idList.push(ids[pos]);
				}
			}
		}
		else {
			idList.push(excludedIds);
		}

		return idList;
	},

	getMemberCount: function (component) {
		this.debug(component, "getMemberCount");

		var self = this;
		var excludedIds = component.get("v.excludedMembers");

		// get the true member count not limited by the StandardSetController
		var countAction = component.get("c.getMemberCount");

		if (excludedIds.length > 0) {
			countAction = component.get("c.getMemberCountEx");
			countAction.setParams({
				excludeList: this.getExcludedIDs(excludedIds)
			});
		}

		countAction.setCallback(this, function (actionResult) {
			if (actionResult.state === 'SUCCESS') {
				var totalItems = actionResult.getReturnValue();
				self.debug(component, 'Total members = ' + totalItems);

				var appEvent = $A.get("e.c:SVNSUMMITS_Members_Header_Event");

				appEvent.setParams({
					"totalResults": actionResult.getReturnValue()
				});

				appEvent.fire();
			} else {
				self.debug(component, 'getMemberCount failed:');

				var errors = actionResult.getError();
				for (var i = 0; i < errors.length; i++) {
					self.debug(component, '    :', errors[i].message);
				}
			}
		});

		$A.enqueueAction(countAction);
	},

	getMemberList: function (component, event, currentPage) {
		var self = this;

		self.showSpinner(component);

		var action = component.get("c.getMemberList");
		var excludedIds = component.get("v.excludedMembers");

		action.setParams({
			pageSize: component.get("v.numberOfMembers"),
			currentPage: currentPage,
			sortBy: component.get("v.sortBy"),
			searchMyMembers: component.get("v.searchMyMembers"),
			searchString: component.get("v.searchString") || "",
			topicId: component.get('v.topicString'),
			hideInternal: component.get("v.hideInternal"),
			excludeList: excludedIds.length > 0 ? this.getExcludedIDs(excludedIds) : null
		});

		action.setCallback(this, function (response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				var membersListWrapper = response.getReturnValue();
				var updatedWrapper     = self.updateMemberList(membersListWrapper);

				if (updatedWrapper.totalResults === 0) {
					updatedWrapper.totalPages = 0;
				}

				self.updateHeader(component, updatedWrapper.totalResults);
				component.set("v.membersListWrapper", updatedWrapper);
			} else {
				self.debug(component, 'getMemberList failed:');

				var errors = response.getError();
				for (var i = 0; i < errors.length; i++) {
					self.debug(component, '    :', errors[i].message);
				}
			}

			self.hideSpinner(component);
		});

		$A.enqueueAction(action);
	},

	clearMemberList: function(component) {
		var membersListWrapper = component.get('v.membersListWrapper');

		membersListWrapper.membersList    = [];
		membersListWrapper.totalResults   = 0;
		membersListWrapper.pageNumber     = 0;
		membersListWrapper.totalPages     = 0;
		membersListWrapper.hasNextSet     = false;
		membersListWrapper.hasPreviousSet = false;

		component.set('v.membersListWrapper', membersListWrapper);
		this.updateHeader(component, membersListWrapper.totalResults);
	},

	updateHeader : function (component, totalResults) {
		var appEvent = $A.get("e.c:SVNSUMMITS_Members_Header_Event");

		appEvent.setParams({
			"totalResults": totalResults === -1 ? '' : totalResults
		});

		appEvent.fire();
	},

	updateMemberList: function (membersListWrapper) {
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

		return membersListWrapper;
	},

	followRecord : function (component, followAction, recordId, currentPage) {
		var self   = this;
		var action = component.get(followAction ? 'c.followRecord' : 'c.unfollowRecord');

		action.setParams({
			'recordId' : recordId
		});

		action.setCallback(this, function(response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				self.getMemberList(component, null, currentPage);
			}
		});

		$A.enqueueAction(action);
	},

	debug: function (component, msg, variable) {
		if (component.get("v.debugMode")) {
			if (msg) {
				console.log(msg);
			}
			if (variable) {
				console.log(variable);
			}
		}
	}
})