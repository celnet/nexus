/*Author:Leo
 *Date:2014-4-11
 *function:当插入Raw_Data__c时自动根据Billing_Doc__c和Store_Code__c匹配lookup字段
 *		   Billing__c、Store__c
 */
trigger RawData_AutoMatch_LookUp on Raw_Data__c (before insert) {
	
	List<Store__c> storeList = new List<Store__c>();
	storeList = [Select Store_Code__c,Id From Store__c];
	
	List<Billing__c> billingList = new List<Billing__c>();
	billingList = [Select Name__c, Id From Billing__c];
	
	List<Product__c> productList = new List<Product__c>();
	productList = [Select SKU_No__c, Id From Product__c];
	
	for(Raw_Data__c rawData : trigger.new)
	{
		if(rawData.Store_Code__c != null && storeList.size() > 0)
		{
			for(Store__c store : storeList)
			{
				if(rawData.Store_Code__c == store.Store_Code__c)
				{
					rawData.Store__c = store.Id;
				}
			}
		}
		
		if(rawData.Billing_Doc__c != null && billingList.size() > 0)
		{
			for(Billing__c billing : billingList)
			{
				if(rawData.Billing_Doc__c == billing.Name__c)
				{
					rawData.Billing__c = billing.Id;
				}
			}
		}
		
		if(rawData.SKU_No__c != null && productList.size() > 0)
		{
			for(Product__c product : productList)
			{
				if(rawData.SKU_No__c == product.SKU_No__c)
				{
					rawData.Product__c = product.Id;
				}
			}
		}
	}
	/*
	Set<String> set_Billing = new Set<String>();
	Map<String,Id> map_Billing = new Map<String,Id>();
	Set<string> set_Store = new Set<string>();
	Map<string,Id> map_Store = new Map<string,Id>();
	//获取需要匹配的Target__c 
	for(Raw_Data__c rd : trigger.new)
	{
		if(rd.Billing__c==null || rd.Billing__c=='')
		{
			set_Billing.add(rd.Billing_Doc__c);
		}
		if(rd.Store__c == null || rd.Store__c == '')
		{
			set_Store.add(rd.Store_Code__c);
		}
	}
	//如果没有需要匹配的Target__c，返回
	if(set_Billing.size()==0 && set_Store.size()==0)
	{
		return;
	}
	//如果日期需要匹配lookup
	if(set_Billing.size()!=0)
	{
		//获得date对象上的id集合
		List<Billing__c> tempdate = [select id,Name__c from Billing__c where Name__c in :set_Billing];
		if(tempdate.size()==0)
		{
			return;
		}
		//封装到map
		for(Billing__c d : tempdate)
		{
			map_Billing.put(d.Name__c,d.Id);
		}
		//遍历要匹配的数据
		for(Raw_Data__c rd : trigger.new)
		{
			if(rd.Billing__c !=null)
			{
				continue;
			}
			if(map_Billing.containsKey(rd.Billing_Doc__c))
			{
				rd.Billing__c = map_Billing.get(rd.Billing_Doc__c);
			}
		}
	}
	//如果门店需要匹配lookup
	if(set_Store.size()!=0)
	{
		List<Store__c> tempstore = [Select Store_Code__c, Id From Store__c where Store_Code__c in :set_Store];
		if(tempstore.size()==0)
		{
			return;
		}
		for(Store__c s : tempstore)
		{
			map_Store.put(s.Store_Code__c,s.Id);
		}
		for(Raw_Data__c rd : trigger.new)
		{
			if(rd.Store__c !=null)
			{
				continue;
			}
			if(map_Store.containsKey(rd.Store_Code__c))
			{
				rd.Store__c = map_Store.get(rd.Store_Code__c);
			}
		}
	}
	*/
}