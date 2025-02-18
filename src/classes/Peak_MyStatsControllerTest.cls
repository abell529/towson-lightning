@isTest
public with sharing class Peak_MyStatsControllerTest {

    @isTest
    public static void testPeakStatsController() {

        // Assert simple static test
    	system.assertEquals(Peak_MyStatsController.getSampleStatApex().figure1,2);

        // Test user
        User user = Peak_TestUtils.createStandardUser();
        insert user;

        // Insert two opporunities for user, 1 open, 1 closed
        Opportunity closedOpportunity = Peak_TestUtils.createOpportunity(user.id,Peak_TestConstants.FORECAST_CATEGORY_CLOSED);
        insert closedOpportunity;
        Opportunity openOpportunity = Peak_TestUtils.createOpportunity(user.id,Peak_TestConstants.FORECAST_CATEGORY_COMMIT);
        insert openOpportunity;

        test.startTest();

        System.runAs(user){
            // Assert 1 closed opp found
            system.assertEquals(0,Peak_MyStatsController.getMyClosedWonOpps().figure1);
            // Assert 1 open opp found
            system.assertEquals(0,Peak_MyStatsController.getMyNewOpps().figure1);
        }
        test.stopTest();

    }

}