/*
 * Author: Steven
 * Date: 2014-3-12
 * Description: 为每个符合条件业务机会计算并生成Balance历史数据, 每个月每个业务机会生成一条Balance记录
 */
global class OpportunityBalanceBatch implements Database.Batchable<sObject>, Schedulable
{
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		Datetime thisMonth = Date.today().toStartOfMonth();
		String query = 'Select Id, Amount, CloseDate, Project_End_Date__c From Opportunity Where (StageName = \'Approved\' OR StageName = \'Closed Won(Signed PO or contract)\') And Project_End_Date__c >=';
    	query += thisMonth.format('YYYY-MM-dd');
    	return Database.getQueryLocator(query);
   	}

	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
	    Set<Id> oppIdSet = new Set<Id>();
	    List<Balance__c> balanceList = new List<Balance__c>();
	    
	    for(sobject s : scope)
	    {
	    	oppIdSet.add(s.Id); 
	    }
	    
	    List<DB_Notes__c> DNList = [Select Date__c, Amount__c, Opportunity__c 
	    							From DB_Notes__c
	    							Where Opportunity__c IN: oppIdSet]; 
	    
	    for(Opportunity opp : (List<Opportunity>) scope)
	    {
	    	// 从Close Date到当前月份之间的月份数
	    	Integer monthToToday = 0;
	    	monthToToday = (13 - opp.CloseDate.month()) + Date.today().month() + (Date.today().year() - opp.CloseDate.year() - 1) * 12;
	    	
	    	for(Integer i = 1; i <= monthToToday; i++)
	    	{
	    		Balance__c bl = new Balance__c();
	    		
	    		bl.Opportunity__c = opp.Id;
	    		bl.Date__c = opp.CloseDate.addMonths(i).toStartOfMonth().addDays(-1);
	    		bl.Opp_Amount__c = opp.Amount;
	    		
	    		Decimal amount = 0;
	    		Decimal sumamount = 0;
	    		
	    		for(DB_Notes__c dn : DNList)
	    		{
	    			// 统计该月份的Debit Notes Amount总和
	    			if(dn.Date__c >= bl.Date__c.toStartOfMonth() && dn.Date__c <= bl.Date__c && dn.Opportunity__c == opp.Id)
	    			{
	    				if(dn.Amount__c != null)
	    				{
	    					amount += dn.Amount__c;
	    				}
	    			}
	    			
	    			// 统计从Close Date至该月份的所有Debit Notes Amount 总和
	    			if(dn.Date__c >= opp.CloseDate.toStartOfMonth() && dn.Date__c <= bl.Date__c && dn.Opportunity__c == opp.Id)
	    			{
	    				if(dn.Amount__c != null)
	    				{
	    					sumamount += dn.Amount__c;
	    				}
	    			}
	    		}
	    		
	    		bl.DN_Monthly_Amount__c = amount;
	    		bl.DN_Sum_Amount__c = sumamount;
	    		
	    		if(bl.Date__c.month() < 10)
	    		{
	    			bl.OppId_Month__c = opp.Id + String.valueOf(bl.Date__c.year()) + '0' + String.valueOf(bl.Date__c.month());
	    		}
	    		else
	    		{
	    			bl.OppId_Month__c = opp.Id + String.valueOf(bl.Date__c.year()) + String.valueOf(bl.Date__c.month());
	    		}

				balanceList.add(bl);
	    	}
	    }
	    
	    upsert balanceList OppId_Month__c;
    }
    
   	global void finish(Database.BatchableContext BC)
   	{
   			
   	}
   	
   	global void execute(SchedulableContext sc)
   	{
   		OpportunityBalanceBatch obb = new OpportunityBalanceBatch();
   		Database.executeBatch(obb);
   	}
}