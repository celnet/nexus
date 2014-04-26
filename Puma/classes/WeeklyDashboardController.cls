/*
 * Author : 
 * 
 *
 */
public class WeeklyDashboardController {
	public String strGoogleChartUrl {get;set;}
	
	public Date__c d{get;set;}
	public String selectedStore{get;set;}
	public List<SelectOption> stores{get;set;}
	public String displayPDF{get;set;}
	public boolean pdf{get;set;}
	
	public WeeklyDashboardController(){
		selectedStore = '新世界';
		stores = new List<SelectOption>();
		stores.add(new selectOption(selectedStore,selectedStore));
		stores.add(new selectOption('三里屯店','三里屯店'));
		stores.add(new selectOption('上海时尚中心','上海时尚中心'));
		stores.add(new selectOption('天通苑店','天通苑店'));
		
		d = new Date__c();
		d.Date__c = Date.today();
		
    	strGoogleChartUrl = getGoogleChartUrl();
    	system.debug(strGoogleChartUrl);
    	displayPDF = '';
    	pdf = true;
    }
    
    public void generate()
    {
    	
    }
    
    public void convert()
    {
    	displayPDF = 'pdf';
    	pdf = false;
    }
    
	public String getGoogleChartUrl(){
    	Map<String , Integer> map_AccountType = new Map<String , Integer>();
    	for(Account acc : [Select Id,Type From Account Where Type != null]){
    		if(map_AccountType.containsKey(acc.Type)){
    			Integer i = map_AccountType.get(acc.Type);
    			i++ ;
    			map_AccountType.put(acc.Type , i);
    		}else{
    			map_AccountType.put(acc.Type , 1);
    		}
    	}
    	
    	String strUrl = 'http://chart.apis.google.com/chart?';
    	//chart类型（柱状）
    	strUrl += 'cht=bvg';
    	//颜色
    	strUrl += '&chco=cc0000,00aa00' ;
    	//图片大小
    	strUrl += '&chs=550x100';
    	//
    	String strTypes = '';
    	String strValues = '' ;
    	for(String strType : map_AccountType.keySet()){
    		strTypes += '|'+strType ;
    		if(strValues == ''){
    			strValues += map_AccountType.get(strType)*10 ;//数据太少，*10
    		}else{
    			strValues += ','+map_AccountType.get(strType)*10 ;//数据太少*10
    		}
    		
    	}
    	//值
    	strUrl += '&chd=t:'+strValues;
    	//X轴Y轴
    	strUrl += '&chxt=x,y';
    	strUrl += '&chxl=0:'+strTypes+'|1:|0|50|100';
    	
    	//柱宽度
    	strUrl += '&chbh=100' ;
    	
    	return strUrl ;
    	
    }
}