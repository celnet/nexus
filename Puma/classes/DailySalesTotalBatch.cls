/*
 * Author: Steven
 * Date: 2014-04-15 
 * Description: 生成全部门店的Daily Sales 数据
 */
global class DailySalesTotalBatch implements Database.Batchable<sObject>, Database.Stateful
{
	global final Date runDate;
	global final String query;
	
	global DailySalesTotalBatch(Date d)
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
		Daily_Sales__c totalDS = new Daily_Sales__c();
		Date__c runDatec = [Select Id From Date__c Where Date__c =: runDate];
		
		totalDS.Date__c = runDatec.Id;
		totalDS.Daily_Sales_Type__c = 'All';
		totalDS.Daily_Sales_External_ID__c = 'All-' + this.runDate;
		
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
		thisYearRawDatas = [Select Billing_Doc__c, GP_Amt__c, Division__c, Sales_Amt__c, Sales_Qty__c, Store__c, Transaction_Date__c From Raw_Data__c Where Transaction_Date__c <=:runDate And Transaction_Date__c >=: runDate.toStartOfMonth()];
		// 去年本月至今(含今天)所有门店的Raw_Data
		lastYearRawDatas = [Select Billing_Doc__c, GP_Amt__c, Division__c, Sales_Amt__c, Sales_Qty__c, Store__c, Transaction_Date__c From Raw_Data__c Where Transaction_Date__c <=:runDate.addYears(-1) And Transaction_Date__c >=: runDate.addYears(-1).toStartOfMonth()];
		

		for(Store__c r : (List<Store__c>) scope)
		{	
			// 赋值Target__c和Sales_Target
			if(allTargets.size() > 0)
			{
				for(Target__c t : allTargets)
				{
					if(t.Store__c == r.Id)
					{
						if(t.Date_Import__c == runDate)
						{
							if(totalDS.Sales_Target_This_Year_New__c == null)
							{
								totalDS.Sales_Target_This_Year_New__c = t.Sales_Volume__c;
							}
							else
							{
								totalDS.Sales_Target_This_Year_New__c += t.Sales_Volume__c;
							}
						}
						if(t.Date_Import__c == runDate.addYears(-1))
						{
							if(totalDS.Sales_Target_Last_Year__c == null)
							{
								totalDS.Sales_Target_Last_Year__c = t.Sales_Volume__c;
							}
							else
							{
								totalDS.Sales_Target_Last_Year__c += t.Sales_Volume__c;
							}
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
							if(totalDS.MTD_Target__c == null)
							{
								totalDS.MTD_Target__c = t.Sales_Volume__c;
							}
							else
							{
								totalDS.MTD_Target__c += t.Sales_Volume__c;
							}
						}
						
						if(totalDS.Monthly_Target__c == null)
						{
							totalDS.Monthly_Target__c = t.Sales_Volume__c;
						}
						else
						{
							totalDS.Monthly_Target__c += t.Sales_Volume__c;
						}
					}
				}
			}
			
			// 赋值今天的Traffic
			if(thisYearTraffics.size() > 0)
			{
				for(Traffic__c t : thisYearTraffics)
				{
					if(t.Store__c == r.Id && t.Traffic_Amount__c != null)
					{
						if(t.Date_Import__c == runDate)
						{
							if(totalDS.Traffic_This_Year__c == null)
							{
								totalDS.Traffic_This_Year__c = t.Traffic_Amount__c;
							}
							else
							{
								totalDS.Traffic_This_Year__c += t.Traffic_Amount__c;
							}
						}

						if(t.Date_Import__c >= runDate.toStartOfMonth() && t.Date_Import__c <= runDate)
						{
							if(totalDS.Traffic_This_Year_MTD__c == null)
							{
								totalDS.Traffic_This_Year_MTD__c = t.Traffic_Amount__c;
							}
							else
							{
								totalDS.Traffic_This_Year_MTD__c += t.Traffic_Amount__c;	
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
							if(totalDS.Traffic_Last_Year__c == null)
							{
								totalDS.Traffic_Last_Year__c = t.Traffic_Amount__c;
							}
							else
							{
								totalDS.Traffic_Last_Year__c += t.Traffic_Amount__c;
							}
						}
						
						if(t.Date_Import__c >= runDate.addYears(-1).toStartOfMonth() && t.Date_Import__c <= runDate.addYears(-1))
						{
							if(totalDS.Traffic_Last_Year_MTD__c == null)
							{
								totalDS.Traffic_Last_Year_MTD__c = t.Traffic_Amount__c;
							}
							else
							{
								totalDS.Traffic_Last_Year_MTD__c += t.Traffic_Amount__c;
							}
						}
					}
				}
			}
			
			// 
			if(thisYearRawDatas.size() > 0)
			{
				// 存放某一billing的今天raw data数量
				Map<String,Double> billingMap = new Map<String,Double>();
				// 存放某一billing的本月至今raw data数量
				Map<String,Double> MTDBillingMap = new Map<String, Double>();
				
				for(Raw_Data__c rdc : thisYearRawDatas)
				{
					if(rdc.Store__c == r.Id)
					{
						if(rdc.Transaction_Date__c == runDate)
						{
							if(rdc.Division__c.contains('服装') || rdc.Division__c.contains('服裝'))
							{
								if(totalDS.Sales_APP__c == null)
								{
									totalDS.Sales_APP__c = rdc.Sales_Amt__c;
								}
								else
								{
									totalDS.Sales_APP__c += rdc.Sales_Amt__c;
								}
								
								if(totalDS.Sales_APP_Net__c == null)
								{
									totalDS.Sales_APP_Net__c = (rdc.Sales_Amt__c/1.17);
								}
								else
								{
									totalDS.Sales_APP_Net__c += (rdc.Sales_Amt__c/1.17);
								}
								
								if(totalDS.GP_APP__c == null)
								{
									totalDS.GP_APP__c = rdc.GP_Amt__c;
								}
								else
								{
									totalDS.GP_APP__c += rdc.GP_Amt__c;
								}
								
								if(totalDS.Unit_APP__c == null)
								{
									totalDS.Unit_APP__c = rdc.Sales_Qty__c;
								}
								else
								{
									totalDS.Unit_APP__c += rdc.Sales_Qty__c;
								}
							}
							
							if(rdc.Division__c.contains('配件'))
							{
								if(totalDS.Sales_ACC__c == null)
								{
									totalDS.Sales_ACC__c = rdc.Sales_Amt__c;
								}
								else
								{
									totalDS.Sales_ACC__c += rdc.Sales_Amt__c;
								}
								
								if(totalDS.Sales_ACC_Net__c == null)
								{
									totalDS.Sales_ACC_Net__c = (rdc.Sales_Amt__c/1.17);
								}
								else
								{
									totalDS.Sales_ACC_Net__c += (rdc.Sales_Amt__c/1.17);
								}
								
								if(totalDS.GP_ACC__c == null)
								{
									totalDS.GP_ACC__c = rdc.GP_Amt__c;
								}
								else
								{
									totalDS.GP_ACC__c += rdc.GP_Amt__c;
								}
								
								if(totalDS.Unit_ACC__c == null)
								{
									totalDS.Unit_ACC__c = rdc.Sales_Qty__c;
								}
								else
								{
									totalDS.Unit_ACC__c += rdc.Sales_Qty__c;
								}
							}
							
							if(rdc.Division__c.contains('鞋'))
							{
								if(totalDS.Sales_FW__c == null)
								{
									totalDS.Sales_FW__c = rdc.Sales_Amt__c;
								}
								else
								{
									totalDS.Sales_FW__c += rdc.Sales_Amt__c;
								}
								
								if(totalDS.Sales_FW_Net__c == null)
								{
									totalDS.Sales_FW_Net__c = (rdc.Sales_Amt__c/1.17);
								}
								else
								{
									totalDS.Sales_FW_Net__c += (rdc.Sales_Amt__c/1.17);
								}
								
								if(totalDS.GP_FW__c == null)
								{
									totalDS.GP_FW__c = rdc.GP_Amt__c;
								}
								else
								{
									totalDS.GP_FW__c += rdc.GP_Amt__c;
								}
								
								if(totalDS.Unit_FW__c == null)
								{
									totalDS.Unit_FW__c = rdc.Sales_Qty__c;
								}
								else
								{
									totalDS.Unit_FW__c += rdc.Sales_Qty__c;
								}
							}
							
							if(billingMap.get(rdc.Billing_Doc__c) == null)
							{
								billingMap.put(rdc.Billing_Doc__c,rdc.Sales_Qty__c);
							}
							else
							{
								billingMap.put(rdc.Billing_Doc__c,billingMap.get(rdc.Billing_Doc__c) + rdc.Sales_Qty__c);
							}
							
						}
						
						if(rdc.Transaction_Date__c <= runDate && rdc.Transaction_Date__c >= runDate.toStartOfMonth())
						{
							if(totalDS.Actual_Sales_This_Year_MTD__c == null)
							{
								totalDS.Actual_Sales_This_Year_MTD__c = rdc.Sales_Amt__c;
							}
							else
							{
								totalDS.Actual_Sales_This_Year_MTD__c += rdc.Sales_Amt__c;
							}
							
							if(totalDS.Actual_Sales_This_Year_MTD_Net__c == null)
							{
								totalDS.Actual_Sales_This_Year_MTD_Net__c = (rdc.Sales_Amt__c/1.17);
							}
							else
							{
								totalDS.Actual_Sales_This_Year_MTD_Net__c += (rdc.Sales_Amt__c/1.17);
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
				
				
				if(totalDS.No_of_Tx_This_Year__c == null)
				{
					totalDS.No_of_Tx_This_Year__c = billingMap.size();
				}
				else
				{
					totalDS.No_of_Tx_This_Year__c += billingMap.size();
				}
				
				if(totalDS.No_of_Tx_This_Year_MTD__c == null)
				{
					totalDS.No_of_Tx_This_Year_MTD__c = MTDBillingMap.size();
				}
				else
				{
					totalDS.No_of_Tx_This_Year_MTD__c += MTDBillingMap.size();
				}
				
				List<Double> billCountList = billingMap.values();
				Integer numberOfBillings = 0;
				for(Double i : billCountList)
				{
					if(i > 2)
					{
						numberOfBillings += 1;
					}
				}
				if(totalDS.Multi_doc__c == null)
				{
					totalDS.Multi_doc__c = numberOfBillings;
				}
				else
				{
					totalDS.Multi_doc__c += numberOfBillings;
				}
			}
			
			// 去年的Raw Data数据
			if(lastYearRawDatas.size() > 0)
			{
				Map<String,Double> lastYearBillingMap = new Map<String, Double>();
				Map<String,Double> MTDLastYearBillingMap = new Map<String, Double>();
				
				for(Raw_Data__c rdc : lastYearRawDatas)
				{
					if(rdc.Store__c == r.Id)
					{
						if(rdc.Transaction_Date__c == runDate.addYears(-1))
						{
							if(totalDS.Actual_Sales_Last_Year__c == null)
							{
								totalDS.Actual_Sales_Last_Year__c = rdc.Sales_Amt__c;
							}
							else
							{
								totalDS.Actual_Sales_Last_Year__c += rdc.Sales_Amt__c;
							}
							
							if(totalDS.Actual_Sales_Last_Year_Net__c == null)
							{
								totalDS.Actual_Sales_Last_Year_Net__c = (rdc.Sales_Amt__c/1.17);
							}
							else
							{
								totalDS.Actual_Sales_Last_Year_Net__c += (rdc.Sales_Amt__c/1.17);
							}
							
							if(lastYearBillingMap.get(rdc.Billing_Doc__c) == null)
							{
								lastYearBillingMap.put(rdc.Billing_Doc__c,rdc.Sales_Qty__c);
							}
							else
							{
								lastYearBillingMap.put(rdc.Billing_Doc__c,lastYearBillingMap.get(rdc.Billing_Doc__c) + rdc.Sales_Qty__c);
							}
							
						}
						
						if(rdc.Transaction_Date__c <= runDate.addYears(-1) && rdc.Transaction_Date__c >= runDate.toStartOfMonth())
						{
							if(totalDS.Actual_Sales_Last_Year_MTD__c == null)
							{
								totalDS.Actual_Sales_Last_Year_MTD__c = rdc.Sales_Amt__c;
							}
							else
							{
								totalDS.Actual_Sales_Last_Year_MTD__c += rdc.Sales_Amt__c;
							}
							
							if(totalDS.Actual_Sales_Last_Year_MTD_Net__c == null)
							{
								totalDS.Actual_Sales_Last_Year_MTD_Net__c = (rdc.Sales_Amt__c/1.17);
							}
							else
							{
								totalDS.Actual_Sales_Last_Year_MTD_Net__c += (rdc.Sales_Amt__c/1.17);
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
				
				if(totalDS.No_of_Tx_Last_Year__c == null)
				{
					totalDS.No_of_Tx_Last_Year__c = lastYearBillingMap.size();
				}
				else
				{
					totalDS.No_of_Tx_Last_Year_MTD__c += lastYearBillingMap.size();
				}
				
				if(totalDS.No_of_Tx_Last_Year_MTD__c == null)
				{
					totalDS.No_of_Tx_Last_Year_MTD__c = MTDLastYearBillingMap.size();
				}
				else
				{
					totalDS.No_of_Tx_Last_Year_MTD__c += MTDLastYearBillingMap.size();
				}
			}
		}
		
		if(totalDS != null)
		{
			upsert totalDS Daily_Sales_External_ID__c;
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		DailySalesByTypeBatch dsbtb = new DailySalesByTypeBatch(runDate);
		Database.executeBatch(dsbtb);
	}
}