/* Copyright ©2016-2017 7Summits Inc. All rights reserved. */

/*
	@Class Name		  : SVNSUMMITS_MembersController_Test
	@Created by		  :
	@Description		 : Apex Test class for SVNSUMMITS_MembersController
*/

@isTest
private class SVNSUMMITS_MembersController_Test {

	User objTestUser;

	private static testMethod void testAllMethods() {
		SVNSUMMITS_WrapperMembers testWrapper = new SVNSUMMITS_WrapperMembers();
		system.assertNotEquals(null, testWrapper);

		SVNSUMMITS_MembersController_Test test1 = new SVNSUMMITS_MembersController_Test();
		List<User> testUsers = SVNSUMMITS_TestUtil.createUsers(8, SVNSUMMITS_TestUtil.COMPANY_COMMUNITY_PROFILE_NAME);
		system.assertEquals(8, testUsers.size());

		test1.objTestUser = testUsers[0];

		system.runAs(test1.objTestUser) {

			Test.startTest();

			SVNSUMMITS_MembersController.networkId = SVNSUMMITS_TestUtil.NETWORK_ID;
			system.assertNotEquals(SVNSUMMITS_MembersController.networkId, null);

			//To test the methods in members controller class
			//on load default values & to check only the test records.
			SVNSUMMITS_WrapperMembers membrs = SVNSUMMITS_MembersController.getMembers(8, 'Sort by First Name', '', 'Test');
			system.assertNotEquals(membrs.membersList, null);
			system.assertEquals(membrs.listSizeValue, 8);
			system.assertEquals(membrs.membersList[0].Name, '0Test 0Test');

			SVNSUMMITS_WrapperMembers nxtmembrs = SVNSUMMITS_MembersController.nextPage(4, 1, 'Sort by First Name', '', 'Test');
			system.assertEquals(2, nxtmembrs.pageNumber);
			system.assertEquals(4, nxtmembrs.listSizeValue);
			system.assert(nxtmembrs.totalResults > 0);

			SVNSUMMITS_WrapperMembers prevmembrs = SVNSUMMITS_MembersController.previousPage(4, 2, 'Sort by First Name', '', 'Test');
			system.assertEquals(1, prevmembrs.pageNumber);
			system.assertEquals(4, prevmembrs.listSizeValue);
			system.assert(prevmembrs.totalResults > 0);

			SVNSUMMITS_MembersController.getSitePrefix();
			SVNSUMMITS_WrapperMembers featuredMembers = SVNSUMMITS_MembersController.getFeaturedMembers(
					membrs.membersList[0].communitynickname,
					membrs.membersList[1].communitynickname,
					membrs.membersList[2].communitynickname,
					membrs.membersList[3].communitynickname,
					membrs.membersList[4].communitynickname,
					membrs.membersList[5].communitynickname,
					membrs.membersList[6].communitynickname,
					membrs.membersList[7].communitynickname);
			system.assert(featuredMembers != null);

			//To cover the if - else conditions
			SVNSUMMITS_WrapperMembers nxtmembrs1 = SVNSUMMITS_MembersController.nextPage(4, 1, 'Sort by First Name', 'Members I Follow', 'Test');
			//SVNSUMMITS_WrapperMembers nxtmembrs2 = SVNSUMMITS_MembersController.nextPage(4, 1, 'Sort by Last Name', 'Members I Follow', 'Test');

			SVNSUMMITS_WrapperMembers prevmembrs1 = SVNSUMMITS_MembersController.previousPage(4, 2, 'Sort by First Name', 'Members I Follow', 'Test');
			//SVNSUMMITS_WrapperMembers prevmembrs2 = SVNSUMMITS_MembersController.previousPage(4, 2, 'Sort by Last Name', 'Members I Follow', 'Test');

			//SVNSUMMITS_WrapperMembers membrs0 = SVNSUMMITS_MembersController.getMembers(7, 'Sort by First Name', 'Members I Follow', 'Test');
			//system.assertEquals(membrs0.membersList[6].Name, '7Test 7Test');

			SVNSUMMITS_WrapperMembers membrs1 = SVNSUMMITS_MembersController.getMembers(7, 'Sort by Last Name', 'Members I Follow', 'Test');
			system.assertEquals(membrs1.membersList[6].Name, '7Test 7Test');

			SVNSUMMITS_WrapperMembers membrs2 = SVNSUMMITS_MembersController.getMembers(8, 'Sort by First Name', '', 'Test');
			system.assertEquals(membrs2.membersList[0].Name, '0Test 0Test');

			SVNSUMMITS_WrapperMembers membrs3 = SVNSUMMITS_MembersController.getMembers(8, 'Sort by Last Name', '', 'Test');
			system.assertEquals(8, membrs3.membersList.size());

			Test.stopTest();
		}
	}

