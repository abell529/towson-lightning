/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 7/14/17.
 */

public with sharing class pc_model {

	// -----------------------------------------------------------
	// Object wrapper

	@AuraEnabled
	public sObject record {
		get;
		set;
	}

	@AuraEnabled
	public String id, productId, name, description, productCode, family, priceBookId;

	@AuraEnabled
	public Decimal unitPrice, points;

	@AuraEnabled
	public String imageUrl, externalProductUrl, recipientName, specialInstructions, specialMessage;

	@AuraEnabled
	public Boolean featured, userDefinedAmountAllowed, allowRecipient, instructionsRequired, specialMessageAllowed, isSchedulable ;

	@AuraEnabled
	public Integer sequence;

	public pc_model(PricebookEntry entry, String communityUrl, Id imageId) {
		this.record             = entry;
		this.id                 = entry.Id;
		this.priceBookId        = entry.Pricebook2Id;
		this.productId          = entry.Product2.Id;
		this.name               = entry.Product2.Name;
		this.description        = entry.Product2.Description;
		this.productCode        = entry.ProductCode;
		this.family             = entry.Product2.Family;
		this.unitPrice          = entry.UnitPrice;
		this.points             = entry.Product2.Points__c;
		this.externalProductUrl = entry.Product2.External_Product_URL__c;
		this.featured           = entry.Product2.Featured__c;
		this.sequence           = Integer.valueOf(entry.Product2.Sequence__c);
		this.allowRecipient     = entry.Product2.AllowRecipient_TU__c;
		this.instructionsRequired = entry.Product2.InstructionsRequired_TU__c;
		this.specialMessageAllowed = entry.Product2.SpecialMessageAllowed_TU__c;
		this.isSchedulable      = entry.Product2.RecurringProduct_TU__c;
		this.recipientName      = null;
		this.specialInstructions = null;
		this.specialMessage     = null;
		this.userDefinedAmountAllowed = entry.UserDefinedAmountAllowed_TU__c;

		// build the image URL
		if (imageId != null && String.isNotBlank(imageId)) {
			this.imageUrl = communityUrl
					+ ss_contentDocument.CHATTER_FILE_LOCATION
					+ imageId
					+ ss_contentDocument.CHATTER_FILE_PARAMS;
		}
		else {
			this.imageUrl = entry.Product2.External_Image_URL__c;
		}
	}


	// -------------------------------------------------------------
	// Utility functions
	// -------------------------------------------------------------
	public static String getCommunityUrl() {
		try {
			String url = Network.getLoginUrl(Network.getNetworkId());
			return url.substring(0, url.lastIndexOf('/s/'));
		} catch (Exception e) {
			return '..';
		}
	}

	public void dumpModel(String title)
	{
		System.debug('Dump pc_model: ' + title);
		System.debug('  id               : ' + this.id);
		System.debug('  name             : ' + this.name);
		System.debug('  productId        : ' + this.productId);
		System.debug('  priceBookId      : ' + this.priceBookId);
	}
}
