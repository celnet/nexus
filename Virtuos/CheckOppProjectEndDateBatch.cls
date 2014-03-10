/*
 * Author: Steven
 * Date: 2014-3-4
 * Description: 更新历史Opportunity的Project_End_Date__c字段
 */
global class CheckOppProjectEndDateBatch implements Database.Batchable<sObject>
{
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator('Select Id From Opportunity');
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		
		Set<Id> oppIdSet = new Set<Id>();
		List<Opportunity> updateOpps = new List<Opportunity>();
		
		for(Sobject s : scope)
		{
			oppIdSet.add(s.Id);
		}
	
		for(AggregateResult dnAggre : [Select 
											Opportunity__r.Id OppId,
											Opportunity__r.Project_End_Date__c OppProjectEndDate,
											max(Date__c) maxDNDate
										From DB_Notes__c 
										Where Opportunity__c IN: oppIdSet
										GROUP BY Opportunity__r.Id, Opportunity__r.Project_End_Date__c])
		{
			if(dnAggre.get('OppId') == null)
			{
				continue;
			}
			ID oppId = (ID)dnAggre.get('OppId');
			Date oppDate = null;
			Date maxDnDate = null;
			if(dnAggre.get('OppProjectEndDate') != null)
			{
				oppDate = (Date)dnAggre.get('OppProjectEndDate');
			}
			if(dnAggre.get('maxDNDate') != null)
			{
				maxDnDate = (Date)dnAggre.get('maxDNDate');
			}
			if(oppDate != null)
			{
				if(maxDnDate != null)
				{
					if(maxDnDate > oppDate)
					{
						updateOpps.add(new Opportunity(ID = oppId, Project_End_Date__c = maxDnDate));
					}
				}
			}
			else
			{
				if(maxDnDate != null)
				{
					updateOpps.add(new Opportunity(ID = oppId, Project_End_Date__c = maxDnDate));
				}
			}
		}
		update updateOpps;
		
    }

	global void finish(Database.BatchableContext BC){
		
	}
	
	/*
	global Iterable<DB_Notes__c> start(Database.BatchableContext bc) 
	{
		return [Select Date__c, Opportunity__c, Id From DB_Notes__c];
	}
	
	global void execute(Database.BatchableContext BC, List<DB_Notes__c> scope)
	{
		List<Opportunity> oppList = new List<Opportunity>();
		List<AggregateResult> dnAggreList = new List<AggregateResult>();
		Set<Id> oppIdSet = new Set<Id>();
		List<Id> dnIdList = new List<Id>();
		
		for(DB_Notes__c s : scope)
		{
			oppIdSet.add(s.Opportunity__c);
			dnIdList.add(s.Id);
		}
	
		oppList = [Select Project_End_Date__c, Id From Opportunity Where Id IN: oppIdSet];
		dnAggreList = [Select Opportunity__c, max(Date__c) From DB_Notes__c Where Id IN: dnIdList GROUP BY Opportunity__c];
	
		for(AggregateResult dnAggre : dnAggreList)
		{
			Id oppId = (Id)dnAggre.get('Opportunity__c');
			Date dnDate = (Date)dnAggre.get('expr0');
			for(Opportunity opp : oppList)
			{
				if(opp.Id == oppId)
				{
					Date oppProjectEndDate = opp.Project_End_Date__c;
					if(dnDate > oppProjectEndDate)
					{
						opp.Project_End_Date__c = dnDate;
					}
				}
			}
		}
		
		update oppList;
		
	}
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
	*/
}
