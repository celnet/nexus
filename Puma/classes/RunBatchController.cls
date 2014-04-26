public with sharing class RunBatchController 
{
	public Date__c d{get;set;}
	public RunBatchController()
	{
		d = new Date__c();
		d.Date__c = date.today();
	}
	
	public void RunMonthly()
	{
		if(d.Date__c == null)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请先选择日期');         
	   		ApexPages.addMessage(msg);
		}
		else
		{
			DailySalesMonthlyBatch dsmb = new DailySalesMonthlyBatch(d.Date__c);
			Database.executeBatch(dsmb);
		}
	}
	
	public void Run()
	{
		if(d.Date__c == null)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请先选择日期');         
	   		ApexPages.addMessage(msg);
		}
		else
		{
			DailySalesBatch dsb = new DailySalesBatch(d.Date__c);
			Database.executeBatch(dsb);
		}
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, '已提交系统进行计算，请稍等一段时间进行查看。');         
	   	ApexPages.addMessage(msg);
	}
}