public  class WEQY_Demo_BaiFangController 
{
	public List<Demo_VisitInfo__c> viList{get;set;}
	public Id vpId{get;set;}
	public string bfvpid {get;set;}
	public VisitPlan__c vp{get;set;}
	
	public string qyUserId{get;set;}
	public string visitName{get;set;}

	public 	WEQY_Demo_BaiFangController()
	{
		this.viList = new List<Demo_VisitInfo__c>();
		this.vp = new VisitPlan__c();
		
		visitName = ApexPages.currentPage().getParameters().get('visitName');
		qyUserId = ApexPages.currentPage().getParameters().get('qyUserId');

		vpId = ApexPages.currentPage().getParameters().get('id');
		bfvpid = ApexPages.currentPage().getParameters().get('vpid');
		if(vpId != null)
		{
			vp = [select Id,Name,VisitDate__c,Store__r.Address__c,Store__r.Name from VisitPlan__c where id=:vpId];
			viList = [select Id,Name,Item__c,Price__c,VisitPlan__c from Demo_VisitInfo__c where VisitPlan__c=:vpId ];
		}
	}
}
