global class AttachStore4PPhoto {
    public AttachStore4PPhoto(ApexPages.StandardController controller) { }
 
    @RemoteAction
    global static sf1Result submitData(sf1Data data) {
        ID recordID;
    
        try {
            System.debug('Data Received');
            System.debug(data);
            if (data == null) {
                // throw new sf1Exception('No data received!');
            } else if ((data.sImage == null) || (data.sImage.length() == 0)) {
                // throw new sf1Exception('Empty file received!');
            } else {
                // Good data received.
                String b64;
                String dataType;
                Attachment att;
                
                // Get Data
                List<String> docParts = data.sImage.split(',');
                String metadata = docParts[0];
                b64 = docParts[1];            
                List<String> metadataParts = metadata.split(';');
                dataType = metadataParts[0].split(':')[1];            
                data.bImage = EncodingUtil.base64Decode(b64);
            	
            	List<Store_4P__c> s4List = new List<Store_4P__c>();
            	s4List = [Select Id, Store__r.Name, Store__r.Address__c From Store_4P__c Where Id =: data.ParentId];
                // Attach file
                att = new Attachment();
                att.Body = data.bImage;
                att.ContentType = data.contentType;
                att.Name = s4List[0].Store__r.Name + '-' + s4List[0].Store__r.Address__c;
                att.ParentId = data.ParentId;
                Insert att;
                recordID = att.id;
            }        
            System.debug('Data Processed');
        } catch (Exception ex) {
            return new sf1Result(ex);
        }
        return new sf1Result(recordID); 
    }
    
    global class sf1Data {
        public Blob bImage { get; set; }
 
        global String ParentId { get; set; }
        global String name { get; set; }
        global String sImage { get; set; }
        global String contentType { get; set; }
        global Integer bodyLength { get; set; }
    }
}