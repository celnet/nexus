public with sharing class WEQY_XunDianDetailController
{
	public VisitPlan__c vp{get;set;}
	public Id vpId{get;set;}
	public string qyUserId{get;set;}
	public string visitName{get;set;}
	public VisitPlanWrapper vpw{get;set;}
	
	public 	WEQY_XunDianDetailController()
	{
		
		this.vp = new VisitPlan__c();
		vpId = ApexPages.currentPage().getParameters().get('id');
		visitName = ApexPages.currentPage().getParameters().get('visitName');
		qyUserId = ApexPages.currentPage().getParameters().get('qyUserId');
		system.debug(qyUserId + 'qyUserId=======');
		if(vpId != null)
		{
			vp = [select 
					Id,
					Name,
					Note__c,
					VisitDate__c,
					Store__r.Address__c,
					Store__r.Name,
					Store__r.Demo_Geocode__Latitude__s,
					Store__r.Demo_Geocode__Longitude__s,
					DemoAccount__c,
					DemoAccount__r.Location__Longitude__s,
					DemoAccount__r.Location__Latitude__s
				  from VisitPlan__c 
				  where id=:vpId ];
		}
		
	}
	
	@RemoteAction
	public static String saveNote(VisitPlanWrapper vpcw){
		
		vpcw.vpc.Id = vpcw.vId;
		update vpcw.vpc;
		return vpcw.vpc.Note__c;
	}
	
	public class VisitPlanWrapper{
		public VisitPlan__c vpc{get;set;}
		public Id vId{get;set;}
	}
}
