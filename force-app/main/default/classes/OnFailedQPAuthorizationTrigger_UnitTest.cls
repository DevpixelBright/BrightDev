@isTest
public class OnFailedQPAuthorizationTrigger_UnitTest {
  
      static testMethod void testOnFailedQPAuthorization() {
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();    
         
        Account a = new Account();
        a.name = 'ABC1234';
        a.type = 'ACCOUNT';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.Zip__c = '20171';
        a.MDS_Status__c = 'Sent';
        a.QAS_Mailing_County__c = 'Fairfax';
      //  a.QAS_Billing_Country__c = 'CAN';
        a.County__c = 'Fairfax';
        a.Country__c = 'UNITED STATES';
        a.Phone = '5559991234';
        a.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
       // WASHINGTON
        insert  a;      
        
        Account a2 = new Account();
        a2.name = 'ABC1236';
        a2.type = 'Association';
        a2.Account_Name__c = 'Test Account';
        a2.City__c = 'Herndon';
        a2.Zip__c = '20171';
        a2.MDS_Status__c = 'Sent';
        a2.County__c = 'Fairfax';
        a2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        
        
        
        Contact c2 = new Contact();
        c2.Email = 'email@something.com';
        c2.FirstName = 'Test';
        c2.LastName = 'Contact';
        c2.Public_Email__c = 'email@something.com';
        c2.AccountId = a2.id; 
        c2.Salutation = 'Mr.';
        c2.City__c = 'Herndon';
        c2.QAS_Mailing_County__c = 'Arlington';
        c2.Zip__c = '20171';
        
        insert c2;
            
        
        Subscriptions__c sc2 = new Subscriptions__c();
        sc2.Name = '1234531';
        sc2.Contact_Type__c = 'Agent';
        sc2.Subscription_Type__c = 'Licensee';
        sc2.Related_Location_Broker_Office__c = a2.id;
        sc2.Public_Email__c = 'email@something.com';
        sc2.Status__c = 'In Progress';
        sc2.Primary_Phone__c = '1231111643';
        sc2.Public_Email__c = 'email@something.com';
        sc2.Mobile_Phone__c = '1231112643';
        sc2.City__c = 'Herndon';
        sc2.Zip__c = '20171';
        sc2.County__c = 'Fairfax';
        sc2.Country__c = 'UNITED STATES';
        sc2.State__c = 'VA';
        sc2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc2.Contact__c = c2.id;
        sc2.Related_Location_Broker_Office__c = a.id;
        sc2.Contact_Type__c = 'Agent';
        sc2.Public_Email__c = 'test@something.com';
        insert sc2;
        
        Relationship__c rr = new Relationship__c();
        rr.Relationship_Type__c = 'Corporate';
        rr.Related_Account__c = a.id;
        rr.MDS_Status__c = 'Success';
        rr.Broker_Office__c = a.id;
        insert rr;
        
        Related_Association__c r1 = new Related_Association__c();
        r1.Broker_Code__c = a.id;
        r1.Primary__c = true;
        r1.Association__c = a2.id;   
        r1.Status__c = 'Active';
                    
        insert r1;
        
        Subscription_Role__c sr1 = new Subscription_Role__c ();
        sr1.Role__c = 'Applied Video';
        sr1.Status__c = 'Active';
        sr1.sysPrRoleKey__c = '89752575777';
        sr1.Subscription__c = sc2.id;
        sr1.Role__c = 'Status Active';

        insert sr1;
        
        
      
         
         SFQPConnector__c  connObj6 =  new SFQPConnector__c();
         connObj6.MessageSent__c = 'MSTest Message';
         connObj6.ObjectType__c = 'AccountRole';
         connObj6.QPMessage__c = 'QPTest Message';
         connObj6.QPStatus__c = 'Success';
         connObj6.relatedid__c = a.Id;
         connObj6.SFMessageID__c = 'SFTestMessageID6';
//         insert  connObj6;
         
         
         SFQPConnector__c  connObj7 =  new SFQPConnector__c();
         connObj7.MessageSent__c = 'MSTest Message';
         connObj7.ObjectType__c = 'AccountStockholder';
         connObj7.QPMessage__c = 'QPTest Message';
         connObj7.QPStatus__c = 'Success';
         connObj7.relatedid__c = a.Id;
         connObj7.SFMessageID__c = 'SFTestMessageID7';
//         insert  connObj7;
        
             
         List<SFQPConnector__c> subList = new  List<SFQPConnector__c>();
            subList.add(connObj6);
            subList.add(connObj7);
        
            insert subList; 
            update subList; 
 
  }

}