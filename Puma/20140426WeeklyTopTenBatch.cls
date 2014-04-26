/*
 * Author: Steven
 * Date: 2014-4-12
 * Description: Batch生成Top 10
 */
global class WeeklyTopTenBatch implements Database.Batchable<sObject>, Database.Stateful 
{
	global Date weekStartDate;
	global Date weekEndDate;
	
	// 周编号 201403 即 2014年第3周
	global String weekNumber;
	
	// 各Region各品类的产品本周排名数据
	List<Product_Top_Ten__c> topList = new List<Product_Top_Ten__c>();
		
	// 存放Region的Product_Top_Ten__c的数据，内部的Map中String为该Product_Top_Ten__c的SKU_No__c
	Map<Region__c, Map<String,Product_Top_Ten__c>> maleAppMap = new Map<Region__c, Map<String,Product_Top_Ten__c>>();
	Map<Region__c, Map<String,Product_Top_Ten__c>> femaleAppMap = new Map<Region__c, Map<String,Product_Top_Ten__c>>();
	Map<Region__c, Map<String,Product_Top_Ten__c>> bagAccMap = new Map<Region__c, Map<String,Product_Top_Ten__c>>();
	Map<Region__c, Map<String,Product_Top_Ten__c>> sockAccMap = new Map<Region__c, Map<String,Product_Top_Ten__c>>();
	Map<Region__c, Map<String,Product_Top_Ten__c>> footwareMap = new Map<Region__c, Map<String,Product_Top_Ten__c>>();
	
	// 获取所有Region
	List<Region__c> regionList = new List<Region__c>();
	
	global WeeklyTopTenBatch(Date d)
	{
		// 获取所有Region
		regionList = [Select Id, Name__c From Region__c];
		this.assignWeekInfo(d);
	}
	
	global Database.Querylocator start(Database.BatchableContext BC)
	{ 
		return Database.getQueryLocator([Select 
											Id,
											Transaction_Date__c, 
											Sales_Qty__c,
											Sales_Amt__c,
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
										 	Transaction_Date__c >=: this.weekStartDate And Transaction_Date__c <=:this.weekEndDate]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		for(Raw_Data__c rd : (List<Raw_Data__c>) scope)
		{
			if(rd.Store__c != null && rd.SKU_No__c != null)
			{
				// 统计各个Region的Raw Data
				if(rd.Store__r.Region__c != null)
				{
					for(Region__c region : regionList)
					{	
						if(rd.Gender__c == '男' && rd.Division__c.contains('服装') && rd.Store__r.Region__c == region.Id)
						{
							this.generateProductTopTen(maleAppMap, rd, region, '服装', '服装');
						}
						
						if(rd.Gender__c == '男' && rd.Division__c.contains('服裝') && rd.Store__r.Region__c == region.Id)
						{
							this.generateProductTopTen(maleAppMap, rd, region, '服装', '服装');
						}
						
						if(rd.Gender__c == '女' && rd.Division__c.contains('服装') && rd.Store__r.Region__c == region.Id)
						{
							this.generateProductTopTen(femaleAppMap, rd, region, '服装', '服装');
						}
						
						if(rd.Gender__c == '女' && rd.Division__c.contains('服裝') && rd.Store__r.Region__c == region.Id)
						{
							this.generateProductTopTen(femaleAppMap, rd, region, '服装', '服装');
						}
						
						if(rd.Division__c.contains('配件') && rd.Cty_Division__c.contains('包') && rd.Store__r.Region__c == region.Id)
						{
							this.generateProductTopTen(bagAccMap, rd, region, '配件', '包');
						}
						
						if(rd.Division__c.contains('配件') && rd.Cty_Division__c.contains('袜') && rd.Store__r.Region__c == region.Id)
						{
							this.generateProductTopTen(sockAccMap, rd, region, '配件', '袜');
						}
						
						if(rd.Division__c.contains('鞋') && rd.Store__r.Region__c == region.Id)
						{
							this.generateProductTopTen(footwareMap, rd, region, '鞋', '鞋');
						}
					}
				}
			}
		}
	}
	
	// 统计各个Region的Raw Data保存到Map<Region__c, Map<String,Product_Top_Ten__c>>上
	private void generateProductTopTen(Map<Region__c, Map<String,Product_Top_Ten__c>> productMap, Raw_Data__c rawData, Region__c region, String div, String ctyDiv)
	{
		if(productMap.get(region) == null)
		{
			Map<String,Product_Top_Ten__c> pMap1 = new Map<String,Product_Top_Ten__c>();
			Product_Top_Ten__c p = new Product_Top_Ten__c();
			
			p = this.assignGeneralFields(rawData, true, div, ctyDiv);
								
			p.Weekly_Sales_Unit__c = rawData.Sales_Qty__c;
			p.Weekly_Sales_Amount__c = rawData.Sales_Amt__c;
			p.GP_Amount__c = rawData.GP_Amt__c;
								
			pMap1.put(rawData.SKU_No__c, p);
			productMap.put(region, pMap1);
		}
		else
		{
			if(productMap.get(region).get(rawData.SKU_No__c) == null)
			{
				Map<String,Product_Top_Ten__c> pMap = productMap.get(region);
				Product_Top_Ten__c p = new Product_Top_Ten__c();
				
				p = this.assignGeneralFields(rawData, true, div, ctyDiv);
										
				p.Weekly_Sales_Unit__c = rawData.Sales_Qty__c;
				p.Weekly_Sales_Amount__c = rawData.Sales_Amt__c;
				p.GP_Amount__c = rawData.GP_Amt__c;
										
				pMap.put(rawData.SKU_No__c, p);
				productMap.put(region, pMap);
			}
			else
			{	
				Map<String,Product_Top_Ten__c> pMap = productMap.get(region);
				Product_Top_Ten__c p = productMap.get(region).get(rawData.SKU_No__c);
							
				p.Weekly_Sales_Unit__c += rawData.Sales_Qty__c;
				p.Weekly_Sales_Amount__c += rawData.Sales_Amt__c;
				p.GP_Amount__c += rawData.GP_Amt__c;
									
				pMap.put(rawData.SKU_No__c, p);
				productMap.put(region, pMap);
			}
		}
	}
	
	// 对Product_Top_Ten__c的产品属性进行赋值
	private Product_Top_Ten__c assignGeneralFields(Raw_Data__c rdc, Boolean isRegional, String div, String ctyDiv)
	{
		Product_Top_Ten__c p = new Product_Top_Ten__c();
		
		if(isRegional)
		{
			p.Region__c = rdc.Store__r.Region__c;
			p.Product_Top_Ten_Type__c = 'Region';
			
		}
		else
		{
			p.Product_Top_Ten_Type__c = 'All';
		}
		
		p.Week_No__c = this.weekNumber;
		p.SKU_No__c = rdc.SKU_No__c;
		p.Gender__c = rdc.Gender__c;
		p.Division__c = div;
		p.Cty_Division__c = ctyDiv;
		p.Std_Retail_Price__c = rdc.Std_Retail_Price__c;
		p.Original_Retail_Price__c = rdc.Original_Retail_Price__c;
		p.Discount_Rate__c = rdc.Discount_Rate__c;
		p.Season__c = rdc.Season__c;
		p.RBU__c = rdc.RBU__c;
		p.Description__c = rdc.Description__c;
		p.Concept__c = rdc.Concept__c;
		p.Color__c = rdc.Color__c;
		p.Article_Code__c = rdc.Article_Code__c;
		
		return p;
	}
	
	// 对生成的Product_Top_Ten__c数据根据Sales Unit和Sales Amount进行排序，取出配件前5，服装前10，鞋类前20
	private List<Product_Top_Ten__c> sortProductTopTen(List<Product_Top_Ten__c> productList)
	{
		List<Product_Top_Ten__c> productTopList = new List<Product_Top_Ten__c>();
		Integer dataSize = productList.size();
		if(dataSize == 0)
		{
			return null;
		}
		
		Product_Top_Ten__c tmp = new Product_Top_Ten__c();
		
		for(Integer i = 0;i < dataSize;i++)
		{
			for(Integer j = (dataSize - 1); j >= (i+1);j--)
			{
				if(productList[j-1].Weekly_Sales_Unit__c < productList[j].Weekly_Sales_Unit__c)
				{
					tmp = productList[j-1];
					productList[j-1] = productList[j];
					productList[j] = tmp;
				}
				else if(productList[j-1].Weekly_Sales_Unit__c == productList[j].Weekly_Sales_Unit__c)
				{
					if(productList[j-1].Weekly_Sales_Amount__c <= productList[j].Weekly_Sales_Amount__c)
					{
						tmp = productList[j-1];
						productList[j-1] = productList[j];
						productList[j] = tmp;
					}
				}
			} 
		}
		
		if(productList[0].Division__c == '鞋')
		{
			Integer delimit = Math.min(20, dataSize);
			
			for(Integer i = 0; i < delimit; i++)
			{
				Product_Top_Ten__c p = productList[i];
				
				p.Ranking__c = i + 1;
				// TODO: 图片字段
				p.Picture_URL__c = 'http://wallpepperhd.com/wp-content/uploads/2014/02/Puma-Logo-Big-Resolution.jpg';
				
				productTopList.add(p);
			}
		}
		else if(productList[0].Division__c == '配件')
		{
			Integer delimit = Math.min(5, dataSize);
			
			for(Integer i = 0; i < delimit; i++)
			{
				Product_Top_Ten__c p = productList[i];
				
				p.Ranking__c = i + 1;
				// TODO: 图片字段
				p.Picture_URL__c = 'http://wallpepperhd.com/wp-content/uploads/2014/02/Puma-Logo-Big-Resolution.jpg';
				
				productTopList.add(p);
			}
		}
		else
		{
			Integer delimit = Math.min(10, dataSize);
			
			for(Integer i = 0; i < delimit; i++)
			{
				Product_Top_Ten__c p = productList[i];
				
				p.Ranking__c = i + 1;
				// TODO: 图片字段
				p.Picture_URL__c = 'http://wallpepperhd.com/wp-content/uploads/2014/02/Puma-Logo-Big-Resolution.jpg';
				
				productTopList.add(p);
			}	
		}
		
		return productTopList;
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
		// AggregateResult[] arList = [Select SKU_No__c, SUM(Sales_Amt__c) sa, SUM(Sales_Qty__c) sq, SUM(GP_Amt__c) gp From Raw_Data__c Where Transaction_Date__c >=: this.weekStartDate And Transaction_Date__c <=:this.weekEndDate Group By SKU_No__c];
		
		// 添加各Region排名数据到topList
		for(Region__c region : regionList)
		{
			if(maleAppMap.get(region) != null)
			{
				List<Product_Top_Ten__c> maleTopList = this.sortProductTopTen(maleAppMap.get(region).values());
				
				if(maleTopList != null)
				{
					for(Product_Top_Ten__c p1 : maleTopList)
					{
						p1.Top_Ten_External_ID__c = region.Id + '-' + 'maleapp' + '-' + this.weekNumber + '-' + p1.Ranking__c;
					}
					topList.addAll(maleTopList);	
				}
			}
			
			if(femaleAppMap.get(region) != null)
			{
				List<Product_Top_Ten__c> femaleTopList = this.sortProductTopTen(femaleAppMap.get(region).values());
				if(femaleTopList != null)
				{
					for(Product_Top_Ten__c p1 : femaleTopList)
					{
						p1.Top_Ten_External_ID__c = region.Id + '-' + 'femaleapp' + '-' + this.weekNumber + '-' + p1.Ranking__c;
					}
					topList.addAll(femaleTopList);
				}
			}
			
			if(bagAccMap.get(region) != null)
			{
				List<Product_Top_Ten__c> bagTopList = this.sortProductTopTen(bagAccMap.get(region).values());
				if(bagTopList != null)
				{
					for(Product_Top_Ten__c p1 : bagTopList)
					{
						p1.Top_Ten_External_ID__c = region.Id + '-' + 'bag' + '-' + this.weekNumber + '-' + p1.Ranking__c;
					}
					topList.addAll(bagTopList);
				}
			}
			
			if(sockAccMap.get(region) != null)
			{
				List<Product_Top_Ten__c> sockTopList = this.sortProductTopTen(sockAccMap.get(region).values());
				if(sockTopList != null)
				{
					for(Product_Top_Ten__c p1 : sockTopList)
					{
						p1.Top_Ten_External_ID__c = region.Id + '-' + 'sock' + '-' + this.weekNumber + '-' + p1.Ranking__c;
					}
					topList.addAll(sockTopList);
				}
			}
			
			if(footwareMap.get(region) != null)
			{
				List<Product_Top_Ten__c> footwareTopList = this.sortProductTopTen(footwareMap.get(region).values());
				if(footwareTopList != null)
				{
					for(Product_Top_Ten__c p : footwareTopList)
					{
						p.Top_Ten_External_ID__c = region.Id + '-' + 'footware' + '-' + this.weekNumber + '-' + p.Ranking__c;
						
						System.debug('>>>footware' + region.Name__c + '>>>>' + p.Ranking__c + '>>>>>' + p.Gender__c + '>>>>>' + p.Division__c + '>>>>' + p.Cty_Division__c + '>>>' + p.Product_Top_Ten_Type__c + '>>>>' + p.Region__c);
					}
					topList.addAll(footwareTopList);
				}
			}
		}
		
		if(topList.size() > 0)
		{
			upsert topList Top_Ten_External_ID__c;
		}
	}
}
