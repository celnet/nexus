/*Author:Leo
 *Date:2014-4-11
 *function:当插入Billing__c时自动根据Date_Import__c和Store_Code__c匹配lookup字段
 *		   Date__c、Store__c
 */
trigger Billing_AutoMatch_LookUp on Billing__c (before insert) {
	Set<Date> set_Date = new Set<Date>();
	Map<Date,Id> map_Date = new Map<Date,Id>();
	Set<string> set_Store = new Set<string>();
	Map<string,Id> map_Store = new Map<string,Id>();
	//获取需要匹配的Target__c 
	for(Billing__c bil : trigger.new)
	{
		if(bil.Date__c==null || bil.Date__c=='')
		{
			set_Date.add(bil.DateImport__c);
		}
		if(bil.Store__c == null || bil.Store__c == '')
		{
			set_Store.add(bil.Store_Code__c);
		} 
	}
	system.debug('********************set_Date.size*********************' + set_Date.size());
	system.debug('********************set_Store.size*********************' + set_Store.size());	
	//如果没有需要匹配的Target__c，返回
	if(set_Date.size()==0 && set_Store.size()==0)
	{
		return;
	}
	//如果日期需要匹配lookup
	if(set_Date.size()!=0)
	{
		//获得date对象上的id集合
		List<Date__c> tempdate = [select id,Date__c from Date__c where Date__c in :set_Date];
		system.debug('********************tempdate.size*********************' + tempdate.size());
		if(tempdate.size()==0)
		{
			return;
		}
		//封装到map
		for(Date__c d : tempdate)
		{
			map_Date.put(d.Date__c,d.Id);
		}
		//遍历要匹配的数据
		for(Billing__c bil : trigger.new)
		{
			if(bil.Date__c !=null)
			{
				continue;
			}
			if(map_Date.containsKey(bil.DateImport__c))
			{
				bil.Date__c = map_Date.get(bil.DateImport__c);
			}
		}
	}
	//如果门店需要匹配lookup
	if(set_Store.size()!=0)
	{
		List<Store__c> tempstore = [Select Store_Code__c, Id From Store__c where Store_Code__c in :set_Store];
		system.debug('********************tempstore.size*********************' + tempstore.size());
		if(tempstore.size()==0)
		{
			return;
		}
		for(Store__c s : tempstore)
		{
			map_Store.put(s.Store_Code__c,s.Id);
		}
		for(Billing__c bil : trigger.new)
		{
			if(bil.Store__c !=null)
			{
				continue;
			}
			if(map_Store.containsKey(bil.Store_Code__c))
			{
				bil.Store__c = map_Store.get(bil.Store_Code__c);
			}
		}
	}
}