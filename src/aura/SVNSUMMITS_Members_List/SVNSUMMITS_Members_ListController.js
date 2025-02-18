// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
	doInit: function (component, event, helper) {
		var tiles = component.get('v.numberOfTiles');

		var tileSize = '4'; // 3 across

		switch (tiles) {
			case '1' :
				tileSize = '10';
				break;
			case '2' :
				tileSize = '6';
				break;
			case '5' :
				tileSize = '2';
				break;
			default:
				tileSize = '4';
				break;
		}

		component.set('v.tileSize', tileSize);

		if (component.get('v.initialLoad')) {
			helper.getMemberList(component, event, 1);
		} else {
			helper.hideSpinner(component);
		}
	},

	getNextPage: function (component, event, helper) {
		var model = component.get('v.membersListWrapper');
		var currentPage = model !== null ? model.pageNumber + 1 : 1;

		helper.debug(component, 'Next Page getMemberList for page ' + currentPage);
		component.set("v.membersListWrapper.membersList", null);

		helper.getMemberList(component, event, currentPage);
	},

	getPreviousPage: function (component, event, helper) {
		var model = component.get('v.membersListWrapper');
		var currentPage = model !== null ? model.pageNumber - 1 : 1;

		helper.debug(component, 'Prev Page getMemberList for page ' + currentPage);
		component.set("v.membersListWrapper.membersList", null);
		
		helper.getMemberList(component, event, currentPage);
	},

	setSortBy: function (component, event, helper) {
		helper.debug(component, "sort by method called", null);

		var sortBy = event.getParam("sortBy");
		component.set("v.sortBy", sortBy);
		helper.getMemberList(component, event, 1);
	},

	setMembersFilters: function (component, event, helper) {
		helper.debug(component, "members filter called", null);

		var searchMyMembers = event.getParam("searchMyMembers");
		var searchString = event.getParam("searchString");
		var topicSearch = event.getParam("topicString");
		var clearAll = event.getParam("clearAll");

		component.set("v.searchString", searchString);
		component.set("v.searchMyMembers", searchMyMembers);
		component.set('v.topicString', topicSearch);

		var search = searchString.replace(';', '').replace(':', '').trim();

		if (!component.get('v.initialLoad') &&
			(clearAll || (search.length === 0 && searchMyMembers.length === 0 && topicSearch.length === 0))) {
			helper.clearMemberList(component);
		} else {
			helper.getMemberList(component, event, 1);
		}
	},

	handleFollowRecord: function (component, event, helper) {
		helper.debug(component, "follow event handled");

		var followAction = event.getParam("follow");
		var followRecord = event.getParam("recordId");

		var model = component.get('v.membersListWrapper');
		var currentPage = model !== null ? model.pageNumber : 1;

		helper.followRecord(component, followAction, followRecord, currentPage);
	}
})