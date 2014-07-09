/*
 * Author: Steven
 * Date: 2014-5-8
 * Description: 更新Store4P记录的地理位置信息，放在Salesforce1的Publisher Action
 */
global with sharing class UpdateGeolocationController {
    public UpdateGeolocationController(ApexPages.StandardController controller) { }

    @RemoteAction
    global static sf1Result submitData(sf1Data data) {
        ID recordID;
        
        try {
            System.debug('Data Received: ' + data.store4P);
            
             update data.store4P;
            recordID = data.store4P.id;
            System.debug('Data Processed');
        } catch (Exception ex) {
            return new sf1Result(ex);
        }
        return new sf1Result(recordID); 
    }
    
    global class sf1Data {
        global Store_4P__c store4P{get;set;}
    }
}