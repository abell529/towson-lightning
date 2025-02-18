/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 8/4/17.
 */

@IsTest
public class sc_listController_test
{
	static final Integer TEST_SIZE = 5;
	private static final String testUserName = 'tester@7s001-pc-noemail.com';

	@TestSetup
	static void setupData()
	{
		ss_testUtil.createTestUser(testUserName, 'testOrderAccount');
		ss_testUtil.createTestProducts(TEST_SIZE, true);

	}

	@IsTest
	static void testListModel()
	{
		Id pricebookId = Test.getStandardPricebookId();

//		Id testProfile = [select id from profile where name = 'Partner Community User' OR name = 'Customer Community User' LIMIT 1].id;
		Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
		Id testProfile = setupId.Self_Registration_Profile_Id__c;

		Account testAccount = (Account) ss_testFactory.createSObject(new Account(name = 'testOrderAccount'), true);
		system.assertNotEquals(null, testAccount);

		Contact testContact = (Contact) SS_TestFactory.createSObject(new Contact(LastName = 'testCon', AccountId = testAccount.Id), true);

		User user = (User) ss_testFactory.createSObject(new User(alias = 'test123', email = 'tester123@noemail.com',
			emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
			localesidkey = 'en_US', profileid = testProfile, country = 'United States', IsActive = true,
			ContactId = testContact.Id,
			timezonesidkey = 'America/Los_Angeles', username = 'tester001@noemail.com'), true);

		System.assertNotEquals(null, user);

		Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product', isActive = true, productCode = 'ABC'), true);
		system.assertNotEquals(null, testProduct);

		PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = true), true);
		system.assertNotEquals(null, testEntry);

		Order testOrder = (Order) ss_testFactory.createSObject(new Order(AccountId = testAccount.Id, OwnerId=user.Id, Pricebook2Id = pricebookId, status = 'draft', EffectiveDate = System.today()), true);
		system.assertNotEquals(null, testOrder);

		OrderItem orderItem = (OrderItem) ss_testFactory.createSObject(new OrderItem(OrderId = testOrder.Id, PricebookEntryId = testEntry.Id, Quantity = 1.0, UnitPrice = 50.0), true);
		system.assertNotEquals(null, orderItem);

		Test.startTest();
		sc_model model = new sc_model(orderItem, 'communityUrl', testProduct.Id);
		system.assertNotEquals(null, model);
		model.dumpModel('unit test');

		model = new sc_model(orderItem, '', null);
		sc_model defaultModel = new sc_model();
		system.assertNotEquals(null, defaultModel);

		Test.stopTest();
	}

	@IsTest
	static void testListController()
	{
		sc_listController controller = new sc_listController();
		system.assertNotEquals(null, controller);
	}

	@IsTest
	static void testGetOrderEmpty()
	{
		Id pricebookId = Test.getStandardPricebookId();
		User testUser = [select Id, AccountId from User where Username = :testUserName limit 1];
		ss_settings settings = new ss_settings(testUser.AccountId, false, pricebookId);

		System.runAs(testUser)
		{
			Test.startTest();

			sc_listModel newOrder = sc_listController.getOrder(testUser.Id, settings, null, null);
			system.assertNotEquals(null, newOrder);
			system.assertEquals(null, newOrder.orderId);
			system.assertEquals(0, newOrder.subTotal);
			system.assertEquals(0, newOrder.items.size());

			newOrder.dumpModel('test get order - empty');

			Test.stopTest();
		}
	}

	@IsTest
	static void testCreateOrder()
	{
		Id pricebookId = Test.getStandardPricebookId();
		User testUser = ss_testUtil.createTestUser('testUser01@nomail.com', 'testAccount01');
		ss_settings settings = new ss_settings(testUser.AccountId, false, pricebookId);

		sc_listModel model = new sc_listModel();
		model.userId = testUser.Id;
		model.usePoints = settings.usePoints;
		model.pricebookId = settings.pricebookId;

		System.runAs(testUser)
		{
			Test.startTest();

			Order newOrder = sc_listController.createOrder(settings, model, null);
			system.assertNotEquals(null, newOrder);

			Test.stopTest();
		}
	}

	@IsTest
	static void testUpdateOrder()
	{
		Id pricebookId = Test.getStandardPricebookId();

//		Id testProfile = [select id from profile where name = 'Partner Community User' OR name = 'Customer Community User' LIMIT 1].id;
		Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
		Id testProfile = setupId.Self_Registration_Profile_Id__c;

		Account testAccount = (Account) ss_testFactory.createSObject(new Account(name = 'testOrderAccount'), true);
		system.assertNotEquals(null, testAccount);

		Contact testContact = (Contact) SS_TestFactory.createSObject(new Contact(LastName = 'testCon', AccountId = testAccount.Id), true);

		User user = (User) ss_testFactory.createSObject(new User(alias = 'test123', email = 'tester123@noemail.com',
			emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US',
			profileid = testProfile, country = 'United States', IsActive = true, ContactId = testContact.Id,
			timezonesidkey = 'America/Los_Angeles', username = 'tester001@noemail.com'), true);

		System.assertNotEquals(null, user);

		System.runAs(user)
		{
			Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product 1', isActive = true, productCode = 'ABC'), true);
			system.assertNotEquals(null, testProduct);

			Product2 testProduct2 = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product 2', isActive = true, productCode = 'ABC'), true);
			system.assertNotEquals(null, testProduct);

			PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = true), true);
			system.assertNotEquals(null, testEntry);

			PricebookEntry testEntry2 = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(Product2ID = testProduct2.id, Pricebook2ID = pricebookId, UnitPrice = 10, isActive = true), true);
			system.assertNotEquals(null, testEntry);

			Order testOrder = (Order) ss_testFactory.createSObject(new Order(AccountId = testAccount.Id, OwnerId = user.Id, Pricebook2Id = pricebookId, status = 'draft', EffectiveDate = System.today()), true);
			system.assertNotEquals(null, testOrder);

			OrderItem orderItem = (OrderItem) ss_testFactory.createSObject(new OrderItem(OrderId = testOrder.Id, PricebookEntryId = testEntry.Id, Quantity = 1.0, UnitPrice = 50.0), true);
			system.assertNotEquals(null, orderItem);

			OrderItem orderItem2 = (OrderItem) ss_testFactory.createSObject(new OrderItem(OrderId = testOrder.Id, PricebookEntryId = testEntry2.Id, Quantity = 1.0, UnitPrice = 10.0), true);
			system.assertNotEquals(null, orderItem2);

			ss_settings settings = new ss_settings(testAccount.Id, false, pricebookId);

			Test.startTest();

			sc_listController.updateOrder(user.Id, settings, testProduct.id, 2, 'add', null, null, testEntry.UnitPrice);
			sc_listController.updateOrder(user.Id, settings, testProduct.id, 1, 'delete', null, null, testEntry.UnitPrice);
			sc_listController.updateOrder(user.Id, settings, testProduct2.id, 2, 'add', null, null, testEntry2.UnitPrice);
			sc_listController.updateOrder(user.Id, settings, testProduct.Id, 0, 'clear', null, null, testEntry.UnitPrice);

			orderItem = (OrderItem) ss_testFactory.createSObject(new OrderItem(OrderId = testOrder.Id, PricebookEntryId = testEntry.Id, Quantity = 1.0, UnitPrice = 50.0), true);
			sc_listModel model = sc_listController.getOrder(user.Id, settings, null, null);
			OrderItem foundItem = sc_listController.findOrderItem(model, '123');

			model.dumpModel('Test Order');
			Boolean activated = sc_listController.activateOrder(model);
			System.assertEquals(true, activated);

			// should see the order is activated
			activated = sc_listController.activateOrder(model);
			System.assertEquals(false, activated);

			Test.stopTest();
		}
	}

	@IsTest
	static void testRSVPOrderStandardUser() {
		Id pricebookId = Test.getStandardPricebookId();

		Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
		Id testProfile = setupId.Self_Registration_Profile_Id__c;

		Contact testContact = (Contact) SS_TestFactory.createSObject(new Contact(LastName = 'testCon', AccountId = setupId.Self_Registration_Account_Id__c), true);

		User user = (User) ss_testFactory.createSObject(new User(alias = 'test123', email = 'tester123@noemail.com',
				emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US',
				profileid = testProfile, country = 'United States', IsActive = true, ContactId = testContact.Id,
				timezonesidkey = 'America/Los_Angeles', username = 'tester001@noemail.com'), true);

		System.assertNotEquals(null, user);

		List<Event__c> events = TU_TestUtilities.createEventsRecords(false,1,true);
		system.assertEquals(1, events.size());

		List<User> users = new List<User>();
		users.add(user);

		Test.startTest();

		System.runAs(user) {
			List<Event_RSVP__c> eventRSVPS = TU_TestUtilities.createRSVPRecords(1, events, new List<Contact>(), users, true, TU_EventRSVPHelper.rsvpConfirm);
			system.assertEquals(1, eventRSVPS.size());

			Event_RSVP__c thisRSVP = new Event_RSVP__c();
			thisRSVP = [SELECT RSVPToken_TU__c FROM Event_RSVP__c WHERE Id = :eventRSVPS[0].Id LIMIT 1];

			System.debug(thisRSVP.RSVPToken_TU__c);
			Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product 1', isActive = true, productCode = 'ABC'), true);
			system.assertNotEquals(null, testProduct);
			System.debug(testProduct);

			PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = true), true);
			system.assertNotEquals(null, testEntry);
			System.debug(testEntry);

			sc_listModel listModel = sc_listController.getOrder(thisRSVP.RSVPToken_TU__c, null);

			listModel = sc_listController.updateOrder(testProduct.Id, 1, 'add', thisRSVP.RSVPToken_TU__c, null, testEntry.UnitPrice);
			System.debug(listModel);

			String paymentURL = sc_listController.getECommerceURL(thisRSVP.RSVPToken_TU__c, null);
			System.debug(paymentURL);

			sc_listModel model = sc_listController.getPlaceOrder(thisRSVP.RSVPToken_TU__c, null);
			System.assertEquals(thisRSVP.RSVPToken_TU__c, model.rsvpToken);

		}

		Test.stopTest();

	}

	@IsTest
	static void testRSVPOrderGuestUser() {
		Id pricebookId = Test.getStandardPricebookId();

		Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
		Id testProfile = setupId.Self_Registration_Profile_Id__c;

		Contact testContact = (Contact) SS_TestFactory.createSObject(new Contact(LastName = 'testCon', AccountId = setupId.Self_Registration_Account_Id__c), true);

		User user = Peak_TestUtils.createGuestUser();

		System.assertNotEquals(null, user);

		List<Event__c> events = TU_TestUtilities.createEventsRecords(false,1,true);
		system.assertEquals(1, events.size());

		List<Contact> contacts = new List<Contact>();
		contacts.add(testContact);

		Test.startTest();

		System.runAs(user) {
			List<Event_RSVP__c> eventRSVPS = TU_TestUtilities.createRSVPRecords(1, events, contacts, new List<User>(), true, TU_EventRSVPHelper.rsvpConfirm);
			system.assertEquals(1, eventRSVPS.size());

			Event_RSVP__c thisRSVP = new Event_RSVP__c();
			thisRSVP = [SELECT RSVPToken_TU__c FROM Event_RSVP__c WHERE Id = :eventRSVPS[0].Id LIMIT 1];

			System.debug(thisRSVP.RSVPToken_TU__c);
			Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product 1', isActive = true, productCode = 'ABC'), true);
			system.assertNotEquals(null, testProduct);
			System.debug(testProduct);

			PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = true), true);
			system.assertNotEquals(null, testEntry);
			System.debug(testEntry);

			sc_listModel listModel = sc_listController.getOrder(thisRSVP.RSVPToken_TU__c, null);

			listModel = sc_listController.updateOrder(testProduct.Id, 1, 'add', thisRSVP.RSVPToken_TU__c, null, testEntry.UnitPrice);
			System.debug(listModel);

			String paymentURL = sc_listController.getECommerceURL(thisRSVP.RSVPToken_TU__c, null);
			System.debug(paymentURL);

			sc_listModel model = sc_listController.getPlaceOrder(thisRSVP.RSVPToken_TU__c, null);
			System.assertEquals(thisRSVP.RSVPToken_TU__c, model.rsvpToken);

		}

		Test.stopTest();
	}

	@IsTest
	static void testOrderGuestUser() {
		Id pricebookId = Test.getStandardPricebookId();

		Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
		Id testProfile = setupId.Self_Registration_Profile_Id__c;

		Contact testContact = (Contact) SS_TestFactory.createSObject(new Contact(LastName = 'testCon', AccountId = setupId.Self_Registration_Account_Id__c), true);

		User user = Peak_TestUtils.createGuestUser();

		System.assertNotEquals(null, user);

		List<Contact> contacts = new List<Contact>();
		contacts.add(testContact);

		Test.startTest();

		System.runAs(user) {

			Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product 1',
					isActive = true, productCode = 'ABC', AllowRecipient_TU__c = true), true);
			system.assertNotEquals(null, testProduct);

			PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = true), true);
			system.assertNotEquals(null, testEntry);

			sc_listModel listModel = sc_listController.getOrder(null, null);

			listModel = sc_listController.updateOrder(testProduct.Id, 1, 'add', null, null, testEntry.UnitPrice);
			System.debug(listModel);
			System.assert(listModel.specialItems);

			Boolean updated = sc_listController.updateOrderCart(listModel.items[0].id, 'Bob Test',
					'Unit Test is Heavy', 'I like unit tests');
			System.assert(updated);

			String paymentURL = sc_listController.getECommerceURL(null, listModel.orderToken);
			System.assertNotEquals(null, paymentURL);

			List<asp04__Payment__c> payments = new List<asp04__Payment__c>();
			for (asp04__Payment__c payment : [SELECT asp04__First_Name__c, asp04__Last_Name__c, asp04__Email__c, Contact_TU__c,
					asp04__Billing_Address_City__c, asp04__Billing_Address_State__c, asp04__Billing_Address_Country__c,
					asp04__Billing_Address_PostalCode__c, asp04__Billing_Address_Street__c,	Order_TU__r.OrderToken_TU__c
					FROM asp04__Payment__c WHERE Order_TU__r.OrderToken_TU__c = :listModel.orderToken]) {

				if (payment.Contact_TU__c == null) {
					payment.asp04__Last_Name__c = Peak_TestConstants.LASTNAME;
					payment.asp04__First_Name__c = Peak_TestConstants.FIRSTNAME;
					payment.asp04__Email__c = Peak_TestConstants.GUEST_EMAIL;
					payments.add(payment);
				}
			}

			update payments;

			sc_listModel model = sc_listController.getPlaceOrder(null, listModel.orderToken);
			System.assertEquals(listModel.orderToken, model.orderToken);
		}

		Test.stopTest();
	}

	@IsTest
	static void testOrderGuestUserWithContact() {
		Id pricebookId = Test.getStandardPricebookId();

		Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());

		User user = Peak_TestUtils.createGuestUser();

		System.assertNotEquals(null, user);

		Test.startTest();

		System.runAs(user) {
			Contact testContact = (Contact) SS_TestFactory.createSObject(new Contact(LastName = Peak_TestConstants.LASTNAME,
					FirstName = Peak_TestConstants.FIRSTNAME, TU_Home_Email__c = Peak_TestConstants.GUEST_EMAIL,
					AccountId = setupId.Self_Registration_Account_Id__c), true);

			System.debug(testContact);

			Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product 1',
					isActive = true, productCode = 'ABC', AllowRecipient_TU__c = true), true);
			system.assertNotEquals(null, testProduct);

			PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = true), true);
			system.assertNotEquals(null, testEntry);

			sc_listModel listModel = sc_listController.getOrder(null, null);

			listModel = sc_listController.updateOrder(testProduct.Id, 1, 'add', null, null, testEntry.UnitPrice);
			System.debug(listModel);
			System.assert(listModel.specialItems);

			Boolean updated = sc_listController.updateOrderCart(listModel.items[0].id, 'Bob Test',
					'Unit Test is Heavy', 'I like unit tests');
			System.assert(updated);

			String paymentURL = sc_listController.getECommerceURL(null, listModel.orderToken);
			System.assertNotEquals(null, paymentURL);

			List<asp04__Payment__c> payments = new List<asp04__Payment__c>();
			for (asp04__Payment__c payment : [SELECT asp04__First_Name__c, asp04__Last_Name__c, asp04__Email__c, Contact_TU__c,
					asp04__Billing_Address_City__c, asp04__Billing_Address_State__c, asp04__Billing_Address_Country__c,
					asp04__Billing_Address_PostalCode__c, asp04__Billing_Address_Street__c,	Order_TU__r.OrderToken_TU__c
			FROM asp04__Payment__c WHERE Order_TU__r.OrderToken_TU__c = :listModel.orderToken]) {

				if (payment.Contact_TU__c == null) {
					payment.asp04__Last_Name__c = testContact.LastName;
					payment.asp04__First_Name__c = testContact.FirstName;
					payment.asp04__Email__c = testContact.TU_Home_Email__c;
					payments.add(payment);
				}
			}

			update payments;

			sc_listModel model = sc_listController.getPlaceOrder(null, listModel.orderToken);
			System.assertEquals(listModel.orderToken, model.orderToken);
		}

		Test.stopTest();
	}

	@IsTest
	static void testCreatePaymentScheduleGuestUser() {

		Id pricebookId = Test.getStandardPricebookId();

		Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
		Id testProfile = setupId.Self_Registration_Profile_Id__c;

		Contact testContact = (Contact) SS_TestFactory.createSObject(new Contact(LastName = 'testCon',
				AccountId = setupId.Guest_Event_Account_Id__c), true);

		User user = Peak_TestUtils.createGuestUser();

		System.assertNotEquals(null, user);

		List<Contact> contacts = new List<Contact>();
		contacts.add(testContact);

		Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product 1',
				isActive = true, productCode = 'ABC', AllowRecipient_TU__c = true), true);
		system.assertNotEquals(null, testProduct);

		PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(
				Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = true,
				UserDefinedAmountAllowed_TU__c = true), true);
		system.assertNotEquals(null, testEntry);

		Decimal quanity = 0;
		Decimal unitPrice = 0;
		String frequency = '';
		String nextPaymentDate;
		String finalPaymentDate;

		Test.startTest();

		System.runAs(user) {
			Peak_Response peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals(LABEL.ss_pc_label_next_payment_date + ' is required', peakResponse.messages[0]);

			nextPaymentDate = String.valueOf(Date.today().addDays(-3));
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals('Quantity cannot be equal to zero', peakResponse.messages[0]);

			quanity = 1;
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals('Please select a valid ' + LABEL.ss_pc_label_frequency, peakResponse.messages[0]);

			frequency = 'Monthly';
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals(LABEL.ss_pc_label_next_payment_date + ' must be greater or equal to Today',
					peakResponse.messages[0]);

			nextPaymentDate = String.valueOf(Date.today());
			finalPaymentDate = String.valueOf(Date.today().addDays(-3));
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals(LABEL.ss_pc_label_final_payment_date + ' must be greater or equal to ' +
					LABEL.ss_pc_label_next_payment_date, peakResponse.messages[0]);

			finalPaymentDate = String.valueOf(Date.today().addDays(3));
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals(LABEL.ss_pc_label_unit_price + ' is required.', peakResponse.messages[0]);

			unitPrice = 50;
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(peakResponse.success);

			Order scheduleOrder = (Order) peakResponse.results[0];
			String orderToken = scheduleOrder.OrderToken_TU__c;
			String paymentURL = sc_listController.getECommerceURL(null, orderToken);
			System.assertNotEquals(null, paymentURL);

			sc_listModel model = sc_listController.getPlaceOrder(null, orderToken);
			System.assertEquals(orderToken, model.orderToken);

		}

		Test.stopTest();
	}

	@IsTest
	static void testCreatePaymentScheduleUser() {

		Id pricebookId = Test.getStandardPricebookId();

		Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
		Id testProfile = setupId.Self_Registration_Profile_Id__c;

		Contact testContact = (Contact) SS_TestFactory.createSObject(new Contact(LastName = 'testCon',
				AccountId = setupId.Self_Registration_Account_Id__c), true);

		User user = Peak_TestUtils.createStandardUserNoContact();
		user.ContactId = testContact.Id;
		insert user;

		System.assertNotEquals(null, user);

		List<Contact> contacts = new List<Contact>();
		contacts.add(testContact);

		Product2 testProduct = (Product2) ss_testFactory.createSObject(new Product2(Name = 'Test Product 1',
				isActive = true, productCode = 'ABC', AllowRecipient_TU__c = true), true);
		system.assertNotEquals(null, testProduct);

		PricebookEntry testEntry = (PricebookEntry) ss_testFactory.createSObject(new PricebookEntry(
				Product2ID = testProduct.id, Pricebook2ID = pricebookId, UnitPrice = 50, isActive = true,
				UserDefinedAmountAllowed_TU__c = true), true);
		system.assertNotEquals(null, testEntry);

		Decimal quanity = 0;
		Decimal unitPrice = 0;
		String frequency = '';
		String nextPaymentDate;
		String finalPaymentDate;

		Test.startTest();

		System.runAs(user) {
			Peak_Response peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals(LABEL.ss_pc_label_next_payment_date + ' is required', peakResponse.messages[0]);

			nextPaymentDate = String.valueOf(Date.today().addDays(-3));
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals('Quantity cannot be equal to zero', peakResponse.messages[0]);

			quanity = 1;
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals('Please select a valid ' + LABEL.ss_pc_label_frequency, peakResponse.messages[0]);

			frequency = 'Monthly';
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals(LABEL.ss_pc_label_next_payment_date + ' must be greater or equal to Today',
					peakResponse.messages[0]);

			nextPaymentDate = String.valueOf(Date.today());
			finalPaymentDate = String.valueOf(Date.today().addDays(-3));
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals(LABEL.ss_pc_label_final_payment_date + ' must be greater or equal to ' +
					LABEL.ss_pc_label_next_payment_date, peakResponse.messages[0]);

			finalPaymentDate = String.valueOf(Date.today().addDays(3));
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(!peakResponse.success);
			System.assertEquals(LABEL.ss_pc_label_unit_price + ' is required.', peakResponse.messages[0]);

			unitPrice = 50;
			peakResponse = sc_listController.createPaymentSchedule(quanity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, testProduct.Id);
			System.assert(peakResponse.success);

			Order scheduleOrder = (Order) peakResponse.results[0];
			String orderToken = scheduleOrder.OrderToken_TU__c;
			String paymentURL = sc_listController.getECommerceURL(null, orderToken);
			System.assertNotEquals(null, paymentURL);

			sc_listModel model = sc_listController.getPlaceOrder(null, orderToken);
			System.assertEquals(orderToken, model.orderToken);

		}

		Test.stopTest();
	}

}
