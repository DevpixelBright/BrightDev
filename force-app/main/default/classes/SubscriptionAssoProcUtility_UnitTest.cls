@isTest
private class SubscriptionAssoProcUtility_UnitTest {

    static User createUser(){
        Profile p = [SELECT Id FROM profile WHERE name='Standard User' limit 1];   
        User mockUser = new User(alias = 'UserTest', email='newusertest@testorg.com',
        emailencodingkey='UTF-8', lastname='TestingUser', 
        languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/Los_Angeles', username='newusertest@testorg.com');
        return mockUser;
    }
    static testMethod void subscriptionAssoProcUtilityUnitTest() {
        System.runAs(createUser()){
            test.starttest();
                                       
            CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
            cau.addAddrs();
            
            List<Account> accounts = new List<Account>();
    
            Account corporateAccount = new Account();
            corporateAccount.name = 'ABC133';
            corporateAccount.Account_Name__c = 'Test Account';
            corporateAccount.City__c = 'Herndon';
            corporateAccount.Zip__c = '20171';
            corporateAccount.OfficeKey__c = 'TESS1234';        
            corporateAccount.CS_AccountTypeRole_ID__c = '';
            corporateAccount.status__c = 'Active';
            corporateAccount.type = 'Corporate';
            corporateAccount.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
            corporateAccount.Company_Type__c = 'Corporate Office';   
            corporateAccount.QAS_Mailing_County__c = 'Fairfax';
            corporateAccount.County__c = 'Fairfax'; 
            corporateAccount.State__c = 'VA';     
            accounts.add(corporateAccount);
            
            Account corporateAccount2 = new Account();
            corporateAccount2.Name = 'CASE321';
            corporateAccount2.OfficeKey__c = '909090';
            corporateAccount2.Account_Name__c = 'Testing Account';
            corporateAccount2.type = 'Corporate';
            corporateAccount2.Company_Type__c = 'Corporate Office';
            corporateAccount2.Shareholder_Board__c = 'None';
            corporateAccount2.Street_Number__c = '6824';
            corporateAccount2.Street_Name__c = 'Dean';
            corporateAccount2.Zip__c = '22101';
            corporateAccount2.QAS_Mailing_County__c = 'Fairfax';
            corporateAccount2.City__c = 'Herndon';
            corporateAccount2.State__c = 'VA';
            corporateAccount2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
            corporateAccount2.Country__c = 'UNITED STATES';
            corporateAccount2.Phone = '5559991234';
            corporateAccount2.Company_Type__c = 
            corporateAccount2.Status__c = 'In Progress';
            corporateAccount2.QAS_Mailing_County__c = 'Fairfax';
            corporateAccount2.County__c = 'Fairfax';
            accounts.add(corporateAccount2);
            
            Account parentAssociationAccount = new Account();
            parentAssociationAccount.name = 'ABC1234';
            parentAssociationAccount.type = 'Association';
            parentAssociationAccount.Account_Name__c = 'Test Account';
            parentAssociationAccount.City__c = 'Herndon';
            parentAssociationAccount.Zip__c = '20171';
            parentAssociationAccount.OfficeKey__c = 'TESS1234';     
            parentAssociationAccount.QAS_Mailing_County__c = 'Fairfax';
            parentAssociationAccount.company_type__c = 'Corporate Office';
            parentAssociationAccount.PIN__c = '1234';
            parentAssociationAccount.Website = 'www.mywebsite.com';
            parentAssociationAccount.Trading_As__c = 'TERW';
            parentAssociationAccount.Box__c = 'BOW';
            parentAssociationAccount.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
            parentAssociationAccount.County__c = 'Fairfax'; 
            parentAssociationAccount.State__c = 'VA';     
            accounts.add(parentAssociationAccount);                        
            
            insert accounts;
            
            Account childAssociationAccount = new Account();
            childAssociationAccount.Name = 'CASE3212';
            childAssociationAccount.Account_Name__c = 'Testing Account';
            childAssociationAccount.type = 'Corporate';
            childAssociationAccount.Company_Type__c = 'Corporate Office';
            childAssociationAccount.OfficeKey__c = 'TETS1234';
            childAssociationAccount.Shareholder_Board__c = 'None';
            childAssociationAccount.Street_Number__c = '6824';
            childAssociationAccount.Street_Name__c = 'Dean';
            childAssociationAccount.QAS_Mailing_County__c = 'Fairfax';
            childAssociationAccount.Zip__c = '22101';
            childAssociationAccount.City__c = 'Herndon';
            childAssociationAccount.State__c = 'VA';
            childAssociationAccount.County__c = 'Fairfax';
            childAssociationAccount.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
            childAssociationAccount.Country__c = 'UNITED STATES';
            childAssociationAccount.Phone = '5559991234';
            childAssociationAccount.Company_Type__c = 
            childAssociationAccount.Status__c = 'In Progress';
            childAssociationAccount.parentid = parentAssociationAccount.id;
            childAssociationAccount.PIN__c = '1234';
            childAssociationAccount.Website = 'www.mywebsite.com';
            childAssociationAccount.Trading_As__c = 'TERW';
            childAssociationAccount.Box__c = 'BOW';
            childAssociationAccount.State__c = 'VA'; 
            insert childAssociationAccount;            
                
            Contact c1 = new Contact();
            c1.Salutation = 'Mr.';
            c1.FirstName = 'Jimmy';
            c1.LastName = 'Parks';
            c1.Status__c = 'Active';
            c1.AccountId = corporateAccount2.Id; 
            c1.Phone = '443-739-0628';
            c1.City__c = 'Balimore';
            c1.State__c = 'MD';
            c1.County__c = 'Baltimore City';
            c1.Zip__c = '21224';    
            c1.Professional_Designations__c='CPM';
            c1.Middle_Name__c ='Chip';
            c1.QAS_Mailing_County__c = 'Arlington';
            c1.Nickname__c='Chip';
            c1.Suffix__c='JR.';
            insert c1;   
            
            Subscriptions__c s = new  Subscriptions__c();
            s.Name = 'Test Subscription';
            s.Contact__c = c1.Id;
            s.Subscription_Type__c = 'Realtor/Shareholder';
            s.Status__c = 'In Progress';
            s.City__c = 'Herndon';
            s.Zip__c = '20171';
            s.County__c = 'Fairfax';
            s.AgentKey__c = '123112';
            s.name = '123112';
            s.Related_Location_Broker_Office__c = accounts[1].Id;
            s.Contact_Type__c = 'Agent';
            s.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
            s.County__c = 'Fairfax';
            s.Public_Email__c = 'test@test.com';
            s.Addl_Display_Name__c = 'Test';
            s.QAS_Mailing_Country__c = 'USA';
            s.QAS_Mailing_County__c = 'Fairfax';
            s.State__c = 'VA';
            s.QAS_Mailing_Street_Direction__c = 'NORTH';
            s.Street_Name__c = 'First';
            s.Street_Number__c ='1275';
            s.Street_Number_Suffix__c = NULL;
            s.Unit__c = '1';
            s.QAS_Mailing_Unit_Type__c = 'SU';
            s.Zip__c ='20002';
            s.Zip_4__c = NULL;
            s.QAS_Mailing_POBox__c = NULL;
            s.QAS_Mailing_Record_Type__c = NULL;
            s.Copy_Address_to_Billing__c = true;
            s.QAS_Mailing_Record_Type__c = 'P';
            s.QAS_Billing_Record_Type__c = 'P';
            s.Primary__c = true;
            insert s;                
                
            List<Related_Association__c> subscriptionAssociations = new List<Related_Association__c>();                                    
            
            Related_Association__c subPrimaryAssociation = new Related_Association__c();
            subPrimaryAssociation.Broker_Code__c = childAssociationAccount.id;
            subPrimaryAssociation.Primary__c = true;
            subPrimaryAssociation.Association__c = parentAssociationAccount.id;   
            subPrimaryAssociation.Status__c = 'Active';
            subPrimaryAssociation.Subscription__c = s.Id;
            subscriptionAssociations.add(subPrimaryAssociation);

            
            Related_Association__c subSecondaryAssociation = new Related_Association__c();
            subSecondaryAssociation.Broker_Code__c = childAssociationAccount.id;
            subSecondaryAssociation.Primary__c = false;
            subSecondaryAssociation.Association__c = parentAssociationAccount.id;
            subSecondaryAssociation.Status__c = 'Active';
            subSecondaryAssociation.Subscription__c = s.Id;  
            subscriptionAssociations.add(subSecondaryAssociation);
            
            insert subscriptionAssociations;
            
            subPrimaryAssociation.Status__c = 'Inactive';
            update subPrimaryAssociation;
            
            subSecondaryAssociation.Status__c = 'Inactive';
            update subSecondaryAssociation;
            
            
            List<Related_Association__c> subscriptionAssociations2 = new List<Related_Association__c>();                                    
            
            for(Integer i=0; i<3; i++) {
                Related_Association__c subPrimaryAssociation2 = new Related_Association__c();
                subPrimaryAssociation.Broker_Code__c = childAssociationAccount.id;
                subPrimaryAssociation.Primary__c = true;
                subPrimaryAssociation.Association__c = parentAssociationAccount.id;   
                subPrimaryAssociation.Status__c = 'Active';
                subPrimaryAssociation.Subscription__c = s.Id;
                subPrimaryAssociation.Notes__c = 'test' + String.valueOf(i);
                subscriptionAssociations2.add(subPrimaryAssociation2);
    
                
                Related_Association__c subSecondaryAssociation2 = new Related_Association__c();
                subSecondaryAssociation.Broker_Code__c = childAssociationAccount.id;
                subSecondaryAssociation.Primary__c = false;
                subSecondaryAssociation.Association__c = parentAssociationAccount.id;
                subSecondaryAssociation.Status__c = 'Active';
                subSecondaryAssociation.Subscription__c = s.Id;  
                subPrimaryAssociation.Notes__c = 'test' + String.valueOf(i+1);
                subscriptionAssociations2.add(subSecondaryAssociation2);                                
            }
            insert subscriptionAssociations2;
          
            test.stopTest();
        }
    }
    
}