/*
 * Author: Steven
 * Date: 2014-4-22
 * Description: 根据给定日期统计Raw Data的利润，销售额，销量生成Product Top，维度为门店，产品，日期
 */
global class ProductTopBatch implements Database.Batchable<sObject>, Database.Stateful 
{
	// ProductTop的计算日期
	global Date runDate;
	global Date__c runDatec;

	// 生成的ProductTop
	global List<Product_Top__c> ptList;
	
	global ProductTopBatch(Date d)
	{
		runDate = d;
		runDatec = new Date__c();
		ptList = new List<Product_Top__c>();
		
		runDatec = [Select Id, Date__c From Date__c Where Date__c =: d limit 1];
		System.debug('日期>>>>>>>' + runDatec.Date__c);
	}
	
	global Database.Querylocator start(Database.BatchableContext BC)
	{ 
		return Database.getQueryLocator([Select Id From Store__c]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		// 遍历所有门店
		for(Store__c s : (List<Store__c>) scope)
		{
			System.debug('门店>>>>' + s.Id);
			
			// 从Raw Data中获取每个产品(SKU)当天每个门店的SalesAmt, SalesQty, GPAmt
			AggregateResult[] arList = [Select 
											Product__c,
											SUM(GP_Amt__c) ga, 
											SUM(Sales_Amt__c) sa, 
											SUM(Sales_Qty__c) sq
										From 
											Raw_Data__c 
										Where
											Store__c =:s.Id
										And 
											Transaction_Date__c =: runDate
										Group by
											Product__c];
			
			System.debug('RawData统计的SKU' + arList.size());
			
			// 遍历每一个产品的记录
			for(AggregateResult ar : arList)
			{
				Product_Top__c pt = new Product_Top__c();
				
				pt.Product__c = (Id)ar.get('Product__c');
				pt.Store__c = s.Id;
				pt.Date__c = runDatec.Id;
				pt.Sales_Amount__c = (Double)ar.get('sa');
				pt.Sales_Quantity__c = (Double)ar.get('sq');
				pt.GP_Amount__c = (Double)ar.get('ga');
				pt.Product_Top_External_ID__c = s.Id + '-' + pt.Product__c + '-' + runDatec.Id;

				if(pt.Product__c != null)
				{
					ptList.add(pt);
				}
			}
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		System.debug('产生的ProductTop条数' + ptList.size());
		if(ptList.size() > 0)
		{
			upsert ptList Product_Top_External_ID__c;
		}	
	}
}