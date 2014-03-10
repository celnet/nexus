/*
 * Author: Steven
 * Date: 2014-3-4
 * Description: 比较Debit Notes的Date字段和对应的Opportunity的Project_End_Date字段, 把较晚的时间赋给Project_End_Date
 */
trigger CheckOpportunityProjectEndDate on DB_Notes__c (after insert, after update) 
{
	//List<Opportunity> oppList = new List<Opportunity>();
	//List<AggregateResult> dnAggreList = new List<AggregateResult>();
	Set<Id> oppIdSet = new Set<Id>();
	List<Opportunity> updateOpps = new List<Opportunity>();
	//List<Id> dnIdList = new List<Id>();
	
	for(DB_Notes__c dn : trigger.new)
	{
		oppIdSet.add(dn.Opportunity__c);
		//dnIdList.add(dn.Id);
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
	/*
	oppList = [Select Project_End_Date__c, Id From Opportunity Where Id IN: oppIdSet];
	dnAggreList = [Select Opportunity__c, max(Date__c) From DB_Notes__c Where Opportunity__c IN oppIdSet
	Id IN: dnIdList GROUP BY Opportunity__c];
	
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
	*/
	
}
