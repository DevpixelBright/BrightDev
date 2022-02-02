@isTest
private class AccountProcessingUtility_Test {

    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    /*
    private static testMethod void doTestOne(){        
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();       
        
        Account parentAccount = createParentAccount();
        Account childAccount = createChildAccount(parentAccount.Id, 'Residential', 'XYZ123');
        Account relatedAccount = createChildAccount(parentAccount.Id, 'Association', 'XYZ321');
            
        createRelationship(childAccount.Id, relatedAccount.Id);
        
        Related_Association__c associationOne = new Related_Association__c ();
        associationOne.Association__c = relatedAccount.id;
        associationOne.Broker_Code__c = childAccount.id;
        associationOne.Primary__c = true;
        insert associationOne;
        
        Related_Association__c associationTwo = new Related_Association__c ();
        associationTwo.Association__c = relatedAccount.id;
        associationTwo.Broker_Code__c = childAccount.id;      
        insert associationTwo;        
             
        Map<Id,String> newJsonAccountString = new Map<Id,String>();
        Map<Id,String> oldJsonAccountString = new Map<Id,String>();
        
        newJsonAccountString.put(childAccount.id, JSON.serialize(childAccount));
        AccountProcessingUtility.sendAccountsToQueueProcessor('INSERT', newJsonAccountString, null); 
    }
    */
  
    
    private static testMethod void doTestTwo(){  
    
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
        parentAccount.Phone = '9999999999'; 
        parentAccount.Fax = '9999999999';  
    
        AccountProcessingUtility_New.buildOfficeResourceMessage(parentAccount, 'INSERT');            
        
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();       
        
        Account parentAccount1 = createParentAccount();
        Account childAccount = createChildAccount(parentAccount1.Id, 'Residential', 'XYZ123');
        Account relatedAccount = createChildAccount(parentAccount.Id, 'Association', 'XYZ321');
        createRelationship(childAccount.Id, relatedAccount.Id);      
        
        childAccount.Shareholder_Board__c = 'Yes';
        childAccount.Type = 'Commercial';
        childAccount.Company_Type__c = 'Broker Office';
        childAccount.Status__c = 'Inactive';
        update childAccount; 
        
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
        insert childAccount; 
        
        return childAccount;  
    
    }
    
    private Static void createRelationship(String accountId, String relatedAccountId) {
    
        Relationship__c relationshipOne = new Relationship__c();
        relationshipOne.Relationship_Type__c = 'Broker Of Record';
        relationshipOne.MDS_Status__c = 'Success';
        relationshipOne.Broker_Office__c = accountId;
        relationshipOne.Related_Account__c = relatedAccountId;
        insert relationshipOne; 
    
    }
    
}