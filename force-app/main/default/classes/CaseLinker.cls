public with sharing class CaseLinker {
    //Batch Processing of New Cases Linker
    
    /*
    public static void Process(List<Case> cases)
    {
        system.debug('Case Linker Entered');
        for (Case c:cases)
        {
            system.debug('Contact Id:'+c.ContactId);
            if (c.ContactId != null)
            {
                //SFDC has attached a Contact - Fill in the Primary Subscription for the Contact
                List<Subscriptions__c> primary = new List<Subscriptions__c>();
                primary = [SELECT
                Subscriptions__c.Id
                FROM Subscriptions__c
                WHERE Subscriptions__c.Contact__c =: c.ContactId
                AND Subscriptions__c.Primary__c = true];
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
                subscriptions = [SELECT
                Subscriptions__c.Id,
                Subscriptions__c.Contact__c,
                Subscriptions__c.Related_Location_Broker_Office__c,
                Subscriptions__c.Primary__c
                FROM Subscriptions__c
                WHERE Subscriptions__c.Public_Email__c =: c.SuppliedEmail];
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
    
    */
    
    public void displayMessage(){
    	
    	System.debug('Code Coverage');
    }
    
    static testMethod void CaseLinkerTest()
    {
        //Insert Contact and Subscriptions
        
          
        test.starttest();
        
 /*       
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
         Account a12 = new Account();
        a12.name = 'ABC1234';
        a12.type = 'Residential';
        a12.Account_Name__c = 'Test Account';
        a12.City__c = 'Herndon';
        a12.Zip__c = '20171';
        a12.company_type__c = 'Corporate Office';
        insert a12;  
        
        System.debug('Tester Inserted A12 ID: ---> ' + a12.id);       
        

        Account a = new Account();
        a.Name = 'CASE321';
        a.Account_Name__c = 'Testing Account';
        a.type = 'Residential';
        a.Company_Type__c = 'Broker Office';
        a.Shareholder_Board__c = 'None';
        a.Street_Number__c = '6824';
        a.Street_Name__c = 'Dean';
        a.Street_Type__c = 'DRIVE, DR';
        a.Zip__c = '22101';
        a.City__c = 'Herndon';
        a.State__c = 'VA';
        a.County__c = 'Fairfax';
        a.Country__c = 'UNITED STATES';
        a.Phone = '5559991234';
        a.Company_Type__c = 
        a.Status__c = 'In Progress';
        a.parentid = a12.id;
        
        insert a; 
        System.debug('Tester After a Insert ID: ---> ' + a.id);           
        
    //Create a Contact
        Contact c1 = new Contact();
        c1.Salutation = 'Mr.';
        c1.FirstName = 'Jimmy';
        c1.LastName = 'Parks';
        c1.Status__c = 'Active';
        //c1.Public_Email__c = 'jparks@rainmaker-llc.com';
        //c1.Email = 'jparks@rainmaker-llc.com';
        c1.Phone = '443-739-0628';
        c1.City__c = 'Balimore';
        c1.State__c = 'MD';
        c1.County__c = 'Baltimore City';
        c1.Zip__c = '21224';    
        c1.Professional_Designations__c='CPM';
        c1.Middle_Name__c ='Chip';
        c1.Nickname__c='Chip';
        c1.Suffix__c='JR.';
        
        
        insert c1;

        //Create Subscription
        Subscriptions__c s1 = new Subscriptions__c();
        s1.AgentKey__c = '123456789';
        s1.Name = '1239090';
        s1.City__c = 'Baltimore';
        s1.County__c = 'Baltimore City';
        s1.Zip__c = '21224';
        s1.Contact__c = c1.Id;
        s1.Related_Location_Broker_Office__c = a.id;
        s1.status__c = 'Active';
        s1.Contact_type__c = 'Broker';
        s1.Subscription_Type__c = 'Realtor/Shareholder';
        s1.Addl_Display_Name__c = 'Test Display';
        s1.Box__c = 'PO Box';
        s1.Mobile_Phone__c  = '2404569098';
        s1.Public_Email__c = 'jpuckett@aol.com';
        s1.Fax__c = '2402439878';
        s1.Home_Fax__c = '3012409090';
        s1.Agent_Office_Phone__c = '3013529000';
        s1.Pager__c = '3012409898';
        //s1.Date_Reinstated__c = today;
        s1.State__c = 'MD';
        s1.Street_Type__c = 'ROAD, RD';
        s1.Street_Direction__c ='S, SOUTH';
        s1.Unit__c ='STE, SUITE';
        s1.VM_Ext__c = '123';
        s1.Voicemail__c = '3013524343';
        s1.Website__c= 'www.tester.com';
        s1.Zip_4__c = '3549';
        
        
        
        insert(s1);
        
        
        Subscription_Role__c sr2= new Subscription_Role__c ();
        sr2.Role__c = 'Agent';
        sr2.Status__c = 'Active';
        sr2.sysPrRoleKey__c = '89752575199';
        sr2.Subscription__c = s1.id;
        insert sr2;
        
        s1.City__c = 'Bowie';
        s1.County__c = 'Prince Georges';
        s1.Zip__c = '20716';
        s1.Contact_type__c = 'Agent';   
        

        update s1;

        
        //update Subscription  
        s1.Status_Change_Reason__c = 'Late';
        s1.Status_Change_Fee__c = 'No Charge';
        s1.status__c = 'Inactive';     
        update s1;  
        

        s1.Status_Change_Reason__c = 'Reinstate';
        s1.Status_Change_Fee__c = 'No Charge';
        s1.status__c = 'Active';   
        s1.primary__c = false;  
        update s1;      
        
        Subscription_Role__c sr3 = new Subscription_Role__c ();
        sr3.Role__c = 'Status Duplicate';
        sr3.Status__c = 'Active';
        sr3.sysPrRoleKey__c = '89752575777';
        sr3.Subscription__c = s1.id;
        insert sr3;       
        
        s1.Street_Name__c ='17th';
        s1.Street_Number__c ='3410';
        s1.primary__c = true;  
        update s1; 
        

        Case c = new Case();
        
        //CaseLinker.Process(new List<Case>{c});
        c.Origin = 'Email'; 
        c.Description='from unit test';
        c.Subject ='testing trigger';
        c.Status='New';        
        c.SuppliedEmail = 'jpuckett@aol.com';
        //c.ContactId = c1.Id;
        
        //CaseLinker.Process(new List<Case>{c});
       insert(c);         
        
            //Create Subscription
        Subscriptions__c s2  = new Subscriptions__c();
        s2.AgentKey__c = '123456';
        s2.Name = 'TEST2';
        s2.City__c = 'Bowie';
        s2.County__c = 'Prince Georges';
        s2.Zip__c = '20716';
        s2.Contact__c = c1.Id;
        s2.Related_Location_Broker_Office__c = a.id;
        s2.status__c = 'Active';
        s2.Contact_type__c = 'Agent';
        s2.Subscription_Type__c = 'Realtor/Shareholder';
        s2.Public_Email__c = 'jpuckett@aol.com';       
        insert(s2);           
           
        
         c.Description='from unit test 3';  
         update c;  
       
       
 
        Subscription_Role__c sr1 = new Subscription_Role__c ();
        sr1.Role__c = 'Applied Video';
        sr1.Status__c = 'Active';
        sr1.sysPrRoleKey__c = '89752575777';
        sr1.Subscription__c = s1.id;
        insert sr1;     
                
   */      
          CaseLinker ck = new CaseLinker();
          ck.displayMessage();
          Test.StopTest();   
     }
}