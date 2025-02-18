/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 7/18/17.
 */

public with sharing class pc_listController {

	final static Decimal DEFAULT_PAGE_SIZE = 10;

	final static String SORT_BY_NAME     = 'Product Name';
	final static String SORT_BY_FAMILY   = 'Product Family';
	final static String SORT_BY_PCODE    = 'Product Code';
	final static String SORT_BY_PRICE    = 'Unit Price';
	final static String SORT_BY_SEQUENCE = 'Sequence__c';

	//-------------------------------------------------------------------------------------------------
	// Public  methods
	//-------------------------------------------------------------------------------------------------

	@AuraEnabled
	public static pc_listModel getProductsFeatured(
			Decimal pageSize,
			Decimal currentPage) {
		ss_settings  settings = new ss_settings();

		return getProducts(settings, pageSize, currentPage, true, '', '', SORT_BY_SEQUENCE, 0, 0, null);
	}

	@AuraEnabled
	public static pc_listModel getProductsById(
			Decimal pageSize,
			Decimal currentPage,
			List<String> ids) {
		ss_settings  settings = new ss_settings();

		return getProducts(settings, pageSize, currentPage, false, '', '', '', 0, 0, ids);
	}

	@AuraEnabled
	public static pc_model getProductById(String productId)
	{
		ss_settings settings = new ss_settings();
		return getProductById(settings, productId);
	}

	@AuraEnabled
	public static pc_model getProductById(ss_settings settings, String productId)
	{
		List<String> ids = new List<String>();
		ids.add(productId);

		pc_listModel model = getProducts(settings, 1, 1, false, '', '', '', 0, 0, ids);
		System.debug('getProductById ' + '(' + productId + ')' + ' items ' + model.items.size());

		return model.items.size() > 0 ? model.items[0] : null;
	}

	@AuraEnabled
	public static pc_listModel getProducts(
			Decimal pageSize,
			Decimal currentPage,
			String searchFilter,
			String familyFilter,
			String sortOrder,
			Decimal minimumPrice,
			Decimal maximumPrice) {
		ss_settings  settings = new ss_settings();

		return getProducts(settings, pageSize, currentPage, false, searchFilter, familyFilter, sortOrder, minimumPrice, maximumPrice, null);
	}

	/*
		Get Event RSVP Details
	*/
	@AuraEnabled
	public static pc_listModel getEventProducts(String rsvpToken, Decimal pageSize,	Decimal currentPage,
			String searchFilter, String familyFilter, String sortOrder,	Decimal minimumPrice, Decimal maximumPrice)  {
		ss_settings  settings = new ss_settings();

		List<Event_RSVP__c> eventRSVPS = new List<Event_RSVP__c>([SELECT Id, Event__c,
				Event__r.AssociatedProductCode_TU__c, Event__r.Name, Contact_TU__c, User__c,Response__c FROM
				Event_RSVP__c WHERE RSVPToken_TU__c = :rsvpToken LIMIT 1]);

		if (!eventRSVPS.isEmpty()) {
			Event_RSVP__c thisRsvp = eventRSVPS[0];
			List<Event_RSVP__c> rsvpList = new List<Event_RSVP__c>([
					SELECT Id, Event__c, FAComplete_TU__c, RSVPToken_TU__c,
							Event__r.Enable_Pricing_Payment__c, Response__c, ParentRSVP_TU__c,
							Event__r.AssociatedProductCode_TU__c
					FROM Event_RSVP__c
					WHERE Id = :thisRsvp.Id OR ParentRSVP_TU__c = :thisRsvp.Id ORDER BY ParentRSVP_TU__c]);

			createTicketItems(rsvpToken, thisRsvp.Event__r.AssociatedProductCode_TU__c, rsvpList.size());
			searchFilter = thisRsvp.Event__r.AssociatedProductCode_TU__c;
		}

		return getProducts(settings, pageSize, currentPage, false, searchFilter, familyFilter, sortOrder, minimumPrice,
				maximumPrice, null);
	}

	//--------------------------------------------------------------------------------------------------
	// Test methods
	//--------------------------------------------------------------------------------------------------
	public static pc_listModel getProducts(
			Boolean test,
			ss_settings settings,
			Decimal pageSize,
			Decimal currentPage,
			Boolean featured,
			String searchFilter,
			String familyFilter,
			String sortOrder,
			Decimal minimumPrice,
			Decimal maximumPrice,
			List<String> ids) {

		return getProducts(settings, pageSize, currentPage, featured, searchFilter, familyFilter, sortOrder, minimumPrice, maximumPrice, ids);
	}

	//--------------------------------------------------------------------------------------------------
	// Private methods
	//--------------------------------------------------------------------------------------------------

	private static void createTicketItems(String rsvpToken, String associatedProductCode, Integer ticketQuantity) {

		ss_settings  settings = new ss_settings();
		String       userId   = UserInfo.getUserId();
		associatedProductCode = '%' + associatedProductCode + '%';


		List<OrderItem> orderItems = new List<OrderItem>([SELECT Id FROM OrderItem WHERE
				Order.EventRSVP_TU__r.RSVPToken_TU__c = :rsvpToken AND Product2.Ticket_TU__c=true]);
		if (orderItems.isEmpty()) {
			for (PricebookEntry entry : [
					SELECT Id, Product2Id, UnitPrice
					FROM PricebookEntry
					WHERE IsActive = true AND Product2.IsActive = true AND ProductCode LIKE :associatedProductCode AND
					Product2.Ticket_TU__c = true
					ORDER BY UnitPrice
			]) {

				sc_listController.updateOrder(userId, settings, entry.Product2Id, ticketQuantity, 'add', rsvpToken,
						null, entry.UnitPrice);
			}

			Order rsvpOrder = new Order();
			try {
				rsvpOrder = [
						SELECT Id, Tickets_Needed_TU__c
						FROM Order
						WHERE
								EventRSVP_TU__r.RSVPToken_TU__c = :rsvpToken
						LIMIT 1
				];
				rsvpOrder.Tickets_Needed_TU__c = ticketQuantity;
				update rsvpOrder;
			} catch (Exception e) {

			}

		}

	}

	private static pc_listModel getProducts(
			ss_settings  settings,
			Decimal pageSize,
			Decimal currentPage,
			Boolean featured,
			String searchFilter,
			String familyFilter,
			String sortOrder,
			Decimal minimumPrice,
			Decimal maximumPrice,
			List<String> ids) {

		if (pageSize == null || pageSize < 1) {
			pageSize = DEFAULT_PAGE_SIZE;
		}

		if (currentPage == null || currentPage < 1) {
			currentPage = 1;
		}

		pc_listModel listModel  = new pc_listModel();

		String pricebookId      = settings != null ? settings.pricebookId : '';

		listModel.pageSize      = pageSize;
		listModel.pageCurrent   = currentPage;
		listModel.hideImages    = settings.hideImages;
		listModel.hideAddToCart = settings.hideAddToCart;
		listModel.hideUnitPrice = settings.hideUnitPrice;
		listModel.usePoints     = settings.usePoints;
		listModel.quantityList  = settings.quantityList;
		listModel.pricebookId   = pricebookId;

		Decimal searchOffset    = pageSize * (currentPage - 1);
		String fromClause       = getFromClause();
		String orderByClause    = getOrderByClause(settings.usePoints, sortOrder);
		String whereClause      = getWhereClause(
									pricebookId,
									featured,
									settings.usePoints,
									searchFilter,
									familyFilter,
									minimumPrice,
									maximumPrice,
									ids);

		Decimal total           = getProductCount(fromClause, whereClause);

		if (total < 1) {
			return listModel;
		}

		listModel.total = total;
		listModel.pageCount = Math.max(Math.ceil(total / pageSize), 1);

		Integer recordLimit     = (Integer) pageSize;
		Integer recordOffset    = (Integer) searchOffset;
		String limitClause      = ' LIMIT ' + recordLimit;
		String offsetClause     = ' OFFSET ' + recordOffset;

		String query = getFieldsClause()
				+ fromClause
				+ whereClause
				+ orderByClause
				+ limitClause
				+ offsetClause;

		Map<Id, PricebookEntry> productMap = new Map<Id, PricebookEntry>((List<PricebookEntry>) Database.query(query));

		List<Id> productIds = new List<Id>();

		for (PricebookEntry product : productMap.values()) {
			productIds.add(product.Product2.Id);
		}

		List<ContentDocumentLink> documentLinkList = ss_contentDocument.getContentDocumentLinks(productIds);
		List<pc_model>            products         = new List<pc_model>();
		String                    communityUrl     = pc_model.getCommunityUrl();

		for (PricebookEntry product : productMap.values()) {
			ContentDocumentLink link = ss_contentDocument.containsEntityId(documentLinkList, product.Product2.Id);

			products.add(new pc_model(product, communityUrl, link == null ? null : link.ContentDocument.LatestPublishedVersionId));
		}

		listModel.items           = products;
		listModel.pageHasNext     = (recordLimit * currentPage) < total;
		listModel.pageHasPrevious = searchOffset > 0;

		return listModel;
	}

	private static String getFromClause() {
		return ' FROM PricebookEntry';
	}

	private static String getFieldsClause() {
		String query = 'SELECT Id'
			+ ', Pricebook2Id'
			+ ', Product2.Id'
			+ ', Product2.Name'
			+ ', UnitPrice'
			+ ', ProductCode'
			+ ', Product2.Description'
			+ ', Product2.Family'
			+ ', Product2.Featured__c'
			+ ', Product2.Sequence__c'
			+ ', Product2.External_Image_URL__c'
			+ ', Product2.External_Product_URL__c'
			+ ', Product2.Points__c'
			+ ', Product2.AllowRecipient_TU__c'
			+ ', Product2.InstructionsRequired_TU__c'
			+ ', Product2.SpecialMessageAllowed_TU__c'
			+ ', Product2.RecurringProduct_TU__c'
			+ ', UserDefinedAmountAllowed_TU__c';

		return query;
	}

	private static String getOrderByClause(Boolean usePoints, String sortOrder) {
		String orderBy = '';

		if (String.isNotBlank(sortOrder)) {
			orderBy = ' ORDER BY ';

			if (sortOrder == SORT_BY_NAME) {
				orderBy += 'Product2.Name';
			}

			if (sortOrder == SORT_BY_FAMILY) {
				orderBy += 'Product2.Family';
			}

			if (sortOrder == SORT_BY_PCODE) {
				orderBy += 'ProductCode';
			}

			if (sortOrder == SORT_BY_PRICE) {
				orderBy += usePoints ? 'Product2.Points__c' : 'UnitPrice';
			}

			if (sortOrder == SORT_BY_SEQUENCE) {
				orderBy += 'Product2.Sequence__c';
			}
		}

		return orderBy;
	}

	private static String getWhereClause(
			String pricebookId,
			Boolean featured,
			Boolean usePoints,
			String searchFilter,
			String familyFilter,
			Decimal minPrice,
			Decimal maxPrice,
			List<String> productIds) {

		String whereClause = String.isNotBlank(pricebookId) ? ' WHERE PriceBook2.Id = \'' + pricebookId + '\'' : ' WHERE PriceBook2.IsStandard = true';

		// problematic in Unit tests when using IsStandard
		if (Test.isRunningTest()) {
//			whereClause = ' WHERE PriceBook2.IsActive = true';
			whereClause = ' WHERE PriceBook2Id != null';
		}

		// only active products
		whereClause += ' AND Product2.IsActive = true';

		if (productIds != null && productIds.size() > 0) {
			whereClause += ' AND Product2.Id IN';

			String temp = ' (';

			for (Id itemId : productIds) {
				temp += '\'' + itemId + '\', ';
			}

			whereClause += temp.contains(', ') ? temp.substring(0, temp.lastIndexOf(', ')) + ')' : '';
		}

		if (featured) {
			whereClause += ' AND Product2.Featured__c = true';
		}

		// search on product code
		if (String.isNotBlank(searchFilter)) {
			whereClause += ' AND ProductCode LIKE \'%' + searchFilter + '%\'';
		}

		// search on product family
		if (String.isNotBlank(familyFilter) && familyFilter != Label.ss_pc_selectAll) {
			whereClause += ' AND Product2.Family = \'' + familyFilter + '\'';
		}

		if (minPrice > 0) {
			whereClause += usePoints ? ' AND Product2.Points__c >= ' : ' AND UnitPrice >= ';
			whereClause += minPrice;
		}

		if (maxPrice > 0) {
			whereClause += usePoints ? ' AND Product2.Points__c <= ' : ' AND UnitPrice <= ';
			whereClause += maxPrice;
		}

		return whereClause;
	}

	private static Decimal getProductCount(String fromClause, String whereClause) {
		String countQuery = 'SELECT count()' + fromClause + whereClause;
		Decimal total = Database.countQuery(countQuery);

		return total;
	}
}
