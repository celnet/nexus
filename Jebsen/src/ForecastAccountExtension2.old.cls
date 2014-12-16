/**
 * Account下Forecast部分
 */
public class ForecastAccountExtension2
{
    public String selectedYear{get;set;}
    
    public list<SelectOption> years{
        get{
            list<SelectOption> options = new list<SelectOption>();
            Schema.DescribeFieldResult year = Forecast_Account__c.Year__c.getDescribe();
            for(Schema.Picklistentry p : year.getPicklistValues())
            {
                if(p.isActive())
                {
                    options.add(new SelectOption(p.getLabel(),p.getValue()));
                }
            }
            
            return options;
        }
        private set;
    }
    
    public class ForecastWrapper{
        public boolean IsEdit{get;set;}
        public Integer Index{get;set;}
        public Forecast_Account__c forecast{get;set;}
    }
    
    public list<ForecastWrapper> fwList{get;set;}
    public Forecast_Account__c totalForecast{get;set;}
    
    // 添加行
    public void addLine(){
        ForecastWrapper fw = new ForecastWrapper();
        fw.IsEdit = true;
        fw.Index = fwList.size();
        Forecast_Account__c f = new Forecast_Account__c();
        f.Account__c = AccId;
        f.Year__c = selectedYear;
        f.Business_Type__c = 'Existing customer, existing business';
        f.Sales_Type__c = 'Stock Sales';
        fw.forecast = f;
        fwList.add(fw);
    }
    
    public void refreshRecords(){
        fwList = new list<ForecastWrapper>();
        list<Forecast_Account__c> forecastList = [Select Account__c, Q1__c, Q2__c, Q3__c, Q4__c, GP__c, Product_Article__c, Business_Type__c, Sales_Type__c 
                                            From Forecast_Account__c Where Account__c =: AccId And Year__c =: selectedYear];
        if(forecastList.size()<=0)
        {
            String lastyear=String.valueOf(Integer.valueOf(selectedYear)-1);
            forecastList = [Select Account__c, Q1__c, Q2__c, Q3__c, Q4__c, GP__c, Product_Article__c, Business_Type__c, Sales_Type__c  
                                            From Forecast_Account__c Where Account__c =: AccId And Year__c =: lastyear];
            for(Forecast_Account__c f : forecastList){
            Forecast_Account__c f1=new Forecast_Account__c();
            f1.Q1__c=f.Q1__c;
            f1.Q2__c=f.Q2__c;
            f1.Q3__c=f.Q3__c;
            f1.Q4__c=f.Q4__c;
            f1.GP__c=f.GP__c;
            f1.Business_Type__c = f.Business_Type__c;
            f1.Sales_Type__c = f.Sales_Type__c;
            f1.Year__c=selectedYear;
            f1.Account__c=f.Account__c;
            f1.Product_Article__c=f.Product_Article__c;
            ForecastWrapper fw = new ForecastWrapper();
            fw.forecast = f1;
            fw.IsEdit = true;
            fw.Index = fwList.size();
            fwList.add(fw);
            }
        }else
        {
        for(Forecast_Account__c f : forecastList){
            ForecastWrapper fw = new ForecastWrapper();
            fw.forecast = f;
            fw.IsEdit = false;
            fw.Index = fwList.size();
            fwList.add(fw);
            }
        }
        calculateTotal();
    }
    
    public void saveRecords(){
        list<Forecast_Account__c> insertForecasts = new list<Forecast_Account__c>();
        list<Forecast_Account__c> updateForecasts = new list<Forecast_Account__c>();
        if(fwList != null && fwList.size() > 0){
            for(ForecastWrapper fw : fwList){
                fw.IsEdit = false;
                if(fw.forecast.Id != null){
                    updateForecasts.add(fw.forecast);
                } else {
                    insertForecasts.add(fw.forecast);
                }
            }
        }
        try{
            if(insertForecasts.size() > 0){
                insert insertForecasts;
            }
            
            if(updateForecasts.size() > 0){
               update updateForecasts;
            }
            
            refreshRecords();
        } catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    }
    
    public void editRecord(){
        if(Index>=0)
        {
            for(Integer i = 0 ; i<  fwList.size() ; i++)
            {
                if(fwList[i].Index == Index)
                {
                    if(fwList[i].forecast.id != null)
                    {
                        fwList[i].IsEdit = true;
                    }
                    return;
                }
            }
        }
    }
    
    public void deleteRecord(){
        if(Index>=0)
        {
            for(Integer i = 0 ; i<  fwList.size() ; i++)
            {
                if(fwList[i].Index == Index)
                {
                    if(fwList[i].forecast.id != null)
                    {
                        delete fwList[i].forecast;
                    }
                    fwList.remove(i);
                   calculateTotal();
                    return;
                }
            }
        }
        
        calculateTotal();
    }
    
    public void calculateTotal(){
        totalForecast = new Forecast_Account__c();
       
        totalForecast.Q1__c = 0;
        totalForecast.Q2__c = 0;
        totalForecast.Q3__c = 0;
        totalForecast.Q4__c = 0;
        for(ForecastWrapper fw : fwList){
            totalForecast.Q1__c += fw.forecast.Q1__c;
            totalForecast.Q2__c += fw.forecast.Q2__c;
            totalForecast.Q3__c += fw.forecast.Q3__c;
            totalForecast.Q4__c += fw.forecast.Q4__c;
        }
    }
    
    public ID AccId{get;set;}
    public Integer Index{get;set;}//删除记录的下标
    public Boolean IsAccess{get;set;}//控制Approve和Retake按钮的可见性
    public PubMethod pub{get;set;}
    public string IsShare{get;set;}
    public Boolean IsEdit{get;set;}
    
    public ForecastAccountExtension2(ApexPages.StandardController controller)
    {
        IsEdit = PubMethod.IsEdit(UserInfo.getUserRoleId());
        AccId = controller.getId();
        pub = new PubMethod();
        Account acc = [select Owner.UserRoleId from Account where id =: AccId];
        set<ID> HighRole = pub.getHighRoleName(acc.Owner.UserRoleId);
        if(HighRole.contains(UserInfo.getUserRoleId()))
        {
            IsAccess = true;
        }
        else
        {
            IsAccess = false;
        }
        
        selectedYear = String.valueOf(Date.today().Year());
        
        fwList = new list<ForecastWrapper>();
        list<Forecast_Account__c> forecastList = [Select Account__c, Q1__c, Q2__c, Q3__c, Q4__c, GP__c, Product_Article__c , Business_Type__c, Sales_Type__c 
                                            From Forecast_Account__c Where Account__c =: AccId And Year__c =: selectedYear];
        
        for(Forecast_Account__c f : forecastList){
            ForecastWrapper fw = new ForecastWrapper();
            fw.forecast = f;
            fw.IsEdit = false;
            fw.Index = fwList.size();
            fwList.add(fw);
        }
        
        calculateTotal();
    }
}
