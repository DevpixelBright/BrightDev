@isTest
private class MRISServiceAccountProcessingUtility_Test{
   
    private static testMethod void doTestOne(){       
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Test.startTest();
            
            generateData();             
            
            Account account = createAccount('Broker Office','XYZ121');
            insert  account;
            
            Contact contact = createContact(account.Id);
            insert contact;
            
            Subscriptions__c subscriptionOne = createSubscription(account.Id, contact.Id, 'RETS/MDS');
            insert subscriptionOne;             
            
            MRISServiceAccountProcessingUtility_New.processServiceAccounts(subscriptionOne, account);
            
            Test.stopTest();
        }
        
    }
    
    private static testMethod void doTestTwo(){       
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Test.startTest();
            
            generateData();             
            
            Account account = createAccount('Broker Office','XYZ121');
            insert  account;
            
            Contact contact = createContact(account.Id);
            insert contact;            
            
            Subscriptions__c subscriptionTwo = createSubscription(account.Id, contact.Id, 'RETS');
            insert subscriptionTwo;             
            
            MRISServiceAccountProcessingUtility_New.processServiceAccounts(subscriptionTwo, account);                        
            
            Test.stopTest();
        }
        
    }
    
    private static testMethod void doTestThree(){       
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Test.startTest();
            
            generateData();             
            
            Account account = createAccount('Broker Office','XYZ121');
            insert  account;
            
            Contact contact = createContact(account.Id);
            insert contact;          
                      
            Subscriptions__c subscriptionThree = createSubscription(account.Id, contact.Id, 'MDS');
            insert subscriptionThree;           
            
            MRISServiceAccountProcessingUtility_New.processServiceAccounts(subscriptionThree, account);
            
            Test.stopTest();
        }
        
    }
    
    private static Account createAccount(String type,String name){
        Account account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        
        return account;
    }
    
    private static Contact createContact(String accountId){
        Contact contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        
        return contact; 
    }
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId, String subscriptionType){
        Subscriptions__c sc = new  Subscriptions__c();
        sc.Name = 'Test Subscription';
        sc.Contact__c = contactId;
        sc.Subscription_Type__c = subscriptionType;
        sc.Status__c = 'In Progress';
        sc.City__c = 'Herndon';
        sc.Zip__c = '20171';
        sc.County__c = 'Fairfax';
        sc.AgentKey__c = '123111';
        sc.name = '123111';
        sc.Related_Location_Broker_Office__c = accountId;
        sc.Contact_Type__c = 'Agent';
        sc.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        sc.County__c = 'Fairfax';
        sc.Public_Email__c = 'test@test.com';
        sc.Addl_Display_Name__c = 'Test';
        sc.QAS_Mailing_Country__c = 'USA';
        sc.QAS_Mailing_County__c = 'Fairfax';
        sc.State__c = 'VA';
        sc.QAS_Mailing_Street_Direction__c = 'NORTH';
        sc.Street_Name__c = 'First';
        sc.Street_Number__c ='1275';
        sc.Street_Number_Suffix__c = NULL;
        sc.Unit__c = '1';
        sc.QAS_Mailing_Unit_Type__c = 'SU';
        sc.Zip__c ='20002';
        sc.Zip_4__c = NULL;
        sc.QAS_Mailing_POBox__c = NULL;
        sc.QAS_Mailing_Record_Type__c = NULL;
        sc.Copy_Address_to_Billing__c = true;
        sc.QAS_Mailing_Record_Type__c = 'P';
        sc.QAS_Billing_Record_Type__c = 'P';
        sc.Primary__c = true;
        sc.Contact_Type__c = 'Vendor';
        
        return sc;
    }
    
    private Static Relationship__c createRelationship(String accountId, String relatedAccountId, String type) {
    
        Relationship__c relationship = new Relationship__c();
        relationship.Relationship_Type__c = type;
        relationship.MDS_Status__c = 'Success';
        relationship.Broker_Office__c = accountId;
        relationship.Related_Account__c = relatedAccountId;
        
        return relationship;
    
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        List<CornerstoneMappings__c> cornerstoneMappings = new List<CornerstoneMappings__c>();
        
        CornerstoneMappings__c mc8 = new CornerstoneMappings__c();
        mc8.CornerstoneID__c = '98765432123456789098765432123460';
        mc8.Type__c = 'Agent/streetTypes';
        mc8.TypeName__c = 'UNDEFINED, UNDEF';
        insert(mc8);
        
        CornerstoneMappings__c cm13 = new CornerstoneMappings__c();
        cm13.TypeName__c = 'Broker Office';
        cm13.CornerStoneID__c = ' 10041844140';
        insert cm13;
        
        CornerstoneMappings__c cm17 = new CornerstoneMappings__c();
        cm17.TypeName__c = 'MDS User Login';
        cm17.CornerStoneID__c = ' 10041844550';
        insert cm17;
        
        CornerstoneMappings__c cm16 = new CornerstoneMappings__c();
        cm16.TypeName__c = 'RETS Customer';
        cm16.CornerStoneID__c = ' 10041847740';
        insert cm16;
        
        CornerstoneMappings__c cm18 = new CornerstoneMappings__c();
        cm18.TypeName__c = 'Login';
        cm18.CornerStoneID__c = ' 10041847755';
        insert cm18;
        
        CornerstoneMappings__c cm14 = new CornerstoneMappings__c();
        cm14.TypeName__c = 'MRIS Vendor';
        cm14.CornerStoneID__c = ' 50000131624';
        insert cm14;       
        
        CornerstoneMappings__c cm15 = new CornerstoneMappings__c();
        cm15.TypeName__c = 'MRIS';
        cm15.CornerStoneID__c = ' 50000900598';
        insert cm15; 
       
         CornerstoneMappings__c cm1 = new CornerstoneMappings__c();
        cm1.TypeName__c = 'Association';
        cm1.CornerStoneID__c = '10234163875';
        insert cm1;
        
        CornerstoneMappings__c cm2 = new CornerstoneMappings__c();
        cm2.TypeName__c = 'Branch Office';
        cm2.CornerStoneID__c = '10041844141';
        insert cm2;
        
        
        CornerstoneMappings__c cm3 = new CornerstoneMappings__c();
        cm3.TypeName__c = 'Office';
        cm3.CornerStoneID__c = '10000065693';
        insert cm3;    
        
        CornerstoneMappings__c cm4 = new CornerstoneMappings__c();
        cm4.TypeName__c = 'Stockholder';
        cm4.CornerStoneID__c = '50000016059';
        insert cm4;        
        
        CornerstoneMappings__c cm5 = new CornerstoneMappings__c();
        cm5.TypeName__c = 'Agent';
        cm5.CornerStoneID__c = '10391959693';
        insert cm5;        
        
        CornerstoneMappings__c cm6 = new CornerstoneMappings__c();
        cm6.TypeName__c = 'Edit';
        cm6.CornerStoneID__c = '10244895319';
        insert cm6;        
            
        CornerstoneMappings__c cm7 = new CornerstoneMappings__c();
        cm7.TypeName__c = 'Lister';
        cm7.CornerStoneID__c = '10244895320';
        insert cm7; 
        
        CornerstoneMappings__c cm8 = new CornerstoneMappings__c();
        cm8.TypeName__c = 'Search';
        cm8.CornerStoneID__c = '10244895323';
        insert cm8;     
        
        CornerstoneMappings__c cm9 = new CornerstoneMappings__c();
        cm9.TypeName__c = 'Realtor/Shareholder';
        cm9.CornerStoneID__c = '50000131634';
        insert cm9;        
        
        CornerstoneMappings__c cm10 = new CornerstoneMappings__c();
        cm10.TypeName__c = 'System-MRIS';
        cm10.CornerStoneID__c = '50001337575';
        insert cm10;          
            
        CornerstoneMappings__c cm11 = new CornerstoneMappings__c();
        cm11.TypeName__c = 'Status Duplicate';
        cm11.CornerStoneID__c = '50000016003';
        insert cm11;
          
    }    
        
    
}