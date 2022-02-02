public class CaseLinkerBatch{

       public  List<String> contactList = new List<String>();
       public  List<String> emailList= new List<String>();
 
    public  void Process(List<Case> cases)
    {
                // Gather all of the Contacts IDs to acquire the Subscriptions
                for (Case c:cases){
                       contactList.add(c.ContactId);
                    if ((c.SuppliedEmail != null) && !''.equals(c.SuppliedEmail.trim())) {
                         emailList.add(c.SuppliedEmail);
                    }
                      
                }
                System.debug('contactList----> ' + contactList);
                System.debug('emailList ---> ' + emailList);
                
                if (contactList.size() == 0 || emailList.size() == 0) {
                    return;
                }
               Map<Id, Subscriptions__c> subMapID = new Map<Id, Subscriptions__c>([SELECT 
                Subscriptions__c.Id,
                Subscriptions__c.Contact__c
                FROM Subscriptions__c 
                WHERE Subscriptions__c.Contact__c IN  :contactList AND Subscriptions__c.Primary__c = true]);
                
                if (subMapID.keySet().size() == 0) {
                    return;
                }
                
            //     put limit because of  returning Too many query rows  
            
              /* Map<id, Subscriptions__c> subMapEmail = new Map<Id, Subscriptions__c>([SELECT
                Subscriptions__c.Id,
                Subscriptions__c.Contact__c,
                Subscriptions__c.Related_Location_Broker_Office__c,
                Subscriptions__c.Primary__c,
                Subscriptions__c.Public_Email__c 
                FROM Subscriptions__c
                WHERE Subscriptions__c.Public_Email__c  in :emailList LIMIT 49999]);*/

        
        for (Case c:cases)
        {
            if (c.ContactId != null)
            {
                //SFDC has attached a Contact - Fill in the Primary Subscription for the Contact
                List<Subscriptions__c> primary = new List<Subscriptions__c>();
                
                for(id i: subMapID.keySet()){
                    Subscriptions__c sub = subMapId.get(i);
                    if(c.ContactId == sub.Contact__c){
                        primary.add(sub);
                    }
                
                }
                
                //primary = [SELECT
                //Subscriptions__c.Id
               // FROM Subscriptions__c
               // WHERE Subscriptions__c.Contact__c =: c.ContactId
                //AND Subscriptions__c.Primary__c = true];
                
                
                
                
                if (primary.size() > 0)
                {
                    //JGP Add account information?
                    //Only a single record should be primary for the contact, use zero indexed subscription
                    c.Subscription_ID__c = primary[0].Id;
                }
            }
            else //The Contact was not found - Attempt to match to subscription Public Email Address
            {
                List<Subscriptions__c> subscriptions = new List<Subscriptions__c>();
                
                /*for(id k: subMapEmail.keySet()){
                    Subscriptions__c sub = subMapEmail.get(k);
                    if(c.SuppliedEmail == sub.Public_Email__c){
                        subscriptions.add(sub);
                    }
                
                } */             
                
                
                subscriptions = [SELECT
                Subscriptions__c.Id,
                Subscriptions__c.Contact__c,
                Subscriptions__c.Related_Location_Broker_Office__c,
                Subscriptions__c.Primary__c
                FROM Subscriptions__c
                WHERE Subscriptions__c.Public_Email__c =: c.SuppliedEmail limit 100];
                
                
                
                if (subscriptions.size() > 0)
                {
                    if (subscriptions.size() == 1)
                    {
                        //Only one subscription was found under public email
                        c.Subscription_ID__c = subscriptions[0].Id;
                        c.ContactId = subscriptions[0].Contact__c;
                        c.AccountId = subscriptions[0].Related_Location_Broker_Office__c;
                    }
                    else //More than one Subscription was found
                    {
                        Map<Id,Contact> contact = new Map<Id,Contact>();
                        //Determine if more than one Contact was found under the subscriptions
                        for (Subscriptions__c subscription:subscriptions)
                        {
                            if (!contact.containsKey(subscription.Contact__c))
                            {
                                //Get the Contact details since it's a new contact
                                List<Contact> temp = new List<Contact>();
                                temp = [SELECT
                                Contact.Id,
                                Contact.AccountId
                                FROM Contact
                                WHERE Contact.id =: subscription.Contact__c];
                                if (temp.size() > 0)
                                {
                                    //Will only return one record, use zero indexed contact record
                                    contact.put(subscription.Contact__c,temp[0]);
                                }
                            }
                        }
                        //We now have the contact information that we need for each subscription
                        //Find the Primary Subscription
                        if (contact.size() == 1)
                        {
                            //All subscriptions belong to a single Contact - Assign to Primary Subscription 
                            //for this Contact
                            Subscriptions__c primarySubscription = null;
                            for (Subscriptions__c subscription:subscriptions)
                            {
                                if (subscription.Primary__c == true)
                                {
                                    primarySubscription = subscription;
                                    break;
                                }
                            }
                            if (primarySubscription != null)
                            {
                                //Assign Subscription, Contact and Account Info
                                c.Subscription_ID__c = primarySubscription.Id;
                                c.ContactId = primarySubscription.Contact__c;
                                c.AccountId = primarySubscription.Related_Location_Broker_Office__c;
                            }               
                        }
                    }
                }
            }
        }       
        
    }

}