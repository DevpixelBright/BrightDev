public class SMS_SubEmailUpdate{
    static List<String> accountTypes = new List<String>();
    
    
    public Static void updatePrivateEmailToRelatedObjs(Map<Id,Subscriptions__c> newSubMap, Map<Id,Subscriptions__c> oldSubMap) {
        system.debug('Inside Private email update on subscription---');
        for(SMS_Exclude_Zuora_Integration__c accountType : SMS_Exclude_Zuora_Integration__c.getall().values()) 
            accountTypes.add(accountType.Name);
        Map<Id,Account> subAccountMap = new Map<Id,Account>();
        set<Id> accountIdSet = new set<Id>();
        Map<string,Subscriptions__c> subNameMap = new Map<string,Subscriptions__c>();
        //set<string> subNameSet = new set<string>();
        List<Zuora__CustomerAccount__c> billingAccounts = new List<Zuora__CustomerAccount__c>();
        List<Zuora__SubscriptionProductCharge__c> subscriptionProductCharges = new List<Zuora__SubscriptionProductCharge__c>();
        List<Zuora__PaymentMethod__c> paymentMethods = new List<Zuora__PaymentMethod__c>();
        list<Teams__c> teamsToUpdate = new list<Teams__c>();
        list<Team_Members__c> teamMembersToUpdate = new list<Team_Members__c>();
        list<Team_Members__c> teamLeadAsMemberToUpdate = new list<Team_Members__c>();
        
        for(Subscriptions__c sub : newSubMap.values()){
            if(sub.Related_Location_Broker_Office__c != null && sub.Private_Email__c != oldSubMap.get(sub.id).Private_Email__c){
                accountIdSet.add(sub.Related_Location_Broker_Office__c);
                subNameMap.put(sub.Name, sub);
            }   
        }
        system.debug('----sub name key set---'+subNameMap.keyset());
        subAccountMap = new Map<Id,Account>([SELECT id,Type FROM Account WHERE  Type IN :accountTypes AND id IN :accountIdSet]);
        for(Zuora__CustomerAccount__c billingAccount : [SELECT id,Name,Private_Email__c,SubscriptionID__c FROM Zuora__CustomerAccount__c WHERE SubscriptionID__c IN :subNameMap.keyset()]){
            billingAccount.Private_Email__c = subNameMap.get(billingAccount.SubscriptionID__c).Private_Email__c;
            billingAccounts.add(billingAccount);
        }
        
        for(Zuora__SubscriptionProductCharge__c subProdChrg : [SELECT id,Name,Private_Email__c,MRIS_Subscription_Id__c FROM Zuora__SubscriptionProductCharge__c
                                                               WHERE MRIS_Subscription_Id__c IN :subNameMap.keyset()]){
             subProdChrg.Private_Email__c = subNameMap.get(subProdChrg.MRIS_Subscription_Id__c).Private_Email__c;
             subscriptionProductCharges.add(subProdChrg);                     
        }
        for(Zuora__PaymentMethod__c paymentMethod : [SELECT id,Name,Private_Email__c,Subscription_Id__c FROM Zuora__PaymentMethod__c
                                                     WHERE Subscription_Id__c IN :subNameMap.keyset()]){
            paymentMethod.Private_Email__c = subNameMap.get(paymentMethod.Subscription_Id__c).Private_Email__c;
            paymentMethods.add(paymentMethod);
        }
        //  Subscription_ID__r.Name
        for(Teams__c team : [SELECT Team_Lead_Email__c,Team_Lead_Sub_ID__c,Subscription_ID__r.Name FROM Teams__c WHERE Team_Lead_Sub_ID__c IN :subNameMap.keyset()]){
            team.Team_Lead_Email__c = subNameMap.get(team.Team_Lead_Sub_ID__c).Private_Email__c;
            teamsToUpdate.add(team);
        }
        //Subscription_ID__r.Name
        for(Team_Members__c teamMember : [SELECT Team_Member_Email__c,Team_Member_Sub_ID__c,Subscription_ID__r.Name FROM Team_Members__c WHERE Team_Member_Sub_ID__c IN :subNameMap.keyset()]){
            teamMember.Team_Member_Email__c = subNameMap.get(teamMember.Team_Member_Sub_ID__c).Private_Email__c;
            teamMembersToUpdate.add(teamMember);
        }
        for(Team_Members__c teamMember : [SELECT Team_Lead_Email__c,Team_Lead_Sub_ID__c FROM Team_Members__c WHERE Team_Lead_Sub_ID__c IN :subNameMap.keyset()]){
            teamMember.Team_Member_Email__c = subNameMap.get(teamMember.Team_Lead_Sub_ID__c).Private_Email__c;
            teamLeadAsMemberToUpdate.add(teamMember);
        }
        
        if(!billingAccounts.isEmpty()){
            update billingAccounts;
        }
        if(!subscriptionProductCharges.isEmpty()){
            update subscriptionProductCharges;
        }
        if(!paymentMethods.isEmpty()){
            update paymentMethods;
        }
        system.debug('teamsToUpdate---'+teamsToUpdate);
        system.debug('teamMembersToUpdate---'+teamMembersToUpdate);
        system.debug('teamLeadAsMemberToUpdate---'+teamLeadAsMemberToUpdate);
        if(!teamsToUpdate.isEmpty()){
            update teamsToUpdate;
        }
        if(!teamMembersToUpdate.isEmpty()){
            update teamMembersToUpdate;
        }
        if(!teamLeadAsMemberToUpdate.isEmpty()){
            update teamLeadAsMemberToUpdate;
        }
    }
    /*
    public Static void updatePrivateEmail(String mSubscriptionId,String privateEmail) {
        if (String.isBlank(mSubscriptionId))
            throw new CustomException('Invalid Operation');
            
        system.debug('*** mSubscriptionId: '+ mSubscriptionId);
        system.debug('*** privateEmail: '+ privateEmail);
        
        List<Zuora__CustomerAccount__c> billingAccounts = new List<Zuora__CustomerAccount__c>();
        List<Zuora__SubscriptionProductCharge__c> subscriptionProductCharges = new List<Zuora__SubscriptionProductCharge__c>();
        List<Zuora__PaymentMethod__c> paymentMethods = new List<Zuora__PaymentMethod__c>();
        list<Teams__c> teamsToUpdate = new list<Teams__c>();
        list<Team_Members__c> teamMembersToUpdate = new list<Team_Members__c>();
        list<Team_Members__c> teamLeadAsMemberToUpdate = new list<Team_Members__c>();
                                     
        for(Zuora__CustomerAccount__c billingAccount : [SELECT id,Name,Private_Email__c 
                                                        FROM   Zuora__CustomerAccount__c
                                                        WHERE  SubscriptionID__c = :mSubscriptionId
                                                       ]){
            // billingAccount.Private_Email__c = privateEmail;
             //billingAccounts.add(billingAccount);
             //system.debug('*** billingAccount : ' + billingAccount );
             
          /*  if(privateEmail != billingAccount.Private_Email__c){
            privateEmail = billingAccount.Private_Email__c;
            billingAccounts.add(billingAccount);
        } */
       /*                                                    
         billingAccount.Private_Email__c = privateEmail;
         billingAccounts.add(billingAccount);
         system.debug('*****billingAccounts*****' + billingAccounts);
        }
        
        
        for(Zuora__SubscriptionProductCharge__c subProdChrg : [SELECT id,Name,Private_Email__c 
                                                               FROM   Zuora__SubscriptionProductCharge__c
                                                               WHERE  MRIS_Subscription_Id__c = :mSubscriptionId
                                                              ]){
             subProdChrg.Private_Email__c = privateEmail;
             subscriptionProductCharges.add(subProdChrg);
             system.debug('*** subProdChrg : ' + subProdChrg);                             
        }
        
        for(Zuora__PaymentMethod__c paymentMethod : [SELECT id,Name,Private_Email__c
                                                     FROM Zuora__PaymentMethod__c
                                                     WHERE Subscription_Id__c = :mSubscriptionId
                                                    ]){
            paymentMethod.Private_Email__c = privateEmail;
            paymentMethods.add(paymentMethod);
        }
        for(Teams__c team : [SELECT Team_Lead_Email__c FROM Teams__c WHERE Subscription_ID__c = :mSubscriptionId]){
            team.Team_Lead_Email__c = privateEmail;
            teamsToUpdate.add(team);
        }
        for(Team_Members__c teamMember : [SELECT Team_Member_Email__c FROM Team_Members__c WHERE Subscription_ID__c = :mSubscriptionId]){
            teamMember.Team_Member_Email__c = privateEmail;
            teamMembersToUpdate.add(teamMember);
        }
        for(Team_Members__c teamMember : [SELECT Team_Lead_Email__c FROM Team_Members__c WHERE Team_Lead_SubID_ID__c = :mSubscriptionId]){
            teamMember.Team_Member_Email__c = privateEmail;
            teamLeadAsMemberToUpdate.add(teamMember);
        }
        
        update billingAccounts;
        update subscriptionProductCharges;
        update paymentMethods;
        
        if(!teamsToUpdate.isEmpty()){
            update teamsToUpdate;
        }
        if(!teamMembersToUpdate.isEmpty()){
            update teamMembersToUpdate;
        }
        if(!teamLeadAsMemberToUpdate.isEmpty()){
            update teamLeadAsMemberToUpdate;
        }
    }
    */
    public class CustomException extends Exception {}
}