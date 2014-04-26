/*
 * Author: Steven
 * Date: 2014-4-25
 * Description: 1.根据用户选择的日期运行ProductTopBatch, 2.根据用户选择的开始日期，结束日期，Top类型，区域，从Product_Top记录中查询出给定条件的Top的Product和
 */
public class GenerateTopNewController {
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
	

	public GenerateTopNewController()
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
		
		List<Product_Top__c> maleList = this.queryProductTop('男', '服装');
		List<ProductTop> candidateMaleList = this.generateProductTop(maleList, this.maleTotalSummary);
		this.maleAppList = this.sortProductTop(candidateMaleList, 10, this.maleTopSummary, this.selectedTopOption, '男');
		System.debug('attId>>>>>>' +  this.attId);
		this.assignPercent(this.maleTotalSummary, this.maleTopSummary, this.malePercent);
	
		List<Product_Top__c> femaleList = this.queryProductTop('女', '服装');
		List<ProductTop> candidateFemaleList = this.generateProductTop(femaleList, this.femaleTotalSummary);
		this.femaleAppList = this.sortProductTop(candidateFemaleList, 10, this.femaleTopSummary, this.selectedTopOption, '女');
		System.debug('femaleAttId>>>>' + this.femaleAttId);
		this.assignPercent(this.femaleTotalSummary, this.femaleTopSummary, this.femalePercent);
		
		List<Product_Top__c> footwareFwList = this.queryProductTop('无', '鞋');
		List<ProductTop> candidateFootwareList = this.generateProductTop(footwareFwList, this.footwareTotalSummary);
		this.footwareList = this.sortProductTop(candidateFootwareList, 20, this.footwareTopSummary, this.selectedTopOption, '鞋');
		System.debug('footwareAttId>>>>' + this.footAttId);
		this.assignPercent(this.footwareTotalSummary, this.footwareTopSummary, this.footwarePercent);
		
		List<Product_Top__c> bagList = this.queryProductTop('无', '包');
		List<ProductTop> candidateBagList = this.generateProductTop(bagList, this.bagTotalSummary);
		this.bagAccList = this.sortProductTop(candidateBagList, 5, this.bagTopSummary, this.selectedTopOption, '包');
		System.debug('bagAttId>>>>>' + this.bagAttId);
		this.assignPercent(this.bagTotalSummary, this.bagTopSummary, this.bagPercent);
		
