trigger PopulateStore4PPhotoURLFieldFromChatter on FeedItem (after insert) {
    for(FeedItem fi : trigger.new){
        System.debug(fi.ContentType + '>>>>>>>>');
        if(fi.ContentType.contains('JPG') || fi.ContentType.contains('PNG')||fi.ContentType.contains('GIF')) {
            System.debug(fi.ContentType + '>>>>>>>>');
            List<Store_4P__c> s4List = new List<Store_4P__c>();
            s4List = [Select Id, Photo_URL__c From Store_4P__c Where Id =: fi.ParentId];
            if(s4List.size() > 0) {
                s4List[0].Photo_URL__c = 'https://c.ap1.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + fi.RelatedRecordId;
                update s4List[0];
            }
        }
    }
}