/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 7/18/17.
 */

public with sharing class ss_settings {

	static final String FIELD_SEPARATOR   = ',';
	static final String QUANTITY_DEFAULTS = '1,2,3,4,5,6,7,8,9,10,20,30,50,100';

	@AuraEnabled
	public Boolean hideAddToCart {
		get;
		private set;
	}

	@AuraEnabled
	public Boolean hideImages {
		get;
		private set;
	}

	@AuraEnabled
	public Boolean hideUnitPrice {
		get;
		set;
	}

	@AuraEnabled
	public Boolean usePoints {
		get;
		private set;
	}

	@AuraEnabled
	public String pricebookId {
		get;
		private set;
	}

	@AuraEnabled
	public String accountId {
		get;
		private set;
	}

	@AuraEnabled
	public Boolean suggestEmail {
		get;
		private set;
	}

	@AuraEnabled
	public List<String> familyIds {
		get;
		private set;
	}

	@AuraEnabled
	public List<String> quantityList {
		get;
		private set;
	}

	private void getCustomSettings() {
		SS_Product_Settings__mdt settings = [
				SELECT
					Account_Id__c,
					Hide_Add_to_Cart__c,
					Hide_Images__c,
					Hide_Unit_Price__c,
					Pricebook_Id__c,
					Product_Family_List_IDs__c,
					Suggest_Email__c,
					Use_Points__c,
					Quantity_List__c
				FROM SS_Product_Settings__mdt
				WHERE DeveloperName = 'Default'
		];

		if (settings != null) {
			this.accountId      = settings.Account_Id__c;
			this.hideAddToCart  = settings.Hide_Add_to_Cart__c;
			this.hideImages     = settings.Hide_Images__c;
			this.hideUnitPrice  = settings.Hide_Unit_Price__c;
			this.pricebookId    = settings.Pricebook_Id__c;
			this.usePoints      = settings.Use_Points__c;
			this.suggestEmail   = settings.Suggest_Email__c;
			this.familyIds      = String.isNotBlank(settings.Product_Family_List_IDs__c) ? settings.Product_Family_List_IDs__c.split(FIELD_SEPARATOR) : new List<String>();
			this.quantityList   = String.isNotBlank(settings.Quantity_List__c) ? settings.Quantity_List__c.split(FIELD_SEPARATOR) : QUANTITY_DEFAULTS.split(FIELD_SEPARATOR);
		}
	}

	public ss_settings() {
		getCustomSettings();
	}

	public ss_settings(String accountId, Boolean usePoints, String priceBookId) {
		this.accountId      = accountId;
		this.hideAddToCart  = false;
		this.hideImages     = false;
		this.hideUnitPrice  = false;
		this.pricebookId    = priceBookId;
		this.usePoints      = usePoints;
		this.suggestEmail   = false;
		this.familyIds      = null;
		this.quantityList   = null;
	}
}