		List<Product_Top__c> sockList = this.queryProductTop('无', '袜');
		List<ProductTop> candidateSockList = this.generateProductTop(sockList, this.sockTotalSummary);
		this.sockAccList = this.sortProductTop(candidateSockList, 5, this.sockTopSummary,this.selectedTopOption, '袜');
		System.debug('sockAttId' + this.sockAttId);
		this.assignPercent(this.sockTotalSummary, this.sockTopSummary, this.sockPercent);
	}
	
	// 查询出Product Top
	// gender: 性别, 服装的时候区分男女，其余为无
	// div: 类别, 鞋,包,袜
	public List<Product_Top__c> queryProductTop(String gender, String div)
	{
		List<Product_Top__c> ptList = new List<Product_Top__c>();
		if(this.selectedRegion == '全国')
		{
			if(gender == '男' || gender == '女')
			{
				ptList = [Select 
					Id,
					Sales_Amount__c,
					Sales_Quantity__c,
					GP_Amount__c,
					Product__c,
					Product__r.Article_Code__c,
					Product__r.Color__c,
					Product__r.Description__c,
					Product__r.RBU__c,
					Product__r.Gender__c,
					Product__r.Season__c,
					Product__r.Original_Retail_Price__c,
					Product__r.Std_Retail_Price__c,
					Product__r.Discount_Rate__c 
				  From 
				  	Product_Top__c 
				  Where 
				  	Date__r.Date__c >=: this.startDate.Date__c 
				  And 
				  	Date__r.Date__c <=: this.endDate.Date__c
				  And 
				  	Product__r.Gender__c =: gender
				  And
				  	Product__r.Division__c LIKE '%服%'];
			}
			else if(div == '鞋')
			{
				ptList = [Select 
					Id,
					Sales_Amount__c,
					Sales_Quantity__c,
					GP_Amount__c,
					Product__c,
					Product__r.Article_Code__c,
					Product__r.Color__c,
					Product__r.Description__c,
					Product__r.RBU__c,
					Product__r.Gender__c,
					Product__r.Season__c,
					Product__r.Original_Retail_Price__c,
					Product__r.Std_Retail_Price__c,
					Product__r.Discount_Rate__c 
				  From 
				  	Product_Top__c 
				  Where 
				  	Date__r.Date__c >=: this.startDate.Date__c
				  And 
				  	Date__r.Date__c <=: this.endDate.Date__c
				  And
				  	Product__r.Division__c LIKE '%鞋%'];
			}
			else if(div == '袜')
			{
				ptList = [Select 
					Id,
					Sales_Amount__c,
					Sales_Quantity__c,
					GP_Amount__c,
					Product__c,
					Product__r.Article_Code__c,
					Product__r.Color__c,
					Product__r.Description__c,
					Product__r.RBU__c,
					Product__r.Gender__c,
					Product__r.Season__c,
					Product__r.Original_Retail_Price__c,
					Product__r.Std_Retail_Price__c,
					Product__r.Discount_Rate__c 
				  From 
				  	Product_Top__c 
				  Where 
				  	Date__r.Date__c >=: this.startDate.Date__c 
				  And 
				  	Date__r.Date__c <=: this.endDate.Date__c
				  And
				  	Product__r.Cty_Division__c LIKE '%袜%'
				  ];
			}
			else if(div == '包')
			{
				ptList = [Select 
					Id,
					Sales_Amount__c,
					Sales_Quantity__c,
					GP_Amount__c,
					Product__c,
					Product__r.Article_Code__c,
					Product__r.Color__c,
					Product__r.Description__c,
					Product__r.RBU__c,
					Product__r.Gender__c,
					Product__r.Season__c,
					Product__r.Original_Retail_Price__c,
					Product__r.Std_Retail_Price__c,
					Product__r.Discount_Rate__c 
				  From 
				  	Product_Top__c 
				  Where 
				  	Date__r.Date__c >=: this.startDate.Date__c 
				  And 
				  	Date__r.Date__c <=: this.endDate.Date__c
				  And
				  	Product__r.Cty_Division__c LIKE '%包%'];
			}
		}
		else
		{
			if(gender == '男' || gender == '女')
			{
				ptList = [Select 
					Id,
					Sales_Amount__c,
					Sales_Quantity__c,
					GP_Amount__c,
					Product__c,
					Product__r.Article_Code__c,
					Product__r.Color__c,
					Product__r.Description__c,
					Product__r.RBU__c,
					Product__r.Gender__c,
					Product__r.Season__c,
					Product__r.Original_Retail_Price__c,
					Product__r.Std_Retail_Price__c,
					Product__r.Discount_Rate__c 
				  From 
				  	Product_Top__c 
				  Where 
				  	Date__r.Date__c >=: this.startDate.Date__c 
				  And 
				  	Date__r.Date__c <=: this.endDate.Date__c
				  And
				  	Store__r.Region__r.Name =: this.selectedRegion
				  And 
				  	Product__r.Gender__c =: gender
				  And
				  	Product__r.Division__c LIKE '%服%'];
			}
			else if(div == '鞋')
			{
				ptList = [Select 
					Id,
					Sales_Amount__c,
					Sales_Quantity__c,
					GP_Amount__c,
					Product__c,
					Product__r.Article_Code__c,
					Product__r.Color__c,
					Product__r.Description__c,
					Product__r.RBU__c,
					Product__r.Gender__c,
					Product__r.Season__c,
					Product__r.Original_Retail_Price__c,
					Product__r.Std_Retail_Price__c,
					Product__r.Discount_Rate__c 
				  From 
				  	Product_Top__c 
				  Where 
				  	Date__r.Date__c >=: this.startDate.Date__c 
				  And 
				  	Date__r.Date__c <=: this.endDate.Date__c
				  And
				  	Store__r.Region__r.Name =: this.selectedRegion
				  And
				  	Product__r.Division__c =: div];
			}
			else if(div == '袜')
			{
				ptList = [Select 
					Id,
					Sales_Amount__c,
					Sales_Quantity__c,
					GP_Amount__c,
					Product__c,
					Product__r.Article_Code__c,
					Product__r.Color__c,
					Product__r.Description__c,
					Product__r.RBU__c,
					Product__r.Gender__c,
					Product__r.Season__c,
					Product__r.Original_Retail_Price__c,
					Product__r.Std_Retail_Price__c,
					Product__r.Discount_Rate__c 
				  From 
				  	Product_Top__c 
				  Where 
				  	Date__r.Date__c >=: this.startDate.Date__c 
				  And 
				  	Date__r.Date__c <=: this.endDate.Date__c
				  And
				  	Store__r.Region__r.Name =: this.selectedRegion
				  And
				  	Product__r.Cty_Division__c LIKE '%袜%'
				  ];
			}
			else if(div == '包')
			{
				ptList = [Select 
					Id,
					Sales_Amount__c,
					Sales_Quantity__c,
					GP_Amount__c,
					Product__c,
					Product__r.Article_Code__c,
					Product__r.Color__c,
					Product__r.Description__c,
					Product__r.RBU__c,
					Product__r.Gender__c,
					Product__r.Season__c,
					Product__r.Original_Retail_Price__c,
					Product__r.Std_Retail_Price__c,
					Product__r.Discount_Rate__c 
				  From 
				  	Product_Top__c 
				  Where 
				  	Date__r.Date__c >=: this.startDate.Date__c 
				  And 
				  	Date__r.Date__c <=: this.endDate.Date__c
				  And
				  	Store__r.Region__r.Name =: this.selectedRegion
				  And
				  	Product__r.Cty_Division__c LIKE '%包%'];
			}
		}
		
		return ptList;
	}
	
	// 生成所有Product Top, 及给totalSummary赋值
	// productTopList: 查询出来的所有Product_Top__c的list
	// totalSummary: 要赋值的 Total Summary
	public List<ProductTop> generateProductTop(List<Product_Top__c> productTopList, SummaryNumber totalSummary)
	{
		Map<String,ProductTop> productMap = new Map<String,ProductTop>();
		for(Product_Top__c p : productTopList)
		{
			ProductTop pt = new ProductTop();
			// 查看是否存在于productMap中，存在的话取出
			// 不存在的话新建
			if(productMap.get(p.Product__c) != null)
			{
				pt = productMap.get(p.Product__c);
			}
			else
			{
				pt.articleCode = p.Product__r.Article_Code__c;
				pt.color = p.Product__r.Color__c;
				pt.description = p.Product__r.Description__c;
				pt.rbu = p.Product__r.RBU__c;
				pt.gender = p.Product__r.Gender__c;
				pt.discountRate = p.Product__r.Discount_Rate__c;
				pt.originalPrice = p.Product__r.Original_Retail_Price__c;
				pt.season = p.Product__r.Season__c;
				pt.standardPrice = p.Product__r.Std_Retail_Price__c;
			}
			
			if(pt.gpAmount == null)
			{
				pt.gpAmount = p.GP_Amount__c;
			}
			else
			{
				pt.gpAmount += p.GP_Amount__c;
			}
			
			if(pt.salesAmount == null)
			{
				pt.salesAmount = p.Sales_Amount__c;
			}
			else
			{
				pt.salesAmount += p.Sales_Amount__c;
			}
			
			if(pt.salesQuantity == null)
			{
				pt.salesQuantity = p.Sales_Quantity__c;
			}
			else
			{
				pt.salesQuantity += p.Sales_Quantity__c;
			}
			
			productMap.put(p.Product__c, pt);
			
			// 给Total Summary赋值
			if(totalSummary.gp == null)
			{
				totalSummary.gp = p.GP_Amount__c;
			}
			else
			{
				totalSummary.gp += p.GP_Amount__c;
			}
			
			if(totalSummary.amount == null)
			{
				totalSummary.amount = p.Sales_Amount__c;
			}
			else
			{
				totalSummary.amount += p.Sales_Amount__c;
			}
			
			if(totalSummary.unit == null)
			{
				totalSummary.unit = p.Sales_Quantity__c;
			}
			else
			{
				totalSummary.unit += p.Sales_Quantity__c;
			}
		}
		
		return productMap.values();
	}
	
	// 对生成的ProductTop排序 按销量最高和最低，取前几个，并给Top Summary赋值
	// productTopList: 待排序的ProductTop
	// topSize: 服装为10，鞋为20，配件为5
	// topSummary: 要赋值的Top Summary
	// sortType: 销量最高，销量最低
	// attType: 图片附件参数，未来要修改去掉
	public List<ProductTop> sortProductTop(List<ProductTop> productTopList, Integer topSize, SummaryNumber topSummary, String sortType, String attType)
	{
		List<ProductTop> topList = new List<ProductTop>();
		
		Integer listSize = 0;
		if(productTopList == null || productTopList.size() == 0)
		{
			return null;
		}
		else
		{
			listSize = productTopList.size();
		}
		
		ProductTop tmp = new ProductTop();
		
		if(sortType == '销量最高')
		{
			for(Integer i = 0; i < listSize;i++)
			{
				for(Integer j = (listSize - 1); j>= (i+1);j--)
				{
					if(productTopList[j-1].salesQuantity < productTopList[j].salesQuantity)
					{
						tmp = productTopList[j-1];
						productTopList[j-1] = productTopList[j];
						productTopList[j] = tmp;
					}
					else if(productTopList[j-1].salesQuantity == productTopList[j].salesQuantity)
					{
						if(productTopList[j-1].salesAmount < productTopList[j].salesAmount)
						{
							tmp = productTopList[j-1];
							productTopList[j-1] = productTopList[j];
							productTopList[j] = tmp;
						}
					}
				}
			}
		}
		else
		{
			for(Integer i = 0; i < listSize;i++)
			{
				for(Integer j = (listSize - 1); j>= (i+1);j--)
				{
					if(productTopList[j-1].salesQuantity > productTopList[j].salesQuantity)
					{
						tmp = productTopList[j-1];
						productTopList[j-1] = productTopList[j];
						productTopList[j] = tmp;
					}
					else if(productTopList[j-1].salesQuantity == productTopList[j].salesQuantity)
					{
						if(productTopList[j-1].salesAmount > productTopList[j].salesAmount)
						{
							tmp = productTopList[j-1];
							productTopList[j-1] = productTopList[j];
							productTopList[j] = tmp;
						}
					}
				}
			}
		}
		
		Integer delimit = Math.min(topSize,listSize);
		for(Integer i = 0; i < delimit; i++)
		{
			ProductTop pt = productTopList[i];
			pt.ranking = i + 1;
			topList.add(pt);
			
			// 给topSummary赋值
			if(topSummary.amount == null)
			{
				topSummary.amount = pt.salesAmount;
			}
			else
			{
				topSummary.amount += pt.salesAmount;
			}
			
			if(topSummary.gp == null)
			{
				topSummary.gp = pt.gpAmount;
			}
			else
			{
				topSummary.gp += pt.gpAmount;
			}
			
			if(topSummary.unit == null)
			{
				topSummary.unit = pt.salesQuantity;
			}
			else
			{
				topSummary.unit += pt.salesQuantity;
			}
		}
		
		System.debug('>>>>topSummary' + topSummary.amount);
		System.debug('>>>>>topListSize' + topList.size());
		
		if(topList.size() > 0)
		{
			if(attType == '男')
			{
				this.attId = '00P90000008ch0A';
			}
			
			if(attType == '女')
			{
				this.femaleAttId = '00P90000008ch0A';
			}
			
			if(attType == '鞋')
			{
				this.footAttId = '00P90000008ch0A';
			}
			
			if(attType == '袜')
			{
				this.sockAttId = '00P90000008ch0A';
			}
			
			if(attType == '包')
			{
				this.bagAttId = '00P90000008ch0A';
			}
		}
		
		if(listSize < topSize)
		{
			for(Integer i = 0; i < (topSize - listSize);i++)
			{
				ProductTop pt = new ProductTop();
				topList.add(pt);
			}
		}
		
		return topList;
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