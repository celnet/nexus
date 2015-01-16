public with sharing class SalesOutputEditorController {
	public List<ProductSeries__c> psList{get;set;}
	public List<Product1__c> p1List{get;set;}
	public List<OutputWrapper> owList{get;set;}
	public String openId{get;set;}
	public String psOptions{get;set;}
	public String p1Options{get;set;}
	
	/*
	public List<SelectOption> psOptions{
		get{
			if(psList == null){
				psList = new List<SelectOption>();
				for(ProductSeries__c ps : [Select Id, Name From ProductSeries__c]){
					psList.add(new SelectOption(ps.Id, ps.Name));
				}
			} 
			return psList;
		}
		set;
	}
	
	public List<SelectOption> p1Options{
		get{
			if(p1List == null){
				p1List = new List<SelectOption>();
				for(Product1__c p1 : [Select Id, Name From Product1__c])
			}
		}
	}
	*/
	
	public SalesOutputEditorController(){
		// 获取微信用户的 OpenId
		String code = ApexPages.currentPage().getParameters().get('code');
		String state = ApexPages.currentPage().getParameters().get('state');
		
		if(code != null){
			Welink.WechatCalloutService wcs = new Welink.WechatCalloutService('gh_67b355ccdba5');
			openId = wcs.GetOpenIdbyCode(code);
		}
		
		psList = [Select Id, Name From ProductSeries__c];
		p1List = [Select Id, Name, ProductSeries1__c From Product1__c];
		
		psOptions = '';
		p1Options = '';
		
		for(ProductSeries__c ps : psList){
			String psId = ps.Id;
			String psName = ps.Name;
			psOptions += '<option value="' +psId.replace('\'','\\\'') + '">' + psName.replace('\'','\\\'') + '</option>';
		}
		
		for(Product1__c p1 : p1List){
			String p1ProductSeries1 = p1.ProductSeries1__c == null?'':p1.ProductSeries1__c;
			String p1Id = p1.Id;
			String p1Name = p1.Name;
			p1Options += '<option class="product1_' + p1ProductSeries1.replace('\'','\\\'') + '_xxxxxx" value="' + p1Id.replace('\'','\\\'') + '">' + p1Name.replace('\'','\\\'') + '</option>';

		}
		
		owList = new List<OutputWrapper>();
		add5Lines();
		
	}
	
	public void add5Lines(){
		for(Integer i = 0; i<5;i++){
			owList.add(new OutputWrapper());
		}
	}
	
	public void refreshProductOptions(){
		
	}
	
	public class OutputWrapper{
		public Output1__c o1{get;set;}
		public String date_str{get;set;}
		public Integer sales_amount{get;set;}
		public String selected_product{get;set;}
		public String selected_product_series{get;set;}
	}
	
	@RemoteAction
	public static void saveSalesData(String total_sales_data, String open_id){
		List<String> salesDatas = total_sales_data.split('======');
		List<Output1__c> insert_o1s = new List<Output1__c>();
		for(String salesData : salesDatas){
			List<String> ow_str = salesData.split('------');
			system.debug(ow_str[0] + ow_str[1] + ow_str[2] + ow_str[3]);
			Output1__c o1 = new Output1__c();
			o1.Product2__c = ow_str[1];
			
			if(ow_str[2] != null && ow_str[2] != '')
			o1.Date__c = convertToDate(ow_str[2]);
			
			if(ow_str[3] != null && ow_str[3] != '')
			o1.Quantity__c = Decimal.valueOf(ow_str[3]);
			
			insert_o1s.add(o1);
			
		}
		insert insert_o1s;
	}
	
	public static Date convertToDate(String date_str){
		Integer year = Integer.valueOf(date_str.substring(0,4));
		Integer month = Integer.valueOf(date_str.substring(5,7));
		Integer date_x = Integer.valueOf(date_str.substring(8,10));
		return Date.newInstance(year, month, date_x);
	}
}
