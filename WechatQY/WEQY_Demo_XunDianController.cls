public  class WEQY_Demo_XunDianController 
{
	public List<VisitPlan__c>  vpList{get;set;}
	public WEQYEntity.UserInfoResponse qyUser{get;set;}
	
	public string qyUserId {get;set;}
	public string visitName {get;set;}
	
	public string bfColorShow {get;set;}
	public string bfState {get;set;}
	
	public string isShow{get;set;}
	public string isShowOther{get;set;}
	
	public Id userId {get;set;}
	public VisitPlan__c vp{get;set;}
	
	public WEQY_Demo_XunDianController()
	{
		this.vpList = new List<VisitPlan__c>();
	    qyUserId = Apexpages.currentPage().getParameters().get('qyUserId');

		string code;
		if(qyUserId == null)
		{
			code = Apexpages.currentPage().getParameters().get('code');
			WEQYCalloutService wcs = new WEQYCalloutService('wx9c6403e5364fd478','Salesforce');
    		qyUser = wcs.GetUserInfo(code,'16');
    		qyUserId = qyUser.UserId;
    		visitName = Apexpages.currentPage().getParameters().get('state');
		} else{
	        visitName = Apexpages.currentPage().getParameters().get('visitName');
	       system.debug(visitName + 'visitName');
		}
		system.debug(qyUserId + '=============');
		system.debug(code + '===code==========');
		if(qyUserId == null && code == null)
		{
			isShow = 'display:none';
    		isShowOther = 'display:block';
    		return;
		}else
		{
    		 User u = [select id,Name from User where WeChat_QY_ID__c=:qyUserId];
			 userId = u.Id;
			 isShow = 'display:block';
			 isShowOther = 'display:none';
    	}
    	//Id userId = [select id,Name from User where WeChat_QY_ID__c=:qyUserId].Id;
		if(visitName == 'visited')
		{
		   vpList = [select Id,Name,VisitDate__c,Store__r.Address__c,Store__r.Name from VisitPlan__c where OwnerId=:userId and IsVisited__c=true];
		   bfColorShow = 'color:blue';
		   bfState = '已拜访';
		}
		else
		{
		   vpList = [select Id,Name,VisitDate__c,Store__r.Address__c,Store__r.Name from VisitPlan__c where OwnerId=:userId and IsVisited__c=false];
		   bfColorShow = 'color:red';
		   bfState = '未拜访';
		}
		
	}
}