	private static testMethod void testCount() {
		SVNSUMMITS_MembersController_Test test1 = new SVNSUMMITS_MembersController_Test();
		SVNSUMMITS_MembersController.networkId = SVNSUMMITS_TestUtil.NETWORK_ID;
		system.assertNotEquals(SVNSUMMITS_MembersController.networkId, null);

		List<User> testUsers = SVNSUMMITS_TestUtil.createUsers(8, SVNSUMMITS_TestUtil.COMPANY_COMMUNITY_PROFILE_NAME);
		system.assertEquals(8, testUsers.size());

		test1.objTestUser = testUsers[0];

		system.runAs(test1.objTestUser) {
			Test.startTest();

			// total count
			Decimal memberCount = SVNSUMMITS_MembersController.getMemberCount();
			system.debug('Member count = ' + memberCount);
			system.assert(memberCount > 0);

			Test.stopTest();
		}
	}

	private static testMethod void testExcludedMembers() {
		SVNSUMMITS_MembersController_Test test1 = new SVNSUMMITS_MembersController_Test();
		SVNSUMMITS_MembersController.networkId = SVNSUMMITS_TestUtil.NETWORK_ID;
		system.assertNotEquals(SVNSUMMITS_MembersController.networkId, null);

		List<User> testUsers = SVNSUMMITS_TestUtil.createUsers(8, SVNSUMMITS_TestUtil.COMPANY_COMMUNITY_PROFILE_NAME);
		system.assertEquals(8, testUsers.size());

		test1.objTestUser = testUsers[0];

		system.runAs(test1.objTestUser) {
			Decimal memberCount   = SVNSUMMITS_MembersController.getMemberCount();

			List<String> excluded = new List<String>();
			// test with excluded IDs
			SVNSUMMITS_WrapperMembers membrs = SVNSUMMITS_MembersController.getMembers(8, 'Sort by Last Name', '', 'Test');

			excluded.add(membrs.membersList[0].Id);
			excluded.add(membrs.membersList[1].Id);
			SVNSUMMITS_WrapperMembers membrs1 = SVNSUMMITS_MembersController.getMembersEx(6, 'Sort by Last Name', '', 'Test', excluded);
			system.assertEquals(6, membrs1.membersList.size());
			system.assertEquals(membrs1.membersList[0].Name, '2Test 2Test');
			SVNSUMMITS_WrapperMembers nxtmembrs4 = SVNSUMMITS_MembersController.nextPageEx(4, 1, 'Sort by Last Name', 'Members I Follow', 'Test', excluded);
			SVNSUMMITS_WrapperMembers prevmembrs4 = SVNSUMMITS_MembersController.previousPageEx(4, 2, 'Sort by Last Name', 'Members I Follow', 'Test', excluded);

			// total excluding Ids
			Decimal exMemberCount = SVNSUMMITS_MembersController.getMemberCountEx(excluded);
			system.debug('Member count (Ex) = ' + exMemberCount);
			system.assert(memberCount > exMemberCount);
		}
	}

