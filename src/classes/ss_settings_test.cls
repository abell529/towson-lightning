/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francois korb on 7/18/17.
 */

@IsTest
public with sharing class ss_settings_test {

	@IsTest
	static void testCommon() {
		ss_settings settings = new ss_settings();

		System.assertNotEquals(null, settings);
		//System.assertEquals(null, settings.accountId);
		System.assertNotEquals(null, settings.usePoints);
		//System.assertEquals(null, settings.pricebookId);
		System.assertNotEquals(null, settings.hideAddToCart);
		System.assertNotEquals(null, settings.hideImages);
		System.assertNotEquals(null, settings.hideUnitPrice);
	}

	@IsTest
	static void testUsePoints() {
		ss_settings settings = new ss_settings(null, true, null);

		System.assertEquals(null, settings.accountId);
		system.assertEquals(true, settings.usePoints);
		System.assertEquals(null, settings.pricebookId);
		system.assertEquals(false, settings.hideAddToCart);
		system.assertEquals(false, settings.hideImages);
		system.assertEquals(false, settings.hideUnitPrice);
	}
}
