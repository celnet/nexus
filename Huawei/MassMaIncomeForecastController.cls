/*
 * Author: steven.ke@celnet.com.cn
 * Date: 2014-5-12
 * Description: mass edit income and forecast
 */
public class MassMaIncomeForecastController 
{
    public List<Income_And_Forecast__c> incomeAndForecastList {get;set;}
    
    private ApexPages.StandardSetController setCon;
    public Id salesMeetingId{get;set;}
    public String salesMeetingOffice{get;set;}
    public String salesMeetingName{get;set;}
    public List<RecordType> recordTypeList{get;set;}
    public List<iafWrapper> iafwList{get;set;}
    
    public class iafWrapper
    {
        public Boolean isChecked{get;set;}
        public Income_And_Forecast__c iaf{get;set;}
        public String selectedRecordType{get;set;}
        public Boolean productDisplay{get;set;}
        public Boolean industryDisplay{get;set;}
        public Boolean otherDisplay{get;set;}
        public String recordTypeError{get;set;}
        
        // 已勾选的收入及预测
        public iafWrapper(Income_And_Forecast__c i, String recordType)
        {
            isChecked = false;
            iaf = i;
            selectedRecordType = recordType;
            recordTypeError = '';
            
            if(recordType == 'Income And Forecast Record Type(Industry)')
            {
            	i.Product__c = null;
            	productDisplay = false;
            	industryDisplay = true;
            	otherDisplay = false;
            }
			else if(recordType == 'Income And Forecast Record Type(Product)')
			{
				i.Is_Important_Region__c = null;
				productDisplay = true;
				industryDisplay = false;
				otherDisplay = false;
			}
			else
			{
				selectedRecordType = '无';
				productDisplay = false;
				industryDisplay = false;
				otherDisplay = true;
			}
        }
        
        // 新生成的收入及预测
        public iafWrapper(Income_And_Forecast__c i)
        {
            isChecked = false;
            iaf = i;
            selectedRecordType = '无';
            productDisplay = false;
            industryDisplay = false;
            otherDisplay = true;
            recordTypeError = '';
        }
    }

	public List<SelectOption> getRecordTypes()
	{
		List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('无','--无--'));
        options.add(new SelectOption('Income And Forecast Record Type(Industry)','收入及预测(行业)'));
        options.add(new SelectOption('Income And Forecast Record Type(Product)','收入及预测(产品)'));

