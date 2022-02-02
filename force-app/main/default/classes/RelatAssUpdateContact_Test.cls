@isTest
public class RelatAssUpdateContact_Test {

     static testMethod void testDoTest() {
           
    
    List<Account> accList = new  List<Account>();
    List<Contact> conList = new  List<Contact>();
    List<Subscriptions__c> subList = new  List<Subscriptions__c>();
    List<Relationship> relList = new  List<Relationship>();
    List<CornerstoneMappings__c> mappings = new  List<CornerstoneMappings__c>();
    
        CornerstoneMappings__c csmCityObj = new CornerstoneMappings__c();    
        csmCityObj.CornerstoneID__c = '10000045331';
        csmCityObj.LongValue__c = 'HERNDON-FAIRFAX-VA';
        csmCityObj.ParentLookupItem__c = '10000002985';
        csmCityObj.ParentLookupItemKey__c = '10000005773';
        //csmCityObj.ParenetLookupKeyID__c = '10000006018';
        csmCityObj.TypeName__c = 'HERNDON';
        csmCityObj.Type__c = 'Office/city';
        mappings.add(csmCityObj);
        
        CornerstoneMappings__c csmCityObj1 = new CornerstoneMappings__c();  
        csmCityObj1.CornerstoneID__c = '10000045331';
        csmCityObj1.LongValue__c = 'HERNDON-FAIRFAX-VA';
        csmCityObj1.ParentLookupItem__c = '10000002985';
        csmCityObj1.ParentLookupItemKey__c = '10000005773';      
        csmCityObj1.TypeName__c = 'HERNDON';
        csmCityObj1.Type__c = 'Agent/city';
        mappings.add(csmCityObj1);
        
        
        CornerstoneMappings__c csmCityObj2 = new CornerstoneMappings__c();    
        csmCityObj2.CornerstoneID__c = '10000005773';
        csmCityObj2.LongValue__c = 'FAIRFAX-VA';
        csmCityObj2.ParentLookupItem__c = '10000002984';
        csmCityObj2.ParentLookupItemKey__c = '10000003034';       
        csmCityObj2.TypeName__c = 'FAIRFAX';
        csmCityObj2.Type__c = 'Office/county';
        mappings.add(csmCityObj2);
        
        CornerstoneMappings__c csmCityObj3 = new CornerstoneMappings__c();  
        csmCityObj3.CornerstoneID__c = '10000005773';
        csmCityObj3.LongValue__c = 'FAIRFAX-VA';
        csmCityObj3.ParentLookupItem__c = '10000002984';
        csmCityObj3.ParentLookupItemKey__c = '10000003034';       
        csmCityObj3.TypeName__c = 'FAIRFAX';
        csmCityObj3.Type__c = 'Agent/county';
        mappings.add(csmCityObj3);
        
        
        CornerstoneMappings__c csmCityObj4 = new CornerstoneMappings__c();  
        csmCityObj4.CornerstoneID__c = '10000003034';
        csmCityObj4.LongValue__c = 'VA';
        csmCityObj4.ParentLookupItem__c = '10000002986';    
        csmCityObj4.TypeName__c = 'VA';
        csmCityObj4.Type__c = 'Agent/state';
        mappings.add(csmCityObj4);
        
        CornerstoneMappings__c csmCityObj5 = new CornerstoneMappings__c();  
        csmCityObj5.CornerstoneID__c = '10000003034';
        csmCityObj5.LongValue__c = 'VA';
        csmCityObj5.ParentLookupItem__c = '10000002986';       
        csmCityObj5.TypeName__c = 'VA';
        csmCityObj5.Type__c = 'Office/state';
        mappings.add(csmCityObj5);
        
        
        CornerstoneMappings__c csmCityObj6 = new CornerstoneMappings__c();  
        csmCityObj6.CornerstoneID__c = '10000000409';       
        csmCityObj6.TypeName__c = 'Mr.';
        csmCityObj6.Type__c = 'Agent/salutation';
        mappings.add(csmCityObj6);
        
        insert mappings;
        
        Account a = new Account();
        a.name = 'ABC1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.Zip__c = '20170';
        a.QAS_Mailing_County__c = 'Fairfax';   
        a.County__c = 'Fairfax';
        a.State__c = 'VA';
        a.Status__c='Active';
        accList.add(a);
        
        //Account a1 = new Account();
        //a1.name = 'ABC1235';
        //a1.type = 'Association';
        //a1.Account_Name__c = 'Test Account';
        //a1.City__c = 'Herndon';
        //a1.QAS_Mailing_County__c = 'Fairfax';       
        //a1.County__c = 'Fairfax';
        //a1.Zip__c = '20170';
        //a1.State__c = 'VA';
        //a1.Status__c='Active';
        //accList.add(a1);

        Account a2 = new Account();
        a2.name = 'ELENAO7892';
        a2.type = 'Association';
        a2.Account_Name__c = 'ELENAO7892';
        a2.City__c = 'Herndon';
        a2.Zip__c = '20170';
        a2.QAS_Mailing_County__c = 'Fairfax';   
        a2.County__c = 'Fairfax';
        a2.State__c = 'VA';
        a2.Status__c='Active';
        accList.add(a2);
        
        insert accList;
        
        Contact c = new Contact();
        c.Email = 'email@something.com';
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Public_Email__c = 'email@something.com';
        c.AccountId = a.id; 
        c.QAS_Mailing_County__c = 'Fairfax';
        c.Salutation = 'Mr.';
        c.City__c = 'Herndon';
        c.Zip__c = '20170';
        c.Primary_Contact__c=true;
        c.State__c = 'VA';
        c.Status__c='Active';
        conList.add(c);
        
        //Contact c1 = new Contact();
        //c1.Email = 'email1@something.com';
        //c1.FirstName = 'Test';
        //c1.LastName = 'Contact1';
        //c1.Public_Email__c = 'email1@something.com';
        //c1.AccountId = a1.id; 
        //c1.Salutation = 'Mr.';
        //c1.City__c = 'Herndon';
        //c1.QAS_Mailing_County__c = 'Fairfax';
        //c1.Zip__c = '20170';
        //c1.Primary_Contact__c=true;
        //c1.State__c = 'VA';
        //c1.Status__c='Active';
        //conList.add(c1);

        //Contact c2 = new Contact();
        //c2.Email = 'email2@something.com';
        //c2.FirstName = 'Test2';
        //c2.LastName = 'Contact2';
        //c2.Public_Email__c = 'email2@something.com';
        //c2.AccountId = a2.id; 
        //c2.Salutation = 'Mr.';
        //c2.City__c = 'Herndon';
        //c2.QAS_Mailing_County__c = 'Fairfax';
        //c2.Zip__c = '20170';
        //c2.Primary_Contact__c=true;
        //c2.State__c = 'VA';
        //c2.Status__c='Active';
        //conList.add(c2);

        insert conList;
        
        Subscriptions__c sc = new Subscriptions__c();
        sc.Name = '1234511';
        sc.Contact_Type__c = 'Agent';
        sc.Subscription_Type__c = 'Licensee';
        sc.Related_Location_Broker_Office__c = a.id;
        sc.Public_Email__c = 'emailsub@something.com';
        sc.Status__c = 'In Progress';
        sc.Primary_Phone__c = '1231111643';
        sc.Public_Email__c = 'email@something.com';
        sc.Mobile_Phone__c = '1231112643';
        sc.City__c = 'Herndon';
        sc.Zip__c = '20170';
        sc.County__c = 'Fairfax';
        sc.Country__c = 'UNITED STATES';
        sc.State__c = 'VA';
        sc.Contact__c = c.id;
        sc.Primary__c=true;       
        sc.Related_Location_Broker_Office__c = a.id;
        sc.Contact_Type__c = 'Agent';
        subList.add(sc);
      
        // Subscriptions__c sc1 = new Subscriptions__c();
        // sc1.Name = '1234521';
        // sc1.Contact_Type__c = 'Agent';
        //sc1.Subscription_Type__c = 'Licensee';
        //sc1.Related_Location_Broker_Office__c = a1.id;
        //sc1.Public_Email__c = 'email@something.com';
        //sc1.Status__c = 'In Progress';
        //sc1.Primary_Phone__c = '1231111643';
        //sc1.Public_Email__c = 'email@something.com';
        //sc1.Mobile_Phone__c = '1231112643';
        //sc1.City__c = 'Herndon';
        //sc1.Zip__c = '20170';
        //sc1.County__c = 'Fairfax';
        //sc1.Country__c = 'UNITED STATES';
        //sc1.State__c = 'VA';
        //sc1.Contact__c = c1.id;
        //sc1.Related_Location_Broker_Office__c = a.id;
        //sc1.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        //sc1.Contact_Type__c = 'Agent';
        //sc1.Primary__c=true;
        //subList.add(sc1);
        
        //Subscriptions__c sc2 = new Subscriptions__c();
        //sc2.Name = '1234531';
        //sc2.Contact_Type__c = 'Agent';
        //sc2.Subscription_Type__c = 'Licensee';
        //sc2.Related_Location_Broker_Office__c = a2.id;
        //sc2.Public_Email__c = 'email@something.com';
        //sc2.Status__c = 'In Progress';
        //sc2.Primary_Phone__c = '1231111643';
        //sc2.Public_Email__c = 'email@something.com';
        //sc2.Mobile_Phone__c = '1231112643';
        //sc2.City__c = 'Herndon';
        //sc2.Zip__c = '20171';
        //sc2.County__c = 'Fairfax';
        //sc2.Country__c = 'UNITED STATES';
        //sc2.State__c = 'VA';
        //sc2.Contact__c = c2.id;
        //sc2.Related_Location_Broker_Office__c = a.id;
        //sc2.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        //sc2.Contact_Type__c = 'Agent';
        //sc2.Primary__c = true;
        // insert sc2;
        //subList.add(sc2);
        insert subList;    
        
        sc.Status__c='Active';    
        update sc;
        
        
    
        //Test.startTest();
        Related_Association__c r1 = new Related_Association__c();
        r1.Broker_Code__c = a.id;
        r1.Subscription__c=sc.id;
        
        r1.Primary__c = true;
        r1.Association__c = a2.id;       
        r1.Status__c = 'Active';
        insert r1;
        
        
        Contact tc = [select Id, Primary_Susbcription_Association_ID__c, Name from Contact where Id = :c.Id];
        System.debug('contact primary sub ass value:'+tc.Primary_Susbcription_Association_ID__c);
        System.debug('sub asss primary ass value:'+a2.id);
        System.assertEquals(tc.Primary_Susbcription_Association_ID__c, a2.id);
        r1.Status__c = 'Inactive';  
        r1.End_Date__c=Date.today();   
        update r1;
        delete r1; 
        
    }
}