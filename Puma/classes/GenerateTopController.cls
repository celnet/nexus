/*
 * Author: Steven
 * Date: 2014-4-22
 * Description: 1.根据用户选择的日期运行ProductTopBatch, 2.根据用户选择的开始日期，结束日期，Top类型，区域，从Product_Top记录中查询出给定条件的Top的Product和
 */
public class GenerateTopController {
	// 开始日期
	public Date__c startDate{get;set;}
	
	// 结束日期
	public Date__c endDate{get;set;}
	
	// Top类型：销量最高还是销量最低
	public String selectedTopOption{get;set;}
	public List<SelectOption> topOptions{get;set;}
	
	// 区域
	public String selectedRegion{get;set;}
	public List<SelectOption> regions{get;set;}
	
	// 所有Product
	public List<Product__c> productList{get;set;}
	
	// 转为pdf时控制页面显示
	public String displaySelect{get;set;}
	public String displayPdf{get;set;}
	public String displayFontSize{get;set;}
	
	// 计算Top的日期
	public Date__c d{get;set;} 
	
	// 在页面显示top的数据
	public List<ProductTop> maleAppList{get;set;}
	public List<ProductTop> femaleAppList{get;set;}
	public List<ProductTop> bagAccList{get;set;}
	public List<ProductTop> sockAccList{get;set;}
	public List<ProductTop> footwareList{get;set;}
	
	// Top10小计
	public SummaryNumber maleTopSummary{get;set;}
	// 所有小计
	public SummaryNumber maleTotalSummary{get;set;}
	// Top10占比
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
	
	
	// 小计包装类
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
	
	// 占比包装类 占比加%显示
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
	
	// top10包装类
	public class ProductTop
	{
		public Double salesAmount{get;set;}
		public Double salesQuantity{get;set;}
		public Double gpAmount{get;set;}
		public String articleCode{get;set;}
		public String color{get;set;}
		public String description{get;set;}
		public String rbu{get;set;}
		public String gender{get;set;}
		public Double originalPrice{get;set;}
		public Double standardPrice{get;set;}
		public String season{get;set;}
		public Double discountRate{get;set;}
		public Integer ranking{get;set;}
	}
	
	//
	public ID attId{get;set;}
	public ID femaleAttId{get;set;}
	public ID footAttId{get;set;}
	public ID sockAttId{get;set;}
	public ID bagAttId{get;set;}
	

	public GenerateTopController()
	{
		startDate = new Date__c();
		startDate.Date__c = Date.today();
		endDate = new Date__c();
		endDate.Date__c = Date.today();
		
		selectedRegion = '全国';
		regions = new List<SelectOption>();
		regions.add(new selectOption(selectedRegion, selectedRegion));
		for(Region__c region : [Select Id, Name__c From Region__c])
		{
			regions.add(new selectOption(region.Name__c, region.Name__c));
		}
		
		selectedTopOption ='销量最高';
		topOptions = new List<SelectOption>();
		topOptions.add(new selectOption(selectedTopOption, selectedTopOption));
		topOptions.add(new selectOption('销量最低','销量最低'));
		
		displaySelect = '';
		displayPdf = '';
		
		productList = new List<Product__c>();
		
		maleAppList = new List<ProductTop>();
		femaleAppList = new List<ProductTop>();
		bagAccList = new List<ProductTop>();
		sockAccList = new List<ProductTop>();
		footwareList = new List<ProductTop>();
		
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
		d.Date__c = Date.today();
		
		//attId = '00P90000008ch0A';
		attId = '00P90000008chCb';
		femaleAttId = '00P90000008chCb';
		footAttId = '00P90000008chCb';
		sockAttId = '00P90000008chCb';
		bagAttId = '00P90000008chCb';
		
		this.displayTopTen();
	}
	
	// 生成top数据
	public void generateTop()
	{
		ProductTopBatch ptb = new ProductTopBatch(d.Date__c);
		Database.executeBatch(ptb);
	}

	// 转化为pdf
	public void convertToPDF()
	{
		displayPdf = 'pdf';
		displaySelect = 'display:none';
		displayFontSize = 'font-size:55% ;';
	}
	
