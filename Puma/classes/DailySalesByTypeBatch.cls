/*
 * Author: Steven
 * Date: 2014-4-10
 * Description: Batch,按门店类别生成DailySales
 */
global class DailySalesByTypeBatch implements Database.Batchable<sObject>
{
	global final Date runDate;
	global final String query;
	
	global DailySalesByTypeBatch(Date d)
	{
		runDate = d;
		query = 'Select Id,Store_Type__c From Store__c';
	}
	
	global Database.Querylocator start(Database.BatchableContext BC)
	{ 
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		Map<String, Daily_Sales__c> dsByTypeMap = new Map<String, Daily_Sales__c>();
		
		Date__c runDatec = [Select Id From Date__c Where Date__c =: runDate];
		
		List<Target__c> allTargets = new List<Target__c>();
		List<Target__c> thisYearTargets = new List<Target__c>();
		
		List<Billing__c> runDateBillings = new List<Billing__c>();
		List<Traffic__c> thisYearTraffics = new List<Traffic__c>();
		List<Traffic__c> lastYearTraffics = new List<Traffic__c>();
		List<Raw_Data__c> thisYearRawDatas = new List<Raw_Data__c>();
		List<Raw_Data__c> lastYearRawDatas = new List<Raw_Data__c>();
		
		allTargets = [Select Id, Sales_Volume__c, Store__c, Store__r.Store_Type__c, Date_Import__c From Target__c Where Date_Import__c =: runDate Or Date_Import__c =: runDate.addYears(-1)];
		// 今天和去年今天所有门店Target
		thisYearTargets = [Select Id, Sales_Volume__c, Store__c, Date_Import__c From Target__c Where Date_Import__c <=: runDate.toStartOfMonth().addMonths(1).addDays(-1) And Date_Import__c >=: runDate.toStartOfMonth()];
		
		runDateBillings = [Select Id, Store__c, Store__r.Store_Type__c From Billing__c Where DateImport__c =: runDate];
		thisYearTraffics = [Select Traffic_Amount__c, Id, Store__c, Store__r.Store_Type__c, Date_Import__c From Traffic__c Where Date_Import__c <=: runDate And Date_Import__c >=: runDate.toStartOfMonth()];
		lastYearTraffics = [Select Traffic_Amount__c, Id, Store__c, Store__r.Store_Type__c, Date_Import__c From Traffic__c Where Date_Import__c <=: runDate.addYears(-1) And Date_Import__c >=: runDate.addYears(-1).toStartOfMonth()];
		thisYearRawDatas = [Select Billing_Doc__c, GP_Amt__c, Division__c, Sales_Amt__c, Sales_Qty__c, Store__c, Store__r.Store_Type__c, Transaction_Date__c From Raw_Data__c Where Transaction_Date__c <=:runDate And Transaction_Date__c >=: runDate.toStartOfMonth()];
		lastYearRawDatas = [Select Billing_Doc__c, GP_Amt__c, Division__c, Sales_Amt__c, Sales_Qty__c, Store__c, Store__r.Store_Type__c, Transaction_Date__c From Raw_Data__c Where Transaction_Date__c <=:runDate.addYears(-1) And Transaction_Date__c >=: runDate.addYears(-1).toStartOfMonth()];
		
		for(Store__c r : (List<Store__c>) scope)
		{
			if(r.Store_Type__c == null)
			{
				continue;
			}
			
			Daily_Sales__c dsByType = new Daily_Sales__c();
			dsByType.Date__c = runDatec.Id;
			
			if(dsByTypeMap.get(r.Store_Type__c) == null)
			{
				dsByType.Daily_Sales_Type__c = 'Store Type';
				dsByType.Store_Type__c = r.Store_Type__c;
				dsByType.Daily_Sales_External_ID__c = this.runDate + '-' + 'Store Type-' + r.Store_Type__c;
			}
			else
			{
				dsByType = dsByTypeMap.get(r.Store_Type__c);
			}
			
			if(allTargets.size() > 0)
			{
				for(Target__c t : allTargets)
				{
					if(t.Store__c == r.Id)
					{
						if(t.Date_Import__c == runDate)
						{
							if(dsByType.Sales_Target_This_Year_New__c == null)
							{
								dsByType.Sales_Target_This_Year_New__c = t.Sales_Volume__c;
							}
							else
							{
								dsByType.Sales_Target_This_Year_New__c += t.Sales_Volume__c;
							}
						}
						if(t.Date_Import__c == runDate.addYears(-1))
						{
							if(dsByType.Sales_Target_Last_Year__c == null)
							{
								dsByType.Sales_Target_Last_Year__c = t.Sales_Volume__c;
							}
							else
							{
								dsByType.Sales_Target_Last_Year__c += t.Sales_Volume__c;
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
							if(dsByType.MTD_Target__c == null)
							{
								dsByType.MTD_Target__c = t.Sales_Volume__c;
							}
							else
							{
								dsByType.MTD_Target__c += t.Sales_Volume__c;
							}
						}
						
						if(dsByType.Monthly_Target__c == null)
						{
							dsByType.Monthly_Target__c = t.Sales_Volume__c;
						}
						else
						{
							dsByType.Monthly_Target__c += t.Sales_Volume__c;
						}
					}
				}
			}
			
			if(thisYearTraffics.size() > 0)
			{
				for(Traffic__c t : thisYearTraffics)
				{
					if(t.Traffic_Amount__c == null)
					{
						t.Traffic_Amount__c = 0;	
					}	
					
					if(t.Store__c == r.Id)
					{
						if(t.Date_Import__c == runDate)
						{
							if(dsByType.Traffic_This_Year__c == null)
							{
								dsByType.Traffic_This_Year__c = t.Traffic_Amount__c;
							}
							else
							{
								dsByType.Traffic_This_Year__c += t.Traffic_Amount__c;
							}
						}

						if(t.Date_Import__c >= runDate.toStartOfMonth() && t.Date_Import__c <= runDate)
						{
							if(dsByType.Traffic_This_Year_MTD__c == null)
							{
								dsByType.Traffic_This_Year_MTD__c = t.Traffic_Amount__c;
							}
							else
							{
								dsByType.Traffic_This_Year_MTD__c += t.Traffic_Amount__c;	
							}
						}
					}
				}
			}
			
			if(lastYearTraffics.size() > 0)
			{
				for(Traffic__c t : lastYearTraffics)
				{
					if(t.Traffic_Amount__c == null)
					{
						t.Traffic_Amount__c = 0;	
					}
					
					if(t.Store__c == r.Id)
					{
						if(t.Date_Import__c == runDate.addYears(-1))
						{
							if(dsByType.Traffic_Last_Year__c == null)
							{
								dsByType.Traffic_Last_Year__c = t.Traffic_Amount__c;
							}
							else
							{
								dsByType.Traffic_Last_Year__c += t.Traffic_Amount__c;
							}
						}
						
						if(t.Date_Import__c >= runDate.addYears(-1).toStartOfMonth() && t.Date_Import__c <= runDate.addYears(-1))
						{
							if(dsByType.Traffic_Last_Year_MTD__c == null)
							{
								dsByType.Traffic_Last_Year_MTD__c = t.Traffic_Amount__c;
							}
							else
							{
								dsByType.Traffic_Last_Year_MTD__c += t.Traffic_Amount__c;
							}
						}
					}
				}
			}
			
			if(thisYearRawDatas.size() > 0)
			{
				Map<String,Double> billingMap = new Map<String,Double>();
				Map<String,Double> MTDBillingMap = new Map<String, Double>();
				
				for(Raw_Data__c rdc : thisYearRawDatas)
				{
					if(rdc.Store__c == r.Id)
					{
						if(rdc.Transaction_Date__c == runDate)
						{
							if(rdc.Division__c.contains('服'))
							{
								if(dsByType.Sales_APP__c == null)
								{
									dsByType.Sales_APP__c = rdc.Sales_Amt__c;
								}
								else
								{
									dsByType.Sales_APP__c += rdc.Sales_Amt__c;
								}
								
								if(dsByType.Sales_APP_Net__c == null)
								{
									dsByType.Sales_APP_Net__c = (rdc.Sales_Amt__c/1.17);
								}
								else
								{
									dsByType.Sales_APP_Net__c += (rdc.Sales_Amt__c/1.17);
								}
								
								if(dsByType.GP_APP__c == null)
								{
									dsByType.GP_APP__c = rdc.GP_Amt__c;
								}
								else
								{
									dsByType.GP_APP__c += rdc.GP_Amt__c;
								}
								
								if(dsByType.Unit_APP__c == null)
								{
									dsByType.Unit_APP__c = rdc.Sales_Qty__c;
								}
								else
								{
									dsByType.Unit_APP__c += rdc.Sales_Qty__c;
								}
							}
							
							if(rdc.Division__c.contains('配件'))
							{
								if(dsByType.Sales_ACC__c == null)
								{
									dsByType.Sales_ACC__c = rdc.Sales_Amt__c;
								}
								else
								{
									dsByType.Sales_ACC__c += rdc.Sales_Amt__c;
								}
								
								if(dsByType.Sales_ACC_Net__c == null)
								{
									dsByType.Sales_ACC__c = (rdc.Sales_Amt__c/1.17);
								}
								else
								{
									dsByType.Sales_ACC_Net__c += (rdc.Sales_Amt__c/1.17);
								}
								
								if(dsByType.GP_ACC__c == null)
								{
									dsByType.GP_ACC__c = rdc.GP_Amt__c;
								}
								else
								{
									dsByType.GP_ACC__c += rdc.GP_Amt__c;
								}
								
								if(dsByType.Unit_ACC__c == null)
								{
									dsByType.Unit_ACC__c = rdc.Sales_Qty__c;
								}
								else
								{
									dsByType.Unit_ACC__c += rdc.Sales_Qty__c;
								}
							}
							
							if(rdc.Division__c.contains('鞋'))
							{
								if(dsByType.Sales_FW__c == null)
								{
									dsByType.Sales_FW__c = rdc.Sales_Amt__c;
								}
								else
								{
									dsByType.Sales_FW__c += rdc.Sales_Amt__c;
								}
								
								if(dsByType.Sales_FW_Net__c == null)
								{
									dsByType.Sales_FW_Net__c = (rdc.Sales_Amt__c/1.17);
								}
								else
								{
									dsByType.Sales_FW_Net__c += (rdc.Sales_Amt__c/1.17);
								}
								
								if(dsByType.GP_FW__c == null)
								{
									dsByType.GP_FW__c = rdc.GP_Amt__c;
								}
								else
								{
									dsByType.GP_FW__c += rdc.GP_Amt__c;
								}
								
								if(dsByType.Unit_FW__c == null)
								{
									dsByType.Unit_FW__c = rdc.Sales_Qty__c;
								}
								else
								{
									dsByType.Unit_FW__c += rdc.Sales_Qty__c;
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
							if(dsByType.Actual_Sales_This_Year_MTD__c == null)
							{
								dsByType.Actual_Sales_This_Year_MTD__c = rdc.Sales_Amt__c;
							}
							else
							{
								dsByType.Actual_Sales_This_Year_MTD__c += rdc.Sales_Amt__c;
							}
							
							if(dsByType.Actual_Sales_This_Year_MTD_Net__c == null)
							{
								dsByType.Actual_Sales_This_Year_MTD_Net__c = (rdc.Sales_Amt__c/1.17);
							}
							else
							{
								dsByType.Actual_Sales_Last_Year_MTD_Net__c += (rdc.Sales_Amt__c/1.17);
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
				
				
				if(dsByType.No_of_Tx_This_Year__c == null)
				{
					dsByType.No_of_Tx_This_Year__c = billingMap.size();
				}
				else
				{
					dsByType.No_of_Tx_This_Year__c += billingMap.size();
				}
				
				if(dsByType.No_of_Tx_This_Year_MTD__c == null)
				{
					dsByType.No_of_Tx_This_Year_MTD__c = MTDBillingMap.size();
				}
				else
				{
					dsByType.No_of_Tx_This_Year_MTD__c += MTDBillingMap.size();
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
				
				if(dsByType.Multi_doc__c == null)
				{
					dsByType.Multi_doc__c = numberOfBillings;
				}
				else
				{
					dsByType.Multi_doc__c += numberOfBillings;
				}
			}
			
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
							if(dsByType.Actual_Sales_Last_Year__c == null)
							{
								dsByType.Actual_Sales_Last_Year__c = rdc.Sales_Amt__c;
							}
							else
							{
								dsByType.Actual_Sales_Last_Year__c += rdc.Sales_Amt__c;
							}
							
							if(dsByType.Actual_Sales_Last_Year_MTD_Net__c == null)
							{
								dsByType.Actual_Sales_Last_Year_MTD_Net__c = (rdc.Sales_Amt__c/1.17);
							}
							else
							{
								dsByType.Actual_Sales_Last_Year_MTD_Net__c += (rdc.Sales_Amt__c/1.17);
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
							if(dsByType.Actual_Sales_Last_Year_MTD__c == null)
							{
								dsByType.Actual_Sales_Last_Year_MTD__c = rdc.Sales_Amt__c;
							}
							else
							{
								dsByType.Actual_Sales_Last_Year_MTD__c += rdc.Sales_Amt__c;
							}
							
							if(dsByType.Actual_Sales_Last_Year_MTD_Net__c == null)
							{
								dsByType.Actual_Sales_Last_Year_MTD_Net__c = (rdc.Sales_Amt__c/1.17);
							}
							else
							{
								dsByType.Actual_Sales_Last_Year_MTD_Net__c += (rdc.Sales_Amt__c/1.17);
							}
							
							if(MTDLastYearBillingMap.get(rdc.Billing_Doc__c) == null)
							{
								MTDLastYearBillingMap.put(rdc.Billing_Doc__c, rdc.Sales_Qty__c);
							}
							else
							{
								MTDLastYearBillingMap.put(rdc.Billing_Doc__c, MTDLastYearBillingMap.get(rdc.Billing_Doc__c) + rdc.Sales_Qty__c);
							}
						}
					}
				}
				
				if(dsByType.No_of_Tx_Last_Year__c == null)
				{
					dsByType.No_of_Tx_Last_Year__c = lastYearBillingMap.size();
				}
				else
				{
					dsByType.No_of_Tx_Last_Year__c += lastYearBillingMap.size();
				}
				
				if(dsByType.No_of_Tx_Last_Year_MTD__c == null)
				{
					dsByType.No_of_Tx_Last_Year_MTD__c = MTDLastYearBillingMap.size();
				}
				else
				{
					dsByType.No_of_Tx_Last_Year_MTD__c += MTDLastYearBillingMap.size();
				}
			}
			
			dsByTypeMap.put(r.Store_Type__c,dsByType);
		}
		
		if(dsByTypeMap != null)
		{
			if(dsByTypeMap.values() != null)
			{
				if(dsByTypeMap.values().size() > 0)
				{
					List<Daily_Sales__c> dsByTypeList = dsByTypeMap.values();
					upsert dsByTypeList Daily_Sales_External_ID__c;
				}
			}
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
}