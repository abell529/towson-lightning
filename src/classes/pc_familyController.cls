/*
 * Copyright (c) 2017. 7Summits inc.
 */

/**
 * Created by francoiskorb on 11/21/17.
 */

public with sharing class pc_familyController
{
	@AuraEnabled
	public static List<pc_family> getProductFamilyList()
	{
		ss_settings     settings     = new ss_settings();
		List<pc_family> familyList   = new List<pc_family>();
		String          communityUrl = pc_model.getCommunityUrl();

		if (settings.familyIds != null && settings.familyIds.size() > 0)
		{
			pc_listModel products = pc_listController.getProductsById(settings.familyIds.size(), 1, settings.familyIds);

			// preserve the requested order
			for (String familyId: settings.familyIds)
			{
				pc_model item = products.getItemByProductId(familyId);
				if (item != null) { familyList.add(new pc_family(item.family, item.imageUrl));}
			}
		}

		return familyList;
	}
}
