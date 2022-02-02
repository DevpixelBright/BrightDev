trigger RelationshipAssociationUpdateContactAfterInsertUpdate on Related_Association__c (after insert, after update, after delete) {

    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;
    
    //Call the future method with the list of Relationship__c objects
    Map<String,Id> ContactsMap = new Map<String,Id>();   
    Set<ID>ContactsSet=new Set<ID>();
   
    Id ContactID;
    if(Trigger.isInsert){
        for(Related_Association__c ra : Trigger.new){
        System.debug('ra.Association_Status__c:'+ra.Association_Status__c+ ',ra.Subscription_Status__c:'+ra.Subscription_Status__c +'ra.Contact_Status__c:'+ra.Contact_Status__c+ 'ra.Status__c:'+ra.Status__c+'ra.End_Date__c:'+ra.End_Date__c+'ra.Primary__c:'+ra.Primary__c+'ra.Subscription_IsPrimary__c:'+ra.Subscription_IsPrimary__c+'ra.Contact_ID__c:'+ra.Contact_ID__c+'ra.Association__c:'+ra.Association__c);
        if(ra.Association_Status__c=='Active' && ra.Subscription_Status__c=='Active' && ra.Contact_Status__c=='Active' && ra.Status__c=='Active' && ra.End_Date__c == NULL && ra.Primary__c==true && ra.Subscription_IsPrimary__c  == true && ra.Contact_ID__c !='' && ra.Association__c !=NULL){
             ContactsSet.add(ra.Contact_ID__c); 
            }        
          }
        
          
          
     }
    if(Trigger.isUpdate){
      for(Related_Association__c ra : Trigger.new){
       Related_Association__c oldRA = Trigger.oldMap.get(ra.Id);
         if(ra.Association_Status__c=='Active' && ra.Subscription_Status__c=='Active' && ra.Contact_Status__c=='Active' && ra.Status__c=='Active' && ra.End_Date__c == NULL && ra.Primary__c==true && ra.Subscription_IsPrimary__c  == true && ra.Contact_ID__c !='' && ra.Association__c !=NULL){
     
           ContactsSet.add(ra.Contact_ID__c);  
         }       
      if(oldRA.Contact_ID__c !=''){
        ContactsSet.add(oldRA.Contact_ID__c);  
         }          
      }
  }
   
    if(Trigger.isDelete){
     for(Related_Association__c ra : Trigger.old){
        if(ra.Association_Status__c=='Active' && ra.Subscription_Status__c=='Active' && ra.Contact_Status__c=='Active' && ra.Status__c=='Active' && ra.End_Date__c == NULL && ra.Primary__c==true && ra.Subscription_IsPrimary__c  == true && ra.Contact_ID__c !='' && ra.Association__c !=NULL){
         ContactsSet.add(ra.Contact_ID__c);
        }
        }
    
    }
    
    List<Contact> ContactsRelatedAssToUpdate = new List<Contact>();
    List<Contact> ContactsToUpdate =  [Select ID, Name, Primary_Susbcription_Association_ID__c from contact WHERE ID IN:(ContactsSet)];
    List<Related_Association__c> RelatedAssocList =  [Select ID, Name, Subscription__c, Contact_ID__c, End_Date__c, Status__c, Association__c, Association_Status__c, Subscription_Status__c, Contact_Status__c from Related_Association__c where Association_Status__c = 'Active' AND Subscription_Status__c LIKE 'Active' AND Contact_Status__c LIKE 'Active' AND Status__c LIKE 'Active' AND End_Date__c = NULL AND Primary__c=true AND Subscription_IsPrimary__c  = true AND Contact_ID__c !='' AND Association__c !=NULL AND Contact_ID__c IN:(ContactsSet) ];
      
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
    
    
    
    for(Contact c : ContactsToUpdate){ 
      String cid = String.valueOf(c.ID); 
      Id relassID = c.Primary_Susbcription_Association_ID__c;
          
      if(!(RelAssMap.containsKey(cid))){
       system.debug('in execute 1 - rels does not have key for contact'); 
        if(relassID !=null){
           system.debug('contact has primary prim subs association'); 
           c.Primary_Susbcription_Association_ID__c =null;
           system.debug('in execute - null pr sub ass'); 
           ContactsRelatedAssToUpdate.add(c);
           system.debug('in execute prim sub ass:'+ c.Primary_Susbcription_Association_ID__c); 
           system.debug('in execute - update contact'); 
       }
       }
       else{
       //system.debug('in execute - key found'); 
        ID PrimAssKeyID = RelAssMap.get(cid);
        if(relassID != PrimAssKeyID){
         //system.debug('in execute - pr.sub.ass is different'); 
         c.Primary_Susbcription_Association_ID__c =PrimAssKeyID;
         //system.debug('execute start 6'); 
         ContactsRelatedAssToUpdate.add(c);
         //system.debug('execute start 7'); 
         }
       }
       
      }
      
     
      
    system.debug('Contacts to Update list size:'+String.valueOf(ContactsRelatedAssToUpdate.size()));
    update ContactsRelatedAssToUpdate; 
    system.debug('success - the end'); 
    }