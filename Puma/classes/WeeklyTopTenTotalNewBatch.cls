/*
 * Author: Steven
 * Date: 2014-4-12
 * Description: Batch生成Total Top 10
 */
global class WeeklyTopTenTotalNewBatch implements Database.Batchable<sObject>, Database.Stateful 
{
	global Date weekStartDate;
	global Date weekEndDate; 
	 
	// 周编号 201403 即 2014年第3周
	global String weekNumber;
	
	// 全国各品类的产品本周排名数据
	List<Product_Top_Ten__c> topList = new List<Product_Top_Ten__c>();
	
	// 存放全国的Product_Top_Ten__c的数据，String为该Product_Top_Ten__c的SKU_No__c
	Map<String,Product_Top_Ten__c> allMaleAppMap = new Map<String,Product_Top_Ten__c>();
	Map<String,Product_Top_Ten__c> allFemaleAppMap = new Map<String,Product_Top_Ten__c>();
	Map<String,Product_Top_Ten__c> allBagAccMap = new Map<String,Product_Top_Ten__c>();
	Map<String,Product_Top_Ten__c> allSockAccMap = new Map<String,Product_Top_Ten__c>();
	Map<String,Product_Top_Ten__c> allFootwareMap = new Map<String,Product_Top_Ten__c>();	
	
	global WeeklyTopTenTotalNewBatch(Date d)
	{
		this.assignWeekInfo(d);
	}

	global Database.Querylocator start(Database.BatchableContext BC)
	{ 
		AggregateResult[] arMaleList = [Select 
												SKU_No__c, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq, 
												SUM(GP_Amt__c) ga 
											From 
												Raw_Data__c 
											Where 
												Transaction_Date__c >=: this.weekStartDate And Transaction_Date__c <=:this.weekEndDate
											And
												Division__c LIKE '%服%'
											And
												Gender__c = '男'
											Group By
												SKU_No__c
											Order By 
												SUM(Sales_Qty__c) desc
											limit 10];
		
		Integer ranking1 = 1;
		for(AggregateResult ar : arMaleList)
		{
			Product_Top_Ten__c ptt = new Product_Top_Ten__c();
			ptt.Ranking__c = ranking1;
			ptt.Weekly_Sales_Unit__c = (Double)ar.get('sq');
			ptt.Weekly_Sales_Amount__c = (Double)ar.get('sa');
			ptt.GP_Amount__c = (Double)ar.get('ga');
			ptt.SKU_No__c = (String)ar.get('SKU_No__c');
			//ptt.Top_Ten_External_ID__c = 'all-male' + this.weekNumber + '-' + ptt.Ranking__c;
			allMaleAppMap.put(ptt.SKU_No__c,ptt);
			ranking1 ++;
		}
										
		AggregateResult[] arFemaleList = [Select 
												SKU_No__c, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq, 
												SUM(GP_Amt__c) ga 
											From 
												Raw_Data__c 
											Where 
												Transaction_Date__c >=: this.weekStartDate And Transaction_Date__c <=:this.weekEndDate
											And
												Division__c LIKE '%服%'
											And
												Gender__c = '女'
											Group By
												SKU_No__c
											Order By 
												SUM(Sales_Qty__c) desc
											limit 10];
		
		Integer ranking2 = 1;
		for(AggregateResult ar : arFemaleList)
		{
			Product_Top_Ten__c ptt = new Product_Top_Ten__c();
			ptt.Ranking__c = ranking2;
			ptt.Weekly_Sales_Unit__c = (Double)ar.get('sq');
			ptt.Weekly_Sales_Amount__c = (Double)ar.get('sa');
			ptt.GP_Amount__c = (Double)ar.get('ga');
			ptt.SKU_No__c = (String)ar.get('SKU_No__c');
			//ptt.Top_Ten_External_ID__c = 'all-female' + this.weekNumber + '-' + ptt.Ranking__c;
			allFemaleAppMap.put(ptt.SKU_No__c,ptt);
			ranking2 ++;
		}		
									
		AggregateResult[] arFootwareList = [Select 
												SKU_No__c, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq, 
												SUM(GP_Amt__c) ga 
											From 
												Raw_Data__c 
											Where 
												Transaction_Date__c >=: this.weekStartDate And Transaction_Date__c <=:this.weekEndDate
											And
												Division__c LIKE '%鞋%'
											Group By
												SKU_No__c
											Order By 
												SUM(Sales_Qty__c) desc
											limit 20];
		
		Integer ranking3 = 1;
		for(AggregateResult ar : arFootwareList)
		{
			Product_Top_Ten__c ptt = new Product_Top_Ten__c();
			ptt.Ranking__c = ranking3;
			ptt.Weekly_Sales_Unit__c = (Double)ar.get('sq');
			ptt.Weekly_Sales_Amount__c = (Double)ar.get('sa');
			ptt.GP_Amount__c = (Double)ar.get('ga');
			ptt.SKU_No__c = (String)ar.get('SKU_No__c');
			//ptt.Top_Ten_External_ID__c = 'all-footware' + this.weekNumber + '-' + ptt.Ranking__c;
			allFootwareMap.put(ptt.SKU_No__c,ptt);
			ranking3 ++;
		}			
										
		AggregateResult[] arSockList = [Select 
												SKU_No__c, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq, 
												SUM(GP_Amt__c) ga 
											From 
												Raw_Data__c 
											Where 
												Transaction_Date__c >=: this.weekStartDate And Transaction_Date__c <=:this.weekEndDate
											And
												Cty_Division__c LIKE '%袜%'
											Group By
												SKU_No__c
											Order By 
												SUM(Sales_Qty__c) desc
											limit 5];
		
		Integer ranking4 = 1;
		for(AggregateResult ar : arSockList)
		{
			Product_Top_Ten__c ptt = new Product_Top_Ten__c();
			ptt.Ranking__c = ranking4;
			ptt.Weekly_Sales_Unit__c = (Double)ar.get('sq');
			ptt.Weekly_Sales_Amount__c = (Double)ar.get('sa');
			ptt.GP_Amount__c = (Double)ar.get('ga');
			ptt.SKU_No__c = (String)ar.get('SKU_No__c');
			ptt.Top_Ten_External_ID__c = 'all-sock' + this.weekNumber + '-' + ptt.Ranking__c;
			allSockAccMap.put(ptt.SKU_No__c,ptt);
			ranking4 ++;
		}								
					
		AggregateResult[] arBagList = [Select 
												SKU_No__c, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq, 
												SUM(GP_Amt__c) ga 
											From 
												Raw_Data__c 
											Where 
												Transaction_Date__c >=: this.weekStartDate And Transaction_Date__c <=:this.weekEndDate
											And
												Cty_Division__c LIKE '%包%'
											Group By
												SKU_No__c
											Order By 
												SUM(Sales_Qty__c) desc
											limit 5];	
		
		Integer ranking5 = 1;
		for(AggregateResult ar : arBagList)
		{
			Product_Top_Ten__c ptt = new Product_Top_Ten__c();
			ptt.Ranking__c = ranking5;
			ptt.Weekly_Sales_Unit__c = (Double)ar.get('sq');
			ptt.Weekly_Sales_Amount__c = (Double)ar.get('sa');
			ptt.GP_Amount__c = (Double)ar.get('ga');
			ptt.SKU_No__c = (String)ar.get('SKU_No__c');
			ptt.Top_Ten_External_ID__c = 'all-bag' + this.weekNumber + '-' + ptt.Ranking__c;
			allBagAccMap.put(ptt.SKU_No__c,ptt);
			ranking5 ++;
		}			
		
		return Database.getQueryLocator([Select 
											Id,
											Transaction_Date__c, 
											Sales_Amt__c,
											Sales_Qty__c,
											Store__c, 
											Store__r.Region__c,
											Std_Retail_Price__c, 
											Season__c, 
											SKU_No__c, 
											RBU__c, 
											Original_Retail_Price__c, 
											Gender__c, 
											GP_Amt__c, 
											Division__c, 
											Discount_Rate__c, 
											Description__c, 
											Cty_Division__c, 
											Concept__c, 
											Color__c, 
											Article_Code__c 
										 From 
										 	Raw_Data__c 
										 Where 
										 	Transaction_Date__c >=: this.weekStartDate And Transaction_Date__c <=:this.weekEndDate
										 And 
										 	Store__c != null
										 And 
										 	SKU_No__c != null]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		for(Raw_Data__c rd : (List<Raw_Data__c>) scope)
		{
				// 统计全国的Raw Data
				if(rd.Gender__c == '男' && rd.Division__c.contains('服装'))
				{
					this.generateAllProductTopTen(allMaleAppMap, rd, '服装', '服装');
				}
				
				if(rd.Gender__c == '男' && rd.Division__c.contains('服裝'))
				{
					this.generateAllProductTopTen(allMaleAppMap, rd, '服装', '服装');
				}
				
				if(rd.Gender__c == '女' && rd.Division__c.contains('服装'))
				{
					this.generateAllProductTopTen(allFemaleAppMap, rd, '服装', '服装');
				}
				
				if(rd.Gender__c == '女' && rd.Division__c.contains('服裝'))
				{
					this.generateAllProductTopTen(allFemaleAppMap, rd, '服装', '服装');
				}
				
				if(rd.Division__c.contains('配件') && rd.Cty_Division__c.contains('包'))
				{
					this.generateAllProductTopTen(allBagAccMap, rd, '配件', '包');
				}
						
				if(rd.Division__c.contains('配件') && rd.Cty_Division__c.contains('袜'))
				{
					this.generateAllProductTopTen(allSockAccMap, rd,  '配件', '袜');
				}
						
				if(rd.Division__c.contains('鞋'))
				{
					this.generateAllProductTopTen(allFootwareMap, rd, '鞋', '鞋');
				}
				
		}
	}
	
	// 统计全国的Raw Data保存到Map<String,Product_Top_Ten__c>上
	private void generateAllProductTopTen(Map<String,Product_Top_Ten__c> productMap, Raw_Data__c rawData, String div, String ctyDiv)
	{
		if(productMap.get(rawData.SKU_No__c) != null)
		{
			Product_Top_Ten__c p = productMap.get(rawData.SKU_No__c);
			p = this.assignGeneralFields(p, rawData, div, ctyDiv);
			
			p.Weekly_Sales_Unit__c += rawData.Sales_Qty__c;
			p.Weekly_Sales_Amount__c += rawData.Sales_Amt__c;
			p.GP_Amount__c += rawData.GP_Amt__c;
			
			productMap.put(rawData.SKU_No__c, p);
		}
	}
	
	// 对Product_Top_Ten__c的通用属性进行赋值
	private Product_Top_Ten__c assignGeneralFields(Product_Top_Ten__c p, Raw_Data__c rdc, String div, String ctyDiv)
	{
		p.Product_Top_Ten_Type__c = 'All';
		p.Week_No__c = this.weekNumber;
		// p.SKU_No__c = rdc.SKU_No__c;
		p.Gender__c = rdc.Gender__c;
		p.Division__c = div;
		p.Cty_Division__c = ctyDiv;
		p.Std_Retail_Price__c = rdc.Std_Retail_Price__c;
		p.Season__c = rdc.Season__c;
		p.RBU__c = rdc.RBU__c;
		p.Description__c = rdc.Description__c;
		p.Discount_Rate__c = rdc.Discount_Rate__c;
		p.Original_Retail_Price__c = rdc.Original_Retail_Price__c;
		p.Concept__c = rdc.Concept__c;
		p.Color__c = rdc.Color__c;
		p.Article_Code__c = rdc.Article_Code__c;
		
		return p;
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
	
	global void finish(Database.BatchableContext BC)
	{
		// 添加全国排名数据到topList
		List<Product_Top_Ten__c> allMaleTopList = allMaleAppMap.values();
		List<Product_Top_Ten__c> allFemaleTopList = allFemaleAppMap.values();
		List<Product_Top_Ten__c> allBagTopList = allBagAccMap.values();
		List<Product_Top_Ten__c> allSockTopList = allSockAccMap.values();
		List<Product_Top_Ten__c> allFootwareTopList = allFootwareMap.values();
		
		if(allMaleTopList != null)
		{
			for(Product_Top_Ten__c p : allMaleTopList)
			{
				p.Top_Ten_External_ID__c = 'all-male' + this.weekNumber + '-' + p.Ranking__c;
			}
			topList.addAll(allMaleTopList);
		}
		
		if(allFemaleTopList != null)
		{
			for(Product_Top_Ten__c p : allFemaleTopList)
			{
				p.Top_Ten_External_ID__c = 'all-female' + this.weekNumber + '-' + p.Ranking__c;
			}
			topList.addAll(allFemaleTopList);
		}
		
		if(allBagTopList != null)
		{
			for(Product_Top_Ten__c p : allBagTopList)
			{
				p.Top_Ten_External_ID__c = 'all-bag' + this.weekNumber + '-' + p.Ranking__c;
			}
			topList.addAll(allBagTopList);
		}
		
		if(allSockTopList != null)
		{
			for(Product_Top_Ten__c p : allSockTopList)
			{
				p.Top_Ten_External_ID__c = 'all-sock' + this.weekNumber + '-' + p.Ranking__c;
			}
			topList.addAll(allSockTopList);
		}
		
		if(allFootwareTopList != null)
		{
			for(Product_Top_Ten__c p : allFootwareTopList)
			{
				p.Top_Ten_External_ID__c = 'all-footware' + this.weekNumber + '-' + p.Ranking__c;
			}
			topList.addAll(allFootwareTopList);
		}
		
		if(topList.size() > 0)
		{
			upsert topList Top_Ten_External_ID__c;
		}
	}
}