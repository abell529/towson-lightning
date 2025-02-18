/* Copyright ©2016-2017 7Summits Inc. All rights reserved. */

/**
* \arg ClassName		: SVNSUMMITS_EventListController
* \arg CreatededBy	  :
* \arg Dscription	   : Apex class for lightning components for Events records displaying list view, featured, featured 1+4
*						 and creating Event__c and Event_RSVP__c records
**/
global with sharing class SVNSUMMITS_EventListController
{
	private static final Integer DEFAULT_LIST_SIZE = 50;
	private static final Integer DEFAULT_PAGE_VALUE = 1;


	global static Id netwrkId = TU_Utilities.getCommunityNetworkId();

	public class customException extends Exception
	{
	}

	// Set of fields used for checking TopicAssignment fields
	private static String [] TopicAssigmtAccessFields = new String []
	{
		'EntityId',
		'TopicId'
	};

	// Set of fields used for checking access to Topic fields
	private static String [] TopicAccessFields = new String []
	{
		'Name',
		'Id'
	};

	// Set of fields used for inserting TopicAssignment fields
	private static String [] TopicAssigmtInsertFields = new String []
	{
		'EntityId',
		'TopicId'
	};

	// Set of fields used for inserting fields while creating Events
	private static String [] eventInsertFields = new String []
	{
		'NetworkId__c',
		'Start_DateTime__c',
		'End_DateTime__c',
		'All_Day_Event__c',
		'Details__c',
		'Location_Address__c',
		'Location_Name__c',
		'Ticket_Price__c',
		'Venue_Information__c',
		'Location_URL__c',
		'RSVP_URL_TU__c',
		'Payment_URL__c',
		'GroupId__c'
	};

	// Set of fields used for fetching Event records
	private static String [] EventAccessFields = new String []
	{
		'Id',
		'Name',
		'All_Day_Event__c',
		'Details__c',
		'Enable_Pricing_Payment__c',
		'Enable_RSVP__c',
		'End_DateTime__c',
		'Location_Address__c',
		'Location_Name__c',
		'Location_URL__c',
		'RSVP_URL_TU__c',
		'NetworkId__c',
		'Number_of_Attendees__c',
		'Payment_URL__c',
		'RSVP_Count_Threshold__c',
		'Start_DateTime__c',
		'Ticket_Price__c',
		'Venue_Information__c',
		'GroupId__c'
	};

	// Set of fields used for checking access to Attachment records
	private static String [] AttachmentAccessFields = new String []
	{
		'Id',
		'Name'
	};

	// Set of fields used for inserting Attachment records
	private static String [] AttachmentInsertFields = new String []
	{
		'parentId',
		'Body',
		'Name',
		'ContentType'
	};


	private static String nameSpace
	{
		get
		{
			if (nameSpace == null)
			{
				String ns = getNameSpacePrefix();
				nameSpace = ns == null ? '' : ns + '__';
			}
			return nameSpace;
		}
	}

	@AuraEnabled
	global static String getNameSpacePrefix()
	{
		return SVNSUMMITS_EventBaseController.getModel().namespacePrefix;
	}
	@AuraEnabled
	global static String getSitePrefix()
	{
		return System.Site.getPathPrefix();
	}

	@AuraEnabled
	global static String getSessionId()
	{
		return String.isEmpty(UserInfo.getSessionId()) ? '' : UserInfo.getSessionId();
	}

	@AuraEnabled
	global static Boolean userAuthorizedToPost()
	{
		try
		{
			Events_Settings__mdt setting =
			[
				SELECT PermissionSetName__c
				FROM Events_Settings__mdt
				WHERE DeveloperName = 'Default'
			];

			System.debug('userAuthorizedToPost name = ' + setting.PermissionSetName__c);
			return [
				SELECT count()
				FROM PermissionSetAssignment
				WHERE AssigneeId = :Userinfo.getUserId()
				AND PermissionSet.Name = :setting.PermissionSetName__c
			] > 0;
		}
		catch (Exception e)
		{
			system.debug(System.LoggingLevel.ERROR, 'Events_Settings__mdt not configured');
		}

		return false;
	}

	/*
		* MethodName		: deleteAttachment
		* param			 : eventRecordId
		* Description	   : Method for deleting the first attachment for a particular record when user selects another record in Edit Detail page.
	*/
	@AuraEnabled
	global static List<Attachment> deleteAttachment(String eventRecordId)
	{
		List<Attachment> attachments = [select id from Attachment where parentId = :eventRecordId];
		if (!attachments.isEmpty())
		{
			delete attachments;
		}
		return attachments;
	}

	/*
		* MethodName		: isObjectCreatable
		* param			 :
		* Description	   : Method to check whether Event__c object is creatable or not.
	*/
	@AuraEnabled
	global static Boolean isObjectCreatable()
	{
		if (Schema.SObjectType.Event__c.isCreateable())
		{
			return true;
		}
		return false;
	}

	/*
		* MethodName		: isObjectEditable
		* param			 :
		* Description	   : Method to check whether Event__c object is Updateable or not.
	*/
	@AuraEnabled
	global static Boolean isObjectEditable()
	{
		Boolean isEditEnabled = false;
		if (Schema.SObjectType.Event__c.isUpdateable())
		{
			isEditEnabled = true;
		}
		return isEditEnabled ;
	}

	@AuraEnabled
	global static Boolean isRecordEditable(string eventRecordId)
	{
		List<UserRecordAccess> userRecordAccess = new List<UserRecordAccess>();

		userRecordAccess = [select HasEditAccess, RecordId from UserRecordAccess where RecordId = :eventRecordId and userId = :UserInfo.getUserId()];

		if (!userRecordAccess.isEmpty())
		{
			if (userRecordAccess[0].HasEditAccess)
				return true;
		}

		return false;
	}

	/*
		* MethodName		: saveEvents
		* param			 : eventObj, strfilterByTopic, allDayEventStartDate, allDayEventEndDate
		* Description	   : Method for saving all event records for create as well ad detail page.
	*/
	@AuraEnabled
	global static Event__c saveEvents(Event__c eventObj, String strfilterByTopic, String allDayEventStartDate, String allDayEventEndDate)
	{
		//Updating  all DML to be wrapped in a Database.savepoint() in case we need to roll back due to failure of a DML
		Savepoint SP_PreEventDMLState = Database.setSavepoint();

		// Cecking for a prticular date pattern while creating event records
		Pattern datePattern = Pattern.compile('(([0]?)[0123456789]|10|11|12)(/)([0123][0123456789])(/)([0123456789]{4})');

		if (Schema.SObjectType.Event__c.isCreateable())
		{

			// Obtaining the field name/token map for the Event object
			Map<String, Schema.SObjectField> eventFldMap = Schema.SObjectType.Event__c.fields.getMap();
			Map<String, Schema.SObjectField> TAFldMap = Schema.SObjectType.TopicAssignment.fields.getMap();

			for (String fieldToCheck : eventInsertFields)
			{

				String fullFieldName = fieldToCheck.contains('__c') ? nameSpace + fieldToCheck : fieldToCheck;

				// Check if the user has access to view field
				if (!eventFldMap.get(fullFieldName).getDescribe().isCreateable())
				{

					// exception Search and pass error to client
					throw new System.NoAccessException();

					//included to quiet editor
					return null;
				}
			}

			for (String fieldToCheck : TopicAssigmtInsertFields)
			{

				// Check if the user has access to view field
				if (!TAFldMap.get(fieldToCheck).getDescribe().isCreateable())
				{

					//  exception Search and pass error to client
					throw new System.NoAccessException();

					//included to quiet editor
					return null;
				}
			}

			//Set NetworkId for Newly Created Event
			eventObj.NetworkId__c = netwrkId;

			if (eventObj.All_Day_Event__c)
			{
				Datetime dt1 = DateTime.valueOf(allDayEventStartDate + ' ' + '00:00:00');
				eventObj.Start_DateTime__c = dt1;

				if (String.isNotBlank(allDayEventEndDate) && allDayEventEndDate.contains('-'))
				{
					Datetime dt2 = DateTime.valueOf(allDayEventEndDate + ' ' + '23:59:59');
					eventObj.End_DateTime__c = dt2;

				}
				//Checking if 'allDayEventEndDate' is null
				if (allDayEventEndDate == null || String.isBlank(allDayEventEndDate))
				{
					eventObj.End_DateTime__c = null;
				}
			}
			// Insert or upsert topics for create as well as edit Event page
			Map<string, TopicAssignment> topicMap = new Map<string, TopicAssignment>();
			if (eventObj.Id != null)
			{

				List<TopicAssignment> topicAssignments =
				[
					SELECT Id, EntityId, Topic.Id, Topic.Name
					FROM TopicAssignment
					WHERE NetworkId = :netwrkId AND EntityId = :eventObj.Id
					limit 1000
				];
				for (TopicAssignment tAssgn : topicAssignments)
				{
					topicMap.put(tAssgn.TopicId, tAssgn);
				}

			}
			try
			{
				upsert eventObj;
			}
			catch (DMLException dmlExp)
			{
				Database.rollback(SP_PreEventDMLState);
			}

			// Check for existing topics on edit page for Events such that if no change for topics on Edit
			// then will remains same else will update the topics
			if (String.isNotBlank(strfilterByTopic) && strfilterByTopic.trim().length() > 0)
			{
				List<TopicAssignment> topicAssignmentLst = new List<TopicAssignment>();
				set<string> topicLst = new set<string>();
				topicLst.addAll(strfilterByTopic.split(';'));

				set<string> topicSet = new set<string>();
				List<TopicAssignment> deleteAssignmentsLst = new List<TopicAssignment>();
				if (topicMap.size() > 0)
				{
					for (String topicId : topicMap.KeySet())
					{
						for (String tId : topicLst)
						{
							if (tId == topicId)
							{

							}
							else
							{
								if (!topicSet.contains(tId))
								{
									topicSet.add(tId);
									TopicAssignment t = new TopicAssignment();
									t.EntityId = eventObj.id;
									t.TopicId = tId;
									topicAssignmentLst.add(t);
								}
							}
						}
						if (!topicLst.contains(topicId))
						{
							deleteAssignmentsLst.add(topicMap.get(topicId));
						}
					}
				}
				else
				{
					for (string strTopicId : topicLst)
					{
						TopicAssignment t = new TopicAssignment();
						t.NetworkId = netwrkId;
						t.EntityId = eventObj.id;
						t.TopicId = strTopicId;
						topicAssignmentLst.add(t);
					}
				}
				try
				{
					delete deleteAssignmentsLst;
					upsert topicAssignmentLst;
				}
				catch (DMLException exp)
				{
					Database.rollback(SP_PreEventDMLState);
				}
			}

			return eventObj;
		}
		else
		{
			return null;
		}
	}

	/*
		* MethodName		: saveEvents
		* param			 : fldMap, objectAccess
		* Description	   : Method for Checking no access exception for specific fields in the map.
	*/
	private static Boolean checkFieldType(Map<String, Schema.SObjectField> fldMap, String[] objectAccess)
	{
		for (String fieldToCheck : objectAccess)
		{
			String fullFieldName = fieldToCheck.contains('__c') ? nameSpace + fieldToCheck : fieldToCheck;

			if (!fldMap.get(fullFieldName).getDescribe().isAccessible())
			{
				System.debug(LoggingLevel.ERROR, 'Access failed for field: ' + fullFieldName);
				return false;
			}
		}
		return true;
	}

	/*
		* MethodName		: getDateTime
		* param			 : dt, timer
		* Description	   : Seperate method to check for dates.
	*/
	@TestVisible
	private static DateTime getDateTime(String dt, String timer)
	{
		List<String> lstOfFromDt = dt.split('-');
		DateTime dtr = DateTime.parse(lstOfFromDt[1] + '/' + lstOfFromDt[2] + '/' + lstOfFromDt[0] + timer);
		return dtr;
	}

	/*
	@Name		   : getGroups
	@Description	: Get a list of all the groups this user is a member of
	 */
	@AuraEnabled
	global static Map<string, string> getGroups()
	{
		Map<string, string> groups = new Map<string, string>();

		for (CollaborationGroupMember member :
		[
			SELECT id, CollaborationGroupId, CollaborationGroup.Name
			FROM CollaborationGroupMember
			WHERE MemberId = :userinfo.getuserid()
			LIMIT 1000
		])
		{
			groups.put(member.CollaborationGroupId, member.CollaborationGroup.Name);
		}

		return groups;
	}

	/*
	@Name		   : getAllGroups
	@Description	: Get a list of all the groups on the org
	 */
	@AuraEnabled
	global static Map<string, string> getAllGroups()
	{
		Map<string, string> groups = new Map<string, string>();

		for (CollaborationGroupMember member :
		[
			SELECT id, CollaborationGroupId, CollaborationGroup.Name
			FROM CollaborationGroupMember
			LIMIT 1000
		])
		{
			groups.put(member.CollaborationGroupId, member.CollaborationGroup.Name);
		}

		return groups;
	}

	/*
	 * MethodName		: getEvents
	 * param			 : eventListFlag, numberofresults, listSize, pageNumber, strfilterType
						  strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm,
						  searchTerm, filterOn, fromDate, toDate, listViewMode
	 * Description	   : Method to fetch all event records for list view, topic and search pages.
	 */
	@AuraEnabled
	global static SVNSUMMITS_EventListWrapper getEvents(
		Boolean eventListFlag,
		Integer numberofresults,
		Integer listSize,
		Integer pageNumber,
		String strfilterType,
		String strRecordId,
		String networkId,
		String sortBy,
		String filterByTopic,
		String topicName,
		Boolean filterBySearchTerm,
		String searchTerm,
		String filterOn,
		String fromDate,
		String toDate,
		String listViewMode)
	{
		system.debug('calling getEvents');

		// Obtaining the field name/token map for the Event object
		Map<String, Schema.SObjectField> eventFldMap = Schema.SObjectType.Event__c.fields.getMap();
		Map<String, Schema.SObjectField> topicFldMap = Schema.SObjectType.Topic.fields.getMap();
		Map<String, Schema.SObjectField> TAFldMap	= Schema.SObjectType.TopicAssignment.fields.getMap();

		// Checking no access exception for EventAccessFields, TopicAccessFields and TopicAssigmtAccessFields
		if (!checkFieldType(eventFldMap, EventAccessFields))
		{
			System.debug('ACCESS CHECK failed for EventAccessFields');
			throw new System.NoAccessException();
		}
		if (!checkFieldType(topicFldMap, TopicAccessFields))
		{
			System.debug('ACCESS CHECK failed for TopicAccessFields');
			throw new System.NoAccessException();
		}
		if (!checkFieldType(TAFldMap, TopicAssigmtAccessFields))
		{
			System.debug('ACCESS CHECK failed for TopicAssigmtAccessFields');
			throw new System.NoAccessException();
		}

		listSize = Integer.valueOf(listSize);

		DateTime fromDt;
		DateTime toDt;

		try
		{
			//create datetime instance of fromDate and toDate as we get them in string format
			if (String.isNotBlank(fromDate) || String.isNotBlank(toDate))
			{
				if (String.isNotBlank(fromDate))
				{
					fromDt = DateTime.valueOf(fromDate + ' ' + '00:00:00');
				}
				if (String.isNotBlank(toDate))
				{
					toDt = DateTime.valueOf(toDate + ' ' + '23:59:00');
				}
			}
		}
		catch (Exception e)
		{
			return new SVNSUMMITS_EventListWrapper('Date', e.getMessage());
			System.debug('ERROR:' + e);
		}

		Integer limitint = Integer.valueOf(numberofresults);
		set<string> topicIds = new set<string>();

		for (TopicAssignment topicAssignment : [SELECT Id, EntityId, Topic.Id, Topic.Name FROM TopicAssignment WHERE NetworkId = :netwrkId AND EntityId = :String.valueOf(strRecordId) limit 1000])
		{
			topicIds.add(topicAssignment.Topic.Id);
		}

		set<string> eventIds = new set<string>();
		for (TopicAssignment topicAssignment : [SELECT Id, EntityId, Topic.Id, Topic.Name FROM TopicAssignment WHERE NetworkId = :netwrkId AND Topic.Id IN :topicIds limit 1000])
		{
			eventIds.add(topicAssignment.EntityId);
		}

		List<String> keywordSetCategoriesList = new List<String>(eventIds);
		String categoriesJoined = '(\'' + String.join(keywordSetCategoriesList, '\',\'') + '\')';

		String flds = String.join(EventAccessFields, ',');
		flds = flds.removeEnd(',');
		String Query = 'Select ' + flds + ', (SELECT Id FROM Attachments) from Event__c ';

		Date dToday = System.Today();
		Datetime dt = datetime.newInstance(dToday.year(), dToday.month(), dToday.day());

		system.debug('sortBy = ' + sortBy);
		system.debug('listmode = ' + listViewMode);

		System.debug('listViewMode:' + listViewMode + ' filterOn:' + filterOn + ' limitint:' + limitint + ' eventListFlag:' + eventListFlag);
		// Fetch event records in case of Calendar mode
		if (listViewMode == 'Calendar')
		{
			Query += ' Where NetworkId__c = \'' + netwrkId + '\' AND UnlistedEvent_TU__c = false';

			if (String.isNotBlank(filterByTopic))
			{
				List<string> topicLst = new List<string>();
				topicLst.addAll(filterByTopic.split(';'));
				eventIds = new set<string>();
				for (TopicAssignment t : [SELECT Id, EntityId, Topic.Id, Topic.Name FROM TopicAssignment WHERE NetworkId = :netwrkId AND Topic.Id = :topicLst limit 1000])
				{
					eventIds.add(t.EntityId);
				}
				Query += ' And Id IN : eventIds';
				Query += ' And NetworkId__c = \'' + netwrkId + '\'';
			}
			// sort event records in calendar mode for upcoming dates
			if (sortBy == 'Upcoming')
			{
				Query = Query + ' And Start_DateTime__c >= TODAY';
				Query = Query + ' ORDER BY Start_DateTime__c';
			}

			// sort event records in calendar mode for Top attendees
			else if (sortBy == 'TopAttendance')
			{
				Query = Query + ' ORDER BY Number_of_Attendees__c DESC';
			}
			else
			{
				Query += ' ORDER BY Start_DateTime__c';
			}
		}
		//Event records fetched in case of Recommended for you and eventListFlag = false
		else if (filterOn == 'None' && limitint != Null && eventListFlag == False)
		{
			if (categoriesJoined.length() > 5)
			{
				Query = Query + ' WHERE Id IN ' + categoriesJoined;
				Query = Query += ' AND';
			}
			else
			{
				Query += ' WHERE';
			}

			//system.debug('strRecord = ' + strRecordId);

			Query = Query + ' Start_DateTime__c >= TODAY';
			if (String.isNotBlank(strRecordId))
			{
				Query = Query + ' And Id != \'' + strRecordId + '\'';
			}

			Query = Query + ' And NetworkId__c = \'' + netwrkId + '\' AND UnlistedEvent_TU__c = false';

			if (Peak_Utils.isGuestUser()) {
				Query = Query + ' AND OnlyAuthenticatedUsersAllowed_TU__c = false';
			}

			Query = Query + ' ORDER BY Start_DateTime__c DESC ';
			Query = Query + ' LIMIT ' + limitint;
		}

		//Fetching event records in case of Search page - List view
		else if (filterOn == 'Search Term' && String.isNotBlank(searchTerm))
		{
			if (String.isNotBlank(searchTerm) && searchTerm.trim().length() > 0)
			{
				searchTerm = String.escapeSingleQuotes(searchTerm.trim());
			}

			Query = Query + ' WHERE Name LIKE \'%' + searchTerm + '%\'';
			Query = Query + ' And NetworkId__c = \'' + netwrkId + '\' AND UnlistedEvent_TU__c = false';

			if (Peak_Utils.isGuestUser()) {
				Query = Query + ' AND OnlyAuthenticatedUsersAllowed_TU__c = false';
			}

			if (sortBy == 'Upcoming')
			{
				Query = Query + ' And Start_DateTime__c >= TODAY';
				Query = Query + ' ORDER BY Start_DateTime__c';
			}
			else if (sortBy == 'Top Attendees')
			{
				Query = Query + ' ORDER BY Number_of_Attendees__c DESC';
			}
		}
		//Fetch Event Records related Topic Page
		else if (filterOn == 'Topic Value')
		{
			system.debug('Topic Value selected -- topic name = ' + topicName);
			String queryStrTopic = 'SELECT Id, EntityId, Topic.Id, Topic.Name FROM TopicAssignment ';

			eventIds = new set<string>();

			// hack for Topic names with spaces that are replaced with a '-' in the URL
			String subTopicQuery;

			if (topicName.indexOf('-') != -1)
			{
				subTopicQuery = ' WHERE Topic.Name LIKE \'%' + topicName.replace('-', '%') + '%\'';
			}
			else
			{
				subTopicQuery = ' WHERE Topic.Name = \'' + topicName + '\'';
			}

			queryStrTopic += subTopicQuery;

			if (String.isNotBlank(netwrkId))
			{
				queryStrTopic += ' AND NetworkId = \'' + netwrkId + '\'';
			}
			else
			{
				queryStrTopic += ' AND NetworkId = null';
			}

			queryStrTopic += ' LIMIT 1000';

			system.debug('Topic query: ' + queryStrTopic);

			List<TopicAssignment> topicsLst = DataBase.query(queryStrTopic);

			for (TopicAssignment t : topicsLst)
			{
				eventIds.add(t.EntityId);
			}

			Query = Query + ' Where Id IN : eventIds ';
			Query = Query + ' And NetworkId__c = \'' + netwrkId + '\' AND UnlistedEvent_TU__c = false';

			if (Peak_Utils.isGuestUser()) {
				Query = Query + ' AND OnlyAuthenticatedUsersAllowed_TU__c = false';
			}

			// Sorting event records in case of upcoming dates
			if (sortBy == 'Upcoming')
			{
				Query = Query + ' And Start_DateTime__c >= TODAY';
				Query = Query + ' ORDER BY Start_DateTime__c';
			}
			// Sorting records for Top attendees
			else if (sortBy == 'TopAttendance')
			{
				Query = Query + ' ORDER BY Number_of_Attendees__c DESC';
			}
			// Filter by Group ID
		}
		else if (filterOn == 'Group')
		{
			Query += ' WHERE GroupId__c  = \'' + topicName + '\'';
			system.debug('Query for Groups : ' + Query);
		}
		else if (filterOn == 'LocationName' && String.isNotBlank(strfilterType))
		{
			Query += ' WHERE Location_Name__c  = \'' + strfilterType + '\'';
			system.debug('Query for location : ' + Query);

		}
		//Filter event records by date or topics
		else if (fromDt != null || toDt != null || String.isNotBlank(filterByTopic) || String.isNotBlank(sortBy))
		{
			Query += ' Where NetworkId__c = \'' + netwrkId + '\' AND UnlistedEvent_TU__c = false';

			if (Peak_Utils.isGuestUser()) {
				Query = Query + ' AND OnlyAuthenticatedUsersAllowed_TU__c = false';
			}

			if (fromdt != null)
			{
				Query += ' And Start_DateTime__c >=: fromDt ';
			}
			if (toDt != null)
			{
				Query += ' And Start_DateTime__c <=:  toDt ' ;
			}

			if (String.isNotBlank(filterByTopic))
			{
				List<string> topicLst = new List<string>();
				topicLst.addAll(filterByTopic.split(';'));
				eventIds = new set<string>();
				for (TopicAssignment t : [SELECT Id, EntityId, Topic.Id, Topic.Name FROM TopicAssignment WHERE NetworkId = :netwrkId AND Topic.Id = :topicLst limit 1000])
				{
					eventIds.add(t.EntityId);
				}
				Query += ' And Id IN : eventIds ';
			}

			if (sortBy == 'Upcoming')
			{
				Query = Query + ' And Start_DateTime__c >= TODAY';
				Query = Query + ' ORDER BY Start_DateTime__c';
			}
			else if (sortBy == 'TopAttendance')
			{
				Query = Query + ' ORDER BY Number_of_Attendees__c DESC';
			}
			else
			{
				Query += ' ORDER BY Start_DateTime__c';
			}

		}
		//query for event records Without any filter
		else
		{
			Query = Query + ' Where NetworkId__c = \'' + netwrkId + '\' AND UnlistedEvent_TU__c = false';
			Query += ' ORDER BY Start_DateTime__c';
		}
		system.debug('returned EventListWrapper' + Query);
		return new SVNSUMMITS_EventListWrapper(Query, listSize, fromDt, toDt, eventIds, listViewMode, false, null);
	}

	/*
		* MethodName		: nextPage
		* param			 : eventListFlag, numberofresults, numberofresults, listSize,toDate,
							  pageNumber, strfilterType, strRecordId, networkId, sortBy,searchTerm,
							  filterByTopic, topicName, filterBySearchTerm, filterOn, fromDate, listViewMode
		* Description	   : Method to fetch all event records for next page pagination.
	*/
	@AuraEnabled
	global static SVNSUMMITS_EventListWrapper nextPage(Boolean eventListFlag, Integer numberofresults, Integer listSize, Integer pageNumber, String strfilterType, String strRecordId, String networkId, String sortBy, String filterByTopic, String topicName, Boolean filterBySearchTerm, String searchTerm, String filterOn, String fromDate, String toDate, String listViewMode)
	{
		Integer listSizeValue = listSize != null ? Integer.valueOf(listSize) : DEFAULT_LIST_SIZE;
		Integer pageNumberValue = pageNumber != null ? Integer.valueOf(pageNumber) : DEFAULT_PAGE_VALUE;

		SVNSUMMITS_EventListWrapper ilw = getEvents(eventListFlag, numberofresults, listSizeValue, pageNumberValue, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
		ilw.pageNumber = pageNumberValue;

		ilw.nextPage();

		return ilw;
	}

	/*
		* MethodName		: previousPage
		* param			 : eventListFlag, numberofresults, numberofresults, listSize,toDate,
							  pageNumber, strfilterType, strRecordId, networkId, sortBy,searchTerm,
							  filterByTopic, topicName, filterBySearchTerm, filterOn, fromDate, listViewMode
		* Description	   : Method to fetch all event records for previous page pagination.
	*/
	@AuraEnabled
	global static SVNSUMMITS_EventListWrapper previousPage(Boolean eventListFlag, Integer numberofresults, Integer listSize, Integer pageNumber, String strfilterType, String strRecordId, String networkId, String sortBy, String filterByTopic, String topicName, Boolean filterBySearchTerm, String searchTerm, String filterOn, String fromDate, String toDate, String listViewMode)
	{
		Integer listSizeValue = listSize != null ? Integer.valueOf(listSize) : DEFAULT_LIST_SIZE;
		Integer pageNumberValue = pageNumber != null ? Integer.valueOf(pageNumber) : DEFAULT_PAGE_VALUE;

		SVNSUMMITS_EventListWrapper ilw = getEvents(eventListFlag, numberofresults, listSizeValue, pageNumberValue, strfilterType, strRecordId, networkId, sortBy, filterByTopic, topicName, filterBySearchTerm, searchTerm, filterOn, fromDate, toDate, listViewMode);
		ilw.pageNumber = pageNumberValue;

		ilw.previousPage();

		return ilw;
	}

	/*
		* MethodName		: getTopics
		* param			 :
		* Description	   : Method to fetch all topics records.
	*/
	@AuraEnabled
	global static Map<string, string> getTopics()
	{
		Map<string, string> topics = new Map<string, string>();
		List<Topic> topicList = new List<Topic>();
		Map<String, Schema.SObjectField> topicFldMap = Schema.SObjectType.Topic.fields.getMap();

		if (netwrkId != null)
		{
			for (String fieldToCheck : TopicAccessFields)
			{

				// Check if the user has access to view field
				if (!topicFldMap.get(fieldToCheck).getDescribe().isAccessible())
				{

					// exception Search and pass error to client
					throw new System.NoAccessException();

					//included to quiet editor
					return null;
				}
			}
			topicList =
			[
				SELECT CreatedById, CreatedDate, Description, Id, Name, NetworkId, TalkingAbout
				FROM Topic
				WHERE NetworkId = :netwrkId
			];
		}
		else
		{
			for (String fieldToCheck : TopicAccessFields)
			{

				// Check if the user has access to view field
				if (!topicFldMap.get(fieldToCheck).getDescribe().isAccessible())
				{

					// exception Search and pass error to client
					throw new System.NoAccessException();

					//included to quiet editor
					return null;
				}
			}
			topicList =
			[
				SELECT CreatedById, CreatedDate, Description, Id, Name, NetworkId, TalkingAbout
				FROM Topic
				LIMIT 2000
			];
		}

		for (Topic t : topicList)
		{
			topics.put(t.Id, t.Name);
		}

		return topics;
	}

	/*
		* MethodName		: getEventRecord
		* param			 : eventRecordId
		* Description	   : Method to fetch particular event record on call of edit page.
	*/

	@AuraEnabled
	global static SVNSUMMITS_EventListWrapper getEventRecord(String eventRecordId)
	{
		system.debug('getting event record:');

		Map<String, Schema.SObjectField> eventFldMap = Schema.SObjectType.Event__c.fields.getMap();
		Map<String, Schema.SObjectField> attFldMap = Schema.SObjectType.Attachment.fields.getMap();

		for (String fieldToCheck : EventAccessFields)
		{
			String fullFieldName = fieldToCheck.contains('__c') ? nameSpace + fieldToCheck : fieldToCheck;

			system.debug('	: ' + fullFieldName);

			// Check if the user has access to view field
			if (!eventFldMap.get(fullFieldName).getDescribe().isAccessible())
			{

				// exception Search and pass error to client
				throw new System.NoAccessException();

				//included to quiet editor
				return null;
			}
		}
		for (String fieldToCheck : AttachmentAccessFields)
		{

			// Check if the user has access to view field
			if (!attFldMap.get(fieldToCheck).getDescribe().isAccessible())
			{

				// Search and pass error to client
				throw new System.NoAccessException();

				//included to quiet editor
				return null;
			}
		}

		set<string> eventIds = new set<string>();

		String Query = 'Select ' + String.join(EventAccessFields, ',') + ',(select Id,Name from Attachments limit 1) FROM Event__c Where  Id = \'' + eventRecordId + '\'  And NetworkId__c = \'' + netwrkId + '\'';
		system.debug('query = ' + Query);

		return new SVNSUMMITS_EventListWrapper(Query, 1, null, null, eventIds, null, false, null);
	}

	/*
		* MethodName		: getEditable
		* param			 : eventRecordId
		* Description	   : Method to fetch give access to record from share object.
	*/
	private static Boolean getEditable(Id eventRecordId)
	{
		for (Event__c objEvent :
		[
			Select Id, OwnerId
			from Event__c
			where Id = :eventRecordId
			AND OwnerId = :UserInfo.getUserId()
		])
		{
			return true;
		}
		/*
		if(!Test.isRunningTest())
		{
			for(Event__Share objShare : [Select AccessLevel from Event__Share where ParentId =:eventRecordId AND UserOrGroupId=:UserInfo.getUserId()]) {
				if(objShare.AccessLevel.toLowerCase() == 'edit' || objShare.AccessLevel.toLowerCase() == 'all') {
					return true;
				} else {
					return false;
				}
			}
		}
		*/
		return false;
	}

	/*
		* MethodName		: getEventName
		* param			 : eventRecordId
		* Description	   : Method to fetch particular event record's Name.
	*/
	@AuraEnabled
	global static String getEventName(String eventRecordId)
	{
		String[] flds = new String[]
		{
			'Id', 'Name'
		};
		Map<String, Schema.SObjectField> eventFldMap = Schema.SObjectType.Event__c.fields.getMap();

		for (String fieldToCheck : flds)
		{

			// Check if the user has access to view field
			if (!eventFldMap.get(fieldToCheck).getDescribe().isAccessible())
			{

				// exception Search and pass error to client
				throw new System.NoAccessException();

				//included to quiet editor
				return null;
			}
		}

		return [SELECT Id, Name FROM Event__c Where Id = :eventRecordId And NetworkId__c = :netwrkId].Name;

	}

	/*
		* MethodName		: getFeaturedEvents
		* param			 : recordId1, recordId2, recordId3, recordId4, recordId5
		* Description	   : Method to fetch featured and featured 1+4 event records.
	*/
	@AuraEnabled
	global static SVNSUMMITS_EventListWrapper getFeaturedEvents(String recordId1, String recordId2, String recordId3, String recordId4, String recordId5)
	{
		Map<String, Schema.SObjectField> eventFldMap = Schema.SObjectType.Event__c.fields.getMap();
		Map<String, Schema.SObjectField> attFldMap = Schema.SObjectType.Attachment.fields.getMap();

		for (String fieldToCheck : EventAccessFields)
		{

			String fullFieldName = fieldToCheck.contains('__c') ? nameSpace + fieldToCheck : fieldToCheck;

			// Check if the user has access to view field
			if (!eventFldMap.get(fullFieldName).getDescribe().isAccessible())
			{

				// exception Search and pass error to client
				throw new System.NoAccessException();

				//included to quiet editor
				return null;
			}
		}
		for (String fieldToCheck : AttachmentAccessFields)
		{

			// Check if the user has access to view field
			if (!attFldMap.get(fieldToCheck).getDescribe().isAccessible())
			{

				// exception Search and pass error to client
				throw new System.NoAccessException();

				//included to quiet editor
				return null;
			}
		}
		// fetching all five records related to featured 1+4 records
		boolean isFeatured = true;
		set<string> eventIds = new set<string>();
		Map<string, string> featurdEventIds = new Map<string, string>();
		if (recordId1 != null && !string.isEmpty(recordId1))
		{
			featurdEventIds.put(recordId1, recordId1);
		}
		if (recordId2 != null && !string.isEmpty(recordId2))
		{
			featurdEventIds.put(recordId2, recordId2);
		}
		if (recordId3 != null && !string.isEmpty(recordId3))
		{
			featurdEventIds.put(recordId3, recordId3);
		}
		if (recordId4 != null && !string.isEmpty(recordId4))
		{
			featurdEventIds.put(recordId4, recordId4);
		}
		if (recordId5 != null && !string.isEmpty(recordId5))
		{
			featurdEventIds.put(recordId5, recordId5);
		}

		eventIds = featurdEventIds.keyset();

		String Query = 'Select ' + String.join(EventAccessFields, ',') + ',(select Id,Name from Attachments limit 1) ' +
				'FROM Event__c Where Id IN : eventIds AND UnlistedEvent_TU__c = false ' +
				'And NetworkId__c = \'' + netwrkId + '\'';


		if (Peak_Utils.isGuestUser()) {
			Query = Query + ' AND OnlyAuthenticatedUsersAllowed_TU__c = false';
		}


		return new SVNSUMMITS_EventListWrapper(Query, 5, null, null, eventIds, null, isFeatured, featurdEventIds);
	}

	/*
		* MethodName		: getRSVPMemberAttendes
		* param			 : EventName
		* Description	   : Method to fetch the rsvp member status. Whether they are joining or not.
	*/
	@AuraEnabled
	global static Boolean getRSVPMemberAttendes(Id EventName)
	{
		List<Event_RSVP__c> lstEventRSVP = new List<Event_RSVP__c>([
			SELECT Id, Name, Event__c, User__c
			FROM Event_RSVP__c
			WHERE Event__c = :EventName
			AND User__c = :UserInfo.getUserId()
		]);

		if (!lstEventRSVP.isEmpty())
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	/*
		 * MethodName		: createRSVPevents
		 * param			 : EventName, response
		 * Description	   : Method to create Event_RSVP__c records on clicking yes on the RSVP component.
	 */
	@AuraEnabled
	global static Event_RSVP__c createRSVPevents(Id EventName, String response)
	{
		if (Schema.SObjectType.Event_RSVP__c.isCreateable())
		{
			if ([Select count() from Event_RSVP__c Where Event__c = :EventName AND User__c = :UserInfo.getUserId()] <= 0)
			{
				Event_RSVP__c eventRSVPList = new Event_RSVP__c();
				eventRSVPList.Event__c = EventName;
				eventRSVPList.User__c = UserInfo.getUserId();
				eventRSVPList.Response__c = response;
				insert eventRSVPList;

			}
		}
		return null;
	}

	/*
		* MethodName		: deleteRSVPevents
		* param			 : EventId
		* Description	   : Method to delete Event_RSVP__c records on clicking No on RSVP component.
	*/
	@AuraEnabled
	global static Event_RSVP__c deleteRSVPevents(Id EventId)
	{
		if (EventId != null)
		{
			delete
			[
				Select Id
				From Event_RSVP__c
				Where User__c = :UserInfo.getUserId()
				AND Event__c = :EventId
				LIMIT 1
			];
		}
		return null;
	}

	/*
		* MethodName		: deleteRSVPevents
		* param			 : EventId
		* Description	   : Method to delete Event_RSVP__c records on clicking No on RSVP component.
	*/
	@AuraEnabled
	global static Boolean checkRSVPevents(Id EventId)
	{
		if ([
			Select count()
			From Event_RSVP__c
			Where User__c = :UserInfo.getUserId()
			AND Event__c = :EventId And Event__r.NetworkId__c = :netwrkId
			LIMIT 1
		] > 0)
		{
			return true;
		}
		return false;
	}

	@AuraEnabled
	global static Decimal getRSVPAttendeeCount(Id eventId)
	{
		Event__c[] events = [SELECT Id, Number_of_Attendees__c FROM Event__c WHERE Id = :eventId];

		return (events.size() > 0) ? events[0].Number_of_Attendees__c : 0;
	}

	@AuraEnabled
	global static List<String> getEventsPicklist(String fieldName, string searchString)
	{
		List<String> values = new List<String>();

		Integer recordLimit = DEFAULT_LIST_SIZE;
		String fieldString = 'e.' + fieldName;

		String query = 'SELECT ' + fieldString;

		query += ' location,';
		query += ' COUNT_DISTINCT(e.Id)';
		query += ' FROM Event__c e';

		if (String.isNotBlank(searchString))
		{
			query += ' WHERE (' + fieldString + ' LIKE \'%' + searchString + '%\') AND UnlistedEvent_TU__c = false';
		} else {
			query += ' WHERE UnlistedEvent_TU__c = false';
		}

		if (Peak_Utils.isGuestUser()) {
			query = query + ' AND OnlyAuthenticatedUsersAllowed_TU__c = false';
		}

		query += ' GROUP BY ' + fieldString;
		query += ' LIMIT ' + recordLimit;

		List<AggregateResult> results = Database.query(query);

		for (AggregateResult ar : results)
		{
			String entry = (String) ar.get('location');

			if (String.isNotBlank(entry))
			{
				values.add(entry);
			}
		}

		return values;
	}


	// do not add code below this or mess with the comments
	//DEPRECATED FUNCTIONS START
/*
	@deprecated
	@AuraEnabled
	global static Event__c saveEvent(Event__c eventObj, String strfilterByTopic)
	{
		return null;
	}

	@deprecated
	@AuraEnabled
	global static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType)
	{
		return null;
	}
	@deprecated
	@AuraEnabled
	global static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId)
	{
		return null;
	}
*/
	//DEPRECATED FUNCTIONS END
}