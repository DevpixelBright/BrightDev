public class substatus{

    public void substatus(Map<Id, Subscriptions__c> oldMap, Map<Id, Subscriptions__c> newMap,  Map<Id, Subscriptions__c> SubMap){
                     
        List<Id> subIds = new List<Id>();
            for(Id SubsMap : SubMap.keyset()) {
            if ((oldMap.get(SubsMap).Status__c != newMap.get(SubsMap).Status__c) || (oldMap.get(SubsMap).Related_Location_Broker_Office__r.Status__c != newMap.get(SubsMap).Related_Location_Broker_Office__r.Status__c)){
                subIds.add(newMap.get(SubsMap).Id);
            }
        } 
        
                  List<Listing_Transfer_Request__c> transferList =  [Select Id,CanceledReason__c,
                                                            CancelledOn__c,
                                                            Requested_By__c,
                                                            IsActive__c,
                                                            StatusCode__c 
                                                            from Listing_Transfer_Request__c 
                                                            Where Requested_By__c IN :subIds
                                                            AND   StatusCode__c = 'Pending']; 
                                    if(!transferList.isEmpty()) {
                                        for(Listing_Transfer_Request__c ltf : transferList) {
                                            if((oldMap.get(ltf.Requested_By__c).Status__c == 'Active' && newMap.get(ltf.Requested_By__c).Status__c == 'Inactive') 
                                            ||(oldMap.get(ltf.DestinationOfficeCode__c).Status__c == 'Active' && newMap.get(ltf.DestinationOfficeCode__c).Status__c == 'Inactive')
                                              ||(oldMap.get(ltf.OriginationOfficeCode__c).Status__c == 'Active' && newMap.get(ltf.OriginationOfficeCode__c).Status__c == 'Inactive')){
                                                ltf.isActive__c = false;
                                                ltf.StatusCode__c='Cancel';
                                                ltf.CanceledReason__c='Subscrption has been Inactivated.';
                                                ltf.CancelledOn__c=system.today();
                                            } 
                                        }
                                    }                  
                                    
                                     
}
}