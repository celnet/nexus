global with sharing class CheckinExtension {
    public String username{get;set;}
    public String displayInfo{get;set;}
    public String displayResult{get;set;}
    
    global CheckinExtension(ApexPages.StandardController controller) {
        User currentUser = [Select id,Name,Field_Sales_Code__c From User Where Id =: UserInfo.getUserId()];
        username = currentUser.Name;
        displayInfo = '';
        displayResult = 'display:none;';
    }
    
    public void resultNavigate(){
    	displayInfo = 'display:none;';
    	displayResult = '';
    }
    
    @RemoteAction
    global static sf1Result newSubmitData(CheckinHistoryWrapper chw){
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
    
    global class CheckinHistoryWrapper{
        global Checkin_History__c checkinHistory{get;set;}
    }
    
}