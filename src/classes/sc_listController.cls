/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 8/4/17.
 */

public with sharing class sc_listController {

	private static final String ACTION_ADD    = 'add';
	private static final String ACTION_UPDATE = 'update';
	private static final String ACTION_DELETE = 'delete';
	private static final String ACTION_CLEAR  = 'clear';
	private static String currentOrderToken;

	/* ------------------------------------------------------------------------
	 *  Public AURA methods
	 */

	@AuraEnabled
	public static sc_listModel getOrder(String rsvpToken, String orderToken)
	{
		return getOrder(UserInfo.getUserId(), new ss_settings(), rsvpToken, orderToken);
	}

	@AuraEnabled
	public static sc_listModel updateOrder(String productId, Decimal quantity, String action, String rsvpToken,
			String orderToken, Decimal unitPrice)
	{
		ss_settings  settings = new ss_settings();
		String       userId   = UserInfo.getUserId();

		updateOrder(UserInfo.getUserId(), new ss_settings(), productId, quantity, action, rsvpToken, orderToken, unitPrice);
		if (currentOrderToken != null) {
			orderToken = currentOrderToken;
		}

		return getOrder(userId, settings, rsvpToken, orderToken);
	}

	@AuraEnabled
	public static Boolean updateOrderCart(String orderItemId, String recipientName, String specialInstructions,
			String specialMessage)	{

		return updateOrderCartItems(orderItemId, recipientName, specialInstructions, specialMessage);
	}

	@AuraEnabled
	public static Boolean placeOrder(String orderId, String rsvpToken, String orderToken)
	{
		sc_listModel model    = getOrder(UserInfo.getUserId(), new ss_settings(), rsvpToken, orderToken);

		return model.orderId == orderId ?  activateOrder(model) : false;
	}

	@AuraEnabled
	public static String getECommerceURL(String rsvpToken, String orderToken) {

		sc_listModel model = getOrder(UserInfo.getUserId(), new ss_settings(), rsvpToken, orderToken);

		if (model.scheduleId == null) {
			return processPayment(model);
		} else {
			return getAuthorisationURL(model.scheduleId);
		}
	}

	@AuraEnabled
	public static Peak_Response createPaymentSchedule(Decimal quantity, Decimal unitPrice, String frequency,
			String nextPaymentDateIn, String finalPaymentDateIn, String productId) {
		Peak_Response peakResponse = new Peak_Response();
		String message;
		Date nextPaymentDate, finalPaymentDate;

		System.debug('quantity: ' + quantity + ' Unit Price: ' + unitPrice + ' Frequency: ' + frequency +
				' nextPaymentDate:' + nextPaymentDateIn + ' finalPaymentDate: ' + finalPaymentDateIn);

		if (nextPaymentDateIn == null ) {
			peakResponse.success = false;
			message = LABEL.ss_pc_label_next_payment_date + ' is required';
			peakResponse.messages.add(message);
			return peakResponse;
		} else {
			nextPaymentDate = Date.valueOf(nextPaymentDateIn);
		}

		if (finalPaymentDateIn != null) {
			finalPaymentDate = Date.valueOf(finalPaymentDateIn);
		}

		peakResponse = validatePaymentSchedule(quantity, frequency, nextPaymentDate, finalPaymentDate, unitPrice);
		if (peakResponse.success) {
			peakResponse = createPaymentScheduleOrder(peakResponse, quantity, unitPrice, frequency,
					nextPaymentDate, finalPaymentDate, productId);
		}

		return peakResponse;
	}

	@AuraEnabled
	public static sc_listModel getPlaceOrder(String rsvpToken, String orderToken)
	{
		try {
			sc_listModel order = getOrder(UserInfo.getUserId(), new ss_settings(), rsvpToken, orderToken);

			if (order.orderId != null) {
				Boolean placedOrder = activateOrder(order);
				if (order.rsvpId != null) {
					TU_EventRSVPHelper.updateResponse(order.rsvpId, TU_EventRSVPHelper.rsvpConfirm);
				} else if (Peak_Utils.isGuestUser()) {
					paymentContact(orderToken);
				}
			}

			return order;
		} catch (Exception e) {
			throw new AuraHandledException('getPlaceOrder() - Place Order Exception: ' + e.getMessage());
		}


	}

	/* ------------------------------------------------------------------------
	 * Public methods and constants
	 */

	private final static String STATUS_DRAFT  = 'draft';
	private final static String STATUS_ACTIVE = 'activated';

	public static sc_listModel getOrder(String userId, ss_settings settings, String rsvpToken, String orderToken)
	{
		sc_listModel model = new sc_listModel();

		model.userId       = userId;
		model.usePoints    = settings.usePoints;
		model.quantityList = settings.quantityList;
		model.pricebookId  = getPriceBookId(settings);
		model.rsvpId       = getRSVPId(rsvpToken);
		model.rsvpToken    = rsvpToken;

		String query = getOrderFieldsClause();
		query += getOrderFromClause();
		query += getOrderWhereClause(userId, model.rsvpId, orderToken);
		query += ' LIMIT 1';

		List<Order> orders = Database.query(query);
		if (Peak_Utils.isGuestUser() && model.rsvpId == null && orderToken == null) {
			orders = new List<Order>();
		}

		if (orders.size() > 0)
		{
			Order currentOrder  = orders[0];

			model.record        = currentOrder;
			model.orderId       = currentOrder.Id;
			model.orderNumber   = currentOrder.OrderNumber;
			model.subTotal      = currentOrder.TotalAmount;
			model.specialItems  = currentOrder.Needs_more_information__c;
			model.orderToken    = currentOrder.OrderToken_TU__c;
			model.scheduleId    = getScheduleId(currentOrder.Id);
			model.ticketsNeeded = currentOrder.Tickets_Needed_TU__c;

			// get items
			List<OrderItem> items = getOrderItems(model.orderId);

			if (items.size() > 0)
			{
				String   communityUrl = pc_model.getCommunityUrl();
				List<Id> productIds   = new List<Id>();

				for (OrderItem item : items) {
					productIds.add(item.Product2.Id);
				}

				Decimal totalItems = 0;
				Decimal totalPoints = 0;
				Integer totalTickets = 0;
				List<ContentDocumentLink> documentLinkList = ss_contentDocument.getContentDocumentLinks(productIds);

				for(OrderItem item : items)
				{
					ContentDocumentLink link = ss_contentDocument.containsEntityId(documentLinkList, item.Product2.Id);

					if (settings.usePoints) { item.unitPrice = item.Product2.Points__c;}

					model.items.add(new sc_model(item, communityUrl, link == null ? null : link.ContentDocument.LatestPublishedVersionId));
					totalItems += item.quantity;
					if (item.Product2.Ticket_Product_TU__c) {
						totalTickets += Integer.valueOf(item.quantity);
					}

					if (settings.usePoints) { totalPoints += (item.Product2.Points__c * item.quantity);}
				}

				System.debug('Tickets needed ' + model.ticketsNeeded);
				System.debug('Total Tickets ' + totalTickets);
				model.totalItems = totalItems;
				if (totalTickets != model.ticketsNeeded) {
					model.enoughTickets = false;
				} else {
					model.enoughTickets = true;
				}

				System.debug('Enough Tickets ' + model.enoughTickets);

				if (settings.usePoints) { model.subTotal = totalPoints;}
			}
		}

		return model;
	}

	public static void updateOrder(String userId, ss_settings settings, String productId, Decimal quantity,
			String action, String rsvpToken, String orderToken, Decimal unitPrice)	{

		System.debug('updateOrder(' + userId + ',' + settings + ',' + productId + ',' + quantity + ',' + action + ',' +
				unitPrice + ')');
		sc_listModel model = getOrder(userId, settings, rsvpToken, orderToken);

		if (model.orderId == null)
		{
			System.debug('Order not found');

			if (action == ACTION_ADD)
			{
				Order newOrder = createOrder(settings, model, rsvpToken);
				System.debug('createOrder : ' + newOrder);
				try
				{
					insert newOrder;
				}
				catch (Exception e) {
					throw new AuraHandledException('updateOrder() - Create Order Exception: ' + e.getMessage());
				}

				model = getOrder(userId, settings, rsvpToken, newOrder.OrderToken_TU__c);
				if (rsvpToken == null) {
					currentOrderToken = newOrder.OrderToken_TU__c;
				}

			}
			else
			{
				return;
			}
		}

		if (action == ACTION_CLEAR)
		{
			if (model.items.size() > 0)
			{
				List<OrderItem> items = getOrderItems(model.orderId);
				delete items;

				return;
			}
		}

		OrderItem item = findOrderItem(model, productId);

		if (item == null)
		{
			if (action == ACTION_ADD)
			{
				item = createOrderItem(settings, model, productId, 0);
				System.debug('createOrderItem : ' + item);
			}
			else
			{
				return;
			}
		}

		if (action == ACTION_DELETE)
		{
			delete item;
			return;
		}

		item.quantity = action == ACTION_ADD ? item.quantity + quantity : quantity;
		if (unitPrice != null) {
			item.UnitPrice = unitPrice;
		}

		try
		{
			upsert item;
			if (!model.specialItems) {
				updateNeedsMoreInformation(settings, item);
			}
		}
		catch (Exception e) {
			throw new AuraHandledException('updateOrder() - insert item Exception: ' + e.getMessage());
		}
	}

	public static Boolean updateOrderCartItems(String orderItemId, String recipientName, String specialInstructions,
			String specialMessage) {

		if (orderItemId !=null) {
			OrderItem orderItem = new OrderItem(Id = orderItemId, RecipientName_TU__c = recipientName,
					SpecialInstructions_TU__c = specialInstructions, SpecialMessage_TU__c = specialMessage);
			try {
				update orderItem;
			} catch (Exception e) {
				throw new AuraHandledException('updateOrder() - update item Exception: ' + e.getMessage());
			}
		}
		return true;
	}

	public static OrderItem findOrderItem(sc_listModel model, String productId)
	{
		if (model.items.size() > 0 )
		{
			for (sc_model item: model.items)
			{
				if (item.productId == productId)
				{
					return (OrderItem)item.record;
				}
			}
		}

		return null;
	}

	public static Order createOrder(ss_settings settings, sc_listModel model, String rsvpToken)
	{
		// get the contact record for the current user
		User currentUser = [SELECT Id, Name, AccountId FROM User WHERE Id = :model.userId LIMIT 1];
		String accountId = currentUser.AccountId;

		if (String.isBlank(accountId))
		{
			if (String.isNotBlank(settings.accountId) && !Peak_Utils.isGuestUser()) {
				accountId = settings.accountId;
			} else {
				Community_Setup_Id__mdt setupId = TU_Utilities.getCommunitySetupIds(TU_Utilities.getCommunityNetworkId());
				accountId = setupId.Guest_Event_Account_Id__c;
			}
		}

		Order newOrder = new Order(
			AccountId     = accountId,
			EffectiveDate = System.today(),
			OwnerId       = model.userId,
			Status        = STATUS_DRAFT,
			Pricebook2Id  = model.pricebookId,
			OrderToken_TU__c = TU_Utilities.generateRandomString(18),
			Needs_more_information__c = false,
		    EventRSVP_TU__c = getRSVPId(rsvpToken),
			Tickets_Needed_TU__c = 0);

		return newOrder;
	}

	public static Boolean activateOrder(sc_listModel model)
	{
		Order currentOrder = (Order) model.record;

		if (currentOrder != null && currentOrder.Status == STATUS_DRAFT)
		{
			currentOrder.Status = STATUS_ACTIVE;
			upsert currentOrder;

			System.debug('Changed order status');
			return true;
		}

		System.debug('failed to change order status');
		return false;
	}

	public static List<OrderItem> getOrderItems(String orderId)
	{
		String query = getOrderItemFieldsClause();
		query += getOrderItemFromClause();
		query += getOrderItemWhereClause(orderId);

		List<OrderItem> items = Database.query(query);

		return items;
	}

	public static OrderItem createOrderItem(ss_settings settings, sc_listModel model, String productId, Decimal quantity)
	{
		System.debug('createOrderItem(' + productId + ')');
		pc_model product = pc_listController.getProductById(settings, productId);

		OrderItem newItem = new OrderItem(OrderId = Id.valueOf(model.orderId), Product2Id = Id.valueOf(productId), PricebookEntryId = Id.valueOf(product.Id), UnitPrice = product.unitPrice, Quantity = quantity);

		return newItem;
	}

	public static String getAuthorisationURL(String scheduleId) {
		try {
			if (scheduleId == null) {
				return scheduleId;
			} else {
				return [SELECT asp04__Authorisation__r.asp04__eCommerce_URL__c
						FROM asp04__PaymentSchedule__c
						WHERE Id = :scheduleId].asp04__Authorisation__r.asp04__eCommerce_URL__c;
			}
		} catch (Exception e) {
			throw new AuraHandledException('updateOrder() - Payment Schedule Exception: ' + e.getMessage());
		}
	}

	public static String processPayment(sc_listModel model) {
		String eCommerceUrl, paymentId;

		try {
			paymentId = retrievePaymentId(model);
			eCommerceUrl = [
					SELECT asp04__eCommerce_URL__c
					FROM asp04__Payment__c
					WHERE Id = :paymentId
					LIMIT 1
			].asp04__eCommerce_URL__c;
			System.debug(model);
			if (model.orderId != null) {
				Order updateOrder = new Order(Id = model.orderId, Payment_TU__c = paymentId);
				update updateOrder;
			}
		} catch (Exception e) {
			throw new AuraHandledException('updateOrder() - Payment Exception: ' + e.getMessage());
		}

		return eCommerceUrl;
	}

	public static Peak_Response validatePaymentSchedule(Decimal quantity, String frequency, Date nextPaymentDate,
			Date finalPaymentDate, Decimal unitPrice) {
		Peak_Response peakResponse = new Peak_Response();
		String message;
		peakResponse.success = true;

		System.debug(nextPaymentDate);
		if (quantity < 1) {
			peakResponse.success = false;
			peakResponse.messages.add('Quantity cannot be equal to zero');
		} else if (String.isEmpty(frequency)) {
			peakResponse.success = false;
			message = 'Please select a valid ' + LABEL.ss_pc_label_frequency;
 			peakResponse.messages.add(message);
		} else if (nextPaymentDate == null || nextPaymentDate < Date.today()) {
			peakResponse.success = false;
			message = LABEL.ss_pc_label_next_payment_date + ' must be greater or equal to Today';
			peakResponse.messages.add(message);
		} else if (finalPaymentDate != null && finalPaymentDate < nextPaymentDate) {
			peakResponse.success = false;
			message = LABEL.ss_pc_label_final_payment_date + ' must be greater or equal to ' +
					LABEL.ss_pc_label_next_payment_date;
			peakResponse.messages.add(message);
		} else if (unitPrice < .01) {
			peakResponse.success = false;
			message = LABEL.ss_pc_label_unit_price + ' is required.';
			peakResponse.messages.add(message);
		}

		return peakResponse;
	}

	public static Peak_Response createPaymentScheduleOrder(Peak_Response peakResponse, Decimal quantity, Decimal unitPrice,
			String frequency, Date nextPaymentDate, Date finalPaymentDate, String productId) {

		String       rsvpToken = null;
		String       action = ACTION_ADD;

		try {
			updateOrder(UserInfo.getUserId(), new ss_settings(), productId, quantity, action, rsvpToken, 'New', unitPrice);

			sc_listModel model = getOrder(UserInfo.getUserId(), new ss_settings(), rsvpToken, currentOrderToken);
			Order order = new Order(Id = model.orderId, OrderToken_TU__c = model.orderToken);
			peakResponse.results.add(order);

			peakResponse = createPaymentSchedule(peakResponse, quantity, unitPrice, frequency, nextPaymentDate,
					finalPaymentDate);
		} catch (Exception e) {
			peakResponse.success = false;
			peakResponse.messages.add(e.getMessage());
		}

		return peakResponse;
	}
	public static void updateNeedsMoreInformation(ss_settings settings, OrderItem item) {
		pc_model product = pc_listController.getProductById(settings, item.Product2Id);
		if (product.allowRecipient || product.instructionsRequired || product.specialMessageAllowed) {
			Order updateOrder = new Order(Id = item.OrderId, Needs_more_information__c = true);
			update  updateOrder;
		}
	}

	public static void paymentContact(String orderToken) {

		for (asp04__Payment__c payment : [SELECT asp04__First_Name__c, asp04__Last_Name__c, asp04__Email__c, Contact_TU__c,
				asp04__Billing_Address_City__c, asp04__Billing_Address_State__c, asp04__Billing_Address_Country__c,
				asp04__Billing_Address_PostalCode__c, asp04__Billing_Address_Street__c,	Order_TU__r.OrderToken_TU__c
				FROM asp04__Payment__c WHERE Order_TU__r.OrderToken_TU__c = :orderToken]) {

			if (payment.Contact_TU__c == null) {
				System.debug(payment);
				Contact contact = new Contact();
				contact.FirstName = payment.asp04__First_Name__c;
				contact.LastName = payment.asp04__Last_Name__c;
				contact.Email = payment.asp04__Email__c;
				contact.TU_Home_Email__c = payment.asp04__Email__c;
				contact.MailingCity = payment.asp04__Billing_Address_City__c;
				contact.MailingCountry = payment.asp04__Billing_Address_Country__c;
				contact.MailingStreet = payment.asp04__Billing_Address_Street__c;
				contact.MailingPostalCode = payment.asp04__Billing_Address_PostalCode__c;
				contact.MailingState = payment.asp04__Billing_Address_State__c;

				System.debug(contact);
				Contact foundContact = TU_Utilities.findContact(contact);
				if (foundContact.Id == null && contact.LastName != null) {
					insert contact;
					payment.Contact_TU__c = contact.Id;
					update payment;
				} else {
					payment.Contact_TU__c = foundContact.Id;
					update payment;
				}
			}
		}
	}
	/*
	 * private methods
	 */

	private static String retrievePaymentId(sc_listModel model) {
		asp04__Payment__c payment = new asp04__Payment__c();
		Event_RSVP__c rsvp = new Event_RSVP__c();

		List<asp04__Payment__c> payments = new List<asp04__Payment__c>([SELECT Id, asp04__Amount__c FROM
				asp04__Payment__c WHERE	Order_TU__c = :model.orderId]);

		if (payments.isEmpty()) {
			if (model.rsvpId == null) {
				rsvp = TU_EventRSVPHelper.createRSVPFromUser(null, new Event_RSVP__c(), UserInfo.getUserId());
			} else {
				List<Event_RSVP__c> eventRSVPS = Database.query(TU_Utilities.buildSOQL('Event_RSVP__c', false,
						String.join(TU_EventRSVPHelper.EventRSVPFields, ','), 'Id = \'' + model.rsvpId + '\'', null));
				rsvp = eventRSVPS[0];
			}

			payment.asp04__Amount__c = model.subTotal;
			payment.asp04__Billing_Address_City__c = rsvp.City_TU__c;
			payment.asp04__Billing_Address_Country__c = 'United States'; // hard coded to make sure all Transactions start with United States.
			payment.asp04__Billing_Address_PostalCode__c = rsvp.Zip_TU__c;
			payment.asp04__Billing_Address_State__c = rsvp.State_TU__c;
			payment.asp04__Billing_Address_Street__c = rsvp.Street_TU__c;
			payment.Contact_TU__c = rsvp.Contact_TU__c;
			payment.asp04__Email__c = rsvp.Email_TU__c;
			payment.asp04__First_Name__c = rsvp.FirstName_TU__c;
			payment.asp04__Last_Name__c = rsvp.LastName_TU__c;
			payment.Order_TU__c = model.orderId;
			payment.asp04__Payment_Date__c = Date.today();
			payment.asp04__Payment_Route_Options__c = 'Card';

			insert payment;
		} else {
			payment = payments[0];
			payment.asp04__Amount__c = model.subTotal;
			update payment;
		}

		return payment.Id;

	}

	private static Peak_Response createPaymentSchedule(Peak_Response peakResponse, Decimal quantity, Decimal unitPrice,
			String frequency, Date nextPaymentDate, Date finalPaymentDate) {

		asp04__Authorisation__c authorisation = new asp04__Authorisation__c();
		authorisation.asp04__Payment_Route_Options__c = 'Card';
		authorisation.asp04__Billing_Address_Country__c = 'United States';
		authorisation.Order_TU__c = peakResponse.results[0].Id;

		if (!Peak_Utils.isGuestUser()) {
			User user = [SELECT Contact.Id, FirstName, LastName, Email, GraduationYear_TU__c, LastNameatGraduation_TU__c,
					AlumniID_TU__c, TU_ID_TU__c, Birthday_TU__c, Street, City, State, PostalCode, Country, Gender_TU__c,
					Major_TU__c, Phone FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

			authorisation.asp04__Billing_Address_City__c = user.City;
			authorisation.asp04__Billing_Address_PostalCode__c = user.PostalCode;
			authorisation.asp04__Billing_Address_State__c = user.State;
			authorisation.asp04__Billing_Address_Street__c = user.Street;
			authorisation.Contact_TU__c = user.ContactId;
			authorisation.asp04__Email__c = user.Email;
			authorisation.asp04__First_Name__c = user.FirstName;
			authorisation.asp04__Last_Name__c = user.LastName;
		}

		insert authorisation;

		asp04__PaymentSchedule__c paymentSchedule = new asp04__PaymentSchedule__c();
		paymentSchedule.asp04__Authorisation__c = authorisation.Id;
		paymentSchedule.asp04__Frequency__c = frequency;
		paymentSchedule.asp04__Regular_Amount__c = quantity * unitPrice;
		paymentSchedule.asp04__Next_Payment_Date__c = nextPaymentDate;
		paymentSchedule.asp04__Final_Payment_Date__c = finalPaymentDate;
		paymentSchedule.Order_TU__c = peakResponse.results[0].Id;

		insert paymentSchedule;

		peakResponse.success = true;

		return peakResponse;
	}
	// PriceBook fallback if not specified in Metadata settings - special mode for testing
	private static String getPriceBookId(ss_settings settings)
	{
		String priceBookId = settings.pricebookId;

		// cannot access the pricebook(s) in test mode
		if (String.isBlank(priceBookId)) {
			if (Test.isRunningTest()) { priceBookId = Test.getStandardPricebookId(); } else { priceBookId = [select Id, Name from Pricebook2 where PriceBook2.IsStandard = true limit 1].Id;}
		}
		return priceBookId;
	}

	private static String getRSVPId(String rsvpToken) {
		if (rsvpToken == null) {
			return rsvpToken;
		} else {
			return [SELECT Id FROM Event_RSVP__c WHERE RSVPToken_TU__c = :rsvpToken LIMIT 1].Id;
		}
	}

	private static String getScheduleId(String orderId) {

		List<asp04__PaymentSchedule__c> schedules = new List<asp04__PaymentSchedule__c>(
					[SELECT Id FROM asp04__PaymentSchedule__c WHERE Order_TU__c = :orderId]);

		if (!schedules.isEmpty()) {
			return schedules[0].Id;
		} else {
			return null;
		}
	}

	private static String getOrderFieldsClause()
	{
		String fieldsClause = 'SELECT'
			+ ' Id'
			+ ', Status'
			+ ', AccountId'
			+ ', OwnerId'
			+ ', OrderNumber'
			+ ', TotalAmount'
			+ ', Pricebook2Id'
			+ ', EventRSVP_TU__c'
		    + ', Needs_more_information__c'
		    + ', OrderToken_TU__c'
			+ ', Tickets_Needed_TU__c';

		return fieldsClause;
	}

	private static String getOrderFromClause()
	{
		String fromClause = ' FROM Order';

		return fromClause;
	}

	private static String getOrderWhereClause(String userId, String rsvpId, String orderToken)	{

		String whereClause = ' WHERE status = \'';
		whereClause += STATUS_DRAFT;
		whereClause += '\'';
		if (rsvpId == null && orderToken == null && !Peak_Utils.isGuestUser()) {
			whereClause += ' and OwnerId = \'';
			whereClause += userId;
			whereClause += '\'';
			whereClause += ' and EventRSVP_TU__c = null';
		} else if (rsvpId != null) {
			whereClause += ' and (OwnerId = \'';
			whereClause += userId;
			whereClause += '\'';
			whereClause += ' and EventRSVP_TU__c = \'';
			whereClause += rsvpId;
			whereClause += '\')';
		} else {
			whereClause += ' and OrderToken_TU__c = \'';
			whereClause += orderToken;
			whereClause += '\'';
		}


		system.debug('Order where clause: ' + whereClause);

		return whereClause;
	}

	private static String getOrderItemFieldsClause()
	{
		String fieldsClause = 'SELECT'
			+ ' Id'
			+ ', OrderItemNumber'
			+ ', Product2.Id'
			+ ', Product2.Name'
			+ ', Product2.ProductCode'
			+ ', Product2.Points__c'
			+ ', Product2.Family'
			+ ', Product2.External_Image_URL__c'
			+ ', UnitPrice'
			+ ', Quantity'
			+ ', PricebookEntryId'
			+ ', Product2.AllowRecipient_TU__c'
			+ ', Product2.InstructionsRequired_TU__c'
			+ ', Product2.SpecialMessageAllowed_TU__c'
			+ ', PricebookEntry.UserDefinedAmountAllowed_TU__c'
			+ ', RecipientName_TU__c'
			+ ', SpecialInstructions_TU__c'
			+ ', SpecialMessage_TU__c'
		    + ', OrderId'
		    + ', Product2.Ticket_Product_TU__c';


		return fieldsClause;
	}

	private static String getOrderItemFromClause()
	{
		return ' FROM OrderItem';
	}

	private static String getOrderItemWhereClause(String orderId)
	{
		return ' WHERE OrderId = \'' + orderId + '\'';
	}
}
