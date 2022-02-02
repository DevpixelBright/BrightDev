public class ListingTransferRequestClass {
    
    //Method to Create Listing_Transfer_Request__c
    @RemoteAction
    public static void insertListingTransferRequest(string wrap) {
        /*List<String> subscriptionNames = new List<String>();
        list<string> originOffices = new list<string>();
        for(innerListingWrapper w : wrap) {
            subscriptionNames.add(w.agentId);
            originOffices.add(w.originatingOffice);
        }
        Map<String, Subscriptions__c> subscriptionMap = new Map<String, Subscriptions__c>();
        for(Subscriptions__c sub : [SELECT Id, Name, Related_Location_Broker_Office__c FROM Subscriptions__c 
                                    WHERE Name IN :subscriptionNames AND Status__c = 'Active']) {
            subscriptionMap.put(sub.Name, sub);  
        }
        
        map<string, Account> originOfficeMap = new map<string, Account>();
        for(Account acc : [Select id, Name from Account Where Name in: originOffices]){
            originOfficeMap.put(acc.Name, acc);
        }
        
        List<Listing_Transfer_Request__c> ltreqList = new List<Listing_Transfer_Request__c>();
        for(innerListingWrapper w : wrap) {
            Listing_Transfer_Request__c ltapp = new Listing_Transfer_Request__c();
            ltapp.StatusCode__c = 'Pending';
            ltapp.IsActive__c = true;
            ltapp.RequestedOn__c = System.today();
            ltapp.DestinationOfficeCode__c = subscriptionMap.get(w.agentId).Related_Location_Broker_Office__c;
            ltapp.Requested_By__c = subscriptionMap.get(w.agentId).Id;
            ltapp.ListingKey__c = w.listingKey;
            ltapp.OriginationOfficeCode__c = originOfficeMap.get(w.originatingOffice).Id;
            ltreqList.add(ltapp);
        }
        insert ltreqList;
        */
                        /* List<Id> requestIds = new List<Id>();
                for(Listing_Transfer_Request__c ltreq : ltreqList) {
                requestIds.add(ltreq.Id);
                }
                String cronExp = '0 0 9 * * ?';
                System.schedule('listingtransfer', cronExp, new ScheduleListingTransferReqEmailClass(requestIds));  */          
    }
    //Wrapper Class
    public class innerListingWrapper {
        public String listingKey;
        public String agentId;
        public String originatingOffice;
    }         
}