/*
 * 
 *
 *
 */
global class WeeklyDashboardBatch implements Database.Batchable<sObject>, Database.Stateful
{
	global Date weekStartDate;
	global Date weekEndDate;
	global String weekNumber;
	
	String query;
	global List<Target__c> targetList;
	global List<Store__c> storeList;
	
	// <store type, weeklydashboard>
	global Map<String, Weekly_Dashboard__c> totalWD;
	// <store type + region, <region, weeklydashboard>>
	global Map<String, Weekly_Dashboard__c> regionWD;
	// <store, weeklydashboard>
	global Map<String, Weekly_Dashboard__c> storeWD;
	
	global WeeklyDashboardBatch(Date d)
	{
		this.assignWeekInfo(d);
		this.targetList = [Select 
								Id,
								Store__c,
								Store__r.Region__c,
								Store__r.Store_Type__c,
								UPT__c, 
								Sales_Volume__c, 
								Date__c, 
								Conversion_Rate__c, ASP__c 
							From Target__c 
							Where Date_Import__c >=: this.weekStartDate 
							And Date_Import__c <=: this.weekEndDate];
		this.storeList = [Select Id, Store_Type__c, Region__c From Store__c];
		this.totalWD = new Map<String, Weekly_Dashboard__c>();
		this.regionWD = new Map<String, Weekly_Dashboard__c>();
		this.storeWD = new Map<String, Weekly_Dashboard__c>();
	}
	
	global Database.Querylocator start(Database.BatchableContext BC)
	{ 
		return Database.getQueryLocator([Select 
											Id, 
											Unit_TTL__c, 
											Traffic_This_Year__c, 
											Store__r.Store_Type__c, 
											Store__r.Region__c, 
											Store__c, 
											Sales_FW_Net__c, 
											Sales_APP_Net__c, 
											Sales_ACC_Net__c, 
											No_of_Tx_This_Year__c, 
											Original_Retail_Price_Amount__c,
											GP_TTL__c,
											Actual_Sales_This_Year_Net__c, 
											Actual_Sales_This_Year_MTD_Net__c, 
											Actual_Sales_Last_Year_Net__c, 
											Actual_Sales_Last_Year_MTD_Net__c 
										From 
											Daily_Sales__c 
										Where 
											Date__r.Date__c >=: this.weekStartDate 
										And 
											Date__r.Date__c <=: this.weekEndDate]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		for(Store__c st : this.storeList)
		{
			String storeTypeRegion = st.Store_Type__c + '' + st.Region__c;
			
			Weekly_Dashboard__c tWD;
			Weekly_Dashboard__c rWD;
			Weekly_Dashboard__c sWD;
			
			if(this.totalWD.get(st.Store_Type__c) == null)
			{
				tWD = new Weekly_Dashboard__c();
				tWD.Week_Start_Date__c = this.weekStartDate;
				tWD.Week_End_Date__c = this.weekEndDate;
				tWD.Week_Number__c = this.weekNumber;
				tWD.Weekly_Dashboard_Type__c = 'Total';
				tWD.Store_Type__c = st.Store_Type__c;
				tWD.WeeklyDashboard_External_ID__c = this.weekNumber + '-Total-' + st.Store_Type__c;
			}
			else
			{
				tWD = this.totalWD.get(st.Store_Type__c);
			}
			
			if(this.regionWD.get(storeTypeRegion) == null)
			{
				rWD = new Weekly_Dashboard__c();
				rWD.Week_Start_Date__c = this.weekStartDate;
				rWD.Week_End_Date__c = this.weekEndDate;
				rWD.Week_Number__c = this.weekNumber;
				rWD.Weekly_Dashboard_Type__c = 'Region';
				rWD.Store_Type__c = st.Store_Type__c;
				rWD.Region__c = st.Region__c;
				rWD.WeeklyDashboard_External_ID__c = this.weekNumber + '-Region-' + st.Region__c + '-' + st.Store_Type__c;
			}
			else
			{
				rWD = this.regionWD.get(storeTypeRegion);
			}
			
			if(this.storeWD.get(st.Id) == null)
			{
				sWD = new Weekly_Dashboard__c();
				sWD.Week_Start_Date__c = this.weekStartDate;
				sWD.Week_End_Date__c = this.weekEndDate;
				sWD.Week_Number__c = this.weekNumber;
				sWD.Weekly_Dashboard_Type__c = 'Store';
				sWD.Store__c = st.Id;
				sWD.WeeklyDashboard_External_ID__c = this.weekNumber + '-Store-' + st.Id;
			}
			else
			{
				sWD = this.storeWD.get(st.Id);
			}
			
			for(Daily_Sales__c ds : (List<Daily_Sales__c>) scope)
			{
				if(ds.Store__c == st.Id)
				{
					this.sumSales(sWD, ds);
					this.sumSales(tWD, ds);
					this.sumSales(rWD, ds);
					
					if(ds.Date__r.Date__c == this.weekEndDate)
					{
						sWD.MTD_Sales_Last_Year__c = ds.Actual_Sales_Last_Year_MTD_Net__c;
						sWD.MTD_Sales_This_Year__c = ds.Actual_Sales_This_Year_MTD_Net__c;
						sWD.MTD_Traffic_Last_Year__c = ds.Traffic_Last_Year_MTD__c;
						sWD.MTD_Traffic_This_Year__c = ds.Traffic_This_Year_MTD__c;
						
						this.sumMTDSales(tWD, ds);
						this.sumMTDSales(rWD, ds);
					}
				}
			}
			
			for(Target__c t : targetList)
			{
				if(t.Store__c == st.Id)
				{
					this.sumTargets(sWD, t);
					this.sumTargets(tWD, t);
					this.sumTargets(rWD, t);
				}
			}
			
			this.totalWD.put(st.Store_Type__c,tWD);
			this.regionWD.put(storeTypeRegion,rWD);
			this.storeWD.put(st.Id,sWD);
		}
	}
	
	private void sumSales(Weekly_Dashboard__c wd, Daily_Sales__c ds)
	{
		if(wd.ACC_Sales__c == null)
		{
			wd.ACC_Sales__c = ds.Sales_ACC_Net__c;
		}
		else
		{
			wd.ACC_Sales__c += ds.Sales_ACC_Net__c;
		}
		
		if(wd.APP_Sales__c == null)
		{
			wd.APP_Sales__c = ds.Sales_APP_Net__c;
		}
		else
		{
			wd.APP_Sales__c += ds.Sales_APP_Net__c;
		}
		
		if(wd.FTW_Sales__c == null)
		{
			wd.FTW_Sales__c = ds.Sales_FW_Net__c;
		}
		else
		{
			wd.FTW_Sales__c += ds.Sales_FW_Net__c;
		}
		
		if(wd.GP_Amount__c == null)
		{
			wd.GP_Amount__c = ds.GP_TTL__c;
		}
		else
		{
			wd.GP_Amount__c += ds.GP_TTL__c;
		}
		
		if(wd.Traffic_This_Year__c == null)
		{
			wd.Traffic_This_Year__c = ds.Traffic_This_Year__c;
		}
		else
		{
			wd.Traffic_This_Year__c += ds.Traffic_This_Year__c;
		}
		
		if(wd.Sales_Unit__c == null)
		{
			wd.Sales_Unit__c = ds.Unit_TTL__c;
		}
		else
		{
			wd.Sales_Unit__c += ds.Unit_TTL__c;
		}
		
		if(wd.Original_Retail_Price__c == null)
		{
			wd.Original_Retail_Price__c = ds.Original_Retail_Price_Amount__c;
		}
		else
		{
			wd.Original_Retail_Price__c += ds.Original_Retail_Price_Amount__c;
		}
		
		if(wd.No_of_Tx_This_Year__c == null)
		{
			wd.No_of_Tx_This_Year__c = ds.No_of_Tx_This_Year__c;
		}
		else
		{
			wd.No_of_Tx_This_Year__c += ds.No_of_Tx_This_Year__c;
		}
	}
	
	private void sumMTDSales(Weekly_Dashboard__c wd, Daily_Sales__c ds)
	{
		if(wd.MTD_Sales_Last_Year__c == null)
		{
			wd.MTD_Sales_Last_Year__c = ds.Actual_Sales_Last_Year_MTD_Net__c;
		}
		else
		{
			wd.MTD_Sales_Last_Year__c += ds.Actual_Sales_Last_Year_MTD_Net__c;
		}
		
		if(wd.MTD_Sales_This_Year__c == null)
		{
			wd.MTD_Sales_This_Year__c = ds.Actual_Sales_This_Year_MTD_Net__c;
		}
		else
		{
			wd.MTD_Sales_This_Year__c += ds.Actual_Sales_This_Year_MTD_Net__c;
		}
		
		if(wd.MTD_Traffic_Last_Year__c == null)
		{
			wd.MTD_Traffic_Last_Year__c = ds.Traffic_Last_Year_MTD__c;
		}
		else
		{
			wd.MTD_Traffic_Last_Year__c += ds.Traffic_Last_Year_MTD__c;
		}
		
		if(wd.MTD_Traffic_This_Year__c == null)
		{
			wd.MTD_Traffic_This_Year__c = ds.Traffic_This_Year_MTD__c;
		}
		else
		{
			wd.MTD_Traffic_This_Year__c += ds.Traffic_This_Year_MTD__c;
		}
	}
	
	// 
	private void sumTargets(Weekly_Dashboard__c wd, Target__c t)
	{
		if(wd.Target_ASP_Number__c == null)
		{
			wd.Target_ASP_Number__c = 1;
			wd.Target_ASP_Total__c = t.ASP__c;
		}
		else
		{
			wd.Target_ASP_Number__c += 1;
			wd.Target_ASP_Total__c += t.ASP__c;
		}
		
		if(wd.Target_CR_Number__c == null)
		{
			wd.Target_CR_Number__c = 1;
			wd.Target_CR_Total__c = t.Conversion_Rate__c;
		}
		else
		{
			wd.Target_CR_Number__c += 1;
			wd.Target_CR_Total__c += t.Conversion_Rate__c;
		}
		
		if(wd.Target_UPT_Number__c == null)
		{
			wd.Target_UPT_Number__c = 1;
			wd.Target_UPT_Total__c = t.UPT__c;
		}
		else
		{
			wd.Target_UPT_Number__c += 1;
			wd.Target_UPT_Total__c += t.UPT__c;
		}
		
		if(wd.Target_Sales__c == null)
		{
			wd.Target_Sales__c = t.Sales_Volume__c;
		}
		else
		{
			wd.Target_Sales__c += t.Sales_Volume__c;
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
	
	// 周信息
	private void assignWeekInfo(Date d)
	{
		this.weekStartDate = d.toStartOfWeek();
		this.weekEndDate = d.toStartOfWeek().addDays(7);
		if(Date.newInstance(d.year(), 1, 1).toStartOfWeek().daysBetween(d.toStartOfWeek()) / 7 <= 9)
		{
			this.weekNumber = d.year() + '0' + (Date.newInstance(d.year(), 1, 1).toStartOfWeek().daysBetween(d.toStartOfWeek()) / 7);
		}
		else
		{
			this.weekNumber = d.year() + '' + (Date.newInstance(d.year(), 1, 1).toStartOfWeek().daysBetween(d.toStartOfWeek()) / 7);
		}
	}
}