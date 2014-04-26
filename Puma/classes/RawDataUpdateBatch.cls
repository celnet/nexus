global class RawDataUpdateBatch implements Database.Batchable<sObject>,Database.Stateful
{
	global Database.Querylocator start(Database.BatchableContext BC)
	{
		return Database.getQueryLocator([Select UOM__c, 
												Transaction_Date__c, 
												Store_Type__c, 
												Store_Desc__c, 
												Store_Code__c, 
												Std_Unit_Cost__c, 
												Std_Retail_Price__c, 
												Std_Retail_Amt__c, 
												Size__c, 
												Season__c, 
												Sales_Qty__c, 
												Sales_Amt__c, 
												SKU_No__c, 
												Rounded_Sales_Amt__c, 
												RBU__c, 
												Product__c, 
												Product_Type__c, 
												Product_Type2__c, 
												Posting_Date__c, 
												Original_Retail_Price__c, 
												Original_Retail_Amt__c, 
												Net_Sales_Amt__c, 
												Name, 
												Line_Name__c, 
												Launch_Month__c, 
												Item_No__c, 
												Inv_No__c, 
												Id, 
												Gender__c, 
												GP_Rate__c, 
												GP_Amt__c, 
												Division__c, 
												Discount_Rate__c, 
												Description__c, 
												Cty_Division__c, 
												Concept__c, 
												Color__c, 
												Black_Inline__c, 
												Billing_Doc__c, 
												Article_Code__c 
											From Raw_Data__c]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		List<Raw_Data__c> rList = new List<Raw_Data__c>();
		Set<String> skuSet = new Set<String>();
		
		for(Raw_Data__c p : (List<Raw_Data__c>) scope)
		{
			skuSet.add(p.SKU_No__c);
		}
		
		List<Product__c> productList = [Select Id, SKU_No__c From Product__c Where SKU_No__c IN: skuSet];
		
		for(Product__c pd : productList)
		{
			for(Raw_Data__c p: (List<Raw_Data__c>) scope)
			{
				if(p.SKU_No__c == pd.SKU_No__c)
				{
					p.Product__c = pd.Id;
					rList.add(p);
				}
			}
		}
		
		update rList;
	}	
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
}