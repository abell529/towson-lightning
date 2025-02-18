/**
 * Created by francoiskorb on 10/19/17.
 */

@isTest
private class SVNSUMMITS_MembersFilterBatch_Test
{

	// Can only be called once
	@isTest
	public static void testFilterBatch()
	{
		Test.startTest();

		SVNSUMMITS_MembersFilterBatch filterBatch = new SVNSUMMITS_MembersFilterBatch('Country');

		Id batchProcessId = Database.executeBatch(filterBatch,1000);
		System.assertNotEquals(null, batchProcessId);

		Test.stopTest();
	}
}