public  class WEQY_Demo_ModifyBaiFang 
{
	public Demo_VisitInfo__c dv{get;set;}
	public Id viId{get;set;}
	public VisitInfo viInfo{get;set;}
	public string vpid {get;set;}
	
	public string qyUserId{get;set;}
	public string visitName{get;set;}
	
	public List<VisitPlan__c > vpList {get;set;}
	
	public WEQY_Demo_ModifyBaiFang()
	{
		this.dv = new Demo_VisitInfo__c();
		this.vpList = new List<VisitPlan__c >();
		
		visitName = ApexPages.currentPage().getParameters().get('visitName');
		qyUserId = ApexPages.currentPage().getParameters().get('qyUserId');
	
		vpid = ApexPages.currentPage().getParameters().get('vpid');
		vpList = [select Id,Name from VisitPlan__c];
		if(ApexPages.currentPage().getParameters().get('id') != null)
		{
			viId = ApexPages.currentPage().getParameters().get('id');
			dv = [select Id,Name,Item__c,Price__c,VisitPlan__c,VisitPlan__r.Name from Demo_VisitInfo__c where id=:viId ];
		}
	}
	
	public List<SelectOption> getItems()
	{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('-- 请选择 --','-- 请选择 --'));
            for(VisitPlan__c vp : vpList)
            {
            	options.add(new SelectOption(vp.Id,vp.Name));
            }
            return options;
       }
       
	@RemoteAction
	public static String saveVisit(VisitInfo viInfo){
		if(viInfo.vid != null && viInfo.vid != ''){
			update viInfo.dv;
			return viInfo.dv.Id;
		} else {
			viInfo.dv.Id = null;
			insert viInfo.dv;
			return viInfo.dv.Id;
		}
	}
	
	public class VisitInfo{
		public Demo_VisitInfo__c dv{get;set;}
		public String vid{get;set;}
	}
}
