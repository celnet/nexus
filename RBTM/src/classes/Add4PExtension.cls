global with sharing class Add4PExtension {
    public String username{get;set;}
    public String displaynocheckin{get;set;}
    public String displaychecktype{get;set;}
    public String displaysku{get;set;}
    public String displaygeneral{get;set;}
    public String displayresult{get;set;}
    public String displaycheckoutinfo{get;set;}
    
    global Add4PExtension(ApexPages.StandardController controller) {
        User currentUser = [Select Id, Name, Field_Sales_Code__c From User Where Id =: UserInfo.getUserId()];
        username = currentUser.Name;
        Field_Sales__c currentFS = [Select Id, Name From Field_Sales__c Where Name =: currentUser.Field_Sales_Code__c];
        List<Checkin_History__c> chList = [Select Id From Checkin_History__c 
                                            Where Store__c =: controller.getId() 
                                            And Field_Sales__c =: currentFS.Id
                                            And Checkin_Time__c != null
                                            And Checkout_Time__c = null];
        
        this.brandOptions = this.retrieveBrands();
        this.segmentOptions = this.retrieveSegments();
        this.itemsOptions = this.retrieveItemOptions();
        
        
        if(chList.size() == 0){
            // 尚未Check in
            displaynocheckin = '';
            displaychecktype = 'display:none;';
            displaysku = 'display:none;';
            displaygeneral = 'display:none';
            displayresult = 'display:none';
            displaycheckoutinfo = 'display:none;';
        } else {
            displaynocheckin = 'display:none;';
            displaychecktype = '';
            displaysku = 'display:none;';
            displaygeneral = 'display:none;';
            displayresult = 'display:none;';
            displaycheckoutinfo = 'display:none;';
        }
    }
    
    
    public String selectedSegment{get;set;}
    public String selectedBrand{get;set;}
    
    public void filterItems(){
    	System.debug('>>>>>>>' + this.selectedBrand);
    	this.itemsOptions = this.retrieveItemOptions();
    	this.segmentOptions = this.retrieveSegments();
    }
    
    public void displaysku(){
    	displaynocheckin = 'display:none;';
        displaychecktype = 'display:none;';
        displaysku = '';
        displaygeneral = 'display:none;';
        displaycheckoutinfo = 'display:none;';
    }
    
    public void displaygeneral(){
    	displaynocheckin = 'display:none;';
        displaychecktype = 'display:none;';
        displaysku = 'display:none;';
        displaygeneral = '';
        displaycheckoutinfo = 'display:none;';
    }
    
    public void resultNavigate(){
    	displaynocheckin = 'display:none;';
    	displaychecktype = 'display:none;';
    	displaysku = 'display:none;';
    	displaygeneral = 'display:none;';
    	displayresult = '';
    	displaycheckoutinfo = 'display:none;';
    }
    
    public void resultNavigate2() {
    	displaynocheckin = 'display:none;';
    	displaychecktype = '';
    	displaysku = 'display:none;';
    	displaygeneral = 'display:none;';
    	displayresult = 'display:none;';
    	displaycheckoutinfo = 'display:none;';
    }
    
    public void navToCheckout(){
    	displaynocheckin = 'display:none;';
    	displaychecktype = 'display:none;';
    	displaysku = 'display:none;';
    	displaygeneral = 'display:none;';
    	displayresult = 'display:none;';
    	displaycheckoutinfo = '';
    }
    
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
	/*
    public List<SelectOption> Segments {
        get {
            List<SelectOption> options = new List<SelectOption>();
             // Describe the SObject using its object type.
            Schema.DescribeSObjectResult store4PDescribe = Store_4P__c.getSobjectType().getDescribe();       
              // Get a map of fields for the SObject
            map<String, Schema.SObjectField> fieldMap = store4PDescribe.fields.getMap(); 
              // Get the list of picklist values for this field.
            list<Schema.PicklistEntry> values = fieldMap.get('Segment__c').getDescribe().getPickListValues();
              // Add these values to the selectoption list.
            options.add(new SelectOption('','--None--'));
            for (Schema.PicklistEntry a : values){ 
                options.add(new SelectOption(a.getLabel(), a.getValue())); 
            }

            return options;
        }
        private set;
    }
  	*/  
    public List<SelectOption> segmentOptions{get{
    		return this.retrieveSegments();
	    }
		private set;
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
    
    public List<SelectOption> brandOptions{get;set;}
    
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
    
    public List<optionLists> itemsOptions{get;set;}
    
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
    /*
    public List<optionLists> retrieveItemOptions(){
        List<optionLists> itemsOptions = new List<optionLists>();
        
        Integer itemNumber = [Select Count() From Item__c];
        Integer repeatTimes = (itemNumber / 999) + 1;
        Integer offsetNumber = 0;
        
        for(Integer repeatNumber = 0; repeatNumber < repeatTimes;repeatNumber++) {
            optionLists ol = new optionLists();
            List<Item__c> itemList = [SELECT Id,Name FROM Item__c limit 999 offset: offsetNumber];
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
    */
    @RemoteAction
    global static sf1Result submitData(sf1Data data) {
        ID recordID;
        
        try {
            User currentUser = [Select Id, Name, Field_Sales_Code__c From User Where Id =: UserInfo.getUserId()];
            Field_Sales__c currentFS = [Select Id, Name From Field_Sales__c Where Name =: currentUser.Field_Sales_Code__c];
            
            System.debug('Data Received: ' + data.store4P);
            Checkin_History__c currentCheckin = new Checkin_History__c();
            List<Checkin_History__c> chList = [Select Id From Checkin_History__c 
                                            Where Store__c =: data.store4P.Store__c
                                            And Field_Sales__c =: currentFS.Id
                                            And Checkin_Time__c != null
                                            And Checkout_Time__c = null];
        
            if(chList.size() > 0) {
                data.store4P.Checkin_History__c = chList[0].Id;
                insert data.store4P;
            }
             
             data.addImage();
            recordID = data.store4P.id;
            System.debug('Data Processed');
        } catch (Exception ex) {
            return new sf1Result(ex);
        }
        return new sf1Result(recordID); 
    }
    
    global class sf1Data {
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
    
    @RemoteAction
    global static sf1Result newSubmitData(CheckinHistoryWrapper chw){
        Id recordId;
        
        try{
            User currentUser = [Select id,Name, Field_Sales_Code__c From User Where Id =: UserInfo.getUserId()];
            Field_Sales__c currentFS = [Select Id From Field_Sales__c Where Name =: currentUser.Field_Sales_Code__c];
            List<Checkin_History__c> chList = [Select Id From Checkin_History__c 
                                                Where Store__c =: chw.checkinHistory.Store__c
                                                And Field_Sales__c =: currentFS.Id
                                                And Checkin_Time__c != null
                                                And Checkout_Time__c = null];
            if(chList.size() > 0){
                Checkin_History__c updateCheckinHistory = chList[0];
                updateCheckinHistory.Checkout_Location__Latitude__s = chw.checkinHistory.Checkout_Location__Latitude__s;
                updateCheckinHistory.Checkout_Location__Longitude__s = chw.checkinHistory.Checkout_Location__Longitude__s;
                updateCheckinHistory.Checkout_Time__c = Datetime.now();
                update updateCheckinHistory;
                recordId = chw.checkinHistory.Id;
            }
            
        } catch (Exception ex){
            return new sf1Result(ex);
        }
        return new sf1Result(recordId);
    }
    
    global class CheckinHistoryWrapper{
        global Checkin_History__c checkinHistory{get;set;}
    }
}