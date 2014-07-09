// Trigger runs getLocation() on Stores with no Geolocation
trigger SetGeolocation on Store__c (after insert, after update) {
    for (Store__c a : trigger.new)
        if (a.Geolocation__Latitude__s == null)
            LocationCallouts.getLocation(a.id);
}