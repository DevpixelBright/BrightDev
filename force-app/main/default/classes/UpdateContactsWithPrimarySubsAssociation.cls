global class UpdateContactsWithPrimarySubsAssociation implements Database.Batchable<sObject>{ 
  global String query;
  global UpdateContactsWithPrimarySubsAssociation(string q){    
    query=q;
   } 
  global Database.QueryLocator start(Database.BatchableContext BC){ 
    //  if(query ==''){query = 'Select ID, Name, FirstName, LastName, Primary_Contact__c, Primary_Subscription__c, Primary_Subscription_ID__c, Primary_Subscription_Association__c, Primary_Susbcription_Association_ID__c from Contact where ((LastName LIKE \'Aasim\') AND (FirstName LIKE \'Sikander\')) LIMIT 1'; }
    // if(query ==''){query = 'Select ID, Name, FirstName, LastName, Primary_Contact__c, Primary_Subscription__c, Primary_Subscription_ID__c, Primary_Subscription_Association__c, Primary_Susbcription_Association_ID__c from Contact LIMIT 1000'; }
    if(query ==''){query = 'Select ID, Name, FirstName, LastName, Primary_Contact__c, Primary_Subscription__c, Primary_Subscription_ID__c, Primary_Subscription_Association__c, Primary_Susbcription_Association_ID__c from Contact'; }
    return Database.getQueryLocator(query);
   }  
     
  global void execute(Database.BatchableContext BC, List<Contact>scope){ 
    //system.debug('execute start');    
    List<Contact> ContactsToUpdate = new List<Contact>();
    List<Related_Association__c> RelatedAssocList =  [Select ID, Name, Subscription__c, Contact_ID__c, End_Date__c, Status__c, Association__c from Related_Association__c where End_Date__c = NULL AND Primary__c=true AND Subscription_IsPrimary__c  = true AND Contact_ID__c !='' AND Association__c !=NULL];
    //List<Related_Association__c> RelatedAssocList =  [Select ID, Name, Subscription__c, Contact_ID__c, End_Date__c, Status__c, Association__c from Related_Association__c where End_Date__c = NULL AND Name LIKE '269898'];
  
    Map<String, ID> RelAssMap = new Map<String, ID>();
    Set<String>RelAssSet=new Set<String>();
    system.debug('Related Association List size:'+String.valueOf(RelatedAssocList.size()));
    for (Related_Association__c ra:RelatedAssocList){
         //system.debug('rel ass contact:'+ra.Contact_ID__c); 
         if(ra.Contact_ID__c !=null && ra.Contact_ID__c !='' && ra.Association__c !=null){
            RelAssMap.put(ra.Contact_ID__c, ra.Association__c);
            RelAssSet.add(ra.Contact_ID__c);
            //system.debug('rel ass contact found:'+ra.Contact_ID__c); 
         }
    }
    
    for(Contact c : scope){   
      // system.debug('contact name: '+c.Name);   
      String cid = String.valueOf(c.ID); 
      Id relassID = c.Primary_Susbcription_Association_ID__c;
          
      if(!(RelAssMap.containsKey(cid))){
       //system.debug('in execute 1 - rels does not have key for contact'); 
        if(relassID !='' && relassID !=null){
           //system.debug('contact has primary prim subs association'); 
           c.Primary_Susbcription_Association_ID__c =null;
           //system.debug('in execute - null pr sub ass'); 
           ContactsToUpdate.add(c);
           //system.debug('in execute - update contact'); 
       }
       }
       else{
       //system.debug('in execute - key found'); 
       ID PrimAssKeyID = RelAssMap.get(cid);
        if(relassID != PrimAssKeyID){
         //system.debug('in execute - pr.sub.ass is different'); 
         c.Primary_Susbcription_Association_ID__c =PrimAssKeyID;
         //system.debug('execute start 6'); 
         ContactsToUpdate.add(c);
         //system.debug('execute start 7'); 
         }
       }
       
      }
      
     
      
    system.debug('Contacts to Update list size:'+String.valueOf(ContactsToUpdate.size()));
    update ContactsToUpdate; 
    system.debug('success - the end'); 
  }
  global void finish(Database.BatchableContext BC){ 
 }
}