trigger PopulateStore4PPhotoURLField on Attachment (after insert) {
	for(Attachment att : trigger.new) {
		List<Store_4P__c> s4List = new List<Store_4P__c>();
		s4List = [Select Id, Photo_URL__c From Store_4P__c Where Id =: att.ParentId];
		if(s4List.size() > 0) {
			s4List[0].Photo_URL__c = 'https://c.ap1.content.force.com/servlet/servlet.FileDownload?file=' + att.Id;
			update s4List[0];
		}
	}
}