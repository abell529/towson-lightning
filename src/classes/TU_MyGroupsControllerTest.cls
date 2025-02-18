/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by Kaj Petersen, 7Summits on 5/23/18.
 */

@IsTest
private class TU_MyGroupsControllerTest {
    // Note: For Group Membership, ensure that the type of user matches the type of group. Salesforce prevents
    // Internal Chatter Group (No Network Id) <=> Internal User (Has Standard/Internal Profile)
    // Community Chatter Group (Has Network Id) <=> Community User (Has Community/Partner profile)

    @testSetup
    static void testSetup() {
        Contact testContact = Peak_TestUtils.createTestContact();
    }

    @isTest
    public static void testIsNotInGroup() {
        // Create user
        List<Contact> testContacts = [SELECT Id from Contact where Email = :Peak_TestConstants.STANDARD_EMAIL];

        User testUser = Peak_TestUtils.createStandardUserNoContact();
        testUser.ContactId = testContacts[0].Id;
        insert testUser;

        // Make sure they're not yet in a group
        System.runAs(testUser){
            System.assertEquals(TU_MyGroupsController.isInAGroup(testUser.Id),false);
        }

    }

    @isTest
    public static void testGetFeaturedGroup() {

        // Insert a collab group
        CollaborationGroup testGroup = Peak_TestUtils.createChatterGroup(Peak_TestConstants.TEST_GROUPNAME,'Public');
        insert testGroup;

        // Call action and cast result as Collab Group
        Peak_Response peakResponse = TU_MyGroupsController.getFeaturedGroup(testGroup.Id);
        CollaborationGroup foundGroup = (CollaborationGroup)peakResponse.results[0];

        // Test that the collab group name is accurate
        System.assertEquals(foundGroup.Name,Peak_TestConstants.TEST_GROUPNAME);
    }

    @isTest
    public static void testGetMyGroups() {
        // Create user
        List<Contact> testContacts = [SELECT Id from Contact where Email = :Peak_TestConstants.STANDARD_EMAIL];

        User testUser = Peak_TestUtils.createStandardUserNoContact();
        testUser.ContactId = testContacts[0].Id;
        insert testUser;

        System.runAs(testUser){
            System.assertEquals(TU_MyGroupsController.getMyGroups(testUser.Id,'3').results.size(),0);
        }
    }


    @isTest
    public static void testGetPrefix() {
        system.assert(TU_MyGroupsController.getSitePrefix() != null);
    }
}