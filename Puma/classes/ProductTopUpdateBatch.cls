global class ProductTopUpdateBatch implements Database.Batchable<sObject>,Database.Stateful
{
	global Database.Querylocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator([Select 
											Store__c, 
											Sales_Quantity__c, 
											Sales_Amount__c, 
											SKU_No__c, 
											Product__c, 
											Product_Top_External_ID__c, 
											Name, 
											Id, 
											GP_Amount__c, 
											Date__c 
										From 
											Product_Top__c]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		List<Product_Top__c> pList = new List<Product_Top__c>();
		Set<String> skuSet = new Set<String>();
		
		for(Product_Top__c p : (List<Product_Top__c>) scope)
		{
			skuSet.add(p.SKU_No__c);
		}
		
		List<Product__c> productList = [Select Id, SKU_No__c From Product__c Where SKU_No__c IN: skuSet];
		
		for(Product__c pd : productList)
		{
			for(Product_Top__c p: (List<Product_Top__c>) scope)
			{
				if(p.SKU_No__c == pd.SKU_No__c)
				{
					p.Product__c = pd.Id;
					pList.add(p);
				}
			}
		}
		
		update pList;
	}	
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
}