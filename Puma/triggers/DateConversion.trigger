/*
 * Author: Steven
 * Date: 2014-4-11
 * Description: 完善日期Date对象
 */
trigger DateConversion on Date__c (before insert, before update) {
	for(Date__c d : trigger.new)
	{
		if(d.Date__c != null)
		{
			if(d.Date__c.toStartOfWeek().daysBetween(d.Date__c) == 0)
			{
				d.Week__c = '7';
				d.Holiday__c = '是';
			}
			else
			{
				d.Week__c = String.valueOf(d.Date__c.toStartOfWeek().daysBetween(d.Date__c));
				d.Holiday__c = '否';
			}
			
			if(d.Date__c.toStartOfWeek().daysBetween(d.Date__c) == 6)
			{
				d.Holiday__c = '是';
			}
			
			d.Week_Of_Year__c = 1 + (Date.newInstance(d.Date__c.year(), 1, 1).toStartOfWeek().daysBetween(d.Date__c.toStartOfWeek()) / 7);
			
		}
	}
}