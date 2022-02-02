@isTest
private class ResendToLmsEx_Test{

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;  
   
    private static testMethod void doTestOne(){       
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Test.startTest();
            
            createTestData();
            
            PageReference resendToLms = Page.ResendToLms; 
            Test.setCurrentPage(resendToLms);
            
            ApexPages.StandardController controller = new ApexPages.StandardController(subscription); 
            ResendToLmsEx resendToLmsEx = new ResendToLmsEx(controller);
            resendToLmsEx.ResendSub();
                        
            Test.stopTest();
        }
        
    }
    
    private static testMethod void doTestTwo(){       
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            Test.startTest();
            
            createTestData();
            
            PageReference resendToLms = Page.ResendToLms; 
            Test.setCurrentPage(resendToLms);
           
            subscription.Resend_to_LMS_Flag__c = null;            
            update subscription;
            
            Related_Association__c  relationshipOne = [SELECT Resend_to_LMS_Flag__c FROM Related_Association__c LIMIT 1];
            relationshipOne.Resend_to_LMS_Flag__c = 999999999999999999L;
            update relationshipOne ;
            
            ApexPages.StandardController controller = new ApexPages.StandardController(subscription); 
            ResendToLmsEx resendToLmsEx = new ResendToLmsEx(controller);
            resendToLmsEx.ResendSub();
                        
            Test.stopTest();
        }
        
    }
    
    private Static void createTestData(){
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();    
        
        account = new Account();
        account.name = 'ADA1231';
        account.type = 'Residential';
        account.Account_Name__c = 'Main Account';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert account;
        
        Account relatedAccountOne = new Account();
        relatedAccountOne.name = 'ADA1232';
        relatedAccountOne.type = 'Association';
        relatedAccountOne.Account_Name__c = 'Related Account Association';
        relatedAccountOne.City__c = 'Herndon';
        relatedAccountOne.Zip__c = '20171';
        relatedAccountOne.QAS_Mailing_County__c = 'Fairfax';
        relatedAccountOne.County__c = 'Fairfax';
        relatedAccountOne.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert relatedAccountOne;
        
        Account relatedAccountTwo = new Account();
        relatedAccountTwo.name = 'ADA1233';
        relatedAccountTwo.type = 'Association';
        relatedAccountTwo.Account_Name__c = 'Related Account Association';
        relatedAccountTwo.City__c = 'Herndon';
        relatedAccountTwo.Zip__c = '20171';
        relatedAccountTwo.QAS_Mailing_County__c = 'Fairfax';
        relatedAccountTwo.County__c = 'Fairfax';
        relatedAccountTwo.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert relatedAccountTwo;          
        
        contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = account.Id; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact; 
        
        subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contact.id;
        subscription.Primary__c = true;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Resend_to_LMS_Flag__c = 0;
        subscription.Public_Email__c = 'email@something.com';            
        insert subscription;             
        
        Related_Association__c associationOne = new Related_Association__c ();
        associationOne.Association__c = relatedAccountOne.id;
        associationOne.Broker_Code__c = account.id;
        associationOne.Resend_to_LMS_Flag__c = null;
        associationOne.Subscription__c = subscription.Id;
        associationOne.Primary__c = true;
        associationOne.Status__c = 'Failed';
        insert associationOne;
        
        Related_Association__c associationTwo = new Related_Association__c ();
        associationTwo.Association__c = relatedAccountTwo.id;
        associationTwo.Broker_Code__c = account.id;
        associationTwo.Subscription__c = subscription.Id;
        associationTwo.Primary__c = true;            
        insert associationTwo;
        
        Relationship__c relationshipOne = new Relationship__c();
        relationshipOne.Relationship_Type__c = 'Broker Of Record';
        relationshipOne.Subscription__c =   subscription.id;
        relationshipOne.Related_Account__c = account.id;
        relationshipOne.MDS_Status__c = 'Success';
        relationshipOne.Broker_Office__c = account.id;
        relationshipOne.Contact__c = subscription.Contact__c;
        insert relationshipOne; 
        
        Relationship__c relationshipTwo = new Relationship__c();
        relationshipTwo.Relationship_Type__c = 'Authorized Signer';
        relationshipTwo.Subscription__c =   subscription.id;
        relationshipTwo.Related_Account__c = account.id;
        relationshipTwo.MDS_Status__c = 'Success';
        relationshipTwo.Broker_Office__c = account.id;
        relationshipTwo.Contact__c = subscription.Contact__c;
        relationshipTwo.Resend_to_LMS_Flag__c = null;
        insert relationshipTwo; 
    }
        
    
}