/*
 * 作者：Ziyue
 * 时间：2013-10-18
 * 描述：业务机会报表打印
*/
public class Opportunity_ReportController 
{
    //****************************************
    public static final integer SALES_TEAM_SIZE = 5;
    public static final integer COMPETITOR_LIST_SIZE = 3;
    public static final integer ACITVITIES_LIST_SIZE = 7;
    public static final integer CONTACT_ROLE_SIZE = 6;
    public static final integer IMPLEMENTATION_PLAN_SIZE= 9;
    public static final integer SALES_PROCESS_HISTORY_SIZE =10;
    public class Activities
    {
        public string Subject{get;set;}
        public string DueDate{get;set;}
        public string Assigned{get;set;}//被分配人
        public string Status{get;set;}
    }
    public Opportunity opp{get;set;}
    public ID oppId{get;set;}
    public string link{get;set;}
    public Decimal Order_amount_of_Last_year{get;set;}
    public list<OpportunityTeamMember> members{get;set;}
    public list<OpportunityCompetitor> competitors{get;set;}
    public list<Activities> list_Activities{get;set;}
    public Opportunity_ReportController()
    {
        list_Activities = new list<Activities>();
        oppId = ApexPages.currentPage().getParameters().get('oppId');//'006N0000002Xv4w';
        link = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/'+oppId;
        opp = [Select Decision_Result__c,Decision_Lost_Type__c,Decision_Competitor__c,SAP_Number__c,Opportunity_Number__c,
        Summary_and_Experience__c,Account.Order_Amount_of_History__c,Owner.Name,CreatedDate, CreatedById,CreatedBy.Name, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, 
              Account.Name,Value_Created_by_Solution_in_Year_1__c, Type, Total_Implementation_Cost__c, 
              Total_Impact_in_USD_EUR_RMB__c, Time__c, Tactical__c, Submiter_Manager__c, 
              Strategic__c, StageName, Solution_Implementation_Costs__c, Samples_demand_plan_has_been_uploaded__c, 
              Samples_Purchase_Order_has_been_uploaded__c, RFQ_has_been_uploaded__c, Is_Escalated__c, 
              Quotation_to_customer_has_been_uploaded__c, Quotation_to_Jebsen_has_been_uploaded__c, 
              Questionnaire_has_been_uploaded__c, Purchase_scope__c, Proposed_Price_of_Solution__c, 
              Product_Volume__c, Probability, Political__c, PO_to_Profil_has_been_uploaded__c, 
              OwnerId, Overall_solution_has_been_uploaded__c, Other_reason_for_winning_or_losing__c, NextStep, Name, 
              Main_reason_for_winning_or_losing__c, Recently_Escalation_Type__c, Recently_Escalation_Remark__c, 
              IsAllowAcrossStage__c, Investment__c, Individual__c, Impact_in_Year_1__c, Id, HasOpportunityLineItem, 
              Escalation_Times__c, Effort__c, Decision_Requred__c, Customer_Requirements_Description__c, 
              CloseDate, Capabilities__c, Automated_solution_has_been_uploaded__c, Amount, Frame_contract_has_been_uploaded__c,
              Actual_Volume__c, Actual_Close_Date__c, Actual_Amount__c, Achievement_Requred__c, AccountId, AOR_Requred__c, 
              AON_Requred__c, AOA_Requred__c, 
              (Select Id, OwnerId, Name, Value_Options__c, Importance_to_Customer__c, Competitive_Standing__c, Action_Plan__c,
              Opportunity__c, Value_Criteria__c From Value_Map_Strategies__r), 
              (Select Id, Name,Risk_Type__c, What_risks_or_uncertainties_are_there__c, Prevention_Plan_A__c, Cure_Plan_B__c, 
              Opportunity__c From Risk_Tracker__r), 
              (Select Id, Name,Type__c, Action__c, Opportunity__c, Resposible_Person__c, 
              Feedback__c, Due_Date__c From Imlpementation_Plan__r) From Opportunity where id =: oppId];
        Order_amount_of_Last_year = 0;
        for(Order_Amount_Per_Year__c perYear : [select  Amount__c from Order_Amount_Per_Year__c where Account__c =: opp.AccountId and Amount__c != null])
        {
            Order_amount_of_Last_year += perYear.Amount__c;
        }
        members = [Select OpportunityId ,User.MobilePhone, User.Phone, User.Title, 
                  User.Department, User.Name, UserId, TeamMemberRole From OpportunityTeamMember where OpportunityId=:oppId Order By CreatedDate Desc limit: SALES_TEAM_SIZE];
        if(members == null)
        {
            members = new list<OpportunityTeamMember>();
        }
        if(members.size()<SALES_TEAM_SIZE)
        {
            integer lenght = SALES_TEAM_SIZE-members.size();
            for(integer i=0;i < lenght;i++)
            {
                members.add(new OpportunityTeamMember());
            }
        }
        competitors=[Select Weaknesses, Strengths, CompetitorName From OpportunityCompetitor where OpportunityId=:oppId Order By CreatedDate limit:COMPETITOR_LIST_SIZE];
        if(competitors == null)
        {
            competitors = new list<OpportunityCompetitor>();
        }
        if(competitors.size()<COMPETITOR_LIST_SIZE)
        {
            integer lenght = COMPETITOR_LIST_SIZE-competitors.size();
            for(integer i=0;i < lenght;i++)
            {
                competitors.add(new OpportunityCompetitor());
            }
        }
        /***************************************Tobe Start********************************************/
        list_ContactRole = [Select c.Tendency_Description__c, c.SystemModstamp, c.Role_Type__c, c.Role_TypeURL__c, c.Remark__c, c.Opportunity__c, c.Name, c.Most_Focus_on__c, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Focus_Description__c, c.Customer_Tendency__c, c.CreatedDate, c.CreatedById, c.Contact_title__c, c.Contact__r.Name 
                            From Contact_Role__c c 
                            Where c.Opportunity__c =: oppId
                            Order By CreatedDate 
                            limit: CONTACT_ROLE_SIZE];
        if(list_ContactRole.size()<CONTACT_ROLE_SIZE)
        {
            integer lenght = CONTACT_ROLE_SIZE-list_ContactRole.size();
            for(integer i=0;i < lenght;i++)
            {
                list_ContactRole.add(new Contact_Role__c());
            }
        }
        list_valueStrategies = [Select v.Value_Options__c, v.Value_Criteria__c, v.SystemModstamp, v.OwnerId, v.Opportunity__c, v.Name, v.LastModifiedDate, v.LastModifiedById, v.LastActivityDate, v.IsDeleted, v.Importance_to_Customer__c, v.Id, v.CreatedDate, v.CreatedById, v.Competitive_Standing__c, v.Action_Plan__c 
                                From Value_Map_Strategies__c v 
                                Where v.Opportunity__c =: oppId
                                Order By v.Value_Options__c];
        map<string,list<Risk_Tracker__c>> map_RT = new map<string,list<Risk_Tracker__c>>();
        for(Risk_Tracker__c rt : [Select r.What_risks_or_uncertainties_are_there__c, r.Risk_Type__c, r.Prevention_Plan_A__c, r.OwnerId, r.Opportunity__c, r.Name, r.Id, r.Cure_Plan_B__c 
                                  From Risk_Tracker__c r
                                  Where r.Opportunity__c =:oppId])
        {
            if(map_RT.containsKey(rt.Risk_Type__c))
            {
                list<Risk_Tracker__c> list_RT = map_RT.get(rt.Risk_Type__c);
                list_RT.add(rt);
                map_RT.put(rt.Risk_Type__c,list_RT);
            }
            else
            {
                list<Risk_Tracker__c> list_RT = new list<Risk_Tracker__c>();
                list_RT.add(rt);
                map_RT.put(rt.Risk_Type__c,list_RT);
            }
        }
        list_RiskTracker = new list<RiskTracker>();
        list<Risk_Tracker__c> list_rt1 = new list<Risk_Tracker__c>();
        list<Risk_Tracker__c> list_rt2 = new list<Risk_Tracker__c>();
        Risk_Tracker__c risk = new Risk_Tracker__c();
        risk.What_risks_or_uncertainties_are_there__c = 'Strategic';
        list_rt1.add(risk);
        risk = new Risk_Tracker__c();
        risk.What_risks_or_uncertainties_are_there__c = 'Tactical';
        list_rt1.add(risk);
        risk = new Risk_Tracker__c();
        risk.What_risks_or_uncertainties_are_there__c = 'Political';
        list_rt2.add(risk);
        risk = new Risk_Tracker__c();
        risk.What_risks_or_uncertainties_are_there__c = 'Individual';
        list_rt2.add(risk);
        list_RiskTracker.add(new RiskTracker('Company',list_rt1));
        list_RiskTracker.add(new RiskTracker('Individual',list_rt2));
        for(RiskTracker rt : list_RiskTracker)
        {
            if(map_RT.containsKey(rt.riskType))
            {
                rt.setRickTracker(map_RT.get(rt.riskType));
            }
        }
        list_Imlpementation_Plan = [Select i.Type__c, i.SystemModstamp, i.Resposible_Person__r.Name, i.Opportunity__c, i.Name,i.Id, i.Feedback__c, i.Due_Date__c, i.Action__c 
                                    From Imlpementation_Plan__c i
                                    Where i.Opportunity__c =: oppId 
                                    Order By i.CreatedDate
                                    limit:IMPLEMENTATION_PLAN_SIZE];
        if(list_Imlpementation_Plan.size()<IMPLEMENTATION_PLAN_SIZE)
        {
            integer lenght = IMPLEMENTATION_PLAN_SIZE-list_Imlpementation_Plan.size();
            for(integer i=0;i < lenght;i++)
            {
                list_Imlpementation_Plan.add(new Imlpementation_Plan__c());
            }
        }
        list_OpportunityHistory = [Select o.StageName, o.Probability, o.ForecastCategory, o.ExpectedRevenue, o.CreatedDate, o.Amount 
                                   From OpportunityHistory o 
                                   Where o.OpportunityId =: oppId
                                   Order By o.CreatedDate];
        /***************************************Tobe Start********************************************/
        /************************************Chart Start*******************************************/
        list_Value_Strategies = new list<list_Value_Strategies>();
        list_Strategies = new list<Value_Map_Strategies__c>();
        map_Strategies = new map<string,map<string,list<Value_Map_Strategies__c>>>();
        list_Strategies = [select id,Action_Plan__c,Competitive_Standing__c,    
                          Importance_to_Customer__c,Opportunity__c,Value_Criteria__c,
                          Value_Options__c from Value_Map_Strategies__c 
                          where Opportunity__c =: oppId and Importance_to_Customer__c != null 
                          and Competitive_Standing__c != null order by Value_Options__c];
        
        if(list_Strategies != null && list_Strategies.size() > 0)   
        {
            for(Value_Map_Strategies__c strage : list_Strategies)
            {
                map<string,list<Value_Map_Strategies__c>> mapStrategies;
                if(map_Strategies.containsKey(strage.Importance_to_Customer__c))
                {
                    mapStrategies = map_Strategies.get(strage.Importance_to_Customer__c);
                }
                else
                {
                    mapStrategies = new map<string,list<Value_Map_Strategies__c>>();
                    map_Strategies.put(strage.Importance_to_Customer__c,mapStrategies);
                }
                list<Value_Map_Strategies__c> list_strage;
                if(mapStrategies.containsKey(strage.Competitive_Standing__c))
                {
                    list_strage = mapStrategies.get(strage.Competitive_Standing__c);
                }
                else
                {
                    list_strage = new list<Value_Map_Strategies__c>();
                    mapStrategies.put(strage.Competitive_Standing__c,list_strage);
                }
                list_strage.add(strage);
            }
        }
        else
        {
            list_Strategies = new list<Value_Map_Strategies__c>();
        }
        list<string> list_Y = new list<string>();
        list_Y.add('H');
        list_Y.add('M');
        list_Y.add('L');
        list<string> list_X = new list<string>();
        list_X.add('L');
        list_X.add('M');
        list_X.add('H');
        for(string y : list_Y)
        {
            list_Value_Strategies lvs = new list_Value_Strategies();
            list<Value_Strategies> list_strate = new list<Value_Strategies>();
            lvs.list_Strategies = list_strate;
            lvs.Y_Value = y;
            list_Value_Strategies.add(lvs);
            for(string x : list_X)
            {
                Value_Strategies val_strate = new Value_Strategies();
                val_strate.list_Winner = new list<Value_Map_Strategies__c>();
                val_strate.list_Killer = new list<Value_Map_Strategies__c>();
                val_strate.list_Sleeper = new list<Value_Map_Strategies__c>();
                val_strate.list_Others = new list<Value_Map_Strategies__c>();
                list_strate.add(val_strate);
                if(map_Strategies.containsKey(y)&&map_Strategies.get(y).containsKey(x))
                {
                    for(Value_Map_Strategies__c strage : map_Strategies.get(y).get(x))
                    {
                        if(strage.Value_Options__c == 'Value Winner')
                        {
                            val_strate.list_Winner.add(strage);
                        }
                        else if(strage.Value_Options__c == 'Value Killer')
                        {
                            val_strate.list_Killer.add(strage);
                        }
                        else if(strage.Value_Options__c == 'Value Sleeper')
                        {
                            val_strate.list_Sleeper.add(strage);
                        }
                        else if(strage.Value_Options__c == 'Value Other')
                        {
                            val_strate.list_Others.add(strage);
                        }
                    }
                }
            }
        }
        /************************************Chart End*********************************************/
        list<Event> list_Event = [Select WhoId,Owner.Name, WhatId, Subject, StartDateTime, EndDateTime, ActivityDate,CreatedDate From Event where WhatId=:oppId Order By ActivityDate Desc limit: ACITVITIES_LIST_SIZE];
        list<Task> list_Task = [Select WhoId,Owner.Name, WhatId, Subject, Status, ActivityDate,CreatedDate From Task where WhatId=:oppId Order By ActivityDate Desc limit: ACITVITIES_LIST_SIZE];
        /*if(list_Event != null && list_Event.size() > 0)
        {
            for(Event e:list_Event)
            {
                Activities act = new Activities();
                act.Subject = e.Subject;
                act.DueDate = e.EndDateTime.year()+'.'+e.EndDateTime.month()+'.'+e.EndDateTime.day();
                act.Assigned = e.Who.Name;
                list_Activities.add(act);
            }
        }
        if(list_Task != null && list_Task.size() > 0)
        {
            for(Task t:list_Task)
            {
                Activities act = new Activities();
                act.Subject = t.Subject;
                act.DueDate = t.ActivityDate.year()+'.'+t.ActivityDate.month()+'.'+t.ActivityDate.day();
                act.Assigned = t.Who.Name;
                act.Status = t.Status;
                list_Activities.add(act);
            }
        }*/
        for(integer i=0;i < ACITVITIES_LIST_SIZE;i++)
        {
            if(list_Event.size()==0 && list_Task.size()==0)
            {
                Activities act = new Activities();
                list_Activities.add(act);
            }
            else if(list_Event.size()==0)
            {
                Activities act = new Activities();
                act.Subject = list_Task[0].Subject;
                if(list_Task[0].ActivityDate!=null)
                {
                    act.DueDate = list_Task[0].ActivityDate.year()+'.'+list_Task[0].ActivityDate.month()+'.'+list_Task[0].ActivityDate.day();
                }
                act.Assigned = list_Task[0].Owner.Name;
                act.Status = list_Task[0].Status;
                list_Activities.add(act);
                list_Task.remove(0);
            }   
            else if(list_Task.size()==0)
            {
                Activities act = new Activities();
                act.Subject = list_Event[0].Subject;
                if(list_Event[0].EndDateTime!=null)
                {
                    act.DueDate = list_Event[0].EndDateTime.year()+'.'+list_Event[0].EndDateTime.month()+'.'+list_Event[0].EndDateTime.day();
                }
                act.Assigned = list_Event[0].Owner.Name;
                list_Activities.add(act);
                list_Event.remove(0);
            }   
            else if(list_Event[0].ActivityDate>list_Task[0].ActivityDate)
            {
                Activities act = new Activities();
                act.Subject = list_Event[0].Subject;
                if(list_Event[0].EndDateTime!=null)
                {
                    act.DueDate =  list_Event[0].EndDateTime.year()+'.'+list_Event[0].EndDateTime.month()+'.'+list_Event[0].EndDateTime.day();
                }
                act.Assigned = list_Event[0].Owner.Name;
                list_Activities.add(act);
                list_Event.remove(0);
            }
            else
            {
                Activities act = new Activities();
                act.Subject = list_Task[0].Subject;
                if(list_Task[0].ActivityDate!=null)
                {
                    act.DueDate = list_Task[0].ActivityDate.year()+'.'+list_Task[0].ActivityDate.month()+'.'+list_Task[0].ActivityDate.day();
                }
                act.Assigned = list_Task[0].Owner.Name;
                act.Status = list_Task[0].Status;
                list_Activities.add(act);
                list_Task.remove(0);
            }
        }
        //Select WhoId, WhatId, Subject, StartDateTime, EndDateTime, ActivityDate From Event 
        //Select WhoId, WhatId, Subject, Status, ActivityDate From Task t
        
    }
    /************************************Chart start*******************************************/
    public class Value_Strategies
    {
        public list<Value_Map_Strategies__c> list_Winner{get;set;}
        public list<Value_Map_Strategies__c> list_Killer{get;set;}
        public list<Value_Map_Strategies__c> list_Sleeper{get;set;}
        public list<Value_Map_Strategies__c> list_Others{get;set;}
    }
    public class list_Value_Strategies
    {
        public list<Value_Strategies> list_Strategies{get;set;}
        public string Y_Value{get;set;}
    }
    //Importance to Customer值：Competitive Standing值：Value_Map_Strategies__c记录
    public map<string,map<string,list<Value_Map_Strategies__c>>> map_Strategies{get;set;}
    public list<list_Value_Strategies> list_Value_Strategies{get;set;}//在页面中展示的list
    public list<Value_Map_Strategies__c> list_Strategies{get;set;}
    /************************************Chart end*********************************************/
    /**********************************Tobe Start**********************************************/
    public list<Contact_Role__c> list_ContactRole{get;set;}
    public list<Value_Map_Strategies__c> list_valueStrategies{get;set;}//value Strategies
    public list<Imlpementation_Plan__c> list_Imlpementation_Plan{get;set;}
    public list<OpportunityHistory> list_OpportunityHistory{set;get;}
    public list<RiskTracker> list_RiskTracker{get;set;}
    public list<OpportunityHistories> list_OpportunityHistories
    {
        get
        {
            list_OpportunityHistories = new list<OpportunityHistories>();
            for(OpportunityHistory oppHistory: list_OpportunityHistory)
            {
                OpportunityHistories history = new OpportunityHistories();
                history.Stage = oppHistory.StageName;
                history.Amount = oppHistory.Amount==null ? null:oppHistory.Amount.format();
                history.Probability = oppHistory.Probability+'%';
                history.ModifyOn = oppHistory.CreatedDate.format('yyyy-MM-dd');
                list_OpportunityHistories.add(history);
            }
            if(list_OpportunityHistories.size()<SALES_PROCESS_HISTORY_SIZE)
            {
                integer lenght = SALES_PROCESS_HISTORY_SIZE-list_OpportunityHistories.size();
                for(integer i=0;i < lenght;i++)
                {
                    list_OpportunityHistories.add(new OpportunityHistories());
                }
            }
            return list_OpportunityHistories;
        }
        set;
    }
    public class OpportunityHistories
    {
        public string Stage{get;set;}
        public string Amount{get;set;}
        public string Probability{get;set;}
        public string ModifyOn{get;set;}
    }
    public class RiskTracker //Risk Tracker 封装类
    {
        public string riskType{get;set;}
        public Risk_Tracker__c Rick_Tracker_1{get;set;}
        public Risk_Tracker__c Rick_Tracker_2{get;set;}
        public RiskTracker(string riskType, list<Risk_Tracker__c> listRickTracker)
        {
            Rick_Tracker_1 = new Risk_Tracker__c();
            Rick_Tracker_2 = new Risk_Tracker__c();
            this.riskType = riskType;
            if(listRickTracker.size()>0)
            {
                Rick_Tracker_1 = listRickTracker[0];
            }
            if(listRickTracker.size()>1)
            {
                Rick_Tracker_2 = listRickTracker[1];
            }
        }
        public void setRickTracker(list<Risk_Tracker__c> listRickTracker)
        {
            if(listRickTracker.size()>0)
            {
                Rick_Tracker_1 = listRickTracker[0];
            }
            if(listRickTracker.size()>1)
            {
                Rick_Tracker_2 = listRickTracker[1];
            }
        }
        
    }
    //日期格式转换
    public string CeatedOn//创建时间
    {
        get
        {
            return opp.CreatedDate.format('yyyy/MM/dd a hh:mm');
        }
        set;
    }
    public string LastModifiedOn//上次修改时间
    {
        get
        {
            return opp.LastModifiedDate.format('yyyy/MM/dd a hh:mm');
        }
        set;
    }
    public string thisDt//当前时间
    {
        get
        {
            return DateTime.now().format('yyyy/MM/dd a hh:mm');
        }
        set;
    }
    public string CloseDate
    {
        get
        {
            if(opp.CloseDate==null)
            {
                return null;
            }
            else
            {
                return opp.CloseDate.Year()+'.'+opp.CloseDate.Month()+'.'+opp.CloseDate.Day();
            }        
        }
        set;
    }
    public string ActualCloseDate
    {
        get
        {
            if(opp.Actual_Close_Date__c == null)
            {
                return null;
            }
            else
            {
                return opp.Actual_Close_Date__c.format();
            }
        }
    }
    //数字格式
    public string ProductVolume
    {
        get
        {
            if(opp.Product_Volume__c != null)
            {
                return opp.Product_Volume__c.format();
            }
            else
            {
                return null;
            }
        }
        set;
    }
    public string Amount
    {
        get
        {
            if(opp.Amount != null)
            {
                return opp.Amount.format();
            }
            else
            {
                return null;
            }
        }
        set;
    }
    public string OrderAmountOfLastYear
    {
        get
        {
            if(Order_amount_of_Last_year != null)
            {
                return Order_amount_of_Last_year.format();
            }
            else
            {
                return null;
                
            }
        }
        set;
    }
    public string HistoryAccumulation
    {
        get
        {
            if(opp.Account != null && opp.Account.Order_Amount_of_History__c != null)
            {
                return opp.Account.Order_Amount_of_History__c.format();
            }
            else
            {
                return null;
            }
        }
        set;
    }
    
    public string ActualVolume
    {
        get
        {
            if(opp.Actual_Volume__c != null)
            {
                return opp.Actual_Volume__c.format();
            }
            else
            {
                return null;
            }
        }
        set;
    }
    public string ActualAmount
    {
        get
        {
            if(opp.Actual_Amount__c != null)
            {
                return opp.Actual_Amount__c.format();
            }
            else
            {
                return null;
            }
        }
        set;
    }
    /*************************************Tobe End******************************************/
}
