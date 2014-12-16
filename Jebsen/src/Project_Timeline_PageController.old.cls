/*
 * 作者：Zoe
 * 时间：2014-6-26
 * 功能：业务机会页面上的Project Timeline模块页面
*/
public class Project_Timeline_PageController 
{
    public class Strategies
    {
        public Boolean IsEdit{get;set;}
        public Integer Index{get;set;}
        public Project_Timeline__c Strategie{get;set;}
    }
    public list<Strategies> list_Strategies{get;set;}
    public ID OppId{get;set;}
    public Integer Index{get;set;}//删除记录的下标
    
    public list<SelectOption> getOptions()
    {
        Schema.DescribeFieldResult F = Project_Timeline__c.Milestones__c.getDescribe();
        List<SelectOption> options = new List<SelectOption>();
        for(Schema.Picklistentry p : F.getPicklistValues())
        {
            if(!p.isActive())
            {
                continue;
            }
            options.add(new SelectOption(p.getLabel(),p.getValue()));
        }
        return options;
    }
    public Boolean IsEdit{get;set;}
    public Project_Timeline_PageController(ApexPages.StandardController controller)
    {
        IsEdit = PubMethod.IsEdit(UserInfo.getUserRoleId());
        OppId = controller.getId();
        list_Strategies = new list<Strategies>();
        list<Project_Timeline__c> list_Value_Map_Strategies = 
                                      [select Milestones__c,Start_Date__c,End_Date__c,
                                      Remarks__c 
                                      from Project_Timeline__c 
                                      where Opportunity__c=:OppId];
                          
        if(list_Value_Map_Strategies == null || list_Value_Map_Strategies.size() == 0)  
        {
            Schema.DescribeFieldResult F = Project_Timeline__c.Milestones__c.getDescribe();
            for(Schema.Picklistentry p : F.getPicklistValues())
            {
                Strategies strate = new Strategies();
                strate.IsEdit = true;
                strate.Index = list_Strategies.size();
                Project_Timeline__c VMstrate = new Project_Timeline__c();
                VMstrate.Opportunity__c = OppId;
                VMstrate.Milestones__c = p.getValue();
                strate.Strategie = VMstrate;
                list_Strategies.add(strate);
            }
        }
        else
        {
            for(Project_Timeline__c vm : list_Value_Map_Strategies)
            {
                Strategies strate = new Strategies();
                strate.IsEdit = false;
                strate.Index = list_Strategies.size();
                strate.Strategie = vm;
                list_Strategies.add(strate);
            }
        }
    }
    //删除操作
    public void Del()
    {
        if(Index>=0)
        {
            for(Integer i = 0 ; i<  list_Strategies.size() ; i ++)
            {
                if(list_Strategies[i].Index == Index)
                {
                    if(list_Strategies[i].Strategie.id != null)
                    {
                        delete list_Strategies[i].Strategie;
                    }
                    list_Strategies.remove(i);
                    return;
                }
            }
        }
    }
    //编辑操作
    public void Upd()
    {
        if(Index>=0)
        {
            for(Integer i = 0 ; i<  list_Strategies.size() ; i ++)
            {
                if(list_Strategies[i].Index == Index)
                {
                    if(list_Strategies[i].Strategie.id != null)
                    {
                        list_Strategies[i].IsEdit = true;
                        //delete list_Strategies[i].Strategie;
                    }
                    //list_Strategies.remove(i);
                    return;
                }
            }
        }
        
    }
    //添加记录操作
    public void Add()
    {
        Strategies strate = new Strategies();
        strate.IsEdit = true;
        strate.Index = list_Strategies.size();
        Project_Timeline__c VMstrate = new Project_Timeline__c();
        VMstrate.Opportunity__c = OppId;
        strate.Strategie = VMstrate;
        list_Strategies.add(strate);
    }
    //保存记录操作
    public void Hold()
    {
        list<Project_Timeline__c> In_Strategies = new list<Project_Timeline__c>();
        list<Project_Timeline__c> Upd_Strategies = new list<Project_Timeline__c>();
        if(list_Strategies != null && list_Strategies.size() > 0)
        {
            for(Strategies strate : list_Strategies)
            {
                strate.IsEdit = false;
                if(strate.Strategie.id != null)
                {
                    Upd_Strategies.add(strate.Strategie);
                }
                else
                {
                    In_Strategies.add(strate.Strategie);
                }
            }
        }
        if(In_Strategies.size() > 0)
        {
            insert In_Strategies;
        }
        if(Upd_Strategies.size() > 0)
        {
            update Upd_Strategies;
        }
    }
}
