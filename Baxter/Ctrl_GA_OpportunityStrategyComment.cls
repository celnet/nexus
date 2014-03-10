/*
 * Author: Steven
 * Date: 2014-2-24
 * Description: controller
 */
public class Ctrl_GA_OpportunityStrategyComment 
{
	private Integer intDay = 10 ;//标记几号之前可以进行评价操作
    public List<OppEvaWrapper> list_OppEva{get;set;}
    public List<OppEvaWrapperByYear> list_OppEvaYear{get;set;}
    public List<List<OppEvaWrapper>> list_oppEvaByYear{get;set;}
    public String strNewMonth{get;set;}
    public String strNewYear{get;set;}
    public List<SelectOption> getNewMonths(){
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('--无--','--无--'));
        if(Date.today().day() > 8){
            strNewMonth = String.valueOf(date.today().month());
        }else{
            strNewMonth = String.valueOf(date.today().addMonths(-1).month());
        }
        options.add(new SelectOption(String.valueOf(date.today().month()),String.valueOf(date.today().month())));
        if(date.today().day() <= intDay){
            options.add(new SelectOption(String.valueOf(date.today().addMonths(-1).month()),String.valueOf(date.today().addMonths(-1).month())));
        }
        
        return options;
    }
    
    public List<SelectOption> getOwnerNewMonths()
    {
    	List<SelectOption> ownerOptions = new List<SelectOption>();
    	
    	for(Integer optionMonths = 12; optionMonths >= 1;optionMonths--)
    	{
    		ownerOptions.add(new SelectOption(String.valueOf(optionMonths), String.valueOf(optionMonths)));
    	}
    	
    	return ownerOptions;
    }
    
    public List<SelectOption> getNewYears(){
        List<SelectOption> options = new List<SelectOption>();
        strNewYear=String.valueOf(date.today().Year());
        options.add(new SelectOption(String.valueOf(date.today().Year()),String.valueOf(date.today().Year())));
        if(date.today().month() == 1){
            options.add(new SelectOption(String.valueOf(date.today().addMonths(-1).Year()),String.valueOf(date.today().addMonths(-1).Year())));
        }
        return options;
    }
    public String strEditId{get;set;}
    public ID OppId{get;set;}
    public ID UserId{get;set;}
    public Boolean blnHaveNew{get;set;}
    private ID OppOwnerId ;
    private string strUrole;
    public boolean ismanager{get;set;}
    /***Steven update 2014-2-18 增加判断是否为Opportunity的Owner的变量***/
    public boolean isOwner{get;set;}
    /***Steven update 2014-2-18 增加判断是否为Opportunity的Owner的变量***/
    public Ctrl_GA_OpportunityStrategyComment(Apexpages.Standardcontroller controller){
        //strNewMonth = String.valueOf(date.today().month());
        if(Date.today().day() > 8){
        	strNewMonth = String.valueOf(date.today().month());
        }else{
        	strNewMonth = String.valueOf(date.today().addMonths(-1).month());
        }
        
        UserId=UserInfo.getUserId();
        OppId = controller.getId();
        list_OppEva = new List<OppEvaWrapper>();
        list_OppEvaYear = new List<OppEvaWrapperByYear>();
        list_oppEvaByYear = new List<List<OppEvaWrapper>>();
        
        /***Steven update 2014-2-18 查询当前Opportunity的Owner, 判断当前用户是否为Opportunity所有人, 并给isOwner赋值***/
        Opportunity opp1 = [Select OwnerId, Id From Opportunity Where Id =: OppId];
        
        if(Userinfo.getUserId() == opp1.OwnerId)
        {
         	isOwner = true;
        }
        else
        {
         	isOwner = false;
        }
        /***Steven update 2014-2-18 查询当前Opportunity的Owner, 判断当前用户是否为Opportunity所有人, 并给isOwner赋值***/
        
        List<UserRole> listur = [Select Id,Name From UserRole Where Id =: Userinfo.getUserRoleId()];
        if(listur.size() > 0 ){
            String strRolName = listur[0].Name; 
        
            if(strRolName.toUpperCase().contains('REP')){
                ismanager=false;
            }else if(this.isOwner){
                ismanager=false;
            }else{
            	ismanager=true;
            }
            
            if(strRolName.contains('-')){
                List<String> list_s = strRolName.split('-');
                if(list_s.size() == 5){
                    strUrole=list_s[1];
                }else{
                    strUrole=strRolName;
                }
            }else{
                strUrole=strRolName;
            }
        }
        
        getOppEvaluations();
    }
    public String strYear{get{return String.valueOf(date.today().Year());}}
    public String strMonth{get{return String.valueOf(date.today().Month());}}
    private Set<String> set_haveComment = new Set<String>();
    private Map<String , List<OppEvaWrapper>> map_oew = new Map<String , List<OppEvaWrapper>>();
    private void getOppEvaluations(){
        if(OppId != null){
            //list_oppEvaByYear.clear();
            map_oew.clear();
            list_OppEva.clear();
            set_haveComment.clear();
            /***Steven update 2014-2-18 query 增加 Summary__c***/
            for(OppEvaluation__c oppEva : [Select Id,BeCommentUser__c,Commentator__c,CommentDate__c,
                                           Year__c,Score__c,Comments__c,Opportunity__c,Opportunity__r.OwnerId,Month__c,IsQualityEva__c,
                                           Summary__c 
                                           From OppEvaluation__c Where Opportunity__c =: OppId Order By Month__c desc]){
            /***Steven update 2014-2-18 query 增加Summary__c***/
                //封装
                OppEvaWrapper oppEvaWra = new OppEvaWrapper();
                set_haveComment.add(oppEva.Commentator__c+oppEva.Month__c+oppEva.Year__c);
                oppEvaWra.blnOld = true;
                /***Steven update 2014-2-18 设定自我总结显示为Output***/
                oppEvaWra.blnSumView = true;
                if(this.isOwner)
                {
                	oppEvaWra.blnSumButtonEdit = true;
                }
                /***Steven update 2014-2-18 设定自我总结显示为Output***/
                if(OppOwnerId==null){
                    OppOwnerId = oppEva.Opportunity__r.OwnerId;
                }
                oppEvaWra.OppEva = oppEva ;
                if(date.today().day() <= intDay && 
                   oppEva.Year__c == String.valueOf(date.today().addMonths(-1).Year()) && 
                   oppEva.Month__c == String.valueOf(date.today().addMonths(-1).Month()) &&
                   oppEva.Commentator__c == UserInfo.getUserId()){
                    oppEvaWra.blnCanEdit = true;
                    oppEvaWra.blnSumButtonEdit = false;
                }else if(oppEva.Year__c == String.valueOf(date.today().Year()) && oppEva.Month__c == String.valueOf(date.today().Month()) && oppEva.Commentator__c == UserInfo.getUserId()){
                    oppEvaWra.blnCanEdit = true;
                    oppEvaWra.blnSumButtonEdit = false;
                }
                /***Steven update 2014-2-18 点评人不存在时也赋予编辑***/
                if(date.today().day() <= intDay && 
                   oppEva.Year__c == String.valueOf(date.today().addMonths(-1).Year()) && 
                   oppEva.Month__c == String.valueOf(date.today().addMonths(-1).Month()) &&
                   oppEva.Commentator__c == null && ismanager == true){
                    oppEvaWra.blnCanEdit = true;
                    oppEvaWra.blnSumButtonEdit = false;
                }else if(oppEva.Year__c == String.valueOf(date.today().Year()) && oppEva.Month__c == String.valueOf(date.today().Month()) && oppEva.Commentator__c == null && ismanager == true){
                    oppEvaWra.blnCanEdit = true;
                    oppEvaWra.blnSumButtonEdit = false;
                }
                /***Steven update 2014-2-18 点评人不存在时也赋予编辑***/
                
                
                //按年构建
                if(map_oew.containsKey(oppEva.Year__c)){
                    List<OppEvaWrapper> list_oew = map_oew.get(oppEva.Year__c);
                    list_oew.add(oppEvaWra);
                    map_oew.put(oppEva.Year__c , list_oew);
                }else{
                    List<OppEvaWrapper> list_oew = new List<OppEvaWrapper>();
                    list_oew.add(oppEvaWra);
                    map_oew.put(oppEva.Year__c , list_oew);
                }
                list_OppEva.add(oppEvaWra);
            }
            buildTable(map_oew);
            
            
        }
    }
    private void buildTable(Map<String , List<OppEvaWrapper>> map_oewr){
        list_oppEvaByYear.clear();
        list_OppEvaYear.clear();
        if(map_oewr.size() > 0){
            List<String> list_year = new List<String>();
            list_year.addAll(map_oewr.keySet());
            list_year.sort();
            for(String stryear : list_year){
                List<OppEvaWrapper> listoew = map_oewr.get(stryear);
                OppEvaWrapperByYear oewby = new OppEvaWrapperByYear();
                oewby.strYear = stryear;
                oewby.listOppEvaw=listoew;
                if(list_OppEvaYear.size() > 0){
                    list_OppEvaYear.add(0,oewby);
                }else{
                    list_OppEvaYear.add(oewby);
                }
                
                
                if(list_oppEvaByYear.size() > 0){
                    list_oppEvaByYear.add(0 , listoew);
                }else{
                    list_oppEvaByYear.add(listoew);
                }
            }
        }
    }
    
    public void addComment(){
        
        OppEvaWrapper oppEvaWra = new OppEvaWrapper();
        oppEvaWra.OppEva = new OppEvaluation__c();
        /***Steven update 2014-2-18 当前用户为所有人时不赋予点评人***/
        if(!isOwner)
        {
        	oppEvaWra.OppEva.Commentator__c = UserInfo.getUserId();
        }
        /***Steven update 2014-2-18 当前用户为所有人时不赋予点评人***/
        oppEvaWra.OppEva.Opportunity__c = OppId;
        oppEvaWra.strMonth = strNewMonth;
        
        if(!isOwner)
        {
        	if(oppEvaWra.strMonth == String.valueOf(date.today().month())){
            	oppEvaWra.OppEva.Year__c = String.valueOf(date.today().year());
	        }else if(oppEvaWra.strMonth == String.valueOf(date.today().addMonths(-1).month())){
	            oppEvaWra.OppEva.Year__c = String.valueOf(date.today().addMonths(-1).year());
	        }
        }
        else
        {
        	oppEvaWra.OppEva.Year__c = strNewYear;
        }
        
        if(OppOwnerId!=null){
            oppEvaWra.OppEva.BeCommentUser__c = OppOwnerId;
        }else{
            List<Opportunity> list_opp = [Select Id,OwnerId From Opportunity Where Id =: OppId];
            if(list_opp.size() > 0){
                oppEvaWra.OppEva.BeCommentUser__c = list_opp[0].OwnerId;
            }
        }
        /***Steven update 2014-2-18 增加对业务机会所有人可见***/
        if(!isOwner)
        {
        	oppEvaWra.blnNew=true;
        	oppEvaWra.blnSumView = true;
        	oppEvaWra.blnSumButtonEdit = true;
        }
        else
        {
        	oppEvaWra.blnOld=true;
        	oppEvaWra.blnSumNew = true;
        }
        /***Steven update 2014-2-18 增加对业务机会所有人可见***/
        if(map_oew.containsKey(oppEvaWra.OppEva.Year__c)){
            List<OppEvaWrapper> list_oew=map_oew.get(oppEvaWra.OppEva.Year__c);
            list_oew.add(0,oppEvaWra);
            map_oew.put(oppEvaWra.OppEva.Year__c , list_oew);
        }else{
            List<OppEvaWrapper> list_oew=new List<OppEvaWrapper>();
            list_oew.add(oppEvaWra);
            map_oew.put(oppEvaWra.OppEva.Year__c , list_oew);
        }
        buildTable(map_oew);
        /*
        if(list_OppEva.size() > 0){
            list_OppEva.add(0 , oppEvaWra);
        }else{
            list_OppEva.add( oppEvaWra);
        }
        */
        blnHaveNew = true;
        system.debug('have new ???'+blnHaveNew);
    }
    public void saveComment(){
        List<OppEvaluation__c> list_oppEvaIns = new List<OppEvaluation__c>();
        List<OppEvaluation__c> list_oppEvaUp = new List<OppEvaluation__c>();
        for(OppEvaWrapperByYear oewby : list_OppEvaYear){
           for(OppEvaWrapper oew : oewby.listOppEvaw){
                system.debug(oew);
                if(strEditId == 'new'){
                    if(oew.blnNew == true && oew.OppEva.Id == null){
                        
                        oew.OppEva.Month__c=oew.strMonth;
                        oew.OppEva.CommentatorRole__c=strUrole;
                        oew.OppEva.CommentDate__c = date.today();
                        if(oew.strMonth == String.valueOf(date.today().month())){
                            oew.OppEva.Year__c = String.valueOf(date.today().year());
                        }else if(oew.strMonth == String.valueOf(date.today().addMonths(-1).month())){
                            oew.OppEva.Year__c = String.valueOf(date.today().addMonths(-1).year());
                        }else{
                        	//error
                        }
                        if(set_haveComment.contains(oew.OppEva.Commentator__c+oew.OppEva.Month__c+oew.OppEva.Year__c)){
                            continue;
                        }
                        system.debug(oew);
                        list_oppEvaIns.add(oew.OppEva);
                        blnHaveNew = false;
                    }
                    /***Steven update 2014-2-18 保存所有人新添加的记录***/
                    if(oew.blnSumNew == true && oew.OppEva.Id == null)
                    {
                    	oew.OppEva.Month__c=oew.strMonth;
                        oew.OppEva.CommentatorRole__c=strUrole;
                        oew.OppEva.CommentDate__c = date.today();
						
                        if(oew.strMonth == String.valueOf(date.today().month())){
                            oew.OppEva.Year__c = String.valueOf(date.today().year());
                        }else if(oew.strMonth == String.valueOf(date.today().addMonths(-1).month())){
                            oew.OppEva.Year__c = String.valueOf(date.today().addMonths(-1).year());
                        }else{
                            oew.OppEva.Year__c = String.valueOf(Date.today().year());
                        }
                        
                        if(set_haveComment.contains(oew.OppEva.Commentator__c+oew.OppEva.Month__c+oew.OppEva.Year__c)){
                            continue;
                        }
                        system.debug(oew);
                        list_oppEvaIns.add(oew.OppEva);
                        blnHaveNew = false;
                    }
                    /***Steven update 2014-2-18 保存所有人新添加的记录***/
                }else if(strEditId == oew.OppEva.Id){
                    if(oew.blnEdit == true && oew.OppEva.Id != null){
                        list_oppEvaUp.add(oew.OppEva);
                    }
                    /***Steven update 2014-2-18 更新所有人修改的记录***/
                    if(oew.blnSumEdit == true && oew.OppEva.Id != null)
                    {
                    	list_oppEvaUp.add(oew.OppEva);
                    }
                    /***Steven update 2014-2-18 更新所有人修改的记录***/
                }
            }
        }
        
        system.debug('Heee'+list_oppEvaIns);
        /*************bill  add 2013/4/26 begin*********************/
        //sunny 2013-5-14注释掉自动发邮件
        //AutoSendmail autoSendmail = NEW AutoSendmail();
        if(list_oppEvaIns.size() > 0){
            insert list_oppEvaIns;
            //autoSendmail.AutoSendmailOpportunity(oppId, list_oppEvaIns[0].Id, '评分');
        }
        if(list_oppEvaUp.size()>0){
            update list_oppEvaUp;
            //autoSendmail.AutoSendmailOpportunity(oppId, list_oppEvaUp[0].Id, '评分修改');
        }
        /*************bill  add 2013/4/26 END*********************/
        getOppEvaluations();
    }
    public void editComment(){
        system.debug('edit record:'+strEditId);
        for(OppEvaWrapper oew : list_OppEva){
            if(oew.OppEva.Id == strEditId){
            	/***Steven update 2014-2-18 给点评人赋值***/
            	if((!isOwner)&&ismanager)
            	{
            		oew.OppEva.Commentator__c = Userinfo.getUserId();
            	}
            	/***Steven update 2014-2-18 给点评人赋值***/
            	if(isOwner)
            	{
            		oew.blnSumEdit = true;
            		oew.blnSumView = false;
            		oew.blnSumButtonEdit = false;
            		oew.blnEdit = false;
            		oew.blnCanEdit = false;
            		oew.blnOld = true;
            	}
            	else
            	{
            		oew.blnSumEdit = false;
            		oew.blnSumView = true;
            		oew.blnSumButtonEdit = false;
	                oew.blnEdit=true;
	                oew.blnCanEdit=false;
	                oew.blnOld=false;
            	}
            }
        }
    }
    public void cannelEdit(){
        getOppEvaluations();
        /*
        for(OppEvaWrapper oew : list_OppEva){
            if(oew.OppEva.Id == strEditId){
                oew.blnEdit=false;
                oew.blnCanEdit=true;
                oew.blnOld=true;
            }
        }
        */
    }
    public void SendEmail(){
    	AutoSendmail autoSendmail = new AutoSendmail();
    	for(OppEvaWrapperByYear oewby : list_OppEvaYear){
    		for(OppEvaWrapper oew : oewby.listOppEvaw){
	            if(strEditId == oew.OppEva.Id){
	                autoSendmail.AutoSendmailOpportunity(OppId, oew.OppEva.Id, '评分');
	                return;
	            }
	        }
    	}
    }
    public class OppEvaWrapperByYear{
        public String strYear{get;set;}
        public list<OppEvaWrapper> listOppEvaw{get;set;}
    }
    public class OppEvaWrapper{
        public OppEvaluation__c OppEva{get;set;}
        public String strMonth{get;set;}
        public Boolean blnNew{get;set;}
        public Boolean blnOld{get;set;}
        public Boolean blnEdit{get;set;}
        public Boolean blnCanEdit{get;set;}
        /***Steven update 2014-2-18 增加判断自我总结一栏显示的值***/
        public Boolean blnSumNew{get;set;}
        public Boolean blnSumEdit{get;set;}
        public Boolean blnSumView{get;set;}
        public Boolean blnSumButtonEdit{get;set;}
        /***Steven update 2014-2-18 增加判断自我总结一栏显示的值***/
    }	
}