	// 显示top10数据
	public void displayTopTen()
	{
		if(this.startDate.Date__c != null && this.endDate.Date__c != null)
		{
			/*
			if(this.productList.size() == 0)
			{
				this.productList = [Select 
										Id,
										Article_Code__c,
										Color__c,
										Description__c,
										RBU__c,
										Gender__c,
										Season__c,
										Original_Retail_Price__c,
										Std_Retail_Price__c,
										Discount_Rate__c
									From 
									 	Product__c];
				System.debug('产品数量>>>>>' + productList.size());
			}
			*/
			
			List<Product__c> pdList = new List<Product__c>();
				pdList = [Select 
										Id,
										SKU_No__c,
										Article_Code__c,
										Color__c,
										Description__c,
										RBU__c,
										Gender__c,
										Season__c,
										Original_Retail_Price__c,
										Std_Retail_Price__c,
										Discount_Rate__c
									From 
									 	Product__c];
			
			this.assignProductTops(pdList, '男', '服装', 10, this.selectedRegion, this.maleTotalSummary, this.maleTopSummary, this.maleAppList, this.selectedTopOption);
			this.assignProductTops(pdList, '女', '服装', 10, this.selectedRegion, this.femaleTotalSummary, this.femaleTopSummary, this.femaleAppList, this.selectedTopOption);
			this.assignProductTops(pdList, '无', '鞋', 20, this.selectedRegion, this.footwareTotalSummary, this.footwareTopSummary, this.footwareList, this.selectedTopOption);
			this.assignProductTops(pdList, '无', '包', 5, this.selectedRegion, this.bagTotalSummary, this.bagTopSummary, this.bagAccList, this.selectedTopOption);	
			this.assignProductTops(pdList, '无', '袜', 5, this.selectedRegion, this.sockTotalSummary, this.sockTopSummary, this.sockAccList, this.selectedTopOption);
		}
		
		this.assignPercent(this.maleTotalSummary, this.maleTopSummary, this.malePercent);
		this.assignPercent(this.femaleTotalSummary, this.femaleTopSummary, this.femalePercent);
		this.assignPercent(this.footwareTotalSummary, this.footwareTopSummary, this.footwarePercent);
		this.assignPercent(this.bagTotalSummary, this.bagTopSummary, this.bagPercent);
		this.assignPercent(this.sockTotalSummary, this.sockTopSummary, this.sockPercent);
	}
	
	// 给top10数据赋值以及统计Top10小计, 参数如下
	// gender: 性别
	// div: 类别和子类别
	// topNumber: 该类别的top数量,比如男女装10, 鞋20, 包袜5
	// region: 页面获取用户选择的区域
	// totalSummary: 所有小计
	// topSummary: Top10 小计
	// productTopList: 每个表中显示的top数据
	// topOption: 页面获取用户选择的销量最高或者销量最低
	public void assignProductTops(List<Product__c> productList, String gender, String div, Integer topNumber, String region,SummaryNumber totalSummary, SummaryNumber topSummary, List<ProductTop> productTopList, String topOption)
	{
		System.debug('进入assignProductTop>>>>>>>>');
		AggregateResult[] arTopList = new List<AggregateResult>();
		arTopList = this.queryTopList(gender, div, region, topOption);
		
		System.debug('arTopList的size>>>>>' + arTopList.size());
		
		AggregateResult[] arTotalList = new List<AggregateResult>();	
		arTotalList = this.queryTotalList(gender, div, region);
		
		System.debug('arTotalList的size>>>>>' + arTotalList.size());		
		System.debug('arTotalList的size>>>>>>>' + arTotalList[0].get('sa'));
		
		if(arTotalList.size() > 0)
		{
			totalSummary.amount = (Double)arTotalList[0].get('sa');
			totalSummary.unit = (Double)arTotalList[0].get('sq');
			totalSummary.gp = (Double)arTotalList[0].get('ga');
		}
		
		Integer topSize = arTopList.size();
		System.debug('TopSize>>>>>>>>>' + topSize);
		if(topSize > 0)
		{
			productTopList.clear();
			topSummary.amount = 0;
			topSummary.unit = 0;
			topSummary.gp = 0;
			
			Integer rank = 1;
			System.debug('统计TopList');
			for(AggregateResult ar : arTopList)
			{
				System.debug('arTopList sa >>>>>>' + ar.get('sa'));
				if(topSummary.amount == null)
				{
					topSummary.amount = (Double)ar.get('sa');
				}
				else
				{
					topSummary.amount += (Double) ar.get('sa');
				}
						
				System.debug('arTopList sq >>>>>>' + ar.get('sq'));
						
				if(topSummary.unit == null)
				{
					topSummary.unit = (Double)ar.get('sq');
				}
				else
				{
					topSummary.unit += (Double) ar.get('sq');
				}
						
				System.debug('arTopList ga >>>>>>' + ar.get('ga'));
				
				if(topSummary.gp == null)
				{
					topSummary.gp = (Double)ar.get('ga');
				}
				else
				{
					topSummary.gp += (Double)ar.get('ga');
				}
				
				ProductTop pt = new ProductTop();
				pt.salesAmount = (Double)ar.get('sa');
				pt.salesQuantity = (Double)ar.get('sq');
				pt.gpAmount = (Double)ar.get('ga');
				pt.ranking = rank;
				rank += 1;
						
				System.debug('productList>>>>' + this.productList.size());	
				
				for(Product__c p : productList)
				{
					System.debug('arProduct__c>>>>>>' + ar.get('SKU_No__c'));
					if(p.SKU_No__c == (String)ar.get('SKU_No__c'))
					{
						pt.articleCode = p.Article_Code__c;
						pt.color = p.Color__c;
						pt.description = p.Description__c;
						pt.discountRate = p.Discount_Rate__c;
						pt.gender = p.Gender__c;
						pt.originalPrice = p.Original_Retail_Price__c;
						pt.rbu = p.RBU__c;
						pt.season = p.Season__c;
						pt.standardPrice = p.Std_Retail_Price__c;
					}
				}
						
				productTopList.add(pt);
			}
				
			if(topSize < topNumber)
			{
				for(Integer i = 1; i< (topNumber- topSize + 2); i++)
				{
					productTopList.add(new ProductTop());
				}
			}
		}
		else
		{
			productTopList.clear();
			
			topSummary.amount = 0;
			topSummary.unit = 0;
			topSummary.gp = 0;
			
			for(Integer i = 0; i < topNumber; i++)
			{
				productTopList.add(new ProductTop());
			}
		}
	}
	
