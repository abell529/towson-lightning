/* Copyright © 2016-2018 7Summits, Inc. All rights reserved. */
@isTest
public class Peak_WelcomeMessageControllerTest {

    @isTest
    public static void testGetCurrentUser() {
        User user = Peak_TestUtils.createStandardUser();

        insert user;

        system.runAs(user) {
            system.assertEquals(user.Id, Peak_WelcomeMessageController.getCurrentUser().Id);
        }
    }

    @isTest
    public static void testGetAccountInfo() {
        User user = Peak_TestUtils.createStandardUser();

        insert user;

        system.runAs(user) {
            system.assertEquals(user.Id, Peak_WelcomeMessageController.getAccountInfo().user.Id);
        }
    }

}