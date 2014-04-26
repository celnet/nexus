/*Author:Leo
 *Date:2014-4-11
 *function:当插入Traffic__c时自动根据Date_Import__c和Store_Code__c匹配lookup字段
 *		   Date__c、Store__c
 */
trigger Traffic_AutoMatch_LookUp on Traffic__c (before insert) {
	Set<Date> set_Date = new Set<Date>();
	Map<Date,Id> map_Date = new Map<Date,Id>();
	Set<string> set_Store = new Set<string>();
	Map<string,Id> map_Store = new Map<string,Id>();
	//获取需要匹配的Target__c 
	for(Traffic__c tra : trigger.new)
	{
		if(tra.Date__c==null || tra.Date__c=='')
		{
			set_Date.add(tra.Date_Import__c);
		}
		if(tra.Store__c == null || tra.Store__c == '')
		{
			set_Store.add(tra.Store_Code__c);
		}
	}
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
		for(Traffic__c tra : trigger.new)
		{
			if(tra.Date__c !=null)
			{
				continue;
			}
			if(map_Date.containsKey(tra.Date_Import__c))
			{
				tra.Date__c = map_Date.get(tra.Date_Import__c);
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
		for(Traffic__c tra : trigger.new)
		{
			if(tra.Store__c !=null)
			{
				continue;
			}
			if(map_Store.containsKey(tra.Store_Code__c))
			{
				tra.Store__c = map_Store.get(tra.Store_Code__c);
			}
		}
	}
}