	private static testMethod void testGetMembersList() {
		SVNSUMMITS_MembersController_Test test1 = new SVNSUMMITS_MembersController_Test();
		SVNSUMMITS_MembersController.networkId = SVNSUMMITS_TestUtil.NETWORK_ID;
		system.assertNotEquals(SVNSUMMITS_MembersController.networkId, null);

		//TestSetupData
		List<User> testUsers = SVNSUMMITS_TestUtil.createUsers(8, SVNSUMMITS_TestUtil.COMPANY_COMMUNITY_PROFILE_NAME);
		system.assertEquals(8, testUsers.size());

		test1.objTestUser = testUsers[0];

		system.runAs(test1.objTestUser) {
			Test.startTest();

			SVNSUMMITS_WrapperMembers members = SVNSUMMITS_MembersController.getMemberList(
					100,
					1,
					'Sort by Last Name',
					'',
					'Test',
					'',
					false,
					null);
			system.assert(members.membersList.size() > 0);
			system.debug('testGetMembersList - total found ' + members.membersList.size());

			// next page
			SVNSUMMITS_WrapperMembers membersPage2 = SVNSUMMITS_MembersController.getMemberList(
					6,
					2,
					'Sort by Last Name',
					'',
					'Test',
					'',
					false,
					null);
			system.assert(membersPage2.membersList.size() > 0);

			// text excluded members
			List<String> excluded = new List<String>();

			excluded.add(members.membersList[0].Id);
			excluded.add(members.membersList[1].Id);

			SVNSUMMITS_WrapperMembers members1 = SVNSUMMITS_MembersController.getMemberList(
					100,
					1,
					'Sort by Last Name',
					'',
					'Test',
					'',
					false,
					excluded);
			system.debug('testGetMembersList - total excluded found ' + members1.membersList.size());
			system.assertEquals(2, members.membersList.size() - members1.membersList.size());

			SVNSUMMITS_WrapperMembers featuredMembers = SVNSUMMITS_MembersController.getFeaturedMembersList(
					members.membersList[0].communitynickname,
					members.membersList[1].communitynickname,
					members.membersList[2].communitynickname,
					members.membersList[3].communitynickname,
					members.membersList[4].communitynickname,
					members.membersList[5].communitynickname,
					members.membersList[6].communitynickname,
					members.membersList[7].communitynickname);
			system.assert(featuredMembers != null);

			Test.stopTest();
		}
	}

	private static testMethod void searchMembersTest() {
		SVNSUMMITS_MembersController_Test test1 = new SVNSUMMITS_MembersController_Test();
		SVNSUMMITS_MembersController.networkId = SVNSUMMITS_TestUtil.NETWORK_ID;
		system.assertNotEquals(SVNSUMMITS_MembersController.networkId, null);

		//TestSetupData
		List<User> testUsers = SVNSUMMITS_TestUtil.createUsers(8, SVNSUMMITS_TestUtil.COMPANY_COMMUNITY_PROFILE_NAME);
		system.assertEquals(8, testUsers.size());

		test1.objTestUser = testUsers[0];

		system.runAs(test1.objTestUser) {
			Test.startTest();

			String searchString = '0Test';

			SVNSUMMITS_WrapperMembers members = SVNSUMMITS_MembersController.getMemberList(
					100,
					1,
					'Sort by Last Name',
					'',
					searchString,
					'',
					false,
					null);

			system.assertEquals(1, members.membersList.size());

			searchString = '54:phone;';
			members = SVNSUMMITS_MembersController.getMemberList(
					100,
					1,
					'Sort by First Name',
					'',
					searchString,
					'',
					false,
					null);
			system.assertEquals(1, members.membersList.size());

			Test.stopTest();
		}
	}

