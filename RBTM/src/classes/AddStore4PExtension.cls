global with sharing class AddStore4PExtension {
    public Id storeId{get;set;}
    global AddStore4PExtension(ApexPages.StandardController controller) {
        displayEdit = 'display:none';
        storeId = controller.getId();
    }
    public Store_4P__c s4P {get;set;}
    
    public String selectedType{get;set;}
    public String displayEdit{get;set;}
    public void displayStore4P(){
        //displayEdit = '';
    }
    
    public void test(){
        displayEdit = '';
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
    
    public class optionLists{
        public List<SelectOption> optionList{get;set;}
        public optionLists(){
            optionList = new List<SelectOption>();
        }
    }
    
    public List<optionLists> itemsOptions{
        get {
            if(itemsOptions == null) {
                itemsOptions = new List<optionLists>();
                
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
            }
            return itemsOptions;
        }
        private set;
    }
    
    @RemoteAction
    global static sf1Result checkOut(sf1Data data) {
        ID recordID;
        List<Store_4P__c> store4PList = new List<Store_4P__c>();
        store4PList = [Select Id, Checkout_Time__c, Checkout_Location__c From Store_4P__c Where Store__c =: data.store4P.Store__c And Date__c =: Date.today()];
        if(store4PList.size()>0){
            for(Store_4P__c s4 : store4PList){
                s4.Checkout_Time__c = Datetime.now();
                s4.Checkout_Location__Longitude__s = data.store4P.Location__Longitude__s;
                s4.Checkout_Location__Latitude__s = data.store4P.Location__Latitude__s;
            }
        }
        update store4PList;
        return new sf1Result(data.store4P.Store__c);
    }
    
    @RemoteAction
    global static sf1Result submitData(sf1Data data) {
        ID recordID;
        
        try {
            System.debug('Data Received: ' + data.store4P);
            data.store4P.Date__c = Date.today();
            data.store4P.Checkin_Time__c = Datetime.now();
             insert data.store4P;
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
        global double lat{get;set;}
        global double lon{get;set;}
        public void addImage() {
            image.ParentId = store4P.Id;
            sf1Result result = AttachStore4PPhoto.submitData(image);
            if(!result.isSuccess){
                // throw new sf1Exception(result.message);
            }
        }
    }
}