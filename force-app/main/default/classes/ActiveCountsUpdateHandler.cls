public class ActiveCountsUpdateHandler {
    
    public static void ActiveSubscriptions(List<Subscriptions__c> NewSubs, Map<Id,Subscriptions__c> OldSubs){
        try{
            Set<Id> accIds = new Set<Id>();
            for(Subscriptions__c sub : NewSubs){
                if(sub.Related_Location_Broker_Office__c != null){
                    if(OldSubs != null && (sub.Related_Location_Broker_Office__c != OldSubs.get(sub.Id).Related_Location_Broker_Office__c)){
                        accIds.add(OldSubs.get(sub.Id).Related_Location_Broker_Office__c);  
                        accIds.add(sub.Related_Location_Broker_Office__c);
                    }
                    if(OldSubs != null && ((sub.Contact_Type__c != OldSubs.get(sub.Id).Contact_Type__c) || (sub.Subscription_Type__c != OldSubs.get(sub.Id).Subscription_Type__c) || (sub.Status__c != OldSubs.get(sub.Id).Status__c))){
                        accIds.add(OldSubs.get(sub.Id).Related_Location_Broker_Office__c);  
                    }else if(OldSubs == null)
                        accIds.add(sub.Related_Location_Broker_Office__c);  
                }
            }
            if(accIds.size()>0){
                List<Aggregateresult> subCount = [SELECT Related_Location_Broker_Office__c,Subscription_Type__c,Contact_Type__c,count(id) from Subscriptions__c WHERE Status__c = 'Active' AND Related_Location_Broker_Office__c IN :accIds group by Related_Location_Broker_Office__c, Subscription_Type__c, Contact_Type__c];
                MAP<String, Account> NewAcc = new MAP<String, Account>();
                
                for(Aggregateresult aggr : subCount){
                    Account acc = new Account();
                    acc.id = (String)aggr.get('Related_Location_Broker_Office__c');
                    acc.Num_Active_Subs__c = 0;
                    acc.Num_Active_Office_Sec_NC__c = 0;
                    if(NewAcc.Containskey((String)aggr.get('Related_Location_Broker_Office__c'))){
                        acc = NewAcc.get((String)aggr.get('Related_Location_Broker_Office__c'));
                    }
                    if(((String)aggr.get('Subscription_Type__c') == 'Licensee/Non Realtor' || (String)aggr.get('Subscription_Type__c') == 'Realtor/Non Shareholder'|| (String)aggr.get('Subscription_Type__c') == 'Realtor/Shareholder')
                       && ((String)aggr.get('Contact_Type__c') == 'Agent' || (String)aggr.get('Contact_Type__c') == 'Broker'|| (String)aggr.get('Contact_Type__c') == 'Office Manager')){
                           acc.Num_Active_Subs__c += (Integer)aggr.get('expr0');
                           system.debug('acc.Num_Active_Subs__c'+acc.Num_Active_Subs__c);
                       }else if((String)aggr.get('Subscription_Type__c') == 'Office Secretary - NC'){
                           acc.Num_Active_Office_Sec_NC__c += (Integer)aggr.get('expr0');
                           system.debug('acc.Num_Active_Office_Sec_NC__c'+acc.Num_Active_Office_Sec_NC__c);
                       }
                    NewAcc.put((String)aggr.get('Related_Location_Broker_Office__c'), acc);
                    system.debug('NewAcc'+NewAcc);
                }
                
                if(NewAcc.size() > 0){
                    update NewAcc.values();
                }
            }
        }
        
        catch(exception e){
            system.debug('***Exception'+e.getMessage());
        }
    }
}