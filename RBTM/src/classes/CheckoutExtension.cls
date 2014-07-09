global with sharing class CheckoutExtension {
    public String username{get;set;}
    public String displayexception{get;set;}
    public String displaycheckout{get;set;}
    
    global CheckoutExtension(ApexPages.StandardController controller) {
        // 查询出当前User对应的FieldSales
        User currentUser = [Select id,Name, Field_Sales_Code__c From User Where Id =: UserInfo.getUserId()];
        username = currentUser.Name;
        Field_Sales__c currentFS = [Select Id From Field_Sales__c Where Name =: currentUser.Field_Sales_Code__c];
        List<Checkin_History__c> chList = [Select Id From Checkin_History__c 
                                            Where Store__c =: controller.getId() 
                                            And Field_Sales__c =: currentFS.Id
                                            And Checkin_Time__c != null
                                            And Checkout_Time__c = null];
        if(chList.size() == 0){
            // 不存在CheckinHistory
            displayexception = '';
            displaycheckout = 'display:none;';
        } else {
            displayexception = 'display:none;';
            displaycheckout = '';
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