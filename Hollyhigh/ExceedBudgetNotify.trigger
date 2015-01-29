trigger ExceedBudgetNotify on AdmiExpense__c (before insert) 
{
	//List<AdmiExpenseBudget__c> aebList = new List<AdmiExpenseBudget__c>(); // 新建行政费用预算List, 用来存放触发的记录对应的所有Master-Detail关系的记录
	
	// 获取当前触发的行政费用支出记录的所有Master-Detail关系的行政费用预算记录
	for(AdmiExpense__c a : trigger.new)
	{
		//Boolean flag = true; // 用来判断List是否为空
		// 获取触发的记录的Master-Detail关系行政费用预算记录
		/*
		AdmiExpenseBudget__c aeb = [Select 
										forecasttotal__c, 
										id 
									From 
										AdmiExpenseBudget__c 
									Where 
										id =: a.Administrative_expenses__c];
		*/
		List<AdmiExpense__c> aeList = new List<AdmiExpense__c>();
		aeList = [Select 
					Expenses__c, 
					Administrative_expenses__c, 
					Id,
					CostType__c,
					ExceedBudgetMoney__c
				  From 
				  	AdmiExpense__c 
				  Where 
					Administrative_expenses__r.Id =: a.Administrative_expenses__c 
				  And 
				  	CostType__c =: a.CostType__c
				  Order by 
					LastModifiedDate asc];
		
		System.debug('支出类型' + a.CostType__c);
		
		List<AdmiExpenseBudgetDetail__c> aebdList = new List<AdmiExpenseBudgetDetail__c>();
		aebdList = [Select 
						Forecast__c 
					From 
						AdmiExpenseBudgetDetail__c 
					Where 
						AdmiExpenseBudgetName__r.Id =: a.Administrative_expenses__c 
					And 
						Administrative_expenses_type__c =: a.CostType__c];
		Double totalExpense = a.Expenses__c;
		for(AdmiExpense__c aec : aeList)
		{
			totalExpense += aec.Expenses__c;
		}
		
		System.debug('总支出' + totalExpense);
		
		Double totalBudget = 0;
		for(AdmiExpenseBudgetDetail__c aebd : aebdList){
			totalBudget += aebd.Forecast__c;
		}
		
		System.debug('总预算' + totalBudget);
		
		if(totalExpense > totalBudget){
			a.ExceedBudgetMoney__c = (totalExpense - totalBudget);
			a.ExceedBudgetId__c = true;
			
			System.debug('超出金额' + a.ExceedBudgetMoney__c);
			System.debug('超出预算标识' + a.ExceedBudgetId__c);
			/*
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new List<String>();
			List<User> userList = [Select Email From User Where User.UserRole.Name = '财务经理'];
			for(User u:userList)
			{
				toAddresses.add(u.Email);
			}
			mail.setToAddresses(toAddresses);
			String content = '现有一笔费用支出"';
			content += a.Name + '"已超出预算，请核实\n费用支出链接如下' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.id;
			mail.PlainTextBody = content;
		    mail.setSubject('支出超出预算提醒');
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		    */
		}
		
		totalExpense = 0;
		totalBudget = 0;
		
		/*
		// 判断获取的行政费用预算记录是否在List中存在
		for(AdmiExpenseBudget__c ae : aebList)
		{
			if(ae.id == aeb.Id)
			{
				flag = false; // 若存在设置为false
			}
		}
		
		if(flag)
		{
			aebList.add(aeb); // 若在List中不存在, 则存入List集合
		}
		*/
	}
	
	/*
	// 根据行政费用预算记录获取Master-Detail关系行政费用支出的记录

	for(AdmiExpenseBudget__c aebc : aebList)
	{
		List<AdmiExpense__c> aeList = new List<AdmiExpense__c>();
		aeList = [Select 
					Expenses__c, 
					Administrative_expenses__c,
					Name, 
					Id,
					ExceedBudgetMoney__c 
				  From 
				  	AdmiExpense__c 
				  Where 
					Administrative_expenses__r.Id =: aebc.Id
				  Order by 
					Expensestime__c asc];
		
		Double totalExpense = 0;
		for(AdmiExpense__c aec : aeList)
		{
			totalExpense += aec.Expenses__c;
		}
		
		if(totalExpense > aebc.forecasttotal__c)
		{
			aeList[aeList.size() - 1].ExceedBudgetMoney__c = totalExpense - aebc.forecasttotal__c;
			aeList[aeList.size() - 1].ExceedBudgetId__c = true;
			update aeList;
			
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new List<String>();
			List<User> userList = [Select Email From User Where User.UserRole.Name = '财务经理'];
			for(User u:userList)
			{
				toAddresses.add(u.Email);
			}
			mail.setToAddresses(toAddresses);
			String content = '现有一笔费用支出"';
			content += aeList[aeList.size() - 1].Name + '"已超出预算，请核实\n费用支出链接如下' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + aeList[aeList.size() - 1].id;
			mail.PlainTextBody = content;
		    mail.setSubject('支出超出预算提醒');
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		
		totalExpense = 0;
	}
	*/
}
