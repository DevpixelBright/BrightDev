/*
class               : ConversionTransit
class called From   : QASSubscriptionBeforeInsertUpdate Trigger
Test class          : SMS_ZuoraIntegration_Test
Description         : updating subscription fields in before trigger 
*/
public class ConversionTransit {
    public static void subscriptionConversionFieldsUpdate(Map<Id, Subscriptions__c> oldSubscriptionsMap, Map<Id, Subscriptions__c> newSubscriptionsMap){
        if(newSubscriptionsMap == null || newSubscriptionsMap.size() == 0)
            return ;
        
        Map<String,String> subscriptionNewOfficeId = new Map<String,String>();      
        
        for(Subscriptions__c newSubscription : newSubscriptionsMap.values()){
            
            Subscriptions__c oldSubscription = oldSubscriptionsMap.get(newSubscription.Id);
            
            if(newSubscription.Service_Jurisdiction__c != null && newSubscription.Service_Jurisdiction__c.toUpperCase() != 'BRIGHT' && newSubscription.Related_Location_Broker_Office__c != null){                
                if((newSubscription.Related_Location_Broker_Office__c  != oldSubscription.Related_Location_Broker_Office__c) || 
                   ((oldSubscription.Status__c == 'In Progress' || oldSubscription.Status__c == 'Inactive') && newSubscription.Status__c == 'Active')
                  ){
                      
                      subscriptionNewOfficeId.put(newSubscription.Id,newSubscription.Related_Location_Broker_Office__c);                      
                  }
            }
        }
        
        Map<Id,Account> newAccountMap = new Map<Id, Account>([SELECT Id, 
                                                                     BRIGHT_ConversionDeploymentGroup__c,
                                                                     BRIGHT_ConversionPreviewDate__c, 
                                                                     BRIGHT_ConversionProductionDate__c,
                                                                     BRIGHT_ConversionSourceMLS__c                                          
                                                              FROM   Account 
                                                              WHERE  Id IN :subscriptionNewOfficeId.values()]);
                                          
        for(String subscriptionId : subscriptionNewOfficeId.keyset()){
            Account newAccount = newAccountMap.get(newSubscriptionsMap.get(subscriptionId).Related_Location_Broker_Office__c);
            newSubscriptionsMap.get(subscriptionId).BRIGHT_ConversionPrevDeploymentGroup__c =  oldSubscriptionsMap.get(subscriptionId).BRIGHT_ConversionDeploymentGroup__c;
            newSubscriptionsMap.get(subscriptionId).BRIGHT_ConversionDeploymentGroup__c = newAccount.BRIGHT_ConversionDeploymentGroup__c;
            newSubscriptionsMap.get(subscriptionId).BRIGHT_ConversionPreviewDate__c = newAccount.BRIGHT_ConversionPreviewDate__c;
            newSubscriptionsMap.get(subscriptionId).BRIGHT_ConversionProductionDate__c = newAccount.BRIGHT_ConversionProductionDate__c;
            newSubscriptionsMap.get(subscriptionId).BRIGHT_ConversionSourceMLS__c = newAccount.BRIGHT_ConversionSourceMLS__c;
            newSubscriptionsMap.get(subscriptionId).BRIGHT_ConversionTransitDate__c = system.today();
        }
    }
}