/*
 * Author: Steven
 * Date: 2014-4-10
 * Description: Batch生成DailySales
 */
global class DailySalesNewBatch implements Database.Batchable<sObject>, Database.Stateful
{
	global final Date runDate;
	
	global Daily_Sales__c totalDS;
	global Map<String, Daily_Sales__c> dsByTypeMap;
	global List<Daily_Sales__c> dsList;
	
	global DailySalesNewBatch(Date d)
	{
		runDate = d;
		
		totalDS = new Daily_Sales__c();
		totalDS.Date2__c = runDate;
		totalDS.Daily_Sales_Type__c = 'All';
		totalDS.Daily_Sales_External_ID__c = 'All-' + this.runDate;
		
		dsByTypeMap = new Map<String, Daily_Sales__c>();
		
		dsList = new List<Daily_Sales__c>();
	}
	
	global Database.Querylocator start(Database.BatchableContext BC)
	{ 
		return Database.getQueryLocator([Select Id,Store_Type__c From Store__c]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		List<Target__c> allTargets = new List<Target__c>();
		List<Target__c> thisYearTargets = new List<Target__c>();
		
		List<Billing__c> runDateBillings = new List<Billing__c>();
		List<Traffic__c> thisYearTraffics = new List<Traffic__c>();
		List<Traffic__c> lastYearTraffics = new List<Traffic__c>();
		List<Raw_Data__c> thisYearRawDatas = new List<Raw_Data__c>();
		List<Raw_Data__c> lastYearRawDatas = new List<Raw_Data__c>();
		
		
		for(Store__c r : (List<Store__c>) scope)
		{
			// 今天和去年今天的所有门店Target
			allTargets = [Select 
								Id, Sales_Volume__c, Store__c, Date_Import__c 
							From 
								Target__c 
							Where 
								(Date_Import__c =: runDate Or Date_Import__c =: runDate.addYears(-1))
							And 
								Store__c =: r.Id];
			
			// 今天和去年今天所有门店Target
			thisYearTargets = [Select 
									Id, Sales_Volume__c, Store__c, Date_Import__c 
								From 
									Target__c 
								Where 
									Date_Import__c <=: runDate.toStartOfMonth().addMonths(1).addDays(-1) 
								And 
									Date_Import__c >=: runDate.toStartOfMonth()
								And 
									Store__c =: r.Id];
			
			// 今天所有门店的Billing
			runDateBillings = [Select 
									Id, 
									Store__c 
								From 
									Billing__c 
								Where 
									DateImport__c =: runDate 
								And 
									Store__c =: r.Id];
									
			// 本月至今(含今天)所有门店的Traffic
			thisYearTraffics = [Select 
									Traffic_Amount__c, Id, Store__c, Date_Import__c 
								From 
									Traffic__c 
								Where 
									Date_Import__c <=: runDate 
								And 
									Date_Import__c >=: runDate.toStartOfMonth()
								And 
									Store__c =: r.Id];
									
			// 去年本月至今(含今天)所有门店的Traffic
			lastYearTraffics = [Select 
									Traffic_Amount__c, Id, Store__c, Date_Import__c 
								From 
									Traffic__c 
								Where 
									Date_Import__c <=: runDate.addYears(-1) 
								And 
									Date_Import__c >=: runDate.addYears(-1).toStartOfMonth()
								And 
									Store__c =: r.Id];
			// 本月至今(含今天)所有门店的Raw_Data
			thisYearRawDatas = [Select 
									Original_Retail_Price__c, Billing_Doc__c, GP_Amt__c, Division__c, Sales_Amt__c, Sales_Qty__c, Store__c, Transaction_Date__c 
								From 
									Raw_Data__c 
								Where 
									Transaction_Date__c <=:runDate 
								And 
									Transaction_Date__c >=: runDate.toStartOfMonth()
								And 
									Store__c =: r.Id];
			// 去年本月至今(含今天)所有门店的Raw_Data
			lastYearRawDatas = [Select 
									Original_Retail_Price__c, Billing_Doc__c, GP_Amt__c, Division__c, Sales_Amt__c, Sales_Qty__c, Store__c, Transaction_Date__c 
								From 
									Raw_Data__c 
								Where 
									Transaction_Date__c <=:runDate.addYears(-1) 
								And 
									Transaction_Date__c >=: runDate.addYears(-1).toStartOfMonth()
								And 
									Store__c =: r.Id];
			
			Daily_Sales__c ds = new Daily_Sales__c();
			
			ds.Daily_Sales_Type__c = 'Store';
			ds.Store__c = r.Id;
			ds.Date2__c = runDate;
			
			if(r.Store_Type__c == null)
			{
				continue;
			}
			
			Daily_Sales__c dsByType = new Daily_Sales__c();
			
			if(dsByTypeMap.get(r.Store_Type__c) == null)
			{
				dsByType.Date2__c = runDate;
				dsByType.Daily_Sales_Type__c = 'Store Type';
				dsByType.Store_Type__c = r.Store_Type__c;
				dsByType.Daily_Sales_External_ID__c = this.runDate + '-' + 'Store Type-' + r.Store_Type__c;
			}
			else
			{
				dsByType = dsByTypeMap.get(r.Store_Type__c);
			}
			
			
		}
	}
	
	private void assignTargets(Store__c r, List<Target__c> targetList, Daily_Sales__c dsStore, Daily_Sales__c dsTotal, Daily_Sales__c dsType)
	{
		if(targetList.size() > 0)
		{
			for(Target__c t : targetList)
			{
				if(t.Store__c == r.Id)
				{
					if(t.Date_Import__c == runDate)
					{
						dsStore.Target__c = t.Id;
						dsStore.Sales_Target_This_Year_New__c = t.Sales_Volume__c;
						if(dsTotal.Sales_Target_This_Year_New__c == null)
						{
							dsTotal.Sales_Target_This_Year_New__c = t.Sales_Volume__c;
						}
						else
						{
							dsTotal.Sales_Target_This_Year_New__c += t.Sales_Volume__c;
						}
						
						if(dsType.Sales_Target_This_Year_New__c == null)
						{
							dsType.Sales_Target_This_Year_New__c = t.Sales_Volume__c;
						}
						else
						{
							dsType.Sales_Target_This_Year_New__c += t.Sales_Volume__c;
						}
					}
					
					if(t.Date_Import__c == runDate.addYears(-1))
					{
						dsStore.Sales_Target_Last_Year__c = t.Sales_Volume__c;
						
						if(dsTotal.Sales_Target_Last_Year__c == null)
						{
							dsTotal.Sales_Target_Last_Year__c = t.Sales_Volume__c;
						}
						else
						{
							dsTotal.Sales_Target_Last_Year__c += t.Sales_Volume__c;
						}
						
						if(dsType.Sales_Target_This_Year_New__c == null)
						{
							dsType.Sales_Target_This_Year_New__c = t.Sales_Volume__c;
						}
						else
						{
							dsType.Sales_Target_This_Year_New__c += t.Sales_Volume__c;
						}
					}
				}
			}
		}
	}
	
	private void assignMonthlyTargets(Store__c r, List<Target__c> monthlyTargetList, Daily_Sales__c dsStore, Daily_Sales__c dsTotal, Daily_Sales__c dsType)
	{
		if(monthlyTargetList.size() > 0)
		{
			for(Target__c t : monthlyTargetList)
			{
				if(t.Store__c == r.Id)
				{
					if(t.Date_Import__c >= runDate.toStartOfMonth() && t.Date_Import__c <= runDate)
					{
						if(dsStore.MTD_Target__c == null)
						{
							dsStore.MTD_Target__c = t.Sales_Volume__c;
						}
						else
						{
							dsStore.MTD_Target__c += t.Sales_Volume__c;
						}
						
						if(dsTotal.MTD_Target__c == null)
						{
							dsTotal.MTD_Target__c = t.Sales_Volume__c;
						}
						else
						{
							dsTotal.MTD_Target__c += t.Sales_Volume__c;
						}
						
						if(dsType.MTD_Target__c == null)
						{
							dsType.MTD_Target__c = t.Sales_Volume__c;
						}
						else
						{
							dsType.MTD_Target__c += t.Sales_Volume__c;
						}
					}
					
					if(dsStore.Monthly_Target__c == null)
					{
						dsStore.Monthly_Target__c = t.Sales_Volume__c;
					}
					else
					{
						dsStore.Monthly_Target__c += t.Sales_Volume__c;
					}
					
					if(dsTotal.Sales_Target_Last_Year__c == null)
					{
						dsTotal.Sales_Target_Last_Year__c = t.Sales_Volume__c;
					}
					else
					{
						dsTotal.Sales_Target_Last_Year__c += t.Sales_Volume__c;
					}
					
					if(dsType.Monthly_Target__c == null)
					{
						dsType.Monthly_Target__c = t.Sales_Volume__c;
					}
					else
					{
						dsType.Monthly_Target__c += t.Sales_Volume__c;
					}
				}
			}
		}
	}
	
	private void assignThisYearTraffics(Store__c r, List<Traffic__c> thisYearTrafficList, Daily_Sales__c dsStore, Daily_Sales__c dsTotal, Daily_Sales__c dsType)
	{
		
	}
	
	private void assignLastYearTraffics(Store__c r, List<Traffic__c> lastYearTrafficList, Daily_Sales__c dsStore, Daily_Sales__c dsTotal, Daily_Sales__c dsType)
	{
		
	}
	
	private void assignThisYearRawData(Store__c r, List<Raw_Data__c> thisYearRawDataList, Daily_Sales__c dsStore, Daily_Sales__c dsTotal, Daily_Sales__c dsType)
	{
		
	}
	
	private void assignLastyearRawData(Store__c r, List<Raw_Data__c> lastYearRawDataList, Daily_Sales__c dsStore, Daily_Sales__c dsTotal, Daily_Sales__c dsType)
	{
		
	}
	
	global void finish(Database.BatchableContext BC)
	{
		if(dsList.size() > 0)
		{
			upsert dsList Daily_Sales_External_ID__c;
		}
		
		// DailySalesTotalBatch dstb = new DailySalesTotalBatch(runDate);
		// Database.executeBatch(dstb,1);
	}
}