	@IsTest
	private static void testGetFilterMemberPickLists() {
		Test.startTest();

		SVNSUMMITS_MembersController_Test test1 = new SVNSUMMITS_MembersController_Test();
		SVNSUMMITS_MembersController.networkId = SVNSUMMITS_TestUtil.NETWORK_ID;
		system.assertNotEquals(SVNSUMMITS_MembersController.networkId, null);

		//TestSetupData
		List<User> testUsers = SVNSUMMITS_TestUtil.createUsers(8, SVNSUMMITS_TestUtil.COMPANY_COMMUNITY_PROFILE_NAME);
		system.assertEquals(8, testUsers.size());

		List<String> countries = SVNSUMMITS_MembersController.getMemberPicklist('Contact.MailingCountry', '');
		system.debug('Countries ' + countries);
		system.assertNotEquals(null, countries);

		List<String> cities = SVNSUMMITS_MembersController.getMemberPicklist('Contact.MailingCity', '');
		system.debug('Cities:   ' + cities);
		system.assertNotEquals(null, cities);

		List<String> states = SVNSUMMITS_MembersController.getMemberPicklist('Contact.MailingState', '');
		system.debug('States:   ' + states);
		system.assertNotEquals(null, states);

		List<String> accounts = SVNSUMMITS_MembersController.getMemberPicklist('Account.Name', '');
		system.debug('Accounts: ' + accounts);
		system.assertNotEquals(null, accounts);

		accounts = SVNSUMMITS_MembersController.getMemberPicklist('Account.Name', 'United');
		system.debug('Accounts: ' + accounts);
		system.assertNotEquals(null, accounts);

//		accounts = SVNSUMMITS_MembersController.getMemberPicklist('Contact.Level__c', '');
//		system.debug('Accounts: ' + accounts);
//		system.assertNotEquals(null, accounts);

		Test.stopTest();
	}

	@IsTest
	private static void testWhereClause() {
		// No database involved
		String search = 'apple';
		String result = SVNSUMMITS_MembersController.getWhereClause(search);
		System.debug('Search: ' + search);
		System.debug('Result: ' + result);
		System.assertNotEquals('', result);

		search = 'apple:;';
		result = SVNSUMMITS_MembersController.getWhereClause(search);
		System.debug('Search: ' + search);
		System.debug('Result: ' + result);
		System.assertNotEquals('', result);

		search = 'apple:phone,email;Contact.MailingCountry:US';
		result = SVNSUMMITS_MembersController.getWhereClause(search);
		System.debug('Search: ' + search);
		System.debug('Result: ' + result);
		System.assertNotEquals('', result);

		search = 'apple:phone,email;Contact.MailingCountry:US;Contact.MailingCity:Lawrence';
		result = SVNSUMMITS_MembersController.getWhereClause(search);
		System.debug('Search: ' + search);
		System.debug('Result: ' + result);
		System.assertNotEquals('', result);

		search = ':;Contact.MailingCountry:US;Contact.MailingCity:Lawrence';
		result = SVNSUMMITS_MembersController.getWhereClause(search);
		System.debug('Search: ' + search);
		System.debug('Result: ' + result);
		System.assertNotEquals('', result);

		search = 'apple:;Contact.MailingCountry:US;Contact.MailingCity:Lawrence';
		result = SVNSUMMITS_MembersController.getWhereClause(search);
		System.debug('Search: ' + search);
		System.debug('Result: ' + result);
		System.assertNotEquals('', result);
	}

	@IsTest
	private static void testWhereCustomField() {
		String search = 'apple';
		String result = SVNSUMMITS_MembersController.getWhereClause(search);
		System.debug('Search: ' + search);
		System.debug('Result: ' + result);
		System.assertNotEquals('', result);

		search = ':;Contact.Level__c:Primary';
		result = SVNSUMMITS_MembersController.getWhereClause(search);
		System.debug('Search: ' + search);
		System.debug('Result: ' + result);
		System.assertNotEquals('', result);
	}

	@IsTest
	private static void testGetTopicValues() {
		Test.startTest();

		Map<String, String> topics = SVNSUMMITS_MembersController.getTopicValues();
		System.assertNotEquals(null, topics);

		Test.stopTest();
	}
}