	// 查询出top10的小计
	public AggregateResult[] queryTopList(String gender, String div, String region, String topOption)
	{
		String param = '';
		if(gender == '男' && div == '服装')
		{
			param = '男';
		}
		
		if(gender == '女' && div == '服装')
		{
			param = '女';
		}
		
		if(div == '鞋')
		{
			param = '鞋';
		}
		
		if(div == '袜')
		{
			param = '袜';
		}
		
		if(div == '包')
		{
			param = '包';
		}
		
		AggregateResult[] arTopList = new List<AggregateResult>();
		if(topOption == '销量最高' && region == '全国')
		{
			if(param == '男')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
								Product__r.Gender__c = '男' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) desc limit 10];
			}
			
			if(param == '女')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
								Product__r.Gender__c = '女' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) desc limit 10];
			}
			
			if(param == '鞋')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Division__c LIKE '%鞋%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) desc limit 20];
			}
			
			if(param == '袜')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Cty_Division__c LIKE '%袜%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) desc limit 5];
			}
			
			if(param == '包')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Cty_Division__c LIKE '%包%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) desc limit 5];
			}
		}
		else if(topOption == '销量最高' && region != '全国')
		{
			if(param == '男')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
								Product__r.Gender__c = '男' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) desc limit 10];
			}
			
			if(param == '女')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
								Product__r.Gender__c = '女' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) desc limit 10];
			}
			
			if(param == '鞋')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Division__c LIKE '%鞋%'
							   And
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) desc limit 20];
			}
			
			if(param == '袜')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Cty_Division__c LIKE '%袜%'
							   And
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) desc limit 5];
			}
			
			if(param == '包')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Cty_Division__c LIKE '%包%'
							   And
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) desc limit 5];
			}
		}
		else if(topOption == '销量最低' && region == '全国')
		{
			if(param == '男')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
								Product__r.Gender__c = '男' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) asc limit 10];
			}
			
			if(param == '女')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
								Product__r.Gender__c = '女' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) asc limit 10];
			}
			
			if(param == '鞋')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Division__c LIKE '%鞋%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) asc limit 20];
			}
			
			if(param == '袜')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Cty_Division__c LIKE '%袜%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) asc limit 5];
			}
			
			if(param == '包')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Cty_Division__c LIKE '%包%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) asc limit 5];
			}
		}
		else if(topOption == '销量最低' && region != '全国')
		{
			if(param == '男')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
								Product__r.Gender__c = '男' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) asc limit 10];
			}
			
			if(param == '女')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
								Product__r.Gender__c = '女' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) asc limit 10];
			}
			
			if(param == '鞋')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Division__c LIKE '%鞋%'
							   And
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) asc limit 20];
			}
			
			if(param == '袜')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Cty_Division__c LIKE '%袜%'
							   And
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) asc limit 5];
			}
			
			if(param == '包')
			{
				arTopList = [Select 
								SKU_No__c,
								SUM(Sales_Amount__c) sa,
								SUM(Sales_Quantity__c) sq,
								SUM(GP_Amount__c) ga
							   From 
							   	Product_Top__c 
							   Where 
							   	Product__r.Cty_Division__c LIKE '%包%'
							   And
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c
							   Group by
							   	SKU_No__c
							   Order by
							   	SUM(Sales_Quantity__c) asc limit 5];
			}
		}
		return arTopList;
	}
	
	
	// 查询出所有的top数据
	public AggregateResult[] queryTotalList(String gender, String div, String region)
	{
		String param = '';
		if(gender == '男' && div == '服装')
		{
			param = '男';
		}
		
		if(gender == '女' && div == '服装')
		{
			param = '女';
		}
		
		if(div == '鞋')
		{
			param = '鞋';
		}
		
		if(div == '袜')
		{
			param = '袜';
		}
		
		if(div == '包')
		{
			param = '包';
		}
		
		AggregateResult[] arTotalList = new List<AggregateResult>();
		if(region == '全国')
		{
			if(param == '男')
			{
				arTotalList = [Select 
								SUM(Sales_Amount__c) sa, 
								SUM(Sales_Quantity__c) sq, 
								SUM(GP_Amount__c) ga
							   From 
								Product_Top__c
							   Where 
								Product__r.Gender__c = '男' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c];
			}
			
			if(param == '女')
			{
				arTotalList = [Select 
								SUM(Sales_Amount__c) sa, 
								SUM(Sales_Quantity__c) sq, 
								SUM(GP_Amount__c) ga
							   From 
								Product_Top__c
							   Where 
								Product__r.Gender__c = '女' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c];
			}
			
			if(param == '鞋')
			{
				arTotalList = [Select 
								SUM(Sales_Amount__c) sa, 
								SUM(Sales_Quantity__c) sq, 
								SUM(GP_Amount__c) ga
							   From 
								Product_Top__c
							   Where
							   	Product__r.Division__c LIKE '%鞋%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c];
			}
			
			if(param == '包')
			{
				arTotalList = [Select 
								SUM(Sales_Amount__c) sa, 
								SUM(Sales_Quantity__c) sq, 
								SUM(GP_Amount__c) ga
							   From 
								Product_Top__c
							   Where
							   	Product__r.Cty_Division__c LIKE '%包%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c];
			}
			
			if(param == '袜')
			{
				arTotalList = [Select 
								SUM(Sales_Amount__c) sa, 
								SUM(Sales_Quantity__c) sq, 
								SUM(GP_Amount__c) ga
							   From 
								Product_Top__c
							   Where 
							   	Product__r.Cty_Division__c LIKE '%袜%'
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c];
			}
		}
		else
		{
			if(param == '男')
			{
				arTotalList = [Select 
								SUM(Sales_Amount__c) sa, 
								SUM(Sales_Quantity__c) sq, 
								SUM(GP_Amount__c) ga
							   From 
								Product_Top__c
							   Where 
								Product__r.Gender__c = '男' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And 
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c];
			}
			
			if(param == '女')
			{
				arTotalList = [Select 
								SUM(Sales_Amount__c) sa, 
								SUM(Sales_Quantity__c) sq, 
								SUM(GP_Amount__c) ga
							   From 
								Product_Top__c
							   Where 
								Product__r.Gender__c = '女' 
							   And 
							   	Product__r.Division__c LIKE '%服%'
							   And 
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c];
			}
			
			if(param == '鞋')
			{
				arTotalList = [Select 
								SUM(Sales_Amount__c) sa, 
								SUM(Sales_Quantity__c) sq, 
								SUM(GP_Amount__c) ga
							   From 
								Product_Top__c
							   Where 
							   	Product__r.Division__c LIKE '%鞋%'
							   And 
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c];
			}
			
			if(param == '包')
			{
				arTotalList = [Select 
								SUM(Sales_Amount__c) sa, 
								SUM(Sales_Quantity__c) sq, 
								SUM(GP_Amount__c) ga
							   From 
								Product_Top__c
							   Where 
							   	Product__r.Cty_Division__c LIKE '%包%'
							   And 
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c];
			}
			
			if(param == '袜')
			{
				arTotalList = [Select 
								SUM(Sales_Amount__c) sa, 
								SUM(Sales_Quantity__c) sq, 
								SUM(GP_Amount__c) ga
							   From 
								Product_Top__c
							   Where 
							   	Product__r.Cty_Division__c LIKE '%袜%'
							   And 
							   	Store__r.Region__r.Name__c =: region
							   And
							    Date__r.Date__c >=: this.startDate.Date__c
							   And 
							   	Date__r.Date__c <=: this.endDate.Date__c];
			}
		}
		
		return arTotalList;
	}
	
	// 赋值Top10占比全部
	public void assignPercent(SummaryNumber totalSummary, SummaryNumber topSummary, SummaryPercent percent)
	{
		if(topSummary.amount != null  && totalSummary.amount != null && totalSummary.amount != 0)
		{
			percent.amount = Math.roundToLong((topSummary.amount/totalSummary.amount) * 100) + '%';
		}
		
		if(topSummary.unit != null && totalSummary.unit != null && totalSummary.unit != 0)
		{
			percent.unit = Math.roundToLong((topSummary.unit/totalSummary.unit) * 100) + '%';
		}
		
		if(topSummary.gp != null && totalSummary.gp != null && totalSummary.gp != 0)
		{
			percent.gp = Math.roundToLong((topSummary.gp/totalSummary.gp) * 100)+ '%';
		}
	}
}