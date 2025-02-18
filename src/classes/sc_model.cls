/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 8/4/17.
 */

// -----------------------------------------------------------
// Shopping Cart Object Wrapper

public with sharing class sc_model {

	@AuraEnabled
	public sObject record {
		get;
		set;
	}

	@AuraEnabled
	public String id, productId, externalUrl, name, family, productCode, imageUrl, recipientName, specialInstructions,
			specialMessage;

	@AuraEnabled
	public Decimal quantity, unitPrice, unitTotal;

	@AuraEnabled
	public Boolean allowRecipient, instructionsRequired, specialMessageAllowed, userDefinedAmountAllowed;

	public sc_model(OrderItem item, String communityUrl, Id imageId) {
		this.record      = item;
		this.id          = item.id;
		this.productId   = item.Product2Id;
		this.quantity    = item.Quantity;
		this.unitPrice   = item.UnitPrice;
		this.name        = item.Product2.Name;
		this.productCode = item.Product2.ProductCode;
		this.family      = item.Product2.Family;
		this.allowRecipient = item.Product2.AllowRecipient_TU__c;
		this.instructionsRequired = item.Product2.InstructionsRequired_TU__c;
		this.specialMessageAllowed = item.Product2.SpecialMessageAllowed_TU__c;
		this.userDefinedAmountAllowed = item.PricebookEntry.UserDefinedAmountAllowed_TU__c;
		this.unitTotal   = quantity * unitPrice;
		this.recipientName = item.RecipientName_TU__c;
		this.specialInstructions = item.SpecialInstructions_TU__c;
		this.specialMessage = item.SpecialMessage_TU__c;

		// build the image URL
		if (imageId != null && String.isNotBlank(communityUrl)) {
			this.imageUrl = communityUrl + ss_contentDocument.CHATTER_FILE_LOCATION + imageId + ss_contentDocument.CHATTER_FILE_PARAMS;
			system.debug('imageUrl = ' + this.imageUrl);
		}
		else {
			this.imageUrl = item.Product2.External_Image_URL__c;
		}

	}

	public sc_model()
	{
		this.record = null;
	}

	public void dumpModel(String title)
	{
		System.debug('Dump sc_model: ' + title);
		System.debug('  Id      : ' + this.id);
		System.debug('  Prod Id : ' + this.productId);
		System.debug('  Name    : ' + this.name);
		System.debug('  qty     : ' + this.quantity);
	}
}
