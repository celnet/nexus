/*
 * Author: Steven
 * Date: 2014-4-10
 * Description: Batch生成DailySales
 */
global class DailySalesBatch implements Database.Batchable<sObject>, Database.Stateful
{
	global final Date runDate;
	global final String query;
	
	global DailySalesBatch(Date d)
	{
		runDate = d;
		query = 'Select Id From Store__c';
	}
	
	global Database.Querylocator start(Database.BatchableContext BC)
	{ 
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		List<Daily_Sales__c> dsList = new List<Daily_Sales__c>();
		
		Date__c runDatec = [Select Id From Date__c Where Date__c =: runDate limit 1];
		
		List<Target__c> allTargets = new List<Target__c>();
		List<Target__c> thisYearTargets = new List<Target__c>();
		
		List<Billing__c> runDateBillings = new List<Billing__c>();
		List<Traffic__c> thisYearTraffics = new List<Traffic__c>();
		List<Traffic__c> lastYearTraffics = new List<Traffic__c>();
		List<Raw_Data__c> thisYearRawDatas = new List<Raw_Data__c>();
		List<Raw_Data__c> lastYearRawDatas = new List<Raw_Data__c>();
		
		// 今天和去年今天的所有门店Target
		allTargets = [Select Id, Sales_Volume__c, Store__c, Date_Import__c From Target__c Where Date_Import__c =: runDate Or Date_Import__c =: runDate.addYears(-1)];
		
		// 今天和去年今天所有门店Target
		thisYearTargets = [Select Id, Sales_Volume__c, Store__c, Date_Import__c From Target__c Where Date_Import__c <=: runDate.toStartOfMonth().addMonths(1).addDays(-1) And Date_Import__c >=: runDate.toStartOfMonth()];
		
		// 今天所有门店的Billing
		runDateBillings = [Select Id, Store__c From Billing__c Where DateImport__c =: runDate];
		// 本月至今(含今天)所有门店的Traffic
		thisYearTraffics = [Select Traffic_Amount__c, Id, Store__c, Date_Import__c From Traffic__c Where Date_Import__c <=: runDate And Date_Import__c >=: runDate.toStartOfMonth()];
		// 去年本月至今(含今天)所有门店的Traffic
		lastYearTraffics = [Select Traffic_Amount__c, Id, Store__c, Date_Import__c From Traffic__c Where Date_Import__c <=: runDate.addYears(-1) And Date_Import__c >=: runDate.addYears(-1).toStartOfMonth()];
		// 本月至今(含今天)所有门店的Raw_Data
		thisYearRawDatas = [Select Original_Retail_Price__c, Billing_Doc__c, GP_Amt__c, Division__c, Sales_Amt__c, Sales_Qty__c, Store__c, Transaction_Date__c From Raw_Data__c Where Transaction_Date__c <=:runDate And Transaction_Date__c >=: runDate.toStartOfMonth()];
		// 去年本月至今(含今天)所有门店的Raw_Data
		lastYearRawDatas = [Select Original_Retail_Price__c, Billing_Doc__c, GP_Amt__c, Division__c, Sales_Amt__c, Sales_Qty__c, Store__c, Transaction_Date__c From Raw_Data__c Where Transaction_Date__c <=:runDate.addYears(-1) And Transaction_Date__c >=: runDate.addYears(-1).toStartOfMonth()];
		
		for(Store__c r : (List<Store__c>) scope)
		{
			Daily_Sales__c ds = new Daily_Sales__c();
			
			ds.Daily_Sales_Type__c = 'Store';
			ds.Store__c = r.Id;
			ds.Date__c = runDatec.Id;
			
			// 赋值Target__c和Sales_Target
			if(allTargets.size() > 0)
			{
				for(Target__c t : allTargets)
				{
					if(t.Store__c == r.Id)
					{
						if(t.Date_Import__c == runDate)
						{
							ds.Target__c = t.Id;
							ds.Sales_Target_This_Year_New__c = t.Sales_Volume__c;
						}
						if(t.Date_Import__c == runDate.addYears(-1))
						{
							ds.Sales_Target_Last_Year__c = t.Sales_Volume__c;
						}
					}
				}
			}
			
			// 赋值MTDTarget和MonthlyTarget
			if(thisYearTargets.size() > 0)
			{
				for(Target__c t : thisYearTargets)
				{
					if(t.Store__c == r.Id)
					{
						if(t.Date_Import__c >= runDate.toStartOfMonth() && t.Date_Import__c <= runDate)
						{
							if(ds.MTD_Target__c == null)
							{
								ds.MTD_Target__c = t.Sales_Volume__c;
							}
							else
							{
								ds.MTD_Target__c += t.Sales_Volume__c;
							}
						}
						
						if(ds.Monthly_Target__c == null)
						{
							ds.Monthly_Target__c = t.Sales_Volume__c;
						}
						else
						{
							ds.Monthly_Target__c += t.Sales_Volume__c;
						}
					}
				}
			}
			
			// 赋值Billing
			if(runDateBillings.size() > 0)
			{
				for(Billing__c b : runDateBillings)
				{
					if(b.Store__c == r.Id)
					{
						ds.Billing__c = b.Id;
					}
				}
			}
			
			// 赋值今天的Traffic
			if(thisYearTraffics.size() > 0)
			{
				for(Traffic__c t : thisYearTraffics)
				{
					if(t.Store__c == r.Id)
					{
						if(t.Date_Import__c == runDate)
						{
							ds.Traffic_This_Year__c = t.Traffic_Amount__c;
						}

						if(t.Date_Import__c >= runDate.toStartOfMonth() && t.Date_Import__c <= runDate)
						{
							if(ds.Traffic_This_Year_MTD__c == null)
							{
								ds.Traffic_This_Year_MTD__c = t.Traffic_Amount__c;
							}
							else
							{
								ds.Traffic_This_Year_MTD__c += t.Traffic_Amount__c;	
							}
						}
					}
				}
			}
			
			// 赋值去年的Traffic
			if(lastYearTraffics.size() > 0)
			{
				for(Traffic__c t : lastYearTraffics)
				{
					if(t.Store__c == r.Id)
					{
						if(t.Date_Import__c == runDate.addYears(-1))
						{
							ds.Traffic_Last_Year__c = t.Traffic_Amount__c;
						}
						
						if(t.Date_Import__c >= runDate.addYears(-1).toStartOfMonth() && t.Date_Import__c <= runDate.addYears(-1))
						{
							if(ds.Traffic_Last_Year_MTD__c == null)
							{
								ds.Traffic_Last_Year_MTD__c = t.Traffic_Amount__c;
							}
							else
							{
								ds.Traffic_Last_Year_MTD__c += t.Traffic_Amount__c;
							}
						}
					}
				}
			}
			
			// 今年的Raw Data数据
			if(thisYearRawDatas.size() > 0)
			{
				// 存放某一billing的今天sales qty数量
				Map<String,Double> billingMap = new Map<String,Double>();
				// 存放某一billing的本月至今sales qty数量
				Map<String,Double> MTDBillingMap = new Map<String,Double>();
				
				for(Raw_Data__c rdc : thisYearRawDatas)
				{
					if(rdc.Store__c == r.Id)
					{
						if(rdc.Transaction_Date__c == runDate)
						{
							// 计算 Original Retail Price
							if(rdc.Original_Retail_Price__c != null)
							{
								if(ds.Original_Retail_Price_Amount__c == null)
								{
									ds.Original_Retail_Price_Amount__c = rdc.Original_Retail_Price__c;
								}
								else
								{
									ds.Original_Retail_Price_Amount__c += rdc.Original_Retail_Price__c;
								}
							}
							
							// 计算 APP的Sales, GP, Unit
							if(rdc.Division__c.contains('服装') || rdc.Division__c.contains('服裝'))
							{
								if(ds.Sales_APP__c == null)
								{
									ds.Sales_APP__c = rdc.Sales_Amt__c;
								}
								else
								{
									ds.Sales_APP__c += rdc.Sales_Amt__c;
								}
								
								if(ds.Sales_APP_Net__c == null)
								{
									ds.Sales_APP_Net__c = (rdc.Sales_Amt__c/1.17);
								}
								else
								{
									ds.Sales_APP_Net__c += (rdc.Sales_Amt__c/1.17);
								}
								
								if(ds.GP_APP__c == null)
								{
									ds.GP_APP__c = rdc.GP_Amt__c;
								}
								else
								{
									ds.GP_APP__c += rdc.GP_Amt__c;
								}
								
								if(ds.Unit_APP__c == null)
								{
									ds.Unit_APP__c = rdc.Sales_Qty__c;
								}
								else
								{
									ds.Unit_APP__c += rdc.Sales_Qty__c;
								}
							}
							
							// 计算 ACC的Sales, GP, Unit
							if(rdc.Division__c.contains('配件'))
							{
								if(ds.Sales_ACC__c == null)
								{
									ds.Sales_ACC__c = rdc.Sales_Amt__c;
								}
								else
								{
									ds.Sales_ACC__c += rdc.Sales_Amt__c;
								}
								
								if(ds.Sales_ACC_Net__c == null)
								{
									ds.Sales_ACC_Net__c = (rdc.Sales_Amt__c/1.17);
								}
								else
								{
									ds.Sales_ACC_Net__c += (rdc.Sales_Amt__c/1.17);
								}
								
								if(ds.GP_ACC__c == null)
								{
									ds.GP_ACC__c = rdc.GP_Amt__c;
								}
								else
								{
									ds.GP_ACC__c += rdc.GP_Amt__c;
								}
								
								if(ds.Unit_ACC__c == null)
								{
									ds.Unit_ACC__c = rdc.Sales_Qty__c;
								}
								else
								{
									ds.Unit_ACC__c += rdc.Sales_Qty__c;
								}
							}
							
							// 计算FW的Sales, GP, Unit
							if(rdc.Division__c.contains('鞋'))
							{
								if(ds.Sales_FW__c == null)
								{
									ds.Sales_FW__c = rdc.Sales_Amt__c;
								}
								else
								{
									ds.Sales_FW__c += rdc.Sales_Amt__c;
								}
								
								if(ds.Sales_FW_Net__c == null)
								{
									ds.Sales_FW_Net__c = (rdc.Sales_Amt__c/1.17);
								}
								else
								{
									ds.Sales_FW_Net__c += (rdc.Sales_Amt__c/1.17);
								}
								
								if(ds.GP_FW__c == null)
								{
									ds.GP_FW__c = rdc.GP_Amt__c;
								}
								else
								{
									ds.GP_FW__c += rdc.GP_Amt__c;
								}
								
								if(ds.Unit_FW__c == null)
								{
									ds.Unit_FW__c = rdc.Sales_Qty__c;
								}
								else
								{
									ds.Unit_FW__c += rdc.Sales_Qty__c;
								}
							}
							
							
							if(billingMap.get(rdc.Billing_Doc__c) == null)
							{
								billingMap.put(rdc.Billing_Doc__c,1);
							}
							else
							{
								billingMap.put(rdc.Billing_Doc__c,billingMap.get(rdc.Billing_Doc__c) + 1);
							}
							
						}
						
						if(rdc.Transaction_Date__c <= runDate && rdc.Transaction_Date__c >= runDate.toStartOfMonth())
						{
							if(ds.Actual_Sales_This_Year_MTD__c == null)
							{
								ds.Actual_Sales_This_Year_MTD__c = rdc.Sales_Amt__c;
							}
							else
							{
								ds.Actual_Sales_This_Year_MTD__c += rdc.Sales_Amt__c;
							}
							
							if(ds.Actual_Sales_This_Year_MTD_Net__c == null)
							{
								ds.Actual_Sales_This_Year_MTD_Net__c = (rdc.Sales_Amt__c/1.17);
							}
							else
							{
								ds.Actual_Sales_This_Year_MTD_Net__c += (rdc.Sales_Amt__c/1.17);
							}
							
							if(MTDBillingMap.get(rdc.Billing_Doc__c) == null)
							{
								MTDBillingMap.put(rdc.Billing_Doc__c,rdc.Sales_Qty__c);
							}
							else
							{
								MTDBillingMap.put(rdc.Billing_Doc__c, MTDBillingMap.get(rdc.Billing_Doc__c) + rdc.Sales_Qty__c);
							}
						}
					}
				}
				
				
				ds.No_of_Tx_This_Year__c = billingMap.size();
				ds.No_of_Tx_This_Year_MTD__c = MTDBillingMap.size();
				
				List<Double> billCountList = billingMap.values();
				Integer numberOfBillings = 0;
				for(Double i : billCountList)
				{
					if(i > 2)
					{
						numberOfBillings += 1;
					}
				}
				
				ds.Multi_doc__c = numberOfBillings;
			}
			
			// 去年的Raw Data数据
			if(lastYearRawDatas.size() > 0)
			{
				Map<String,Double> lastYearBillingMap = new Map<String,Double>();
				Map<String,Double> MTDLastYearBillingMap = new Map<String,Double>();
				
				for(Raw_Data__c rdc : lastYearRawDatas)
				{
					if(rdc.Store__c == r.Id)
					{
						if(rdc.Transaction_Date__c == runDate.addYears(-1))
						{
							if(ds.Actual_Sales_Last_Year__c == null)
							{
								ds.Actual_Sales_Last_Year__c = rdc.Sales_Amt__c;
							}
							else
							{
								ds.Actual_Sales_Last_Year__c += rdc.Sales_Amt__c;
							}
							
							if(ds.Actual_Sales_Last_Year_MTD_Net__c == null)
							{
								ds.Actual_Sales_Last_Year_MTD_Net__c = (rdc.Sales_Amt__c/1.17);
							}
							else
							{
								ds.Actual_Sales_Last_Year_MTD_Net__c += (rdc.Sales_Amt__c/1.17);
							}
							
							if(lastYearBillingMap.get(rdc.Billing_Doc__c) == null)
							{
								lastYearBillingMap.put(rdc.Billing_Doc__c,1);
							}
							else
							{
								lastYearBillingMap.put(rdc.Billing_Doc__c,lastYearBillingMap.get(rdc.Billing_Doc__c) + 1);
							}
							
						}
						
						if(rdc.Transaction_Date__c <= runDate.addYears(-1) && rdc.Transaction_Date__c >= runDate.toStartOfMonth())
						{
							if(ds.Actual_Sales_Last_Year_MTD__c == null)
							{
								ds.Actual_Sales_Last_Year_MTD__c = rdc.Sales_Amt__c;
							}
							else
							{
								ds.Actual_Sales_Last_Year_MTD__c += rdc.Sales_Amt__c;
							}
							
							if(ds.Actual_Sales_Last_Year_MTD_Net__c == null)
							{
								ds.Actual_Sales_Last_Year_MTD_Net__c = (rdc.Sales_Amt__c/1.17);
							}
							else
							{
								ds.Actual_Sales_Last_Year_MTD_Net__c += (rdc.Sales_Amt__c/1.17);
							}
							
							if(MTDLastYearBillingMap.get(rdc.Billing_Doc__c) == null)
							{
								MTDLastYearBillingMap.put(rdc.Billing_Doc__c, 1);
							}
							else
							{
								MTDLastYearBillingMap.put(rdc.Billing_Doc__c, MTDLastYearBillingMap.get(rdc.Billing_Doc__c) + 1);
							}
						}
					}
				}
				
				ds.No_of_Tx_Last_Year__c = lastYearBillingMap.size();
				ds.No_of_Tx_Last_Year_MTD__c = MTDLastYearBillingMap.size();
			}
			ds.Daily_Sales_External_ID__c = this.runDate + '-' + r.Id; 
			dsList.add(ds);
		}
		
		if(dsList.size() > 0)
		{
			upsert dsList Daily_Sales_External_ID__c;
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		DailySalesTotalBatch dstb = new DailySalesTotalBatch(runDate);
		Database.executeBatch(dstb);
	}
}