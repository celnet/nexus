/*
 * Author: Steven
 * Date: 2014-1-14
 * Description: 做单项目中根据客户类型以及所选择的的行业类型来推荐相应的客户
*/
public with sharing class BuySellRecommendation2Controller {
	private ID projectId;
	public Boolean IsError {get; set;}
	public Boolean isChecked {get; set;}
	public ProjectHollyhigh__c projectc {get; set;}
	public Account acc{get;set;}
	public List<AccountPack> targetAccountList {get; set;}
	public Boolean isRenderTab {get; set;}
	private Set<ID> existTargetAccountIds;
	private Map<ID, RecordType> projReIdMap;
	private Map<String, RecordType> accReDevMap;
	private Map<String, RecordType> recommReDevMap;
	private ID recommRecordTypeId;
	
	public class AccountPack
	{
		public boolean isCheck{get;set;}
		public Account account{get;set;}
	}
	
	
	//设置客户类型默认值
	private void setRecordTypeValue()
	{
     	this.projReIdMap = new Map<ID, RecordType>();
		this.accReDevMap = new Map<String, RecordType>();
		this.recommReDevMap = new Map<String, RecordType>();
		
		 for(RecordType reType: [Select ID, Name, DeveloperName From RecordType Where SObjectType = 'ProjectHollyhigh__c'])
        {
        	this.projReIdMap.put(reType.ID, reType);
        }
        for(RecordType reType: [Select ID, Name, DeveloperName From RecordType Where SObjectType = 'Account'])
        {
        	this.accReDevMap.put(reType.DeveloperName, reType);
        }
        for(RecordType reType: [Select ID, Name, DeveloperName From RecordType Where SObjectType = 'ResourceRecommend__c'])
        {
        	this.recommReDevMap.put(reType.DeveloperName, reType);
        }
		
		//设置筛选条件客户的默认记录类型,设置将要生成的推荐的记录类型
		if(projReIdMap.containsKey(this.projectc.RecordTypeId))
		{
        	RecordType currentProjRe = projReIdMap.get(this.projectc.RecordTypeId);
        	if(currentProjRe.DeveloperName == 'Seller')
        	{
        		this.acc.RecordTypeId = this.accReDevMap.get('Buyer').Id;
        		this.recommRecordTypeId = this.recommReDevMap.get('Buyer').Id;
        	}
        	else if (currentProjRe.DeveloperName == 'Buyer')
        	{
        		this.acc.RecordTypeId = this.accReDevMap.get('Seller').Id;
        		this.recommRecordTypeId = this.recommReDevMap.get('Seller').Id;
        	}
        }
	}
	
	public BuySellRecommendation2Controller(ApexPages.standardController controller)
    {
    	this.isRenderTab = false;
    	this.targetAccountList = new List<AccountPack>();
    	this.existTargetAccountIds = new Set<ID>();
      	this.projectId = ApexPages.currentPage().getParameters().get('id');
     	this.projectc = [Select ID, 
			     		Name, 
			     		RecordTypeId,
			     		Account__r.Name, 
			     		Account__r.OwnerId,
			     		Account__r.ID, 
			     		Account__r.Type, 
			     		Account__r.IndustryType__c, 
			     		Account__r.industry, 
			     		Account__r.RecordTypeId,
			     		Account__r.RecordType.ID,
			     		Account__r.RecordType.Name,
			     		(Select ID, 
			     			Target_Account__c
			     		From relatedproject__r)
			     	From ProjectHollyhigh__c 
			     	Where Id =: this.projectId];
     	if(this.projectc.Account__r == null)
     	{
     		this.projectc.Account__r = new Account();
     	}
     	this.acc = projectc.Account__r;
     	this.setRecordTypeValue();
     	if(this.projectc.relatedproject__r != null)
     	{
     		for(ResourceRecommend__c rec : this.projectc.relatedproject__r)
     		{
     			if(rec.Target_Account__c != null)
     			{
     				this.existTargetAccountIds.add(rec.Target_Account__c);
     			}
     		}
     	}
     	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, '请合理设置筛选条件后点击 “搜索”按钮开始检索目标客户');         
   		ApexPages.addMessage(msg);
    }
	
	public PageReference Search()
	{
		this.targetAccountList.clear();
		if(this.acc.industry==null)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请选择行业信息');         
       		ApexPages.addMessage(msg);
       		return null;		
		}
		for(Account acc : [Select 
								Id,
								Name 
							From Account 
							where Account.RecordTypeId=:this.acc.RecordTypeId 
							And IndustryType__c =: this.acc.IndustryType__c 
							And industry=: this.acc.industry
							And Id Not IN: this.existTargetAccountIds Limit 2000])
		{
			AccountPack accP = new AccountPack();
			accP.isCheck = false;
			accp.account = acc;
			this.targetAccountList.add(accP);
		}
		if(this.targetAccountList.size() <= 0)
		{
			this.isRenderTab = false;
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, '按照您设置的条件，没有找到任何可推荐的客户，请合理设置条件后重新搜索');         
   			ApexPages.addMessage(msg);
		}
		else
		{
			this.isRenderTab = true;
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, '按照您设置的条件， 找到共' + this.targetAccountList.size() + '条可推荐的目标客户, 请选择您要推荐的客户后点击“确认”按钮');         
   			ApexPages.addMessage(msg);
		}
		return null;
	}
	
	public PageReference Sure()
	{
		List<ResourceRecommend__c> newRecommendList = new List<ResourceRecommend__c>();
		
		/***Steven update 2014-2-17***/
		List<Task> taskList = new List<Task>();
		Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
		String[] toAddresses = new List<String>();
		/***Steven update 2014-2-17***/
		
		for(AccountPack accp : this.targetAccountList)
		{
			if(accp.isCheck)
			{
				ResourceRecommend__c recommend = new ResourceRecommend__c();
				recommend.Account__c = this.acc.Id;
				recommend.Project__c = this.projectc.Id;
				recommend.Target_Account__c = accp.account.Id;
				recommend.RecordTypeId = this.recommRecordTypeId;
				newRecommendList.add(recommend);
				
				/***Steven update 2014-2-17***/
				User u1 = [Select Email From User Where Id =: this.acc.OwnerId];
				toAddresses.add(u1.Email);
				String content = '现有做单项目"' + this.projectc.Name + '"需要您的关注。';
				content += '以下是项目链接: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.projectId;
				mail.setPlainTextBody(content);
				mail.setSubject('做单项目关注');
				
				Task t1 = new Task();
				t1.OwnerId = this.acc.OwnerId;
				t1.WhatId = this.projectId;
				t1.ChildProject__c = String.valueOf(this.projectc.Name);
				t1.Description = '现有做单项目"' + this.projectc.Name + '"需要您的关注。';
				taskList.add(t1);
				/***Steven update 2014-2-17***/
			}
		}
		/***Steven update 2014-2-17***/
		mail.setToAddresses(toAddresses);
		Messaging.sendEmail(new Messaging.Singleemailmessage[]{mail});
		insert taskList;
		/***Steven update 2014-2-17***/
		insert newRecommendList;
		PageReference redirectPag = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.projectId);
        redirectPag.setRedirect(true);
        return redirectPag;
	}
	public PageReference Cancel()
	{
		PageReference redirectPag = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.projectId);
        redirectPag.setRedirect(true);
        return redirectPag; 
	}
	
}
