/*
 * Description: 共享并发送项目链接给其它用户以获得买方/卖方推荐
 * Author: Steven
 * Date: 2014-1-10
 */

public with sharing class NoticeForRecommendationController 
{
	private ID projectId;
	public List<UserPack> userPackList{get; set;}
	public ProjectHollyhigh__c projectc{get; set;}
	public class UserPack
	{
		public boolean isCheck{get;set;}
		public User user{get;set;}
	}
	
	public NoticeForRecommendationController(ApexPages.standardController controller)
	{
		this.userPackList = new List<UserPack>();
		this.projectId = ApexPages.currentPage().getParameters().get('id');
		this.projectc = [Select 
							Name, 
							Id,
							OwnerId
						 From ProjectHollyhigh__c 
						 Where Id=: this.projectId];
		/***Steven update 2014-2-17***/
		List<ProjectMember__c> pm = [Select 
										GroupMember__c 
									 From 
									 	ProjectMember__c 
									 Where 
									 	ProjectName__c =: this.projectId];
		List<Id> pIdList = new List<Id>();
		for(ProjectMember__c p : pm)
		{
			pIdList.add(p.GroupMember__c);
		}
		/***Steven update 2014-2-17***/
		for(User user:[Select 
						Id, 
						UserRoleId, 
						Name,
						UserName,
						Email, 
						UserRole.Name,
						Division 
					   From User 
					   Where IsActive=true 
					   and Profile.UserLicense.Name = 'Salesforce' 
					   and Id !=: projectc.OwnerId
					   /***Steven update 2014-2-17***/
					   and Id NOT IN: pIdList
					   /***Steven update 2014-2-17***/
					   Order By Name ASC]) 
		{
			UserPack up = new UserPack();
			if(user.Division == null)
			{
				user.Division = '未定';
			}
			up.isCheck = false;
			up.user = user;
			this.userPackList.add(up);
		}
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, '请勾选用户后点击发送');         
   		ApexPages.addMessage(msg);
	}
	
	public PageReference Send()
	{
		/***Steven update 2014-2-17***/
		List<Task> taskList = new List<Task>();
		/***Steven update 2014-2-17***/
				
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    String[] toAddresses = new List<String>();
	    
	    for(UserPack userPack:userPackList)
		{
			if(userPack.isCheck)
			{
				toAddresses.add(userPack.user.Email);
				manualShareRead(projectId, userPack.user.Id);
				/***Steven update 2014-2-17***/
				Task t1 = new Task();
				t1.OwnerId = userPack.user.Id;
				t1.WhatId = this.projectId;
				t1.ChildProject__c = String.valueOf(this.projectc.Name);
				t1.Description = '现有做单项目"' + this.projectc.Name + '"需要您的关注。';
				taskList.add(t1);
				System.debug('>>>>>>' + userPack.user.Id);
				System.debug('>>>>>>>' + this.projectId);
				System.debug('>>>>>>>>' + this.projectc.Name);
				/***Steven update 2014-2-17***/
			}
		}
		
		if(toAddresses.size() == 0)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请先勾选用户');         
       		ApexPages.addMessage(msg);
       		return null;
		}
		
		mail.setToAddresses(toAddresses);
		String content = '您好';
		content += '现有做单项目"' + projectc.Name + '" 需要您的协作，请将您的与之匹配的买家/卖家推荐给该项目所属企业。项目资料请点击此链接' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.projectId;
		mail.PlainTextBody = content;
	    mail.setSubject('做单项目推荐通知');
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
		/***Steven update 2014-2-17***/
		insert taskList;
		/***Steven update 2014-2-17***/
		
		PageReference redirectPag = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.projectId);
        redirectPag.setRedirect(true);
		return redirectPag;
	}
	
	public void manualShareRead(Id recordId, Id userId)
	{
		ProjectHollyhigh__Share projectShare = new ProjectHollyhigh__Share();
		
		projectShare.ParentId = recordId;
		projectShare.UserOrGroupId = userId;
		projectShare.AccessLevel = 'Read';
		// projectShare.RowCause = Schema.ProjectHollyhigh__Share.RowCause.Manual;
		insert projectShare;
	}
		
	public PageReference cancel()
	{
		PageReference redirectPag = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.projectId);
        redirectPag.setRedirect(true);
        return redirectPag; 
	}
}