        return options;
	}

	// 根据记录类型改变字段的可编辑状态
	public void changeEditability()
	{
		for(iafWrapper iw : iafwList)
		{
			if(iw.selectedRecordType == 'Income And Forecast Record Type(Product)')
			{
				iw.iaf.Is_Important_Region__c = null;
				iw.productDisplay = true;
				iw.industryDisplay = false;
				iw.otherDisplay = false;
			}
			else if(iw.selectedRecordType == 'Income And Forecast Record Type(Industry)')
			{
				iw.iaf.Product__c = null;
				iw.productDisplay = false;
				iw.industryDisplay = true;
				iw.otherDisplay = false;
			}
			else
			{
				iw.iaf.Is_Important_Region__c = null;
				iw.iaf.Product__c = null;
				iw.industryDisplay = false;
				iw.productDisplay = false;
				iw.otherDisplay = true;
			}
		}
	}

    public MassMaIncomeForecastController(ApexPages.StandardSetController setCon)
    {
    	this.setCon = setCon;
    	
    	this.iafwList = new List<iafWrapper>();
        this.incomeAndForecastList = new List<Income_And_Forecast__c>();
        this.recordTypeList = new List<RecordType>();
    	this.salesMeetingId = ApexPages.currentPage().getParameters().get('id');
    	
    	this.recordTypeList = [Select 
	        					SobjectType, 
	        					Name
	        				  From 
	        				  	RecordType 
	        				  Where 
	        				  	SobjectType = 'Income_And_Forecast__c'
	        				  And 
	        				  	IsActive = true];
    	
    	if(this.salesMeetingId != null)
    	{
    		Sales_Meeting__c sm = [Select 
    								Id,
    								Name, 
    								Representative_Office__c 
    							   From 
    							   	Sales_Meeting__c 
    							   Where 
    							   	Id =: this.salesMeetingId];
        	this.salesMeetingOffice = sm.Representative_Office__c;
        	this.salesMeetingName = sm.Name;
        	this.incomeAndForecastList = [SELECT 
					        							Name,
					        							Id,
					        							Sales_Meeting__c,
					        							RecordTypeId,
					        							RecordType.Name,
					        							Sales_Meeting__r.Name,
		        										Sales_Meeting__r.Representative_Office__c,
					        							Industry__c,
					        							Is_Important_Region__c,
					        							Product__c,
					        							Stock_Overall__c,
														Stock_finished__c,
														Incremental_Finished__c,
														Stock_Not_Finished__c,
														Incremental_Not_Finished__c,
														Forecast_This_Quarter_HQ_Distribute__c,
														Forecast_Next_Quarter__c,
														Unique_Name__c
					        						 FROM 
					        							Income_And_Forecast__c 
					        						 Where 
					        						 	Sales_Meeting__c =: this.salesMeetingId];
    	}

        for(Income_And_Forecast__c iaf : this.incomeAndForecastList)
        {
            iafwList.add(new iafWrapper(iaf, iaf.RecordType.Name));
        }
    }
    
    public void addLine()
    {
    	Income_And_Forecast__c iaf = new Income_And_Forecast__c();
    	iaf.Industry__c = null;
    	iaf.Product__c = null;
    	iaf.Is_Important_Region__c = null;
    	iaf.Stock_Overall__c = 0;
    	iaf.Stock_finished__c = 0;
    	iaf.Incremental_Finished__c = 0;
    	iaf.Stock_Not_Finished__c = 0;
    	iaf.Incremental_Not_Finished__c = 0;
    	iaf.Forecast_This_Quarter_HQ_Distribute__c = 0;
    	iaf.Forecast_Next_Quarter__c = 0;
    	iafwList.add(new iafWrapper(iaf));
    }
    
    private boolean validateRecordType(iafWrapper iafw)
    {
    	if(iafw.selectedRecordType == '无')
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '记录类型不能为空');
			ApexPages.addMessage(msg);
			iafw.recordTypeError = 'error';
			return false;
		}
		else
		{
			iafw.recordTypeError = '';
			return true;
		}
    }
    
    private boolean validateImportantRegion(iafWrapper iafw)
    {
    	if(iafw.selectedRecordType == 'Income And Forecast Record Type(Industry)')
		{
    		if(iafw.iaf.Is_Important_Region__c == '是')
    		{
    			if(this.salesMeetingOffice != '北京代表处' && this.salesMeetingOffice != '广州代表处' && this.salesMeetingOffice != '杭州代表处')
    			{
    				iafw.iaf.Is_Important_Region__c.addError('与销售例会不匹配');
    				return false;
    			}
    			else
    			{
    				return true;
    			}
    		}
    		else
    		{
    			if(this.salesMeetingOffice == '北京代表处' || this.salesMeetingOffice == '广州代表处' || this.salesMeetingOffice == '杭州代表处')
    			{
    				iafw.iaf.Is_Important_Region__c.addError('与销售例会不匹配');
    				return false;
    			}
    			else
    			{
    				return true;
    			}
    		}
		}
		else
		{
			return true;
		}
    }
    
    private Set<String> validateIndustry(iafWrapper iafw, Set<String> industrySet)
    {
    	if(iafw.iaf.Industry__c == null)
		{
			iafw.iaf.Industry__c.addError('行业不能为空');
			return null;
		}
		else
		{
			for(String industry : industrySet)
			{
				if(iafw.iaf.Industry__c == industry)
				{
					iafw.iaf.Industry__c.addError('行业不能重复');
					return null;
				}
			}
			industrySet.add(iafw.iaf.Industry__c);
		}
		
		return industrySet;
    }
    
    private Set<String> validateProduct(iafWrapper iafw, Set<String> productSet)
    {
    	if(iafw.iaf.Product__c == null)
		{
			iafw.iaf.Product__c.addError('产品不能为空');
			return null;
		}
		else
		{
			for(String product : productSet)
			{
				if(iafw.iaf.Product__c == product)
				{
					iafw.iaf.Product__c.addError('产品不能重复');
					return null;
				}
			}
			productSet.add(iafw.iaf.Product__c);
		}
		return productSet;
    }
    
    private boolean validateForecastFields(iafWrapper iafw)
    {
    	if(iafw.iaf.Stock_Overall__c == null)
		{
			iafw.iaf.Stock_Overall__c.addError('不能为空');
			return false;
		}
		else if(iafw.iaf.Stock_finished__c == null)
		{
			iafw.iaf.Stock_finished__c.addError('不能为空');
			return false;
		}
		else if(iafw.iaf.Incremental_Finished__c == null)
		{
			iafw.iaf.Incremental_Finished__c.addError('不能为空');
			return false;
		}
		else if(iafw.iaf.Stock_Not_Finished__c == null)
		{
			iafw.iaf.Stock_Not_Finished__c.addError('不能为空');
			return false;
		}
		else if(iafw.iaf.Incremental_Not_Finished__c == null)
		{
			iafw.iaf.Incremental_Not_Finished__c.addError('不能为空');
			return false;
		}
		else if(iafw.iaf.Forecast_This_Quarter_HQ_Distribute__c == null)
		{
			iafw.iaf.Forecast_This_Quarter_HQ_Distribute__c.addError('不能为空');
			return false;
		}
		else if(iafw.iaf.Forecast_Next_Quarter__c == null)
		{
			iafw.iaf.Forecast_Next_Quarter__c.addError('不能为空');
			return false;
		}
		else
		{
			return true;
		}
    }
    
    public PageReference save()
    {
    	List<Income_And_Forecast__c> insertIafList = new List<Income_And_Forecast__c>();
    	List<Income_And_Forecast__c> updateIafList = new List<Income_And_Forecast__c>();
    	
    	Set<String> newAddedIndustrySet = new Set<String>();
    	Set<String> newAddedProductSet = new Set<String>();
    	
    	for(IafWrapper iw : iafwList)
    	{
    		if(this.validateRecordType(iw) == false)
    		{
    			return null;
    		}
    		
    		if(iw.selectedRecordType == 'Income And Forecast Record Type(Industry)')
    		{
    			if(this.validateImportantRegion(iw) == false)
    			{
    				return null;
    			}
    			
    			if(this.validateIndustry(iw,newAddedIndustrySet) != null)
    			{
    				newAddedIndustrySet = this.validateIndustry(iw,newAddedIndustrySet);
    			}
    			else
    			{
    				return null;
    			}
    		}
    		else
    		{
    			newAddedProductSet = this.validateProduct(iw,newAddedProductSet);
    		}
    		
    		if(this.validateForecastFields(iw) == false)
    		{
    			return null;
    		}
    		/*
    		if(iw.selectedRecordType == '无')
    		{
    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '记录类型不能为空');
    			ApexPages.addMessage(msg);
    			iw.recordTypeError = 'error';
    			return null;
    		}
    		else
    		{
    			iw.recordTypeError = '';
    		}
    		
    		if(iw.selectedRecordType == 'Income And Forecast Record Type(Industry)')
    		{
	    		if(iw.iaf.Is_Important_Region__c == '是')
	    		{
	    			if(this.salesMeetingOffice != '北京代表处' && this.salesMeetingOffice != '广州代表处' && this.salesMeetingOffice != '杭州代表处')
	    			{
	    				iw.iaf.Is_Important_Region__c.addError('与销售例会不匹配');
	    				return null;
	    			}
	    		}
	    		else
	    		{
	    			if(this.salesMeetingOffice == '北京代表处' || this.salesMeetingOffice == '广州代表处' || this.salesMeetingOffice == '杭州代表处')
	    			{
	    				iw.iaf.Is_Important_Region__c.addError('与销售例会不匹配');
	    				return null;
	    			}
	    		}
    		}
    		
			if(iw.selectedRecordType == 'Income And Forecast Record Type(Industry)')
			{
    			if(iw.iaf.Industry__c == null)
    			{
    				iw.iaf.Industry__c.addError('行业不能为空');
    				return null;
    			}
    			else
    			{
    				for(String industry : newAddedIndustrySet)
    				{
    					if(iw.iaf.Industry__c == industry)
    					{
    						iw.iaf.Industry__c.addError('行业不能重复');
    						return null;
    					}
    				}
    				newAddedIndustrySet.add(iw.iaf.Industry__c);
    			}
			}
			else
			{
				if(iw.iaf.Product__c == null)
				{
					iw.iaf.Product__c.addError('产品不能为空');
					return null;
				}
				else
				{
					for(String product : newAddedProductSet)
					{
						if(iw.iaf.Product__c == product)
						{
							iw.iaf.Product__c.addError('产品不能重复');
							return null;
						}
					}
					newAddedProductSet.add(iw.iaf.Product__c);
				}
			}
    		/*
    		if(iw.iaf.Stock_Overall__c == null)
    		{
    			iw.iaf.Stock_Overall__c.addError('不能为空');
    			return null;
    		}
    		
    		if(iw.iaf.Stock_finished__c == null)
    		{
    			iw.iaf.Stock_finished__c.addError('不能为空');
    			return null;
    		}
    									
    		if(iw.iaf.Incremental_Finished__c == null)
    		{
    			iw.iaf.Incremental_Finished__c.addError('不能为空');
    			return null;
    		}
    		
    		if(iw.iaf.Stock_Not_Finished__c == null)
    		{
    			iw.iaf.Stock_Not_Finished__c.addError('不能为空');
    			return null;
    		}
    		
    		if(iw.iaf.Incremental_Not_Finished__c == null)
    		{
    			iw.iaf.Incremental_Not_Finished__c.addError('不能为空');
    			return null;
    		}
    		
    		if(iw.iaf.Forecast_This_Quarter_HQ_Distribute__c == null)
    		{
    			iw.iaf.Forecast_This_Quarter_HQ_Distribute__c.addError('不能为空');
    			return null;
    		}
    		
    		if(iw.iaf.Forecast_Next_Quarter__c == null)
    		{
    			iw.iaf.Forecast_Next_Quarter__c.addError('不能为空');
    			return null;
    		}
    		*/
    		if(iw.iaf.Id != null)
    		{
    			for(RecordType rt : recordTypeList)
    			{
    				if(rt.Name == iw.selectedRecordType)
    				{
    					iw.iaf.RecordTypeId = rt.Id;
    				}
    			}
    			
    			updateIafList.add(iw.iaf);
    		}
    		
    		if(iw.iaf.Id == null)
    		{
    			for(RecordType rt : recordTypeList)
    			{
    				if(rt.Name == iw.selectedRecordType)
    				{
    					iw.iaf.RecordTypeId = rt.Id;
    				}
    			}
    			
    			iw.iaf.Sales_Meeting__c = salesMeetingId;
    			insertIafList.add(iw.iaf);
    		}
    	}
    	
    	try
    	{
    		update updateIafList;
    		insert insertIafList;
    	}
    	catch(DMLException e)
    	{
    		ApexPages.addMessages(e);
    		return null;
    	}
    	
    	PageReference pr = new PageReference('/' + salesMeetingId);
    	pr.setRedirect(true);
    	return pr;
    }
    
    public PageReference cancel()
    {
    	PageReference pr = new PageReference('/' + salesMeetingId);
    	pr.setRedirect(true);
    	return pr;
    }
    
    public void deleteSelected()
    {
    	List<Income_And_Forecast__c> deleteIafList = new List<Income_And_Forecast__c>();
    	List<iafWrapper> iwNewList = new List<iafWrapper>();
    	
    	for(iafWrapper iw : iafwList)
    	{
    		if(iw.isChecked == false && iw.iaf.Id == null)
    		{
    			iwNewList.add(new iafWrapper(iw.iaf,iw.selectedRecordType));
    		}
    		if(iw.isChecked == false && iw.iaf.Id != null)
    		{
    			iwNewList.add(new iafWrapper(iw.iaf,iw.selectedRecordType));
    		}
    		if(iw.isChecked == true && iw.iaf.Id != null)
    		{
    			deleteIafList.add(iw.iaf);
    		}
    	}
    	try
    	{
    		delete deleteIafList;
    	}
    	catch(DMLException e)
    	{
    		ApexPages.addMessages(e);
    	}
    	
    	iafwList.clear();
    	iafwList.addAll(iwNewList);
    }
}
