/*Author:Leo
 *Date:2014-4-11
 *function:test Billing_AutoMatch_LookUp.trigger、RowData_AutoMatch_LookUp.trigger
 				Target_AutoMatch_LookUp.trigger、Traffic_AutoMatch_LookUp.trigger
 */
@isTest
private class Test_AutoMatch_LookUp {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Date__c dt = new Date__c();
        dt.Date__c = Date.newInstance(2014, 4, 11);
        insert dt;
        
        Store__c s = new Store__c();
        s.Name = 'store1';
        s.Store_Code__c = '1001';
        insert s;
        
        Billing__c b = new Billing__c();
        b.Name = 'b1';
        b.Name__c = 'b11111';
        b.DateImport__c = dt.Date__c;
        b.Store_Code__c = s.Store_Code__c;
        insert b;
        
        Date__c ddt = [select id,Date__c from Date__c where Date__c = :dt.Date__c];
        Store__c ss = [select id,Name from Store__c where Name = :s.Name];
        
        
        
        Target__c t = new Target__c();
        t.Name = 'target1';
        t.Store_Code__c = s.Store_Code__c;
        t.Date_Import__c = dt.Date__c;
        insert t;
        Traffic__c tr = new Traffic__c();
        tr.Name = 'traffic1';
        tr.Date_Import__c = dt.Date__c;
        tr.Store_Code__c = s.Store_Code__c;
        insert tr;
		Raw_Data__c rd = new Raw_Data__c();
		rd.Name = 'r11';
		rd.Billing_Doc__c = b.Name__c;
		rd.Store_Code__c = s.Store_Code__c;
		insert rd;        
    }
}