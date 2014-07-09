global with sharing class Checkin2Extension {
    public String username{get;set;}
    public String displayCheckinInfo{get;set;}
    public String displayCheckinResult{get;set;}
    public String display4pCheckType{get;set;}
    public String display4pGeneral{get;set;}
    public String display4pSKU{get;set;}
    public String display4pResult{get;set;}
    public String displayCheckoutInfo{get;set;}
    public String displayCheckoutResult{get;set;}
    
    public String selectedSegment{get;set;}
    public String selectedBrand{get;set;}
    
    public List<SelectOption> segmentOptions{get{
    		return this.retrieveSegments();
	    }
		private set;
	}
	
	public List<SelectOption> brandOptions{get;set;}
	public List<optionLists> itemsOptions{get;set;}
	
	public List<SelectOption> Store4PType {
        get {
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeSObjectResult store4PType = Store_4P__c.getSobjectType().getDescribe();
            map<String, Schema.SObjectField> fieldMap = store4PType.fields.getMap();
            list<Schema.PicklistEntry> values = fieldMap.get('Check_Type__c').getDescribe().getPickListValues();
            for(Schema.PicklistEntry a : values){
                options.add(new SelectOption(a.getLabel(), a.getValue()));
            }
            return options;
        }
        private set;
    }
    
    global Checkin2Extension(ApexPages.StandardController controller){
    	User currentUser = [Select id,Name,Field_Sales_Code__c From User Where Id =: UserInfo.getUserId()];
        username = currentUser.Name;
        
        this.brandOptions = this.retrieveBrands();
        this.segmentOptions = this.retrieveSegments();
        this.itemsOptions = this.retrieveItemOptions();
        
        displayCheckinInfo = '';
        displayCheckinResult = 'display:none;';
        display4pCheckType = 'display:none;';
        display4pGeneral = 'display:none;';
        display4pSKU = 'display:none;';
        display4pResult = 'display:none;';
        displayCheckoutInfo = 'display:none;';
        displayCheckoutResult = 'display:none;';
        
    }
    
    public void filterItems(){
    	System.debug('>>>>>>>' + this.selectedBrand);
    	this.segmentOptions = this.retrieveSegments();
    	this.itemsOptions = this.retrieveItemOptions();
    }
    
    public void navCheckinToResult(){
    	displayCheckinInfo = 'display:none;';
    	displayCheckinResult = '';
    }
    
    public void navCheckinTo4p(){
    	displayCheckinInfo = 'display:none;';
        displayCheckinResult = 'display:none;';
        display4pCheckType = '';
        display4pGeneral = 'display:none;';
        display4pSKU = 'display:none;';
        display4pResult = 'display:none;';
        displayCheckoutInfo = 'display:none;';
        displayCheckoutResult = 'display:none;';
    }
    
    public void nav4pToSKU(){
    	displayCheckinInfo = 'display:none;';
        displayCheckinResult = 'display:none;';
        display4pCheckType = 'display:none;';
        display4pGeneral = 'display:none;';
        display4pSKU = '';
        display4pResult = 'display:none;';
        displayCheckoutInfo = 'display:none;';
        displayCheckoutResult = 'display:none;';
    }
    
    public void nav4pToGeneral(){
    	displayCheckinInfo = 'display:none;';
        displayCheckinResult = 'display:none;';
        display4pCheckType = 'display:none;';
        display4pGeneral = '';
        display4pSKU = 'display:none;';
        display4pResult = 'display:none;';
        displayCheckoutInfo = 'display:none;';
        displayCheckoutResult = 'display:none;';
    }
    
    public void nav4pToResult(){
    	displayCheckinInfo = 'display:none;';
        displayCheckinResult = 'display:none;';
        display4pCheckType = 'display:none;';
        display4pGeneral = 'display:none;';
        display4pSKU = 'display:none;';
        display4pResult = '';
        displayCheckoutInfo = 'display:none;';
        displayCheckoutResult = 'display:none;';
    }
    
    public void nav4pTo4p(){
    	displayCheckinInfo = 'display:none;';
        displayCheckinResult = 'display:none;';
        display4pCheckType = '';
        display4pGeneral = 'display:none;';
        display4pSKU = 'display:none;';
        display4pResult = 'display:none;';
        displayCheckoutInfo = 'display:none;';
        displayCheckoutResult = 'display:none;';
    }
    
    public void nav4pToCheckout(){
    	displayCheckinInfo = 'display:none;';
        displayCheckinResult = 'display:none;';
        display4pCheckType = 'display:none;';
        display4pGeneral = 'display:none;';
        display4pSKU = 'display:none;';
        display4pResult = 'display:none;';
        displayCheckoutInfo = '';
        displayCheckoutResult = 'display:none;';
    }
    
    public void navCheckoutToResult(){
    	displayCheckinInfo = 'display:none;';
        displayCheckinResult = 'display:none;';
        display4pCheckType = 'display:none;';
        display4pGeneral = 'display:none;';
        display4pSKU = 'display:none;';
        display4pResult = 'display:none;';
        displayCheckoutInfo = 'display:none;';
        displayCheckoutResult = '';
    }
    
    @RemoteAction
    global static sf1Result submitCheckin(CheckinHistoryWrapper chw){
        Id recordId;
        try{
            User currentUser = [Select Id, Name, Field_Sales_Code__c From User Where Id =: UserInfo.getUserId()];
            Field_Sales__c currentFS = [Select Id From Field_Sales__c Where Name =: currentUser.Field_Sales_Code__c];
            List<Checkin_History__c> chList = [Select id From Checkin_History__c Where Store__c =: chw.checkinHistory.Store__c And Field_Sales__c =: currentFS.Id And Checkout_Time__c = null];
            if(chList.size() > 0){
                Checkin_History__c updateCheckinHistory = chList[0];
                updateCheckinHistory.Checkin_Location__Latitude__s = chw.checkinHistory.Checkin_Location__Latitude__s;
                updateCheckinHistory.Checkin_Location__Longitude__s = chw.checkinHistory.Checkin_Location__Longitude__s;
                updateCheckinHistory.Checkin_Time__c = Datetime.now();
                update updateCheckinHistory;
                recordId = updateCheckinHistory.Id;
            } else {
                chw.checkinHistory.Field_Sales__c = currentFS.Id;
                chw.checkinHistory.Checkin_Time__c = Datetime.now();
                insert chw.checkinHistory;
                recordId = chw.checkinHistory.Id;
            }
        } catch (Exception ex){
            return new sf1Result(ex);
        }
        return new sf1Result(recordId);
    }
    
    @RemoteAction
    global static sf1Result submit4p(Store4pWrapper s4w) {
        ID recordID;
        
        try {
            User currentUser = [Select Id, Name, Field_Sales_Code__c From User Where Id =: UserInfo.getUserId()];
            Field_Sales__c currentFS = [Select Id, Name From Field_Sales__c Where Name =: currentUser.Field_Sales_Code__c];
            
            System.debug('Data Received: ' + s4w.store4P);
            Checkin_History__c currentCheckin = new Checkin_History__c();
            List<Checkin_History__c> chList = [Select Id From Checkin_History__c 
                                            Where Store__c =: s4w.store4P.Store__c
                                            And Field_Sales__c =: currentFS.Id
                                            And Checkin_Time__c != null
                                            And Checkout_Time__c = null];
        
            if(chList.size() > 0) {
                s4w.store4P.Checkin_History__c = chList[0].Id;
                insert s4w.store4P;
            }
             
             s4w.addImage();
            recordID = s4w.store4P.id;
            System.debug('Data Processed');
        } catch (Exception ex) {
            return new sf1Result(ex);
        }
        return new sf1Result(recordID); 
    }
    
    global class CheckinHistoryWrapper{
        global Checkin_History__c checkinHistory{get;set;}
    }
    
    global class Store4pWrapper {
        global Store_4P__c store4P{get;set;}
        global AttachStore4PPhoto.sf1Data image{get;set;}
        public void addImage() {
            image.ParentId = store4P.Id;
            sf1Result result = AttachStore4PPhoto.submitData(image);
            if(!result.isSuccess){
                // throw new sf1Exception(result.message);
            }
        }
    }
    
    public List<SelectOption> retrieveSegments(){
    	List<SelectOption> options = new List<SelectOption>();
    	List<Segment__c> segmentList = new List<Segment__c>();
    	if(this.selectedBrand != '' && this.selectedBrand != '--None--' && this.selectedBrand != null){
    		segmentList = [Select Id, Name From Segment__c Where Brand__c =: this.selectedBrand];
    	} else {
    		segmentList = [Select Id, Name From Segment__c];
    	}
    	options.add(new SelectOption('','--None--'));
    	for(Segment__c s : segmentList){
    		options.add(new SelectOption(s.Id, s.Name));
    	}
    	return options;
    }
    
    public List<SelectOption> retrieveBrands(){
    	List<SelectOption> options = new List<SelectOption>();
    	List<Brand__c> brandList = [Select Id, Name From Brand__c];
    	options.add(new SelectOption('','--None--'));
    	for(Brand__c b : brandList){
    		options.add(new SelectOption(b.Id, b.Name));
    	}
    	return options;
    }
    
    public class optionLists{
        public List<SelectOption> optionList{get;set;}
        public optionLists(){
            optionList = new List<SelectOption>();
        }
    }
    
    public List<optionLists> retrieveItemOptions(){
    	
    	List<optionLists> itemsOptions = new List<optionLists>();
        
        Integer itemNumber = [Select Count() From Item__c];
        Integer repeatTimes = (itemNumber / 999) + 1;
        Integer offsetNumber = 0;
        
        for(Integer repeatNumber = 0; repeatNumber < repeatTimes;repeatNumber++) {
            optionLists ol = new optionLists();
            List<Item__c> itemList = new List<Item__c>();
            if(this.selectedSegment != '' && this.selectedSegment != '--None--' && this.selectedSegment != null){
            	if(this.selectedBrand != '' && this.selectedBrand != '--None--' && this.selectedBrand != null){
            		itemList = [SELECT Id,Name FROM Item__c Where Brand__c =: this.selectedBrand And Segment__c =: this.selectedSegment limit 999 offset: offsetNumber];
            	} else {
            		itemList = [SELECT Id,Name FROM Item__c Where Segment__c =: this.selectedSegment limit 999 offset: offsetNumber];
            	}
            } else {
            	if(this.selectedBrand != '' && this.selectedBrand != '--None--' && this.selectedBrand != null){
            		itemList = [SELECT Id,Name FROM Item__c Where Brand__c =: this.selectedBrand limit 999 offset: offsetNumber];
            	} else {
            		itemList = [SELECT Id,Name FROM Item__c limit 999 offset: offsetNumber];
            	}
            }
            
            List<SelectOption> items = new List<SelectOption>();
            if(repeatNumber == 0){
                items.add(new SelectOption('','--None--'));
            }
            for(Item__c t : itemList) {
                if(t.Name.length() >21){
                    t.Name = t.Name.substring(0,20);
                }
                items.add(new SelectOption(t.ID, t.Name));
            }
            ol.optionList = items;
            offsetNumber += 999;
            itemsOptions.add(ol);
        }
        return itemsOptions;
    }
    
}