// ===================
// Test Peak Utils
// ===================
@isTest
public with sharing class Peak_UtilsTest {

	@testSetup
	static void testSetup() {
		Contact testContact = Peak_TestUtils.createTestContact();
	}

	// Test building a formatted string from a set of strings
	@isTest
	public static void testBuildStringFromSet(){
		Peak_Utils utils = new Peak_Utils();
		Set<String> sourceSet = new Set<String>();
		sourceSet.add('Hello');
		sourceSet.add('There');
		system.assertEquals('Hello, There', utils.buildStringFromSet(sourceSet)); // test that this is building a string from a set properly
	}

	@isTest
	public static void testGetUser(){
		// Set up and run as a standard user
		List<Contact> testContacts = [SELECT Id from Contact where Email = :Peak_TestConstants.STANDARD_EMAIL];

		User testUser = Peak_TestUtils.createStandardUserNoContact();
		testUser.ContactId = testContacts[0].Id;
		insert testUser;

		system.runAs(testUser){
			system.assertEquals(testUser.Id,Peak_Utils.getUser().Id);
		}
	}

	@isTest
	public static void testIsNullOrEmpty() {
		// Assert return true for empty list
		List<String> stringList = new List<String>();
		system.assertEquals(Peak_Utils.isNullOrEmpty(stringList),true);

		// Assert return false for not empty list
		stringList.add(Peak_TestConstants.ACCOUNT_NAME);
		system.assertEquals(Peak_Utils.isNullOrEmpty(stringList),false);
	}

	@isTest
	public static void testGetSitePrefix() {
		system.assert(Peak_Utils.getSitePrefix() != null);
	}

	@isTest
	public static void testCreateAttachment() {
		// Set up and run as a standard user
		List<Contact> testContacts = [SELECT Id from Contact where Email = :Peak_TestConstants.STANDARD_EMAIL];

		User testUser = Peak_TestUtils.createStandardUserNoContact();
		testUser.ContactId = testContacts[0].Id;
		insert testUser;

		Attachment testAttachment = Peak_TestUtils.createAttachment(testUser.Id);
		system.assert(testAttachment != null);
	}

	@isTest
	public static void testGetPicklistValues(){
		Peak_Utils peakUtils = new Peak_Utils();
		List<String> options = peakUtils.getPicklistValues('User','LanguageLocaleKey');
		System.assert(options.size()>0);
	}

	@isTest
	public static void testCreateListFromMultiPicklist(){

		String multiPicklistString = 'string1;string2;string3';

		List<String> multiPicklistList = Peak_Utils.createListFromMultiPicklist(multiPicklistString);

		system.assertEquals(multiPicklistList.get(0), 'string1');
		system.assertEquals(multiPicklistList.get(1), 'string2');
		system.assertEquals(multiPicklistList.get(2), 'string3');

	}

	@isTest
	public static void testDoesStringContainListItem(){

		List<String> compareList = new List<String>();
		compareList.add('string1');
		compareList.add('string2');

		//Assert list contains target string
		system.assert(Peak_Utils.doesStringContainListItem(compareList, 'string1'));

		//Assert list does not contain target string
		system.assert(!Peak_Utils.doesStringContainListItem(compareList, 'string3') );
	}
}