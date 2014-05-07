/*
 *
 *
 * Description: 修复数据，只用一次
 */
global class WeeklyDashboardUpdateBatch implements Database.Batchable<sObject>,Database.Stateful
{
	global Database.Querylocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator([Select Id, Store__c, Store__r.Region__c, Store__r.Store_Type__c From Weekly_Dashboard__c Where Weekly_Dashboard_Type__c = 'Store']);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		List<Weekly_Dashboard__c> wList = new List<Weekly_Dashboard__c>();
		for(Weekly_Dashboard__c w : (List<Weekly_Dashboard__c>) scope)
		{
			if(w.Store__c != null)
			{
				w.Region__c = w.Store__r.Region__c;
				w.Store_Type__c = w.Store__r.Store_Type__c;
				wList.add(w);
			}
		}
		
		update wList;
	}
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
}
