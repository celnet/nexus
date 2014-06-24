public with sharing class MassTransferDemo  implements ObjectPaginatorListener{
    public Account acc{get;set;}
    public List<SelectOption> options{get;set;}
    public String selected{get;set;}
    
    // 保存当前查询的类型 Account 或者 Opportunity
    private String cloneSelected;
    
    // 从Account的Representative_Office__c字段中获取代表处和系统部的picklist值，Opportunity和Account的该字段picklist值一样
    public List<SelectOption> getRepresentativeOfficeOptions(){
		List<SelectOption> officeOptions = new List<SelectOption>();
		Schema.Describefieldresult fieldResult = Account.Representative_Office__c.getDescribe();
		List<Schema.Picklistentry> ple = fieldResult.getPicklistValues();
		officeOptions.add(new SelectOption('null','--无--'));
		for(Schema.Picklistentry f : ple){
			if(f.getLabel().contains('代表处') || f.getLabel().contains('系统部')){
				officeOptions.add(new SelectOption(f.getLabel(),f.getValue()));
			}
		}
		return officeOptions;
	}
    public String selectedRepresentativeOffice{get;set;}
    
    // Map<Id, OwnerId>
    private Map<Id, Id> cloneMap;
    public List<AccountWrapper> awList{get;set;}
    public List<OpportunityWrapper> owList{get;set;}
    
    public class AccountWrapper{
        public Account account{get;set;}
        public Account newowner{get;set;}
        public String saveStatus{get;set;}
        public String statusColor{get;set;}
        public boolean editable{get;set;}
        public AccountWrapper(Account acc, boolean edit){
        	newowner = new Account();
            account = acc;
            editable = edit;
        }
    }
    
    public class OpportunityWrapper{
        public Opportunity opportunity{get;set;}
        public Opportunity newowner{get;set;}
        public String saveStatus{get;set;}
        public String statusColor{get;set;}
        public boolean editable {get;set;}
        public OpportunityWrapper(Opportunity opp, boolean edit){
        	newowner = new Opportunity();
            opportunity = opp;
            editable = edit;
        }
    }
    
    public ObjectPaginator paginator {get;private set;}
    
    public boolean displayAccounts{get;set;}
    public boolean displayOpportunities{get;set;}
    public boolean displayStatus{get;set;}
    
    public MassTransferDemo(){
        this.cloneMap = new Map<Id, Id>();
        this.awList = new List<AccountWrapper>();
        this.owList = new List<OpportunityWrapper>();
        
        this.options = new List<SelectOption>();     
        this.options.add(new SelectOption('account',Schema.SObjectType.Account.getLabel()));
        this.options.add(new SelectOption('opportunity', Schema.SObjectType.Opportunity.getLabel()));
        this.selected = 'account';
        this.cloneSelected = this.selected;
        
        this.acc = new Account();
        this.displayAccounts = false;
        this.displayOpportunities = false;
        this.displayStatus = false;
    }
    
    public void query(){
        this.cloneSelected = this.selected;
        
        //15 is pageSize, this refers to this class which acts as listener to paginator
        paginator = new ObjectPaginator(15,this);
        
        // 查询条件
        String conditionString = '';
        if(this.acc.OwnerId != null){
            conditionString += ' And OwnerId =\'' + this.acc.OwnerId + '\'';
        }
        
        if(this.selectedRepresentativeOffice != 'null'){
        	conditionString += ' And Representative_Office__c =\'' + this.selectedRepresentativeOffice + '\'';
        }
        
        if(selected == 'account'){
            this.displayOpportunities = false;
            String queryString = 'Select Id, Name, OwnerId, Region_HW__c, CIS__c, Is_Named_Account__c, Customer_Group__c, Local_Name__c, Representative_Office__c  From Account Where RecordTypeId = \'' + CONSTANTS.HUAWEICHINACUSTOMERRECORDTYPE + '\'';
            queryString += conditionString;
            queryString += ' limit 3000';
            
            List<Account> records = Database.query(queryString);
            this.displayAccounts = records.size() > 0?true:false;
            
            paginator.setRecords(records);
        }
        else if(selected == 'opportunity'){
            this.displayAccounts = false;
            String queryString = 'Select Id, Name, OwnerId, Region__c, Account.Name, StageName, Customer_Group__c From Opportunity Where (RecordTypeId = \'' + CONSTANTS.CHINAOPPORTUNITYRECORDTYPE + '\' OR RecordTypeId = \'' + CONSTANTS.HUAWEICHINADEALOPPRECORDTYPE + '\' )';
            queryString += conditionString;
            
            List<Opportunity> records = Database.query(queryString);
            this.displayOpportunities = records.size() > 0?true:false;
            
            paginator.setRecords(records);
        }
        
        if(paginator.recordCount == 0){
            this.addMessage(ApexPages.SEVERITY.INFO, '没有查询到记录，请修改筛选条件后重新查询');
        }else{
            this.addMessage(ApexPages.SEVERITY.INFO, '共查询到' + paginator.recordCount + '条记录，请修改完所有人后点击转移按钮转移本页记录');
        }
        
        
    }
    
    private void addMessage(ApexPages.SEVERITY severity,  String summary){
        ApexPages.Message msg = new ApexPages.Message(severity, summary);
        ApexPages.addMessage(msg);
    }
    
    private Set<Id> retrieveEditableRecords(List<Id> recordIds){
        List<UserRecordAccess> accessList = [Select RecordId From UserRecordAccess Where UserId =: UserInfo.getUserId() 
                And RecordId IN: recordIds And HasEditAccess = true];
        
        Set<Id> editableIds = new Set<Id>();
        
        for(UserRecordAccess access : accessList){
            editableIds.add(access.RecordId);
        }
        
        return editableIds;
    }
    
    private List<Id> retrieveAllRecordIds(List<Object> records){
        List<Id> recordIds = new List<Id>();
    	if(records != null){
    		if(this.cloneSelected == 'account'){
	    		for(Object record : records){
					Account a = (Account) record;
					recordIds.add(a.Id);
	    		}
    		}else if(this.cloneSelected == 'opportunity'){
				for(Object record : records){
					Opportunity o = (Opportunity) record;
					recordIds.add(o.Id);
				}
			}
    	}
    	return recordIds;
    }
    
    public void handlePageChange(List<Object> newPage){
        this.cloneMap.clear();
        this.displayStatus = false;
        List<Id> allRecordIds = this.retrieveAllRecordIds(newPage);
        Set<Id> editableRecordIds = this.retrieveEditableRecords(allRecordIds);
        
        if(this.cloneSelected == 'account'){
            awList.clear();
            if(newPage != null){
                for(Object acct : newPage){
                    Account a = (Account)acct;
                    if(editableRecordIds.contains(a.Id)){
                        this.awList.add(new AccountWrapper(a, true));
                    } else {
                        this.awList.add(new AccountWrapper(a, false));
                    }
                    this.cloneMap.put(a.Id, a.OwnerId);
                }
            }
        } else if(this.cloneSelected == 'opportunity'){
            owList.clear();
            if(newPage != null){
                for(Object oppt : newPage){
                    Opportunity o = (Opportunity)oppt;
                    if(editableRecordIds.contains(o.Id)){
                        this.owList.add(new OpportunityWrapper(o, true));
                    } else {
                        this.owList.add(new OpportunityWrapper(o, false));
                    }
                    this.cloneMap.put(o.Id, o.OwnerId);
                }
            }
        }
    }
    
    private List<Account> retrieveUpdateAccountList(Map<Id, AccountWrapper> awMap){
    	List<Account> accList = new List<Account>();
        for(AccountWrapper aw : awList){
            aw.saveStatus = '';
            if(aw.newowner.OwnerId != null){
            	aw.account.OwnerId = aw.newowner.OwnerId;
            	accList.add(aw.account);
            	awMap.put(aw.account.Id, aw);
            	aw.saveStatus = '转移失败';
                aw.statusColor = 'red';
            }
            
            this.displayStatus = true;
        }
        return accList;
    }
    
    private List<Opportunity> retrieveUpdateOpportunityList(Map<Id, OpportunityWrapper> owMap){
    	List<Opportunity> oppList = new List<Opportunity>();
        for(OpportunityWrapper ow : owList){
            ow.saveStatus = '';
            if(ow.newowner.OwnerId != null){
            	ow.opportunity.OwnerId = ow.newowner.OwnerId;
            	oppList.add(ow.opportunity);
            	ow.saveStatus = '转移失败';
            	ow.statusColor = 'red';
            }
            owMap.put(ow.opportunity.Id, ow);
            this.displayStatus = true;
        }
        return oppList;
    }
    
    public void save(){
        this.displayStatus = false;
        Integer success = 0;
        Integer failure = 0;
        
        if(this.cloneSelected == 'account'){
            Map<Id,AccountWrapper> saveAWMap = new Map<Id, AccountWrapper>();
            List<Account> accList = this.retrieveUpdateAccountList(saveAWMap);
            Database.Saveresult[] srList = Database.update(accList, false);
            this.retrieveUpdateStatus(saveAWMap, null, success, failure, srList);
            this.refreshEditable();
        } else if(this.cloneSelected == 'opportunity'){
            Map<Id, OpportunityWrapper> saveOWMap = new Map<Id, OpportunityWrapper>();
            List<Opportunity> oppList = this.retrieveUpdateOpportunityList(saveOWMap);
            Database.Saveresult[] srList = Database.update(oppList, false);
            this.retrieveUpdateStatus(null, saveOWMap, success, failure, srList);
            this.refreshEditable();
        }
        this.addMessage(ApexPages.Severity.INFO, '共转移' + (success + failure) + '条记录，其中转移成功' + success + '条，转移失败' + failure + '条');
    }
    
    private void retrieveUpdateStatus(Map<Id, AccountWrapper> awMap, Map<Id, OpportunityWrapper> owMap, Integer success, Integer failure, Database.Saveresult[] srList){
		for(Database.Saveresult sr : srList){
            if(sr.isSuccess()){
            	if(this.selected == 'opportunity'){
            		owMap.get(sr.getId()).saveStatus = '转移成功';
                	owMap.get(sr.getId()).statusColor = 'green';
            	}else if(this.selected == 'account'){
            		awMap.get(sr.getId()).saveStatus = '转移成功';
                	awMap.get(sr.getId()).statusColor = 'green';
            	}
                
                success++;
            } else {
            	if(this.selected == 'opportunity'){
            		for(OpportunityWrapper ow : owMap.values()){
                		if(ow.saveStatus == '转移失败'){
                            ow.newowner.OwnerId.addError('' + sr.getErrors() != null?sr.getErrors()[0].getMessage():'');
                        }
                	}
            	} else if(this.selected == 'account'){
            		for(AccountWrapper aw : awMap.values()){
                		if(aw.saveStatus == '转移失败'){
                            aw.newowner.OwnerId.addError('' + sr.getErrors() != null?sr.getErrors()[0].getMessage():'');
                        }
                    }
            	}
                
                failure++;
            }
        }
    }
    
    private void refreshEditable(){
    	List<Id> idList = new List<Id>();
        idList.addAll(this.cloneMap.keySet());
        Set<Id> editables = this.retrieveEditableRecords(idList);
        
        if(this.selected == 'opportunity'){
	        for(OpportunityWrapper ow:this.owList){
	            if(editables.contains(ow.opportunity.Id)){
	                ow.editable = true;
	            }else{
	                ow.editable = false;
	            }
	            
	            this.cloneMap.put(ow.opportunity.Id, ow.opportunity.OwnerId);
	        }
	    }else if(this.selected == 'account'){
	    	for(AccountWrapper aw:this.awList){
                if(editables.contains(aw.account.Id)){
                    aw.editable = true;
                }else{
                    aw.editable = false;
                }
                
                this.cloneMap.put(aw.account.Id, aw.account.OwnerId);
            }
	    }
    }
}
