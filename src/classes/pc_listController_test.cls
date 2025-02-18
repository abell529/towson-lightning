/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 7/18/17.
 */

@IsTest
public with sharing class pc_listController_test
{
	// test constants
	static final Decimal PAGE_SIZE = 10;
	static final Decimal TEST_SIZE = 5;

	@testSetup
	static void createTestData()
	{
		ss_testUtil.createTestProducts((Integer)TEST_SIZE, false);
		List<User> users = TU_TestUtilities.createRegUser(1,true);
		List<Event__c> events = TU_TestUtilities.createEventsRecords(false,1,true);
	}

	@isTest
	static void testListModel()
	{
		pc_listModel model = new pc_listModel();

		system.assertEquals(0, model.pageSize);
		system.assertEquals(0, model.pageCurrent);
		system.assertEquals(0, model.total);
		system.assertEquals(0, model.items.size());
	}

	@isTest
	static void testGetProductFilters()
	{
		Test.startTest();

		String searchFilter = '';
		String familyFilter = '';
		String sortOrder = '';

		pc_listModel model = pc_listController.getProducts(0, 0, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertEquals(10, model.pageSize);
		system.assertEquals(1, model.pageCurrent);

		model = pc_listController.getProducts(PAGE_SIZE, 1, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertEquals(TEST_SIZE, model.total);
		system.assertNotEquals(null, model.usePoints);
		model.dumpModel('PageSize');

		familyFilter = 'None';
		model = pc_listController.getProducts(PAGE_SIZE, 1, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertEquals(1, model.total);

		familyFilter = '';
		searchFilter = 'PC1';
		model = pc_listController.getProducts(PAGE_SIZE, 1, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertEquals(1, model.total);

		familyFilter = 'None';
		searchFilter = 'PC0';
		model = pc_listController.getProducts(PAGE_SIZE, 1, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertEquals(1, model.total);

		searchFilter = 'XYZ';
		model = pc_listController.getProducts(PAGE_SIZE, 1, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertEquals(0, model.total);

		Test.stopTest();
	}

	@IsTest
	static void testOrderBy()
	{
		Test.startTest();

		String searchFilter = '';
		String familyFilter = '';
		String sortOrder = 'Product Name';

		pc_listModel model = pc_listController.getProducts(PAGE_SIZE, 1, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertEquals(TEST_SIZE, model.total);
		system.assertEquals('Product0', model.items[0].name);

		sortOrder = 'Product Family';
		model = pc_listController.getProducts(PAGE_SIZE, 1, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertEquals(TEST_SIZE, model.total);

		sortOrder = 'Product Code';
		model = pc_listController.getProducts(PAGE_SIZE, 1, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertEquals(TEST_SIZE, model.total);

		sortOrder = 'Unit Price';
		model = pc_listController.getProducts(PAGE_SIZE, 1, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertEquals(TEST_SIZE, model.total);

		sortOrder = 'Sequence__c';
		model = pc_listController.getProducts(PAGE_SIZE, 1, searchFilter, familyFilter, sortOrder, 0, 0);
		system.assertEquals(TEST_SIZE, model.total);

		Test.stopTest();
	}

	@IsTest
	static void testGetProductsById()
	{
		Test.startTest();

		pc_listModel model = pc_listController.getProducts(PAGE_SIZE, 1, '', '', '', 0, 0);
		system.assertEquals(TEST_SIZE, model.total);

		pc_model locatedItem = model.getItemByProductId(model.items[0].productId);
		System.assertNotEquals(null, locatedItem);

		List<string> ids = new List<String>();
		ids.add(model.items[0].productId);
		ids.add(model.items[2].productId);

		pc_listModel products = pc_listController.getProductsById(PAGE_SIZE, 1, ids);

		System.assertEquals(2, products.total);
		System.assertEquals(model.items[0].productId, products.items[0].productId);
		System.assertEquals(model.items[2].productId, products.items[1].productId);
		System.assertNotEquals(products.items[0].productId, products.items[1].productId);

		pc_model item = pc_listController.getProductById(ids[0]);
		system.assertNotEquals(null, item);
		system.assertEquals(ids[0], item.productId);
		item.dumpModel('test get products by Id');

		Test.stopTest();
	}

	@IsTest
	static void testGetFeaturedProducts()
	{
		Test.startTest();

		Boolean featured = false;
		pc_listModel model = pc_listController.getProducts(PAGE_SIZE, 1, '', '', '', 0, 0);
		system.assertEquals(TEST_SIZE, model.total);
		system.assertEquals(false, model.items[1].featured);

		featured = true;
		model = pc_listController.getProductsFeatured(PAGE_SIZE, 1);
		system.assertEquals(Math.ceil(TEST_SIZE / 2), model.total);
		for (pc_model item : model.items)
		{
			system.assertEquals(true, item.featured);
		}

		Test.stopTest();
	}

	@IsTest
	static void testGetMinMaxPriceProducts()
	{
		Test.startTest();

		String searchFilter = '';
		String familyFilter = '';
		String sortOrder = '';
		Decimal minPrice = 150 + TEST_SIZE;
		Decimal maxPrice = 150 + (TEST_SIZE * 2);

		pc_listModel model = pc_listController.getProducts(0, 0, searchFilter, familyFilter, sortOrder, minPrice, maxPrice);
		system.assertEquals(2, model.total);

		// disable points
		Id pricebookId = Test.getStandardPricebookId();

		ss_settings settings = new ss_settings('', false, pricebookId);
		model = pc_listController.getProducts(true, settings, 0, 0, false, searchFilter, familyFilter, sortOrder, minPrice, maxPrice, null);
		system.assertEquals(2, model.total);

		Test.stopTest();
	}

	@IsTest
	static void testGetEventProducts() {
		List<User> users = new List<User>([SELECT Id FROM User WHERE FirstName = 'First']);
		List<Event__c> events = new List<Event__c>([SELECT Id, EventFull_TU__c, Enable_Pricing_Payment__c,
				WaitlistAllowed_TU__c, AssociatedProductCode_TU__c  FROM Event__c]);

		events[0].EventFull_TU__c = false;
		events[0].Enable_Pricing_Payment__c = true;
		events[0].WaitlistAllowed_TU__c = false;
		events[0].AssociatedProductCode_TU__c = 'Unit Test';

		update events;

		Id pricebookId = Test.getStandardPricebookId();
		String searchFilter = '';
		String familyFilter = '';
		String sortOrder = '';
		Decimal minPrice = 0;
		Decimal maxPrice = 0;
		Decimal pageSize = 0;
		Decimal currentPage = 0;

		Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product',
				ProductCode = events[0].AssociatedProductCode_TU__c, Ticket_TU__c = true,
				isActive = true), true);
		system.assertNotEquals(null, testProduct);

		PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(
				Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = true), true);
		system.assertNotEquals(null, testEntry);

		Event_RSVP__c thisRsvp = new Event_RSVP__c();
		Test.startTest();
		System.runAs(users[0]) {
			Peak_Response createResponse = TU_EventRSVPController.getRSVPForEvent(events[0].Id, null);
			createResponse = TU_EventRSVPController.updateSingleRSVP((Event_RSVP__c) createResponse.results[0], '/test','/test');
			System.assert(createResponse.success);

			thisRsvp = (Event_RSVP__c) createResponse.results[0];

			pc_listModel listModel = pc_listController.getEventProducts(thisRsvp.RSVPToken_TU__c, pageSize, currentPage,
					searchFilter, familyFilter, sortOrder, minPrice, maxPrice);
			System.assertEquals(1,listModel.items.size());
		}

		Test.stopTest();

		List<OrderItem> orders = new List<OrderItem>([SELECT Id, Order.EventRSVP_TU__c FROM OrderItem WHERE
				Order.EventRSVP_TU__c = :thisRsvp.Id]);
		System.assertEquals(1,orders.size());

	}

	@IsTest
	static void testGetEventRSVP() {
		List<User> users = new List<User>([SELECT Id FROM User WHERE FirstName = 'First']);
		List<Event__c> events = new List<Event__c>([SELECT Id, EventFull_TU__c, Enable_Pricing_Payment__c,
				WaitlistAllowed_TU__c, AssociatedProductCode_TU__c  FROM Event__c]);

		events[0].EventFull_TU__c = false;
		events[0].Enable_Pricing_Payment__c = true;
		events[0].WaitlistAllowed_TU__c = false;
		events[0].AssociatedProductCode_TU__c = 'Unit Test';
		String searchFilter = '';
		String familyFilter = '';
		String sortOrder = '';
		Decimal minPrice = 0;
		Decimal maxPrice = 0;
		Decimal pageSize = 0;
		Decimal currentPage = 0;


		update events;

		Id pricebookId = Test.getStandardPricebookId();
		Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product',
				ProductCode = events[0].AssociatedProductCode_TU__c, Ticket_TU__c = true,
				isActive = true), true);
		system.assertNotEquals(null, testProduct);

		PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(
				Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = true), true);
		system.assertNotEquals(null, testEntry);

		Event_RSVP__c thisRsvp = new Event_RSVP__c();
		Test.startTest();
		System.runAs(users[0]) {
			Peak_Response createResponse = TU_EventRSVPController.getRSVPForEvent(events[0].Id, null);
			createResponse = TU_EventRSVPController.updateSingleRSVP((Event_RSVP__c) createResponse.results[0], '/test','/test');
			System.assert(createResponse.success);

			thisRsvp = (Event_RSVP__c) createResponse.results[0];

			pc_listModel listModel = pc_listController.getEventProducts(thisRsvp.RSVPToken_TU__c, pageSize, currentPage, searchFilter, familyFilter, sortOrder, minPrice, maxPrice);
//			System.assert(response.success);

		}

		Test.stopTest();

		List<OrderItem> orders = new List<OrderItem>([SELECT Id, Order.EventRSVP_TU__c FROM OrderItem WHERE
				Order.EventRSVP_TU__c = :thisRsvp.Id]);
		System.assertEquals(1,orders.size());

	}
}
