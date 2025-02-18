/* Copyright ©2016-2017 7Summits Inc. All rights reserved. */

/**
 * Created by francoiskorb on 8/11/17.
 */

@isTest
private class SS_Members_TopicsController_Test {

	static final Integer TEST_TOPIC_COUNT = 3;

	@TestSetup
	private static void setupTestData(){
		List<Topic> testTopics = new List<Topic>();

		for (Integer i =0; i < TEST_TOPIC_COUNT; i++) {
			testTopics.add(new Topic (Name = 'Topic' + i));
		}

		insert testTopics;
	}

	private static testMethod void testGetTopicMap() {
		Test.startTest();

		Map<String, String> topicMap = SS_Members_TopicsController.getTopics();
		System.assertEquals(TEST_TOPIC_COUNT, topicMap.size());
		System.Debug('Topic ' + topicMap);
		
		Test.stopTest();
	}
}