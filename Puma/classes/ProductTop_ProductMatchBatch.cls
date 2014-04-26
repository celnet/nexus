/*
 *
 *
 * Description: run once
 */
global class ProductTop_ProductMatchBatch implements Database.Batchable<sObject>, Database.Stateful 
{
	public List<Product__c> productList;
	
	global ProductTop_ProductMatchBatch()
	{
		productList = [Select Id, SKU_No__c From Product__c];
	}
	
	global Database.Querylocator start(Database.BatchableContext BC)
	{ 
		return Database.getQueryLocator([Select Id,Product__c, Product__r.SKU_No__c,SKU_No__c From Product_Top__c]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		List<Product_Top__c> insertProductTopList = new List<Product_Top__c>();
		
		for(Product_Top__c p : (List<Product_Top__c>) scope)
		{
			if(p.SKU_No__c != null)
			{
				for(Product__c pc : productList)
				{
					if(p.SKU_No__c == pc.SKU_No__c)
					{
						p.Product__c = pc.Id;
						insertProductTopList.add(p);
					}
				}
			}
		}
		
		if(insertProductTopList.size() > 0)
		{
			update insertProductTopList;
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
}