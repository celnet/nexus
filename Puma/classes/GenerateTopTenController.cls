public class GenerateTopTenController {
	public String displayReport{get;set;}
	public String displaySelect{get;set;}
	public String displayPdf{get;set;}
	public String displayFontSize{get;set;}
	
	public String weekNumber{get;set;}
	
	public String displayPicture{get;set;}
	
	public Date__c d{get;set;} 
	public Date__c weekDate{get;set;}
	
	public String selectedRegion{get;set;}
	public List<SelectOption> options{get;set;}
	
	public List<Product_Top_Ten__c> maleAppList{get;set;}
	public List<Product_Top_Ten__c> femaleAppList{get;set;}
	public List<Product_Top_Ten__c> bagAccList{get;set;}
	public List<Product_Top_Ten__c> sockAccList{get;set;}
	public List<Product_Top_Ten__c> footwareList{get;set;}
	
	public SummaryNumber maleTopSummary{get;set;}
	public SummaryNumber maleTotalSummary{get;set;}
	public SummaryPercent malePercent{get;set;}
	
	public SummaryNumber femaleTopSummary{get;set;}
	public SummaryNumber femaleTotalSummary{get;set;}
	public SummaryPercent femalePercent{get;set;}
	
	public SummaryNumber footwareTopSummary{get;set;}
	public SummaryNumber footwareTotalSummary{get;set;}
	public SummaryPercent footwarePercent{get;set;}
	
	public SummaryNumber bagTopSummary{get;set;}
	public SummaryNumber bagTotalSummary{get;set;}
	public SummaryPercent bagPercent{get;set;}
	
	public SummaryNumber sockTopSummary{get;set;}
	public SummaryNumber sockTotalSummary{get;set;}
	public SummaryPercent sockPercent{get;set;}
	
	public class SummaryNumber
	{
		public Double amount{get;set;}
		public Double unit{get;set;}
		public Double gp{get;set;}
		
		public SummaryNumber()
		{
			amount = 0;
			unit = 0;
			gp = 0;
		}
		public SummaryNumber(Double a, Double u, Double g)
		{
			amount = a;
			unit = u;
			gp = g;
		}
	}
	
	public class SummaryPercent
	{
		public String amount{get;set;}
		public String unit{get;set;}
		public String gp{get;set;}
		
		public SummaryPercent()
		{
			amount = '';
			unit = '';
			gp = '';
		}
		
		public SummaryPercent(String a, String u, String g)
		{
			amount = a;
			unit = u;
			gp = g;
		}
	}
	
	public ID attId{get;set;}
	public ID femaleAttId{get;set;}
	public ID footAttId{get;set;}
	public ID sockAttId{get;set;}
	public ID bagAttId{get;set;}
	
	public GenerateTopTenController()
	{
		displayPicture = '{!$Resource.Puma_Logo}';
		displayReport = 'display:none';
		displaySelect = '';
		displayPdf = '';
		
		selectedRegion = '全国';
		options = new List<SelectOption>();
		options.add(new selectOption(selectedRegion, selectedRegion));
		
		for(Region__c region : [Select Id, Name__c From Region__c])
		{
			options.add(new selectOption(region.Name__c, region.Name__c));
		}
		
		maleTopSummary = new SummaryNumber();
		maleTotalSummary = new SummaryNumber();
		malePercent = new SummaryPercent();
		
		femaleTopSummary = new SummaryNumber();
		femaleTotalSummary = new SummaryNumber();
		femalePercent = new SummaryPercent();
		
		footwareTopSummary = new SummaryNumber();
		footwareTotalSummary = new SummaryNumber();
		footwarePercent = new SummaryPercent();
		
		bagTopSummary = new SummaryNumber();
		bagTotalSummary = new SummaryNumber();
		bagPercent = new SummaryPercent();
		
		sockTopSummary = new SummaryNumber();
		sockTotalSummary = new SummaryNumber();
		sockPercent = new SummaryPercent();
		
		d = new Date__c();
		weekDate = new Date__c();
		
		d.Date__c = Date.today();
		weekDate.Date__c = Date.today();
		
		//attId = '00P90000008ch0A';
		attId = '00P90000008chCb';
		femaleAttId = '00P90000008chCb';
		footAttId = '00P90000008chCb';
		sockAttId = '00P90000008chCb';
		bagAttId = '00P90000008chCb';
		
		this.displayTopTenPDF();
		
		List<Attachment> attList = [Select Id From Attachment Where ParentId = 'a0J9000000SLf7z'];
		if(attList.size() > 0)
		{
			attId = attList[0].Id;
		}
	}
	
	public void convertToPDF()
	{
		displayPdf = 'pdf';
		displaySelect = 'display:none';
		displayFontSize = 'font-size:55% ;';
	}
	
	public void displayTopTenPDF()
	{
		if(this.weekDate.Date__c != null)
		{
			Date d1 = this.weekDate.Date__c;
			
			if(Date.newInstance(d1.year(), 1, 1).toStartOfWeek().daysBetween(d1.toStartOfWeek()) / 7 <= 9)
			{
				this.weekNumber = d1.year() + '0' + (Date.newInstance(d1.year(), 1, 1).toStartOfWeek().daysBetween(d1.toStartOfWeek()) / 7);
			}
			else
			{
				this.weekNumber = d1.year() + '' + (Date.newInstance(d1.year(), 1, 1).toStartOfWeek().daysBetween(d1.toStartOfWeek()) / 7);
			}
			
			if(this.selectedRegion == '全国')
			{
				displayReport = '';	
				List<Product_Top_Ten__c> maleTopList = new List<Product_Top_Ten__c>();
				maleTopList = [Select 
															Id,
															Picture__c, Picture_URL__c,
															Ranking__c,
															Article_Code__c,
															Color__c,
															Description__c,
															RBU__c,
															Gender__c,
															Season__c,
															Original_Retail_Price__c,
															Std_Retail_Price__c,
															Discount_Rate__c,
															Weekly_Sales_Unit__c,
															Weekly_Sales_Amount__c,
															GP_Amount__c
														From 
															Product_Top_Ten__c 
														Where 
															Gender__c = '男' 
														And 
															Division__c = '服装' 
														And
															Product_Top_Ten_Type__c = 'All'
														And 
															Week_No__c =: this.weekNumber
														Order By 
															Ranking__c asc];
					
				AggregateResult[] arMaleList = [Select 
												SUM(GP_Amt__c) ga, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq 
											From 
												Raw_Data__c 
											Where 
												Gender__c = '男'
											And 
												Division__c LIKE '%服%'
											And 
												Transaction_Date__c >=: d1.toStartOfWeek()
											And 
												Transaction_Date__c <=: d1.toStartOfWeek().addDays(7)];
				
				if(arMaleList.size() > 0)
				{
					maleTotalSummary.amount = (Double)arMaleList[0].get('sa');
					maleTotalSummary.unit = (Double)arMaleList[0].get('sq');
					maleTotalSummary.gp = (Double)arMaleList[0].get('ga');
				}
				
				Integer maleTopSize = maleTopList.size();
				
				if(maleTopSize > 0)
				{
					maleTopSummary.amount = 0;
					maleTopSummary.unit = 0;
					maleTopSummary.gp = 0;
					for(Product_Top_Ten__c pt : maleTopList)
					{
						maleTopSummary.amount += pt.Weekly_Sales_Amount__c;
						maleTopSummary.unit += pt.Weekly_Sales_Unit__c;
						maleTopSummary.gp += pt.GP_Amount__c;
					}
					
					this.maleAppList = maleTopList;
					attId = '00P90000008ch0A';
					
					if(maleTopSize < 10)
					{
						for(Integer i = 1; i < (10 - maleTopSize); i++)
						{
							this.maleAppList.add(new Product_Top_Ten__c());
						}
					}
				}
				
				List<Product_Top_Ten__c> femaleTopList = new List<Product_Top_Ten__c>();
				femaleTopList = [Select 
															Id,
															Picture__c, Picture_URL__c,
															Ranking__c,
															Article_Code__c,
															Color__c,
															Description__c,
															RBU__c,
															Gender__c,
															Season__c,
															Original_Retail_Price__c,
															Std_Retail_Price__c,
															Discount_Rate__c,
															Weekly_Sales_Unit__c,
															Weekly_Sales_Amount__c,
															GP_Amount__c
														From 
															Product_Top_Ten__c 
														Where 
															Gender__c = '女' 
														And 
															Division__c = '服装' 
														And
															Product_Top_Ten_Type__c = 'All'
														And 
															Week_No__c =: this.weekNumber
														Order By 
															Ranking__c asc];
				
				AggregateResult[] arFemaleList = [Select 
												SUM(GP_Amt__c) ga, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq 
											From 
												Raw_Data__c 
											Where 
												Gender__c = '女'
											And 
												Division__c LIKE '%服%'
											And 
												Transaction_Date__c >=: d1.toStartOfWeek()
											And 
												Transaction_Date__c <=: d1.toStartOfWeek().addDays(7)];
				
				if(arFemaleList.size() > 0)
				{
					femaleTotalSummary.amount = (Double)arFemaleList[0].get('sa');
					femaleTotalSummary.unit = (Double)arFemaleList[0].get('sq');
					femaleTotalSummary.gp = (Double)arFemaleList[0].get('ga');
				}
				
				Integer femaleTopSize = femaleTopList.size();
					
				if(femaleTopSize > 0)
				{
					femaleTopSummary.amount = 0;
					femaleTopSummary.unit = 0;
					femaleTopSummary.gp = 0;
					for(Product_Top_Ten__c pt : femaleTopList)
					{
						femaleTopSummary.amount += pt.Weekly_Sales_Amount__c;
						femaleTopSummary.unit += pt.Weekly_Sales_Unit__c;
						femaleTopSummary.gp += pt.GP_Amount__c;
					}
					this.femaleAppList = femaleTopList;
					femaleAttId = '00P90000008ch0A';
					
					if(femaleTopSize < 10)
					{
						for(Integer i = 1; i < (10 - femaleTopSize); i++)
						{
							this.femaleAppList.add(new Product_Top_Ten__c());
						}
					}
				}
				
			 	List<Product_Top_Ten__c> footwareTopList = new List<Product_Top_Ten__c>();
				footwareTopList = [Select 
															Id,
															Picture__c, Picture_URL__c,
															Ranking__c,
															Article_Code__c,
															Color__c,
															Description__c,
															RBU__c,
															Gender__c,
															Season__c,
															Original_Retail_Price__c,
															Std_Retail_Price__c,
															Discount_Rate__c,
															Weekly_Sales_Unit__c,
															Weekly_Sales_Amount__c,
															GP_Amount__c
														From 
															Product_Top_Ten__c 
														Where 
															Division__c = '鞋' 
														And
															Product_Top_Ten_Type__c = 'All'
														And 
															Week_No__c =: this.weekNumber
														Order By 
															Ranking__c asc];
					
				AggregateResult[] arFootwareList = [Select 
												SUM(GP_Amt__c) ga, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq 
											From 
												Raw_Data__c 
											Where 
												Division__c LIKE '%鞋%'
											And 
												Transaction_Date__c >=: d1.toStartOfWeek()
											And 
												Transaction_Date__c <=: d1.toStartOfWeek().addDays(7)];
				
				if(arFootwareList.size() > 0)
				{
					footwareTotalSummary.amount = (Double)arFootwareList[0].get('sa');
					footwareTotalSummary.unit = (Double)arFootwareList[0].get('sq');
					footwareTotalSummary.gp = (Double)arFootwareList[0].get('ga');	
				}
				
				Integer footwareTopSize = footwareTopList.size();
					
				if(footwareTopSize > 0)
				{
					footwareTopSummary.amount = 0;
					footwareTopSummary.unit = 0;
					footwareTopSummary.gp = 0;
					for(Product_Top_Ten__c pt : footwareTopList)
					{
						footwareTopSummary.amount += pt.Weekly_Sales_Amount__c;
						footwareTopSummary.unit += pt.Weekly_Sales_Unit__c;
						footwareTopSummary.gp += pt.GP_Amount__c;
					}
					this.footwareList = footwareTopList;
					footAttId = '00P90000008ch0A';
					
					if(footwareTopSize < 20)
					{
						for(Integer i = 1; i < (20 - footwareTopSize); i++)
						{
							this.footwareList.add(new Product_Top_Ten__c());
						}
					}
				}

				List<Product_Top_Ten__c> bagTopList = new List<Product_Top_Ten__c>();
				bagTopList = [Select 
															Id,
															Picture__c, Picture_URL__c,
															Ranking__c,
															Article_Code__c,
															Color__c,
															Description__c,
															RBU__c,
															Gender__c,
															Season__c,
															Original_Retail_Price__c,
															Std_Retail_Price__c,
															Discount_Rate__c,
															Weekly_Sales_Unit__c,
															Weekly_Sales_Amount__c,
															GP_Amount__c
														From 
															Product_Top_Ten__c 
														Where 
															Division__c = '配件' 
														And
															Cty_Division__c = '包'
														And
															Product_Top_Ten_Type__c = 'All'
														And 
															Week_No__c =: this.weekNumber
														Order By 
															Ranking__c asc];
				
				AggregateResult[] arBagList = [Select 
												SUM(GP_Amt__c) ga, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq 
											From 
												Raw_Data__c 
											Where 
												Cty_Division__c LIKE '%包%'
											And 
												Transaction_Date__c >=: d1.toStartOfWeek()
											And 
												Transaction_Date__c <=: d1.toStartOfWeek().addDays(7)];
				
				if(arBagList.size() > 0)
				{
					bagTotalSummary.amount = (Double)arBagList[0].get('sa');
					bagTotalSummary.unit = (Double)arBagList[0].get('sq');
					bagTotalSummary.gp = (Double)arBagList[0].get('ga');		
				}
				
				Integer bagTopSize = bagTopList.size();
				
				if(bagTopSize > 0)
				{
					bagTopSummary.amount = 0;
					bagTopSummary.unit = 0;
					bagTopSummary.gp = 0;
					for(Product_Top_Ten__c pt : bagTopList)
					{
						bagTopSummary.amount += pt.Weekly_Sales_Amount__c;
						bagTopSummary.unit += pt.Weekly_Sales_Unit__c;
						bagTopSummary.gp += pt.GP_Amount__c;
					}
					this.bagAccList = bagTopList;
					bagAttId = '00P90000008ch0A';
					
					if(bagTopSize < 5)
					{
						for(Integer i = 1; i < (5 - bagTopSize); i++)
						{
							this.bagAccList.add(new Product_Top_Ten__c());
						}
					}
				}

				List<Product_Top_Ten__c> sockTopList = new List<Product_Top_Ten__c>();
				sockTopList = [Select 
															Id,
															Picture__c, Picture_URL__c,
															Ranking__c,
															Article_Code__c,
															Color__c,
															Description__c,
															RBU__c,
															Gender__c,
															Season__c,
															Original_Retail_Price__c,
															Std_Retail_Price__c,
															Discount_Rate__c,
															Weekly_Sales_Unit__c,
															Weekly_Sales_Amount__c,
															GP_Amount__c
														From 
															Product_Top_Ten__c 
														Where 
															Division__c = '配件' 
														And
															Cty_Division__c = '袜'
														And
															Product_Top_Ten_Type__c = 'All'
														And 
															Week_No__c =: this.weekNumber
														Order By 
															Ranking__c asc limit 5];
				
				AggregateResult[] arSockList = [Select 
												SUM(GP_Amt__c) ga, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq 
											From 
												Raw_Data__c 
											Where 
												Cty_Division__c LIKE '%袜%'
											And 
												Transaction_Date__c >=: d1.toStartOfWeek()
											And 
												Transaction_Date__c <=: d1.toStartOfWeek().addDays(7)];
				
				if(arSockList.size() > 0)
				{
					sockTotalSummary.amount = (Double)arSockList[0].get('sa');
					sockTotalSummary.unit = (Double)arSockList[0].get('sq');
					sockTotalSummary.gp = (Double)arSockList[0].get('ga');		
				}
				
				Integer sockTopSize = sockTopList.size();
				
				if(sockTopSize > 0)
				{
					sockTopSummary.amount = 0;
					sockTopSummary.unit = 0;
					sockTopSummary.gp = 0;
					for(Product_Top_Ten__c pt : sockTopList)
					{
						System.debug('>>>>' + pt.Weekly_Sales_Unit__c);
						sockTopSummary.amount += pt.Weekly_Sales_Amount__c;
						sockTopSummary.unit += pt.Weekly_Sales_Unit__c;
						sockTopSummary.gp += pt.GP_Amount__c;
					}
					
					this.sockAccList = sockTopList;
					sockAttId = '00P90000008ch0A';
	
					if(sockTopSize < 5)
					{
						for(Integer i = 1; i < (5 - sockTopSize); i++)
						{
							this.sockAccList.add(new Product_Top_Ten__c());
						}
					}
				}

			}
			else
			{
				displayReport = '';
				Region__c region = [Select Id From Region__c Where Name__c =: selectedRegion];
				
				List<Product_Top_Ten__c> maleTopList = new List<Product_Top_Ten__c>();
				maleTopList = [Select 
															Id,
															Picture__c, Picture_URL__c,
															Ranking__c,
															Article_Code__c,
															Color__c,
															Description__c,
															RBU__c,
															Gender__c,
															Season__c,
															Original_Retail_Price__c,
															Std_Retail_Price__c,
															Discount_Rate__c,
															Weekly_Sales_Unit__c,
															Weekly_Sales_Amount__c,
															GP_Amount__c
														From 
															Product_Top_Ten__c 
														Where 
															Gender__c = '男' 
														And 
															Division__c = '服装' 
														And
															Region__c =: region.Id
														And 
															Week_No__c =: this.weekNumber
														Order By 
															Ranking__c asc];
					
				AggregateResult[] arMaleList = [Select 
												SUM(GP_Amt__c) ga, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq 
											From 
												Raw_Data__c 
											Where 
												Gender__c = '男'
											And 
												Store__r.Region__c =: region.Id
											And 
												Division__c LIKE '%服%'
											And 
												Transaction_Date__c >=: d1.toStartOfWeek()
											And 
												Transaction_Date__c <=: d1.toStartOfWeek().addDays(7)];
				
				if(arMaleList.size() > 0)
				{
					maleTotalSummary.amount = (Double)arMaleList[0].get('sa');
					maleTotalSummary.unit = (Double)arMaleList[0].get('sq');
					maleTotalSummary.gp = (Double)arMaleList[0].get('ga');
				}
				
				Integer maleTopSize = maleTopList.size();
					
				if(maleTopSize > 0)
				{
					maleTopSummary.amount = 0;
					maleTopSummary.unit = 0;
					maleTopSummary.gp = 0;
					for(Product_Top_Ten__c pt : maleTopList)
					{
						maleTopSummary.amount += pt.Weekly_Sales_Amount__c;
						maleTopSummary.unit += pt.Weekly_Sales_Unit__c;
						maleTopSummary.gp += pt.GP_Amount__c;
					}
					
					this.maleAppList = maleTopList;
					attId = '00P90000008ch0A';
					
					if(maleTopSize < 10)
					{
						for(Integer i = 1; i < (10 - maleTopSize); i++)
						{
							this.maleAppList.add(new Product_Top_Ten__c());
						}
					}
				}

				List<Product_Top_Ten__c> femaleTopList = new List<Product_Top_Ten__c>();
				femaleTopList = [Select 
															Id,
															Picture__c, Picture_URL__c,
															Ranking__c,
															Article_Code__c,
															Color__c,
															Description__c,
															RBU__c,
															Gender__c,
															Season__c,
															Original_Retail_Price__c,
															Std_Retail_Price__c,
															Discount_Rate__c,
															Weekly_Sales_Unit__c,
															Weekly_Sales_Amount__c,
															GP_Amount__c
														From 
															Product_Top_Ten__c 
														Where 
															Gender__c = '女' 
														And 
															Division__c = '服装' 
														And
															Region__c =: region.Id
														And 
															Week_No__c =: this.weekNumber
														Order By 
															Ranking__c asc];
					
				AggregateResult[] arFemaleList = [Select 
												SUM(GP_Amt__c) ga, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq 
											From 
												Raw_Data__c 
											Where 
												Gender__c = '女'
											And 
												Store__r.Region__c =: region.Id
											And 
												Division__c LIKE '%服%'
											And 
												Transaction_Date__c >=: d1.toStartOfWeek()
											And 
												Transaction_Date__c <=: d1.toStartOfWeek().addDays(7)];
				
				if(arFemaleList.size() > 0)
				{
					femaleTotalSummary.amount = (Double)arFemaleList[0].get('sa');
					femaleTotalSummary.unit = (Double)arFemaleList[0].get('sq');
					femaleTotalSummary.gp = (Double)arFemaleList[0].get('ga');
				}
				
				Integer femaleTopSize = femaleTopList.size();
					
				if(femaleTopSize > 0)
				{
					femaleTopSummary.amount = 0;
					femaleTopSummary.unit = 0;
					femaleTopSummary.gp = 0;
					for(Product_Top_Ten__c pt : femaleTopList)
					{
						femaleTopSummary.amount += pt.Weekly_Sales_Amount__c;
						femaleTopSummary.unit += pt.Weekly_Sales_Unit__c;
						femaleTopSummary.gp += pt.GP_Amount__c;
					}
					
					this.femaleAppList = femaleTopList;
					femaleAttId = '00P90000008ch0A';

					if(femaleTopSize < 10)
					{
						for(Integer i = 1; i < (10 - femaleTopSize); i++)
						{
							this.femaleAppList.add(new Product_Top_Ten__c());
						}
					}
				}

				List<Product_Top_Ten__c> footwareTopList = new List<Product_Top_Ten__c>();
				footwareTopList = [Select 
															Id,
															Picture__c, Picture_URL__c,
															Ranking__c,
															Article_Code__c,
															Color__c,
															Description__c,
															RBU__c,
															Gender__c,
															Season__c,
															Original_Retail_Price__c,
															Std_Retail_Price__c,
															Discount_Rate__c,
															Weekly_Sales_Unit__c,
															Weekly_Sales_Amount__c,
															GP_Amount__c
														From 
															Product_Top_Ten__c 
														Where 
															Division__c = '鞋' 
														And
															Region__c =: region.Id
														And 
															Week_No__c =: this.weekNumber
														Order By 
															Ranking__c asc];
				
				AggregateResult[] arFootwareList = [Select 
												SUM(GP_Amt__c) ga, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq 
											From 
												Raw_Data__c 
											Where 
												Division__c LIKE '%鞋%'
											And	
												Store__r.Region__c =: region.Id
											And 
												Transaction_Date__c >=: d1.toStartOfWeek()
											And 
												Transaction_Date__c <=: d1.toStartOfWeek().addDays(7)];
				
				if(arFootwareList.size() > 0)
				{
					footwareTotalSummary.amount = (Double)arFootwareList[0].get('sa');
					footwareTotalSummary.unit = (Double)arFootwareList[0].get('sq');
					footwareTotalSummary.gp = (Double)arFootwareList[0].get('ga');	
				}
				
				Integer footwareTopSize = footwareTopList.size();
					
				if(footwareTopSize > 0)
				{
					footwareTopSummary.amount = 0;
					footwareTopSummary.unit = 0;
					footwareTopSummary.gp = 0;
					for(Product_Top_Ten__c pt : footwareTopList)
					{
						footwareTopSummary.amount += pt.Weekly_Sales_Amount__c;
						footwareTopSummary.unit += pt.Weekly_Sales_Unit__c;
						footwareTopSummary.gp += pt.GP_Amount__c;
					}
					
					this.footwareList = footwareTopList;
					footAttId = '00P90000008ch0A';

					if(footwareTopSize < 20)
					{
						for(Integer i = 1; i < (20 - footwareTopSize); i++)
						{
							this.footwareList.add(new Product_Top_Ten__c());
						}
					}
				}

				List<Product_Top_Ten__c> bagTopList = new List<Product_Top_Ten__c>();
				bagTopList = [Select 
															Id,
															Picture__c, Picture_URL__c,
															Ranking__c,
															Article_Code__c,
															Color__c,
															Description__c,
															RBU__c,
															Gender__c,
															Season__c,
															Original_Retail_Price__c,
															Std_Retail_Price__c,
															Discount_Rate__c,
															Weekly_Sales_Unit__c,
															Weekly_Sales_Amount__c,
															GP_Amount__c
														From 
															Product_Top_Ten__c 
														Where 
															Division__c = '配件' 
														And
															Cty_Division__c = '包'
														And
															Region__c =: region.Id
														And 
															Week_No__c =: this.weekNumber
														Order By 
															Ranking__c asc];
				
				AggregateResult[] arBagList = [Select 
												SUM(GP_Amt__c) ga, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq 
											From 
												Raw_Data__c 
											Where 
												Cty_Division__c LIKE '%包%'
											And
												Store__r.Region__c =: region.Id
											And 
												Transaction_Date__c >=: d1.toStartOfWeek()
											And 
												Transaction_Date__c <=: d1.toStartOfWeek().addDays(7)];	
				
				if(arBagList.size() > 0)
				{
					bagTotalSummary.amount = (Double)arBagList[0].get('sa');
					bagTotalSummary.unit = (Double)arBagList[0].get('sq');
					bagTotalSummary.gp = (Double)arBagList[0].get('ga');
				}
				
				Integer bagTopSize = bagTopList.size();
					
				if(bagTopSize > 0)
				{
					bagTopSummary.amount = 0;
					bagTopSummary.unit = 0;
					bagTopSummary.gp = 0;
					for(Product_Top_Ten__c pt : bagTopList)
					{
						bagTopSummary.amount += pt.Weekly_Sales_Amount__c;
						bagTopSummary.unit += pt.Weekly_Sales_Unit__c;
						bagTopSummary.gp += pt.GP_Amount__c;
					}
					this.bagAccList = bagTopList;
					bagAttId = '00P90000008ch0A';
					
					if(bagTopSize < 5)
					{
						for(Integer i = 1; i < (5 - bagTopSize); i++)
						{
							this.bagAccList.add(new Product_Top_Ten__c());
						}
					}
				}

				List<Product_Top_Ten__c> sockTopList = new List<Product_Top_Ten__c>();
				sockTopList = [Select 
															Id,
															Picture__c, Picture_URL__c,
															Ranking__c,
															Article_Code__c,
															Color__c,
															Description__c,
															RBU__c,
															Gender__c,
															Season__c,
															Original_Retail_Price__c,
															Std_Retail_Price__c,
															Discount_Rate__c,
															Weekly_Sales_Unit__c,
															Weekly_Sales_Amount__c,
															GP_Amount__c
														From 
															Product_Top_Ten__c 
														Where 
															Division__c = '配件' 
														And
															Cty_Division__c = '袜'
														And
															Region__c =: region.Id
														And 
															Week_No__c =: this.weekNumber
														Order By 
															Ranking__c asc];
					
				AggregateResult[] arSockList = [Select 
												SUM(GP_Amt__c) ga, 
												SUM(Sales_Amt__c) sa, 
												SUM(Sales_Qty__c) sq 
											From 
												Raw_Data__c 
											Where 
												Cty_Division__c LIKE '%袜%'
											And
												Store__r.Region__c =: region.Id
											And 
												Transaction_Date__c >=: d1.toStartOfWeek()
											And 
												Transaction_Date__c <=: d1.toStartOfWeek().addDays(7)];
				
				if(arSockList.size() > 0)
				{
					sockTotalSummary.amount = (Double)arSockList[0].get('sa');
					sockTotalSummary.unit = (Double)arSockList[0].get('sq');
					sockTotalSummary.gp = (Double)arSockList[0].get('ga');
				}
				
				Integer sockTopSize = sockTopList.size();
					
				if(sockTopSize > 0)
				{
					sockTopSummary.amount = 0;
					sockTopSummary.unit = 0;
					sockTopSummary.gp = 0;
					for(Product_Top_Ten__c pt : bagTopList)
					{
						sockTopSummary.amount += pt.Weekly_Sales_Amount__c;
						sockTopSummary.unit += pt.Weekly_Sales_Unit__c;
						sockTopSummary.gp += pt.GP_Amount__c;
					}
					
					this.sockAccList = sockTopList;
					sockAttId = '00P90000008ch0A';		
					
					if(sockTopSize < 5)
					{
						for(Integer i = 1; i < (5 - sockTopSize); i++)
						{
							this.sockAccList.add(new Product_Top_Ten__c());
						}
					}
				}
			}
		}
		else
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请先选择日期');         
	   		ApexPages.addMessage(msg);
		}
		
		if(maleTopSummary.amount != 0  && maleTotalSummary.amount != 0)
		{
			malePercent.amount = Math.roundToLong((maleTopSummary.amount/maleTotalSummary.amount) * 100) + '%';
		}
		
		if(maleTopSummary.unit != 0 && maleTotalSummary.unit != 0)
		{
			malePercent.unit = Math.roundToLong((maleTopSummary.unit/maleTotalSummary.unit) * 100) + '%';
		}
		
		if(maleTopSummary.gp != 0 && maleTotalSummary.gp != 0)
		{
			malePercent.gp = Math.roundToLong((maleTopSummary.gp/maleTotalSummary.gp) * 100)+ '%';
		}
		
		if(femaleTopSummary.amount != 0 && femaleTotalSummary.amount != 0)
		{
			femalePercent.amount = Math.roundToLong((femaleTopSummary.amount/femaleTotalSummary.amount) * 100) + '%';
		}
		
		if(femaleTopSummary.unit != 0 && femaleTotalSummary.unit != 0)
		{
			femalePercent.unit = Math.roundToLong((femaleTopSummary.unit/femaleTotalSummary.unit) * 100) + '%';
		}
		
		if(femaleTopSummary.gp != 0 && femaleTotalSummary.gp != 0)
		{
			femalePercent.gp = Math.roundToLong((femaleTopSummary.gp/femaleTotalSummary.gp) * 100) + '%';
		}
		
		if(footwareTopSummary.amount != 0 && footwareTotalSummary.amount != 0)
		{
			footwarePercent.amount = Math.roundToLong((footwareTopSummary.amount/footwareTotalSummary.amount) * 100) + '%';
		}
		
		if(footwareTopSummary.unit != 0 && footwareTotalSummary.amount != 0)
		{
			footwarePercent.unit = Math.roundToLong((footwareTopSummary.unit/footwareTotalSummary.unit) * 100) + '%';
		}
		
		if(footwareTopSummary.gp != 0 && footwareTotalSummary.gp != 0)
		{
			footwarePercent.gp = Math.roundToLong((footwareTopSummary.gp/footwareTotalSummary.gp) * 100) + '%';
		}
		
		if(bagTopSummary.amount != 0 && bagTotalSummary.amount != 0)
		{
			bagPercent.amount = Math.roundToLong((bagTopSummary.amount/bagTotalSummary.amount) * 100) + '%';
		}
		
		if(bagTopSummary.unit != 0 && bagTotalSummary.unit != 0)
		{
			bagPercent.unit = Math.roundToLong((bagTopSummary.unit/bagTotalSummary.unit) * 100) + '%';
		}
		
		if(bagTopSummary.gp != 0 && bagTotalSummary.gp != 0)
		{
			bagPercent.gp = Math.roundToLong((bagTopSummary.gp/bagTotalSummary.gp) * 100) + '%';
		}
		
		if(sockTopSummary.amount != 0 && sockTotalSummary.amount != 0)
		{
			sockPercent.amount = Math.roundToLong((sockTopSummary.amount/sockTotalSummary.amount) * 100) + '%';
		}
		
		if(sockTopSummary.unit != 0 && sockTotalSummary.unit != 0)
		{
			sockPercent.unit = Math.roundToLong((sockTopSummary.unit/sockTotalSummary.unit) * 100) + '%';
		}
		
		if(sockTopSummary.gp != 0 && sockTotalSummary.gp != 0)
		{
			sockPercent.gp = Math.roundToLong((sockTopSummary.gp/sockTotalSummary.gp) * 100) + '%';
		}
	}
	
	public void generateTopTen()
	{
		WeeklyTopTenBatch wttb = new WeeklyTopTenBatch(d.Date__c);
		Database.executeBatch(wttb);
	}
	
	public void generateTotalTopTen()
	{
		WeeklyTopTenTotalNewBatch wtttnb = new WeeklyTopTenTotalNewBatch(d.Date__c);
		Database.executeBatch(wtttnb);
		
		//WeeklyTopTenTotalBatch wtttb = new WeeklyTopTenTotalBatch(d.Date__c);
		//Database.executeBatch(wtttb);
	}
}