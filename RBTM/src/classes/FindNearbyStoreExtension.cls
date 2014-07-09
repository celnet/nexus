global with sharing class FindNearbyStoreExtension {
     public FindNearbyStoreExtension(ApexPages.StandardSetController controller) { }

    @RemoteAction
    // Find stores nearest a geolocation
    global static List<Store__c> getNearby(String lat, String lon) {

        // If geolocation isn't set, use null
        if(lat == null || lon == null || lat.equals('') || lon.equals('')) {
            lat = '0';
            lon = '0';
        }

        // SOQL query to get the nearest stores
        String queryString =
            'SELECT Id, Name, Geolocation__Longitude__s, Geolocation__Latitude__s, ' +
                'Streetname__c, Phone__c, City__c, City__r.Name ' +
            'FROM Store__c ' +
            'WHERE DISTANCE(Geolocation__c, GEOLOCATION('+lat+','+lon+'), \'km\') < 1 ' +
           // ' AND CreatedBy = \'' + UserInfo.getUserId() + '\'' +
            ' ORDER BY DISTANCE(Geolocation__c, GEOLOCATION('+lat+','+lon+'), \'km\') ';

        // Run and return the query results
        return(database.Query(queryString));
    }
}