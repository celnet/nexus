/**
*Author：Dean
*Date：2013-11-5
*功能：从医院基础表中获取信息，以医院为单位汇总病人数据统计表
*	   以医院为单位统计下属病人转竞品信息
**/
global class PM_PatientDataStatisticsBatch implements Database.Batchable<sObject>{
	private string year;
	private string month;
	public Date NOW_Date;
	global Database.QueryLocator start(Database.BatchableContext BC)
	{ 
        return Database.getQueryLocator([Select Id From Account where RecordType.DeveloperName = 'RecordType']);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	/**************bill 2013-11-20 start*******************/
    	if(NOW_Date == null)
    	{
    		NOW_Date = date.today();
    	}
    	year = string.valueOf(NOW_Date.year());
    	month = string.valueOf(NOW_Date.month());
    	/**************bill 2013-11-20 end  *******************/
    	set<Id> HospitalId = new set<Id>();
    	for(sObject sObj : scope)
        {
            HospitalId.add(((Account)sObj).Id);
        }
        map<string,list<PM_Patient__c>> map_HosPm = new map<string,list<PM_Patient__c>>();
        for(PM_Patient__c pm  : [Select PM_DropOut_Two_Reason__c,PM_TransformBrand__c,PM_InHospital__c,Id,Name, PM_Status__c,PM_TransfornDropout_Date__c,PM_TransfornCreateDate__c,PM_Distributor__c,PM_DropoutActualDate__c,PM_PreviousStatus__c,PM_NewPatientDate__c,PM_DropoutCreated_Date__c,PM_UnreachableDate__c,PM_DropOut_One_Reason__c,PM_InDate__c,PM_TransfornCreated_Date__c, PM_Payment__c, PM_Delivery__c From PM_Patient__c Where PM_InHospital__c IN:HospitalId])
        {
        	if(map_HosPm.containsKey(pm.PM_InHospital__c))
        	{
        		list<PM_Patient__c> list_pm = map_HosPm.get(pm.PM_InHospital__c);
        		list_pm.add(pm);
        		map_HosPm.put(pm.PM_InHospital__c,list_pm);
        	}
        	else
        	{
        		list<PM_Patient__c> list_pm = new list<PM_Patient__c>();
        		list_pm.add(pm);
        		map_HosPm.put(pm.PM_InHospital__c,list_pm);
        	}
        }
    	//更新病人数据统计表使用的Map
    	Map<String,PM_IntermediateTable__c> mappme_IntermediateTable = new Map<String,PM_IntermediateTable__c>();
    	/*******************bill update 2013-11-21*********************/
    	//获取医院基础表中的本年信息
    	integer NOW_Year = NOW_Date.year();
    	//获取医院基础表中本月的信息
    	integer NOW_Month = NOW_Date.month();
    	/*******************bill update 2013-11-21*********************/
    	//储存上年月新病人数的外键
    	String LYNewPatientU = null;
    	//储存上年月存活人数的外键
    	String LYSurviving = null;
    	//储存上年月掉队病人数的外键
    	String LYDropOut = null;
    	//储存上月存活病人数的外键
    	String LMSurviving = null;
    	//储存现存病人数的外键
    	String NowSurviving = null;
    	//储存获取MTD的外键
    	String MTD = null;
    	//用于获取前几个月的数据(年)
    	integer Yearnum = 0;
    	//用于获取前几个月的数据(月)
    	integer Monthnum = 0;
    	//用于获取前几个月的数据(控制获取次数)
    	integer Daysnum = 0;
    	//未知竞品品牌
    	double UnknowPD = 0;
    	double UnknowBrand = 0;
    	//其他竞品品牌
    	double OtherPD = 0;
    	//从医院基础表中存储新病人数量
		Map<String,double> UniNewPatient = new Map<String,double>();
		//从医院基础表中存储存活病人数量
		Map<String,double> UniSurviving = new Map<String,double>();
		//从医院基础表中存掉队活病人数量
		Map<String,double> UniDropout = new Map<String,double>();
		//从医院基础表实际掉队病人数量
		Map<String,double> map_ActDropout = new Map<String,double>();
		//从医院基础表中存储MAT转竞争品牌病人数量
		Map<String,double> MATTransforn = new Map<String,double>();
		//从医院基础表中存储MAT腹透持续时间
		Map<String,double> MATTOT = new Map<String,double>();
		//从医院基础表中存储百特MAT腹透持续时间
		Map<String,double> MATBaxterTOT = new Map<String,double>();		
		Map<String,double> Transforn = new Map<String,double>();
		Map<String,double> TranfirmParient = new Map<String,double>();
		//更新转竞品中间表Map
		Map<String,PM_TurnBrand__c> TurnBrandMap = new Map<String,PM_TurnBrand__c>();
		//存储医院下病人List
		//List<PM_Patient__c> PatientList = new List<PM_Patient__c>();
		//存储医院Id的List
		List<String> set_HospitalID = new List<String>();
		//存储对应医院下病人Map
		Map<String,List<PM_Patient__c>> HospitalAndPatient = new Map<String,List<PM_Patient__c>>();
    	//存储竞争品牌数据
    
    	Map<String,double> PcakListDrop = new Map<String,double>();
    	//获取竞品品牌
    	Schema.DescribeFieldResult TransformList = PM_Patient__c.PM_TransformBrand__c.getDescribe();
		List<Schema.PicklistEntry> ListTransform = TransformList.getPicklistValues();
    	
    	//获取转竞品原因
    	Schema.DescribeFieldResult DropTwo = PM_TurnBrand__c.PM_DropOut_Two_Reason__c.getDescribe();
		List<Schema.PicklistEntry> ListDropTwo = DropTwo.getPicklistValues();
    	
    	
		/************************获得要汇总的医院Id及其病人信息**************************/
    	for(sObject sObj : scope)
		{ 
			//PatientList.clear();
    		Account HospitalB = (Account)sObj;
    		/**************************TObe 2013.11.20 start********************************/
            list<PM_Patient__c> list_pm = new list<PM_Patient__c>();
            if(map_HosPm.containsKey(HospitalB.Id))
            {
            	list_pm = map_HosPm.get(HospitalB.Id);
            }
            /**************************TObe 2013.11.20 end********************************/
			if(list_pm != null && list_pm.size()>0)
			{
				system.debug('这家医院存在病人');
				set_HospitalID.add(HospitalB.Id);
				HospitalAndPatient.put(HospitalB.Id,list_pm);
			}
		}
		/*******************BILL 2013-12-11 ADD******************************/
		map<ID,ID> map_salehos = searchHospatilSale(set_HospitalID);
		/*******************BILL 2013-12-11 ADD******************************/
		
		/*******************BILL 2013-12-17 ADD******************************/
		//获取医院的月份的新病人和存活病人目标值
		map<ID,YearMonthTarget> map_hosPlan = searchHospatilPlan(set_HospitalID);
		/*******************BILL 2013-12-17 ADD******************************/
		
		/************************获得要汇总的医院Id及其病人信息**************************/
		/************************获得要汇总的对应医院的医院基本信息**************************/
		//从医院基础表中获得对应医院的病人数据
		for(PM_HospitalBasie__c HospitalB : [Select p.PM_ActDropOut__c,p.PM_YearMonth__c, p.PM_YearMonth_Formula__c,
    	 p.PM_Surviving__c, p.PM_NewPatient__c, p.PM_Hospital__c, p.PM_TransfornDropOut__c,
    	 p.PM_TOTMonths__c ,p.PM_BaxterTOTMonths__c, p.PM_UniquelyId__c ,p.PM_Dropout__c ,p.PM_Transforn__c,p.PM_TranfirmParient__c From 
    	 PM_HospitalBasie__c p where p.PM_Hospital__c in: set_HospitalID And p.PM_YearMonth__c >= : NOW_Date.addmonths(-24)])
    	 {
    	 	UniNewPatient.put(HospitalB.PM_UniquelyId__c,HospitalB.PM_NewPatient__c);
			UniSurviving.put(HospitalB.PM_UniquelyId__c,HospitalB.PM_Surviving__c);
			UniDropout.put(HospitalB.PM_UniquelyId__c,HospitalB.PM_Dropout__c);
			//BIll 添加
			map_ActDropout.put(HospitalB.PM_UniquelyId__c,HospitalB.PM_ActDropOut__c);
			MATTransforn.put(HospitalB.PM_UniquelyId__c,HospitalB.PM_TransfornDropOut__c);
			MATTOT.put(HospitalB.PM_UniquelyId__c,HospitalB.PM_TOTMonths__c);
			MATBaxterTOT.put(HospitalB.PM_UniquelyId__c,HospitalB.PM_BaxterTOTMonths__c);
			Transforn.put(HospitalB.PM_UniquelyId__c , HospitalB.PM_Transforn__c);
			TranfirmParient.put(HospitalB.PM_UniquelyId__c , HospitalB.PM_TranfirmParient__c);
    	 }
		/************************获得要汇总的对应医院的医院基本信息**************************/
		/************************开始汇总医院基础信息以及转竞品信息**************************/   	 
    	 for(String HosID : set_HospitalID)
    	 {
			//获得“医院基础表”LYNewPatient中对应的数据外键
    	 	LYNewPatientU = HosID + String.valueOf(NOW_Date.addYears(-1).year())+ String.valueOf(NOW_Date.addYears(-1).month());
    	 	//获得“医院基础表”中LYSurviving对应的数据外键
    	 	LYSurviving = HosID + String.valueOf(NOW_Date.addYears(-1).year()) + '12';
    	 	//获得“医院基础表”中LYDropOut对应的数据外键
    	 	LYDropOut = HosID + String.valueOf(NOW_Date.addYears(-1).year())+ String.valueOf(NOW_Date.addYears(-1).month());
    	 	//获得“医院基础表”中LMSurviving对应的数据外键
    	 	LMSurviving = HosID + String.valueOf(NOW_Date.addMonths(-1).year())+ String.valueOf(NOW_Date.addMonths(-1).month());
    	 	//获得“医院基础表”中NowSurviving对应的数据外键
    	 	NowSurviving = HosID + String.valueOf(NOW_Date.year())+ String.valueOf(NOW_Date.month()); 
    	 	//获得“医院基础表”中对应的数据外键
    	 	MTD = HosID + String.valueOf(NOW_Date.year())+ String.valueOf(NOW_Date.month());
 			//新建要更新的病人数据统计信息
    	 	PM_IntermediateTable__c Interme = new PM_IntermediateTable__c();
    	 	Interme.PM_UniquelyId__c = String.valueOf(HosID) + String.valueOf(NOW_Year) + String.valueOf(NOW_Month);
    	 	Interme.PM_Date__c = NOW_Date;
    	 	Interme.PM_HospitalID__c = HosID;
    	 	Interme.PM_YearMonth__c = String.valueOf(NOW_Date.year())+String.valueOf(NOW_Date.month());
    	 	/*******************BILL 2013-12-17 update******************************/
    	 	//当前月份负责销售
    	 	Interme.PM_Saler__c = map_salehos.get(HosID);
    	 	//2014-1-17 Sunny : 若当月负责销售不为空，则设置病人数据统计数据的所有人为当月销售
    	 	if(Interme.PM_Saler__c != null) Interme.OwnerId = Interme.PM_Saler__c;
    	 	//--
    	 	Interme.PM_NewPatientTarget__c = 0;
    	 	Interme.PM_SurivingTarget__c = 0;
    	 	if(map_hosPlan.containsKey(HosID))
    	 	{
    	 		//当月的新病人目标
    	 		Interme.PM_NewPatientTarget__c = map_hosPlan.get(HosID).NewTarget==0?0:map_hosPlan.get(HosID).NewTarget;
    	 		//当月的存活病人目标
    	 		Interme.PM_SurivingTarget__c = map_hosPlan.get(HosID).SurivingTarget==0?0:map_hosPlan.get(HosID).SurivingTarget;
    	 	}
    	 	/********************BILL 2013-12-17 update*****************************/
    	 	//获取上年新病人数
    	 	if(UniNewPatient.get(LYNewPatientU) != null)
    	 	Interme.PM_LYNewPatient__c = UniNewPatient.get(LYNewPatientU);
    	 	else
    	 	Interme.PM_LYNewPatient__c = 0;
    	 	//获取上年存活病人数
    	 	if(UniSurviving.get(LYSurviving) != null)
    	 	Interme.PM_LYSurviving__c = UniSurviving.get(LYSurviving);
    	 	else
    	 	Interme.PM_LYSurviving__c = 0;
    	 	
    	 	if(UniSurviving.get(LYNewPatientU) != null)
    	 	Interme.PM_LYMSurviving__c = UniSurviving.get(LYNewPatientU);
    	 	else 
    	 	Interme.PM_LYMSurviving__c = 0;
    	 	
    	 	//获取上年月DropOut病人数
    	 	if(UniDropout.get(LYDropOut) != null)
    	 	Interme.PM_LYDropOut__c = UniDropout.get(LYDropOut);
    	 	else
    	 	Interme.PM_LYDropOut__c = 0;
    	 	//获取上年月存活病人数
    	 	if(UniSurviving.get(LMSurviving) != null)
    	 	Interme.PM_LMSurviving__c = UniSurviving.get(LMSurviving);
    	 	else
    	 	Interme.PM_LMSurviving__c = 0;
    	 	//现存病人数
    	 	if(UniSurviving.get(NowSurviving) != null)
    	 	Interme.PM_NowSurviving__c = UniSurviving.get(NowSurviving);
    	 	else
    	 	Interme.PM_NowSurviving__c = 0;
    	 	//MTD新病人数
    	 	if(UniNewPatient.get(MTD) != null)
    	 	Interme.PM_MTDSurviving__c = UniNewPatient.get(MTD);
    	 	else
    	 	Interme.PM_MTDSurviving__c = 0;
    	 	//MTDDropOut病人数
    	 	if(UniDropout.get(MTD) != null)
    	 	Interme.PM_MTDDropOut__c = UniDropout.get(MTD);
    	 	else
    	 	Interme.PM_MTDDropOut__c = 0;
    	 	//MTD掉队病人数
    	 	if(Transforn.get(MTD) != null)
    	 	Interme.PM_MTDTransforn__c = Transforn.get(MTD);
    	 	else
    	 	Interme.PM_MTDTransforn__c = 0;
    	 	
    	 	//本年信息计算参数
    	 	Daysnum = 1;
    	 	//YTD存活病人数
    	 	Interme.PM_YTDSurviving__c = 0;
    	 	//YTDDropOut病人数
    	 	Interme.PM_YTDDropOut__c = 0;
    	 	//YTD退出病人数
    	 	Interme.PM_YTDTransforn__c = 0;
    	 	//实际掉队人数
    	 	Interme.PM_MATActDropOut__c = 0;
    	 	
    	 	//汇总本年信息
    	 	do
    	 	{	
    	 		System.debug('进入循环******##########'+NowSurviving+'###############');
    	 		//循环获取YTD本年信息相加 
    	 		Daysnum = Daysnum - 1;
    	 		Yearnum = NOW_Date.addmonths(Daysnum).year();
    	 		Monthnum = NOW_Date.addmonths(Daysnum).month();
    	 		if(Yearnum <= NOW_Date.addYears(-1).year())
    	 		{
    	 			break;
    	 		}
    	 		System.debug('持续******#####YTD######'+HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)+'##############');
    	 		//循环获取YTD新病人数本年信息相加,举例说明当前时间2013-10-15，LYD指的是从2013-1-1到2013-10-15
    	 		if(UniNewPatient.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum))!= null)
    	 		Interme.PM_YTDSurviving__c = Interme.PM_YTDSurviving__c + UniNewPatient.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 		//循环获取YTD掉队病人数本年信息相加，举例说明当前时间2013-10-15，LYD指的是从2013-1-1到2013-10-15
    	 		if(UniDropout.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_YTDDropOut__c = Interme.PM_YTDDropOut__c + UniDropout.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 		//循环获取YTD转归病人数本年信息相加，举例说明当前时间2013-10-15，LYD指的是从2013-1-1到2013-10-15
    	 		if(Transforn.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_YTDTransforn__c = Interme.PM_YTDTransforn__c + Transforn.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 	}while(true);
    	 	
    	 	
    	 	//去年LYD的年份数据
    	 	do
    	 	{	
    	 		//循环获取LYTD本年信息相加 
    	 		Daysnum = Daysnum - 1;
    	 		Yearnum = NOW_Date.addmonths(Daysnum).year()-1;
    	 		Monthnum = NOW_Date.addmonths(Daysnum).month();
    	 		if(Yearnum <= NOW_Date.addYears(-2).year())
    	 		{
    	 			break;
    	 		}
    	 		//循环获取LYTD新病人数本年信息相加，举例说明当前时间2013-10-15，LYD指的是从2012-1-1到2012-10-31
    	 		if(UniNewPatient.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum))!= null)
    	 		Interme.PM_LYTDNewPatient__c = Interme.PM_LYTDNewPatient__c + UniNewPatient.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 		//循环获取LYTD掉队病人数本年信息相加，举例说明当前时间2013-10-15，LYD指的是从2012-1-1到2012-10-31
    	 		if(UniDropout.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_LYTDDropOut__c = Interme.PM_LYTDDropOut__c + UniDropout.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 		//循环获取LYTD转归病人数本年信息相加，举例说明当前时间2013-10-15，LYD指的是从2012-1-1到2012-10-31
    	 		if(Transforn.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_LYTDTransforn__c = Interme.PM_LYTDTransforn__c + Transforn.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 	}while(true);

    	 	Interme.PM_MATSurviving__c = 0;
    	 	Interme.PM_MATDropOut__c = 0;
    	 	Interme.PM_MATTransfornDropOut__c = 0;
    	 	Interme.PM_MATTOTMonths__c = 0;
    	 	Interme.PM_MATBaxterTOTMonths__c = 0;
    	 	Interme.PM_MATTransforn__c = 0;
    	 	Interme.PM_MATTranfirmParient__c = 0;
    	 	Daysnum = 1; 
    	 	//汇总滚动月份信息 	 	
    	 	do
    	 	{	
    	 		//循环获取滚动月份MAT本年信息相加 
    	 		System.debug('进入循环******##########'+NowSurviving+'###############');
    	 		Daysnum = Daysnum - 1;
    	 		Yearnum = NOW_Date.addmonths(Daysnum).year();
    	 		Monthnum = NOW_Date.addmonths(Daysnum).month();
    	 		
    	 		if(NOW_Date.addYears(-1) == NOW_Date.addmonths(Daysnum))
    	 		{
    	 			break; 
    	 		} 
    	 		System.debug('持续******#######MAT####'+HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)+'##############');
    	 		//循环获取滚动月份MAT新病人数信息相加 
    	 		if(UniNewPatient.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_MATSurviving__c = Interme.PM_MATSurviving__c + UniNewPatient.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 		//循环获取滚动月份MATDropOut病人数本年信息相加 
    	 		if(UniDropout.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_MATDropOut__c = Interme.PM_MATDropOut__c + UniDropout.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 		//map_ActDropout循环获取滚动月份MATActDropOut病人数本年信息相加   实际掉队病人数
    	 		if(map_ActDropout.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_MATActDropOut__c = Interme.PM_MATActDropOut__c + map_ActDropout.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 		//循环获取滚动月份MAT转归病人数本年信息相加 
    	 		if(MATTransforn.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_MATTransfornDropOut__c = Interme.PM_MATTransfornDropOut__c + MATTransforn.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 		//循环获取滚动月份MATTOT持续腹透时间本年信息相加 
    	 		if(MATTOT.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_MATTOTMonths__c = Interme.PM_MATTOTMonths__c + MATTOT.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 		//循环获取滚动月份MATBaxterTOT持续腹透时间本年信息相加
    	 		/**********************Bill update 2013-11-21*************************/ 
    	 		if(MATBaxterTOT.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_MATBaxterTOTMonths__c = Interme.PM_MATBaxterTOTMonths__c + MATBaxterTOT.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 		/**********************Bill update 2013-11-21*************************/ 
    	 		//循环获取滚动月份MAT对不病人数本年信息相加 
    	 		if(Transforn.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_MATTransforn__c = Interme.PM_MATTransforn__c + Transforn.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 		//循环获取滚动月份MAT转竞品掉队病人数本年信息相加 
    	 		if(TranfirmParient.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum)) != null)
    	 		Interme.PM_MATTranfirmParient__c = Interme.PM_MATTranfirmParient__c + TranfirmParient.get(HosID + String.valueOf(Yearnum)+ String.valueOf(Monthnum));
    	 	}while(true);
    	 	mappme_IntermediateTable.put(String.valueOf(Interme.PM_UniquelyId__c),Interme);
    	 	UnknowPD = 0;
    	 	OtherPD = 0;
    	 	UnknowBrand = 0;
    	 	PcakListDrop.clear();
			/**********************************获得转竞品品牌信息******************************************/
    	 	for(PM_Patient__c PMPatient : HospitalAndPatient.get(HosID))
    	 	{
    	 		if(PMPatient.PM_DropOut_One_Reason__c == '转用竞争产品')
    	 		{
    	 			//病人转竞品品牌动为空时
	    	 		if(String.valueOf(PMPatient.PM_TransformBrand__c) == null || String.valueOf(PMPatient.PM_TransformBrand__c) == '')
	    	 		{
	    	 				//病人转竞品原因为空时
	    	 				if(String.valueOf(PMPatient.PM_DropOut_Two_Reason__c) == null || String.valueOf(PMPatient.PM_DropOut_Two_Reason__c) == '')
	    	 				UnknowPD++;
	    	 		}
	    	 		for(Schema.PicklistEntry TransformP : ListTransform)
	    	 		{
	    	 			for(Schema.PicklistEntry DropTwoformP : ListDropTwo)
	    	 			{	
	    	 				//病人转竞品品牌不为空时
	    	 				if(String.valueOf(PMPatient.PM_TransformBrand__c) != null && String.valueOf(PMPatient.PM_TransformBrand__c) != '')
	    	 				{
	    	 					//病人转竞品原因动态对比
			    	 			if(String.valueOf(PMPatient.PM_TransformBrand__c).contains(String.valueOf(TransformP.getLabel())))
			    	 			{
			    	 					//病人转竞品原因动态对比，转竞品原因不为空时
			    	 					if(String.valueOf(PMPatient.PM_DropOut_Two_Reason__c) == String.valueOf(DropTwoformP.getLabel()))
			    	 					{
			    	 						if(!PcakListDrop.containsKey(String.valueOf(TransformP.getLabel()) + String.valueOf(DropTwoformP.getLabel())))
			    	 						{
			    	 							PcakListDrop.put(String.valueOf(TransformP.getLabel()) + String.valueOf(DropTwoformP.getLabel()) , 1);
			    	 						}
			    	 						else
			    	 						{	
				    	 						PcakListDrop.put(String.valueOf(TransformP.getLabel()) + 
				    	 						String.valueOf(DropTwoformP.getLabel()) , PcakListDrop.get
				    	 						(String.valueOf(TransformP.getLabel()) + String.valueOf(DropTwoformP.getLabel())) + 1);
			    	 						}
			    	 					}
			    	 					//病人转竞品原因动态对比，转竞品原因为空时
			    	 					else if(String.valueOf(PMPatient.PM_DropOut_Two_Reason__c) == null || String.valueOf(PMPatient.PM_DropOut_Two_Reason__c) == '') 
			    	 					{
			    	 						if(!PcakListDrop.containsKey(String.valueOf(TransformP.getLabel()) + '空'))
			    	 						{
			    	 							PcakListDrop.put(String.valueOf(TransformP.getLabel()) + '空' , 1);
			    	 						
			    	 						}
			    	 						else
			    	 						{	
				    	 						PcakListDrop.put(String.valueOf(TransformP.getLabel()) + 
				    	 						'空' , PcakListDrop.get
				    	 						(String.valueOf(TransformP.getLabel()) + '空') + 1);
			    	 						}
			    	 					}
			    	 			}
			
	    	 				}
	    	 				//转竞品品牌为空时
	    	 				if(String.valueOf(PMPatient.PM_TransformBrand__c) == '' || String.valueOf(PMPatient.PM_TransformBrand__c) == null)
			    	 		{
			    	 				//转竞品原因动态对比
			    	 				if(String.valueOf(PMPatient.PM_DropOut_Two_Reason__c) == String.valueOf(DropTwoformP.getLabel()))
			    	 				{
			    	 					if(!PcakListDrop.containsKey('空' + String.valueOf(DropTwoformP.getLabel())))
			    	 					{
			    	 						PcakListDrop.put('空' + String.valueOf(DropTwoformP.getLabel()) , 1);	
			    	 					}
			    	 					else
			    	 					{	
				    	 					PcakListDrop.put('空' + 
				    	 					String.valueOf(DropTwoformP.getLabel()) , PcakListDrop.get(String.valueOf('空' + String.valueOf(DropTwoformP.getLabel()))) + 1);
			    	 					}
			    	 				}
			    	 		}
	    	 				
	    	 				
	    	 			}
	
	    	 		}
    	 		}
    	 	}   	 	
			/*******************************获得转竞品品牌信息*********************************************/
    	 	for(Schema.PicklistEntry TransformPUP : ListTransform)
    	 	{
    	 		for(Schema.PicklistEntry DropTwoformPUP : ListDropTwo)
    	 		{	
    	 			//以转竞品品牌以及转竞品原因为外键插入数据    	 		
	    	 		PM_TurnBrand__c Turn = new PM_TurnBrand__c();
	    	 		Turn.PM_UniquelyId__c = HosID + String.valueOf(TransformPUP.getLabel())+String.valueOf(DropTwoformPUP.getLabel());
	    	 		Turn.PM_Hospital__c = HosID;	    	 		
	    	 		Turn.PM_Brand__c = String.valueOf(TransformPUP.getLabel());
	    	 		Turn.PM_TurnCause__c = String.valueOf(DropTwoformPUP.getLabel());
	    	 		if(PcakListDrop.get(String.valueOf(TransformPUP.getLabel())+String.valueOf(DropTwoformPUP.getLabel())) != null)
	    	 		{
	    	 		Turn.PM_Number__c = PcakListDrop.get(String.valueOf(TransformPUP.getLabel())+String.valueOf(DropTwoformPUP.getLabel()));
	    	 		} 
	    	 		else
	    	 		Turn.PM_Number__c = 0;
	    	 		if(String.valueOf(TransformPUP.getLabel()) == '不知' && String.valueOf(DropTwoformPUP.getLabel()) == '不知原因')
	    	 		{
	    	 			Turn.PM_Number__c = Turn.PM_Number__c + UnknowPD;
	    	 		}
	    	 		else if(String.valueOf(TransformPUP.getLabel()) == '不知' && String.valueOf(DropTwoformPUP.getLabel()) != '不知原因')
	    	 		{
	    	 			if(PcakListDrop.get('空' + String.valueOf(DropTwoformPUP.getLabel()))!=null)
	    	 			Turn.PM_Number__c = Turn.PM_Number__c + PcakListDrop.get('空' + String.valueOf(DropTwoformPUP.getLabel()))/ListTransform.size();
	    	 		}
	    	 		else if(String.valueOf(DropTwoformPUP.getLabel()) != '不知' && String.valueOf(DropTwoformPUP.getLabel()) == '不知原因')
	    	 		{
	    	 			if(PcakListDrop.get(String.valueOf(TransformPUP.getLabel()) + '空')!=null)
	    	 			Turn.PM_Number__c = Turn.PM_Number__c + PcakListDrop.get(String.valueOf(TransformPUP.getLabel()) + '空')/ListDropTwo.size();
	    	 		}
	    	 		TurnBrandMap.put(HosID + String.valueOf(TransformPUP.getLabel()) + String.valueOf(DropTwoformPUP.getLabel()), Turn);
    	 		}
    	 	}	
    	 }
		/************************开始汇总医院基础信息以及转竞品信息**************************/ 	
		/*******************************更新病人数据信息***********************************/ 	
		if(mappme_IntermediateTable.size()>0)
		{
			upsert mappme_IntermediateTable.values() PM_UniquelyId__c;
		}
		/*******************************更新病人数据信息***********************************/ 
		/*******************************更新转竞品品牌信息***********************************/  
		if(TurnBrandMap.size()>0)
		{
			upsert TurnBrandMap.values() PM_UniquelyId__c; 
		}
		/*******************************更新转竞品品牌信息***********************************/ 
    }
    global void finish(Database.BatchableContext BC)
    {
    	PM_WebServiceUtil.sendMail('病人数据统计表');
    }
    
    /*******************BILL 2013-12-11 ADD******************************/
    //查询医院该月份的负责的销售
    private map<ID,ID> searchHospatilSale(List<String> Set_accId)
    {
    	map<ID,ID> map_sh = new map<ID,ID>();
    	string yearmonth = string.valueOf(NOW_Date.year())+string.valueOf(NOW_Date.month());
	    for(PM_Sale_Hospital_Dimension__c dim :[Select p.PM_Account__c , p.PM_Saler__c From PM_Sale_Hospital_Dimension__c p 
	    			where PM_Account__c IN : Set_accId and p.PM_Date_Formula__c = : yearmonth and PM_UserProduct__c = 'PD'])
	    {
	    	map_sh.put(dim.PM_Account__c,dim.PM_Saler__c);
	    }
	    return map_sh;
    }
    /*******************BILL 2013-12-11 ADD******************************/
    
    /*******************BILL 2013-12-17 ADD******************************/
    //获取医院的本年度的该月份的新病人目标和存活病人目标
    private map<ID,YearMonthTarget> searchHospatilPlan(List<String> Set_accId)
    {
    	map<ID,YearMonthTarget> map_plan = new map<ID,YearMonthTarget>();
    	//病人计划开始日期,PM_Year__c>=startdate
    	Date startdate = date.valueOf(string.valueOf(NOW_Date.year())+'-1-1');
    	//病人计划结束日期,PM_Year__c<enddate
    	Date enddate = startdate.addYears(1);
		//拼接“本月计划新增病人数”字段API名
		string PlanAdd = 'PM_PlanAdd';
		PlanAdd += string.valueOf(NOW_Date.month())+'__c';
		//拼接“本月计划存活病人数”字段API名
		string PlanSurviving = 'PM_PlanSurviving';
		PlanSurviving += string.valueOf(NOW_Date.month())+'__c';
		//拼接soql语句
		String strSoql = 'Select ';
		strSoql += PlanAdd + ',';
		strSoql += PlanSurviving + ',';
		strSoql += 'PM_Year__c, PM_Hospital__c From PM_PatientPlan__c p where PM_Hospital__c IN : Set_accId AND PM_Year__c >= : startdate AND PM_Year__c < : enddate';
		//如果当前医院本月病人计划不为空
	    for(PM_PatientPlan__c plan : database.query(strSoql))
	    {
	    	YearMonthTarget target = new YearMonthTarget();
	    	target.NewTarget = integer.valueOf(plan.get(PlanAdd));
	    	target.SurivingTarget = integer.valueOf(plan.get(PlanSurviving));
	    	map_plan.put(plan.PM_Hospital__c,target);
	    }
	    return map_plan;
    }
    
    //内部包装类
    private class YearMonthTarget
    {
    	//新病人目标
    	double NewTarget;
    	//存活病人目标
    	double SurivingTarget;
    }
    /*******************BILL 2013-12-17 ADD******************************/
}
