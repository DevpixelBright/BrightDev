@isTest
private class MrisReinstatementExtension_Test{    
   
    private static testMethod void doTestOne(){        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
            generateData();     
            
            Account parentAccount = createParentAccount();
            Account childAccount = createChildAccount(parentAccount.Id, 'Association', 'XYZ123');
            childAccount.Shareholder_Board__c = 'Yes';
            update childAccount ;

            Account relatedAccount = createChildAccount(parentAccount.Id, 'Association', 'XYZ321');
            relatedAccount.Shareholder_Board__c = 'Yes';
            update relatedAccount;
            
            Contact contact = createContact(relatedAccount.Id);
            
            Subscriptions__c subscription = createSubscription(relatedAccount.Id,contact.Id);
            
            MRIS_Application__c mrisApplication = createMRISApplication(parentAccount.Id, relatedAccount.Id, subscription.Id);
            
            PageReference pageRef = Page.ReinstateAgent;
            pageRef.getParameters().put('id', mrisApplication.id);
            Test.setCurrentPage(pageRef);
            
            Apexpages.StandardController controller = new Apexpages.StandardController(mrisApplication);
            MrisReinstatementExtension extension = new MrisReinstatementExtension(controller);
            
            extension.getRealtorSelection();
            extension.setRealtorSelection('Yes');
            
            extension.getNonRealtorSelection();
            extension.setNonRealtorSelection('Licensed Real Estate Agent');
            
            extension.getOfficeSecretaryNCSelection();
            extension.setOfficeSecretaryNCSelection('Yes');
            
            extension.getLicenseTypeSelection();
            extension.setLicenseTypeSelection('Associate Broker');
            
            extension.getAppraiserName();
            extension.setAppraiserName('Appraiser');
            
            
            extension.getApplication();
            extension.setApplication(mrisApplication);

            extension.getshowRealtor();
            extension.getshortExpDate();
            extension.getshowPDF();
            extension.setshowPDF(true);          
            
            extension.getshowSecretaryQuestion();
            extension.getshowPersonalAssistant();
            extension.getshowRealEstate();
            extension.getshowFooter();

            
            extension.setSubscription();
            
            extension.getAssociations();
            extension.getLicenseType();
            extension.getNonRealtor();
            extension.getRealtor();
            
            //extension.FindSubscriptionId();
            extension.Print();
            extension.Save();
        
            Test.stopTest();
        } 
    } 
    
    private static testMethod void doTestTwo(){        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
            generateData();     
            
            Account parentAccount = createParentAccount();
            Account relatedAccount = createChildAccount(parentAccount.Id, 'Association', 'XYZ321');
            
            Contact contact = createContact(relatedAccount.Id);
            
            Subscriptions__c subscription = createSubscription(relatedAccount.Id,contact.Id);
            
            MRIS_Application__c mrisApplication = createMRISApplication(parentAccount.Id, relatedAccount.Id, subscription.Id);
            
            PageReference pageRef = Page.ReinstateAgent;
            pageRef.getParameters().put('id', mrisApplication.id);
            Test.setCurrentPage(pageRef);
            
            Apexpages.StandardController controller = new Apexpages.StandardController(mrisApplication);
            MrisReinstatementExtension extension = new MrisReinstatementExtension(controller);
            
            extension.getRealtorSelection();
            extension.setRealtorSelection('No');
            
            extension.getNonRealtorSelection();
            extension.setNonRealtorSelection('Licensed Real Estate Agent');
            
            extension.setSubscription();
        
            Test.stopTest();
        } 
    } 
    
    private static testMethod void doTestThree(){        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
            generateData();     
            
            Account parentAccount = createParentAccount();
            Account relatedAccount = createChildAccount(parentAccount.Id, 'Association', 'XYZ321');
            
            Contact contact = createContact(relatedAccount.Id);
            
            Subscriptions__c subscription = createSubscription(relatedAccount.Id,contact.Id);
            
            MRIS_Application__c mrisApplication = createMRISApplication(parentAccount.Id, relatedAccount.Id, subscription.Id);
            mrisApplication.Subscription_Type__c = 'Personal Assistant';
            update mrisApplication;
            
            PageReference pageRef = Page.ReinstateAgent;
            //pageRef.getParameters().put('id', mrisApplication.id);
            Test.setCurrentPage(pageRef);
            
            Apexpages.StandardController controller = new Apexpages.StandardController(mrisApplication);
            MrisReinstatementExtension extension = new MrisReinstatementExtension(controller);
            
            extension.getRealtorSelection();
            extension.setRealtorSelection('No');
            
            extension.getNonRealtorSelection();
            extension.setNonRealtorSelection('Personal Assistant');
            
            extension.setSubscription();
        
            Test.stopTest();
        } 
    } 
    
    private static testMethod void doTestFour(){        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
            generateData();     
            
            Account parentAccount = createParentAccount();
            Account relatedAccount = createChildAccount(parentAccount.Id, 'Association', 'XYZ321');
            
            Contact contact = createContact(relatedAccount.Id);
            
            Subscriptions__c subscription = createSubscription(relatedAccount.Id,contact.Id);
            
            MRIS_Application__c mrisApplication = createMRISApplication(parentAccount.Id, relatedAccount.Id, subscription.Id);
            
            PageReference pageRef = Page.ReinstateAgent;
            pageRef.getParameters().put('id', mrisApplication.id);
            Test.setCurrentPage(pageRef);
            
            Apexpages.StandardController controller = new Apexpages.StandardController(mrisApplication);
            MrisReinstatementExtension extension = new MrisReinstatementExtension(controller);
            
            extension.getRealtorSelection();
            extension.setRealtorSelection('No');
            
            extension.getNonRealtorSelection();
            extension.setNonRealtorSelection('Office Secretary');
            
            extension.setSubscription();
        
            Test.stopTest();
        } 
    }  
    
    private static testMethod void doTestFive(){        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Test.startTest(); 
            generateData();     
            
            Account parentAccount = createParentAccount();
            Account relatedAccount = createChildAccount(parentAccount.Id, 'Association', 'XYZ321');
            
            Contact contact = createContact(relatedAccount.Id);
            
            Subscriptions__c subscription = createSubscription(relatedAccount.Id,contact.Id);
            
            MRIS_Application__c mrisApplication = createMRISApplication(parentAccount.Id, relatedAccount.Id, subscription.Id);
            
            PageReference pageRef = Page.ReinstateAgent;
            pageRef.getParameters().put('id', mrisApplication.id);
            Test.setCurrentPage(pageRef);
            
            Apexpages.StandardController controller = new Apexpages.StandardController(mrisApplication);
            MrisReinstatementExtension extension = new MrisReinstatementExtension(controller);
            
            extension.getRealtorSelection();
            extension.setRealtorSelection('Yes');
            
            extension.getNonRealtorSelection();
            extension.setNonRealtorSelection('Licensed Real Estate Agent');
            
            extension.setSubscription();
        
            Test.stopTest();
        } 
    } 
    
    private Static Account createParentAccount(){
    
        Account parentAccount = new Account();
        parentAccount.Name = 'XYZ111';
        parentAccount.Type = 'Corporate';
        parentAccount.Account_Name__c = 'Test Account';
        parentAccount.QAS_Mailing_County__c = 'Fairfax';
        parentAccount.County__c = 'Fairfax';
        parentAccount.City__c = 'Herndon';
        parentAccount.Zip__c = '20171';
        parentAccount.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        parentAccount.State__c = 'VA';
        parentAccount.Status__c = 'Active';
        parentAccount.Shareholder_Board__c = 'None';
        parentAccount.company_type__c = 'Corporate Office';
        insert parentAccount;     
        
        return parentAccount;
        
    }
    
    private Static Account createChildAccount(String pAccountId, String type, String name){
    
        Account childAccount = new Account();
        childAccount.Name = name;
        childAccount.ParentId = pAccountId;
        childAccount.Type = type;
        childAccount.Account_Name__c = 'Test Account';
        childAccount.QAS_Mailing_County__c = 'Fairfax';
        childAccount.County__c = 'Fairfax';
        childAccount.City__c = 'Herndon';
        childAccount.Zip__c = '20171';
        childAccount.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        childAccount.State__c = 'VA';
        childAccount.Status__c = 'Active';
        childAccount.Shareholder_Board__c = 'None';
        childAccount.Company_Type__c = 'Broker Office1'; 
        childAccount.OfficeKey__c = '10094283954';
        childAccount.Website = 'www.sample.com';
        
        insert childAccount; 
        
        return childAccount;  
    
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
        insert contact;  
        
        return contact;
    }
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId){
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
        subscription.Primary__c = true;
        subscription.Public_Email__c = 'someone@test.com';
        insert subscription; 
        
        return subscription;
    }
    
    private Static void createRelationship(String accountId, String relatedAccountId) {
    
        Relationship__c relationshipOne = new Relationship__c();
        relationshipOne.Relationship_Type__c = 'Broker Of Record';
        relationshipOne.MDS_Status__c = 'Success';
        relationshipOne.Broker_Office__c = accountId;
        relationshipOne.Related_Account__c = relatedAccountId;
        insert relationshipOne; 
    
    }
    
    private Static void createRelatedAssociation(String associationId, String brokerCodeId, Boolean isPrimary){
        Related_Association__c association = new Related_Association__c ();
        association.Association__c = associationId;
        association.Broker_Code__c = brokerCodeId;
        association.Primary__c = isPrimary;
        insert association;
    }
    
    private Static MRIS_Application__c createMRISApplication(String companyCodeId, String associationBoardId, String subscriptionId){ 
        MRIS_Application__c mrisApp = new MRIS_Application__c();
        mrisApp.Salutation__c = 'Mr.';
        mrisApp.First_Name__c = 'test';
        mrisApp.Last_Name__c = 'test';
        mrisApp.Primary_Phone__c = '9032902323';
        mrisApp.Mobile_Phone__c = '9032902323';
        mrisApp.Company_Code__c = companyCodeId;
        mrisApp.Agent_Subscription_ID__c = subscriptionId;
        mrisApp.Subscription_Type__c = 'Licensed Appraiser/Non Realtor';
        mrisApp.Association_Board_Affiliation__c = associationBoardId;
        mrisApp.Date_Expires_Month__c = 'Dec';
        mrisApp.Date_Expires_Year__c = '2055';
        
        List<Subscriptions__c> subscription = [SELECT id,Name FROM Subscriptions__c];
        mrisApp.Existing_Subscriber_ID__c = subscription[0].Name;
        insert mrisApp;
        
        return mrisApp;
    }        
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        
        List<CornerstoneMappings__c> cornerstoneMappings = new List<CornerstoneMappings__c>();
        
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