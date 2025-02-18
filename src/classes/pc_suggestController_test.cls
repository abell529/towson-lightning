/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francoiskorb on 11/28/17.
 */

@IsTest
public with sharing class pc_suggestController_test
{
	@testSetup
	static void createTestData()
	{
		ss_testUtil.createTestProducts(1, true);
	}

	@IsTest
	static void testSuggestController()
	{
		System.debug('testSuggestController');
		String searchFilter = '';
		String familyFilter = '';
		String sortOrder = '';

		Test.startTest();
		pc_listModel model = pc_listController.getProducts(1, 0, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertNotEquals(null, model);
		system.assert(model.items.size() > 0);
		system.assertNotEquals(null, model.items[0]);
		System.debug('item 0 : ' + model.items[0]);
		pc_model firstItem = pc_listController.getProductById(model.items[0].productId);
		system.assertNotEquals(null, firstItem);

		pc_suggestController.sendSuggestedEmail('testUser1', 'testUser1@testmai.url', model.items[0].productId);
		Test.stopTest();
	}
}
