public  class WEQY_Demo_BaiFangDetailController 
{
	public Demo_VisitInfo__c vi{get;set;}
	public Id viId{get;set;}
	
	public string qyUserId{get;set;}
	public string visitName{get;set;}
	
	public 	WEQY_Demo_BaiFangDetailController()
	{
		this.vi = new Demo_VisitInfo__c();
		visitName = ApexPages.currentPage().getParameters().get('visitName');
		qyUserId = ApexPages.currentPage().getParameters().get('qyUserId');
		viId = ApexPages.currentPage().getParameters().get('id');
		if(viId != null)
		{
			vi = [select Id,Name,Item__c,Price__c,VisitPlan__c, VisitPlan__r.Name from Demo_VisitInfo__c where id=:viId ];
		}
	}
}
