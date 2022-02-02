@istest(seealldata = true)
public class Communities_MyAccount_Controller_Test {
   
   private static testMethod void doTestOne() {        
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'TREND');
        Contact c1 = createContact(a1.Id, 'TREND'); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');       
        s1.Status__c = 'Active';
        update  s1;
                
         /* Visual force page reference */  
        PageReference pageRef = Page.SMS_GenericPaymentPortal;
        Test.setCurrentPage(pageRef);
        
        /* Set subscription id parameter */
        ApexPages.currentPage().getParameters().put('id', s1.Name);
          
        User communityUser = createCommunityUser(s1.Name);             
        System.RunAs(communityUser) {                   
        
           Communities_MyAccount_Controller controller = new Communities_MyAccount_Controller();
            controller.edit();
             controller.reset();
             controller.cancel(); 
               List<String> streetType = new List<String>{
            'BLFS', 'BRKS','BLTY','BGS','CTRS','CIRS','CLF', 'CMNS','CVS', 'DRS','EXTS','FLT', 'FRDS', 'FRGS', 'GDN','GLNS',
            'GRNS','GRVS','HBRS','JCTS','LGTS','LF','MNRS','MTWY','OPAS','PARK','PKWY','PNE','PTS','PRTS','RAMP','RPD',
            'RDGS','RDS','RUE','SKWY','SPUR','SQS','TRWY','TRAK','TRFY','UPAS','UNS','VLYS','VLGS','WALK','WAYS','WL','ST',
            'ALY','ANX','ARC','AVE','BYU','BCH ','BLF ','BTM','BLVD','BR','BRG','BRK','BG','BYP','CP','CYN','CPE','CSWY',
            'CTR','CIR','CLFS','CLB','CMN','COR','CORS','CRSE','CT','CTS','CV','CRK','CRES','XING','XRD','XRDS','CURV','DL',
            'DM','DV','DR','EST','ESTS','EXPY','EXT','FALL','FLS','FRY','FLD','FLDS','FLTS','FRD','FRST','FRG','FRK','FRKS',
            'FT','FWY','GDNS','GTWY','GLN','GRN','GRV','HBR','HVN','HTS','HWY','HOLW','INLT','IS','ISS','ISLE','JCT','KY',
            'KYS','KNL','KNLS','LK','LKS','LAND','LNDG','LN','LGT','LCK','LCKS','LDG','LOOP','MALL','MNR','MDW','MDWS',
            'MEWS','ML','MLS','MSN','MT','MTN','MTNS','NCK','ORCH','OVAL','PARK','PKWY','PASS','PSGE','PATH','PIKE','PNES',
            'PL','PLN','PLNS','PLZ','PT','PRT','PR','RADL','RNCH','RPDS','RST','RDG','RIV','RD','RTE','ROW','RUN','SHL',
            'SHLS','SHR','SPG','SPGS','SPUR','SQ','STA','STRA','STRM','STS','SMT','TER','TRCE','TRL','TRLR','TUNL','TPKE',
            'UN','VLY','VIA','VW','VLG','VL','VIS','WALK','WALL','WAY','WLS'
        };
        List<String> streetDirection = new List<String>{'N','E','W','S','NE','SE','NW','SW'};
        List<String> unitType = new List<String>{
            'APT','BSMT','BLDG','DEPT','FL','FRNT','HNGR','KEY','LBBY','LOT','LOWR','OFC','PH','PIER','REAR','RM','SIDE',
            'SLIP','SPC','STOP','STE','TRLR','UNIT','UPPR'
        }; 

        Integer j = 0;
        Integer k = 0;
        for(Integer i=0; i<streetType.Size(); i++) {
            
            if(Math.mod(i,8) == 0)
                j = 0;
                
            if(Math.mod(i,24) == 0)
                k = 0;                
                        
            Subscriptions__c s = new  Subscriptions__c();
         
           // s.Name = 'Test Subscription';
            s.Contact__c = c1.Id;
            s.Subscription_Type__c = 'Realtor/Shareholder';
            s.Status__c = 'In Progress';
            s.City__c = 'Herndon';
            s.Zip__c = '20171';
            s.County__c = 'Fairfax';
            s.AgentKey__c = '123112';
            s.name = '12345';
            s.State__c = 'VA';
            s.Related_Location_Broker_Office__c = a1.Id;
            s.Contact_Type__c = 'Agent';
            s.QAS_Mailing_Street_Type__c = streetType[i];
            s.QAS_Billing_Street_Type__c = streetType[i];
            s.QAS_Mailing_Street_Direction__c = streetDirection[j];
            s.QAS_Billing_Street_Direction__c= streetDirection[j];
            s.QAS_Mailing_Unit_Type__c = unitType[k];
            s.QAS_Billing_Unit_Type__c = unitType[k];
            s.QAS_Mailing_County__c = 'Fairfax';
            s.Public_Email__c = 'test@test.com';
            s.Private_Email__c = 'test@test.com';
            s.Primary_Phone__c ='(703) 919-9466';
            s.Mobile_Phone__c = '(703) 919-9466';
            s.Service_Jurisdiction__c = 'TREND';
            s.TREND_Login_Name__c = 'TREND001'; 
            
            //commenting contact to avoid SOQL limit exception due to trigger on the contact update
            // s.Contact__r = c1;
            s.Billing_Addl_Display_Name__c='1234';
            s.Billing_Zip_4__c = '2222';
            s.Billing_Zip__c = '20171';
            s.Billing_City__c = 'Herndon';
            s.QAS_Billing_County__c = 'Fairfax';
            s.Billing_state__c = 'VA';
            controller.subscription = s;
            controller.save();
            j++;
            k++; 
        }        
   }       
}
     private static testMethod void doTestTwo() {        
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'TREND');
        Contact c1 = createContact(a1.Id, 'TREND'); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');       
        s1.Status__c = 'Active';
        update  s1;
                
         /* Visual force page reference */  
        PageReference pageRef = Page.SMS_GenericPaymentPortal;
        Test.setCurrentPage(pageRef);
        
        /* Set subscription id parameter */
        ApexPages.currentPage().getParameters().put('id', s1.Name);
          
        User communityUser = createCommunityUser(s1.Name);             
        System.RunAs(communityUser) {                   
        
           Communities_MyAccount_Controller controller = new Communities_MyAccount_Controller();
            controller.edit();
             controller.reset();
             controller.cancel(); 
           
           List<String> streetDirection = new List<String>{'N','E','W','S','NE','SE','NW','SW'};
           List<String> unitType = new List<String>{
            'APT','BSMT','BLDG','DEPT','FL','FRNT','HNGR','KEY','LBBY','LOT','LOWR','OFC','PH','PIER','REAR','RM','SIDE',
            'SLIP','SPC','STOP','STE','TRLR','UNIT','UPPR'
        }; 

        Integer j = 0;
        for(Integer i=0; i<unitType.Size(); i++) {
            if(Math.mod(i,8) == 0)
                j = 0;       
                        
            Subscriptions__c s = new  Subscriptions__c();
         
            s.Name = 'Test Subscription';
            s.Contact__c = c1.Id;
            s.Subscription_Type__c = 'Realtor/Shareholder';
            s.Status__c = 'In Progress';
            s.City__c = 'Herndon';
            s.Zip__c = '20171';
            s.County__c = 'Fairfax';
            s.AgentKey__c = '123112';
            s.name = '12345';
            s.State__c = 'VA';
            s.Related_Location_Broker_Office__c = a1.Id;
            s.Contact_Type__c = 'Agent';
            s.QAS_Mailing_Street_Type__c = 'HTS';
            s.QAS_Billing_Street_Type__c ='HTS';
            s.QAS_Mailing_Street_Direction__c = streetDirection[j];
            s.QAS_Billing_Street_Direction__c= streetDirection[j];
            s.QAS_Mailing_Unit_Type__c = unitType[i];
            s.QAS_Billing_Unit_Type__c = unitType[i];
            s.QAS_Mailing_County__c = 'DISTRICT OF COLUMBIA';
            s.Public_Email__c = 'test@test.com';
            s.Private_Email__c = 'test@test.com';
            s.Primary_Phone__c ='(703) 919-9466';
            s.Mobile_Phone__c = '(703) 919-9466';
            s.Service_Jurisdiction__c = 'TREND';
            s.TREND_Login_Name__c = 'TREND001'; 
            s.Contact__r = c1;
            s.Billing_Addl_Display_Name__c='1234';
            s.Billing_Zip_4__c = '2222';
            s.Billing_Zip__c = '20171';
            s.Billing_City__c = 'Herndon';
            s.QAS_Billing_County__c = 'DISTRICT OF COLUMBIA';
            s.Billing_state__c = 'VA';
                  
            controller.subscription = s;
            controller.save();
            j++;
        }
  }   
}
     private static testMethod void doTestThree() {        
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'TREND');
        Contact c1 = createContact(a1.Id, 'TREND'); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');       
        s1.Status__c = 'Active';
        update  s1;
                
         /* Visual force page reference */  
        PageReference pageRef = Page.SMS_GenericPaymentPortal;
        Test.setCurrentPage(pageRef);
        
        /* Set subscription id parameter */
        ApexPages.currentPage().getParameters().put('id', s1.Name);
          
        User communityUser = createCommunityUser(s1.Name);             
        System.RunAs(communityUser) {                   
        
           Communities_MyAccount_Controller controller = new Communities_MyAccount_Controller();
            controller.edit();
             controller.reset();
             controller.cancel(); 
           
           List<String> streetDirection = new List<String>{'N','E','W','S','NE','SE','NW','SW'};
           List<String> unitType = new List<String>{
            'APT','BSMT','BLDG','DEPT','FL','FRNT','HNGR','KEY','LBBY','LOT','LOWR','OFC','PH','PIER','REAR','RM','SIDE',
            'SLIP','SPC','STOP','STE','TRLR','UNIT','UPPR'
        }; 

        Integer j = 0;
        for(Integer i=0; i<unitType.Size(); i++) {
            if(Math.mod(i,8) == 0)
                j = 0;       
                        
            Subscriptions__c s = new  Subscriptions__c();
         
            
            s.Contact__c = c1.Id;
            s.Subscription_Type__c = 'Realtor/Shareholder';
            s.Status__c = 'In Progress';
            s.City__c = 'Herndon';
            s.Zip__c = '20171';
            s.County__c = 'Fairfax';
            s.AgentKey__c = '123112';
            s.name = '12345';
            s.State__c = 'VA';
            s.Related_Location_Broker_Office__c = a1.Id;
            s.Contact_Type__c = 'Agent';
            s.QAS_Mailing_Street_Type__c = 'HTS';
            s.QAS_Billing_Street_Type__c ='HTS';
            s.QAS_Mailing_Street_Direction__c = streetDirection[j];
            s.QAS_Billing_Street_Direction__c= streetDirection[j];
            s.QAS_Mailing_Unit_Type__c = unitType[i];
            s.QAS_Billing_Unit_Type__c = unitType[i];
            
            
            s.Private_Email__c = 'test@test.com';
            s.Primary_Phone__c ='(703) 919-9466';
            s.Mobile_Phone__c = '(703) 919-9466';
            s.Service_Jurisdiction__c = 'TREND';
            s.TREND_Login_Name__c = 'TREND001'; 
            s.Contact__r = c1;
    
            if (i == 1) {
                s.Name = null;
                s.Public_Email__c = null;
                s.Zip__c = null;
                s.City__c = null;
                s.Zip_4__c = '1234';
                s.QAS_Mailing_County__c = 'DISTRICT OF COLUMBIA';
                s.Billing_Addl_Display_Name__c='1234';
                s.Billing_Zip_4__c = '12';
                s.Billing_Zip__c = null;
                s.Billing_City__c = null;
                s.QAS_Billing_County__c = 'Fairfax';
                s.Billing_state__c = null;
            }
            controller.subscription = s;
            controller.save();
            j++;
        }
		}   
	}
	
	private static testMethod void doTestFour() {        
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'TREND');
        Contact c1 = createContact(a1.Id, 'TREND'); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'TREND');       
        s1.Status__c = 'Active';
        update  s1;
                
         /* Visual force page reference */  
        PageReference pageRef = Page.SMS_GenericPaymentPortal;
        Test.setCurrentPage(pageRef);
        
        /* Set subscription id parameter */
        ApexPages.currentPage().getParameters().put('id', s1.Name);
          
        User communityUser = createCommunityUser(s1.Name);             
        System.RunAs(communityUser) {                   
        
           Communities_MyAccount_Controller controller = new Communities_MyAccount_Controller();
           controller.edit();
           controller.reset();
           controller.cancel();
           controller.furtherValidate();
           
           List<String> streetDirection = new List<String>{'N','E','W','S','NE','SE','NW','SW'};
           List<String> unitType = new List<String>{
            'APT','BSMT','BLDG','DEPT','FL','FRNT','HNGR','KEY','LBBY','LOT','LOWR','OFC','PH','PIER','REAR','RM','SIDE',
            'SLIP','SPC','STOP','STE','TRLR','UNIT','UPPR'
        }; 

        Integer j = 0;
        for(Integer i=0; i<unitType.Size(); i++) {
            if(Math.mod(i,8) == 0)
                j = 0;       
                        
            Subscriptions__c s = new  Subscriptions__c();
         
            
            s.Contact__c = c1.Id;
            s.Subscription_Type__c = 'Realtor/Shareholder';
            s.Status__c = 'In Progress';
            s.City__c = 'Herndon';
            s.Zip__c = '20171';
            s.County__c = 'Fairfax';
            s.AgentKey__c = '123112';
            s.name = '12345';
            //s.State__c = 'VA';
            s.Related_Location_Broker_Office__c = a1.Id;
            s.Contact_Type__c = 'Agent';
            s.QAS_Mailing_Street_Type__c = 'HTS';
            s.QAS_Billing_Street_Type__c ='HTS';
            s.QAS_Mailing_Street_Direction__c = streetDirection[j];
            s.QAS_Billing_Street_Direction__c= streetDirection[j];
            s.QAS_Mailing_Unit_Type__c = unitType[i];
            s.QAS_Billing_Unit_Type__c = unitType[i];
            
            
            //s.Private_Email__c = 'test@test.com';
            //s.Primary_Phone__c ='(703) 919-9466';
            //s.Mobile_Phone__c = '(703) 919-9466';
            s.Service_Jurisdiction__c = 'TREND';
            s.TREND_Login_Name__c = 'TREND001'; 
            s.Contact__r = c1;
    
            if (i == 1) {
                s.Name = null;
                s.Public_Email__c = null;
                s.Zip__c = null;
                s.City__c = null;
                s.Zip_4__c = '12345';
                s.QAS_Mailing_County__c = 'DISTRICT OF COLUMBIA';
                s.Billing_Addl_Display_Name__c='1234';
                s.Billing_Zip_4__c = '12';
                s.Billing_Zip__c = null;
                s.Billing_City__c = null;
                s.QAS_Billing_County__c = 'Fairfax';
                s.Billing_state__c = null;
            }
            controller.subscription = s;
            controller.newValue = 'tr';
            controller.save();
                        
            j++;
        }
  }   
}
	
	private static testMethod void doTestFive() {        
        generateData();
        Account a1 = createAccount('Residential','XYZ124', 'BRIGHT');
        Contact c1 = createContact(a1.Id, 'TREND'); 
        Subscriptions__c s1 = createSubscription(a1.Id, c1.Id, 'BRIGHT');
        s1.TREND_Login_Name__c = '';
        s1.Status__c = 'Active';
        update  s1;
                
         /* Visual force page reference */  
        PageReference pageRef = Page.SMS_GenericPaymentPortal;
        Test.setCurrentPage(pageRef);
        
        /* Set subscription id parameter */
        ApexPages.currentPage().getParameters().put('id', s1.Name);
          
        User communityUser = createCommunityUser(s1.Name);             
        System.RunAs(communityUser) {                   
        
           Communities_MyAccount_Controller controller = new Communities_MyAccount_Controller();
           controller.edit();
           controller.reset();
           controller.cancel();
           controller.furtherValidate();
           controller.save();
           
           List<String> streetDirection = new List<String>{'N','E','W','S','NE','SE','NW','SW'};
           List<String> streetType = new List<String>{
            'BLFS', 'BRKS','BLTY','BGS','CTRS','CIRS','CLF', 'CMNS','CVS', 'DRS','EXTS','FLT', 'FRDS', 'FRGS', 'GDN','GLNS',
            'GRNS','GRVS','HBRS','JCTS','LGTS','LF','MNRS','MTWY','OPAS','PARK','PKWY','PNE','PTS','PRTS','RAMP','RPD',
            'RDGS','RDS','RUE','SKWY','SPUR','SQS','TRWY','TRAK','TRFY','UPAS','UNS','VLYS','VLGS','WALK','WAYS','WL','ST',
            'ALY','ANX','ARC','AVE','BYU','BCH ','BLF ','BTM','BLVD','BR','BRG','BRK','BG','BYP','CP','CYN','CPE','CSWY',
            'CTR','CIR','CLFS','CLB','CMN','COR','CORS','CRSE','CT','CTS','CV','CRK','CRES','XING','XRD','XRDS','CURV','DL',
            'DM','DV','DR','EST','ESTS','EXPY','EXT','FALL','FLS','FRY','FLD','FLDS','FLTS','FRD','FRST','FRG','FRK','FRKS',
            'FT','FWY','GDNS','GTWY','GLN','GRN','GRV','HBR','HVN','HTS','HWY','HOLW','INLT','IS','ISS','ISLE','JCT','KY',
            'KYS','KNL','KNLS','LK','LKS','LAND','LNDG','LN','LGT','LCK','LCKS','LDG','LOOP','MALL','MNR','MDW','MDWS',
            'MEWS','ML','MLS','MSN','MT','MTN','MTNS','NCK','ORCH','OVAL','PARK','PKWY','PASS','PSGE','PATH','PIKE','PNES',
            'PL','PLN','PLNS','PLZ','PT','PRT','PR','RADL','RNCH','RPDS','RST','RDG','RIV','RD','RTE','ROW','RUN','SHL',
            'SHLS','SHR','SPG','SPGS','SPUR','SQ','STA','STRA','STRM','STS','SMT','TER','TRCE','TRL','TRLR','TUNL','TPKE',
            'UN','VLY','VIA','VW','VLG','VL','VIS','WALK','WALL','WAY','WLS'};
           
           List<String> unitType = new List<String>{
            'APT','BSMT','BLDG','DEPT','FL','FRNT','HNGR','KEY','LBBY','LOT','LOWR','OFC','PH','PIER','REAR','RM','SIDE',
            'SLIP','SPC','STOP','STE','TRLR','UNIT','UPPR'
        	}; 

        Integer j = 0;
        Integer k = 0;
        for(Integer i=0; i<streetType.Size(); i++) {
            
            if(Math.mod(i,8) == 0)
                j = 0;
                
            if(Math.mod(i,24) == 0)
                k = 0;                
                        
            Subscriptions__c s = new  Subscriptions__c();
         
           // s.Name = 'Test Subscription';
            s.Contact__c = c1.Id;
            s.Subscription_Type__c = 'Realtor/Shareholder';
            s.Status__c = 'In Progress';
            s.City__c = 'Herndon';
            s.Zip__c = '20171';
            s.County__c = 'Fairfax';
            s.AgentKey__c = '123112';
            s.name = '12345';
            s.State__c = 'VA';
            s.Related_Location_Broker_Office__c = a1.Id;
            s.Contact_Type__c = 'Agent';
            s.QAS_Mailing_Street_Type__c = streetType[i];
            s.QAS_Billing_Street_Type__c = streetType[i];
            s.QAS_Mailing_Street_Direction__c = streetDirection[j];
            s.QAS_Billing_Street_Direction__c= streetDirection[j];
            s.QAS_Mailing_Unit_Type__c = unitType[k];
            s.QAS_Billing_Unit_Type__c = unitType[k];
            s.QAS_Mailing_County__c = 'Fairfax';
            s.Public_Email__c = 'test@test.com';
            s.Private_Email__c = 'test@test.com';
            s.Primary_Phone__c ='(703) 919-9466';
            s.Mobile_Phone__c = '(703) 919-9466';
            s.Service_Jurisdiction__c = 'BRIGHT';
            s.TREND_Login_Name__c = 'TREND001'; 
            
            //commenting contact to avoid SOQL limit exception due to trigger on the contact update
            // s.Contact__r = c1;
            s.Billing_Addl_Display_Name__c='1234';
            s.Billing_Zip_4__c = '2222';
            s.Billing_Zip__c = '20171';
            s.Billing_City__c = 'Herndon';
            s.QAS_Billing_County__c = 'Fairfax';
            s.Billing_state__c = 'VA';
            controller.subscription = s;
            controller.save();
            j++;
            k++; 
        }
  }   
}
	
    private static Account createAccount(String type, String name, String jurisdiction) {
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
        account.Status__c = 'Active';
        account.Primary_Service_Jurisdiction__c = jurisdiction;
        
        insert account; 
        
        return account;
    }
    
    private static Contact createContact(String accountId, String jurisdiction) {
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
        contact.Service_Jurisdiction__c = jurisdiction;
        insert contact;
        
        return contact;
    }
    
    private Static Subscriptions__c createSubscription(String accountId, String contactId, String jurisdiction) {
        Subscriptions__c subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contactId;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Herndon';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = accountId;
        subscription.Contact_Type__c = 'Agent';
        subscription.Public_Email__c = 'test@test.com';
        subscription.Service_Jurisdiction__c = jurisdiction;
        subscription.TREND_Login_Name__c = 'TREND002';    

        insert subscription; 
        
        return subscription;
    }
    
    private static void generateData() {         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    private static User createCommunityUser(String subscriptionId) {
        
         User communityUser = [Select ID,NAME  from user where  FederationIdentifier = :subscriptionId];
        if(communityUser == null){
       Subscriptions__c sSubscription = [SELECT Id, 
                                                 Name, 
                                                 Public_Email__c, 
                                                 SF_Subscription_ID__c, 
                                                 AgentKey__c, 
                                                 Contact__c, 
                                                 Contact__r.FirstName,
                                                 Contact__r.LastName 
                                          FROM Subscriptions__c 
                                          WHERE  id = :subscriptionId];        
        
        communityUser = new User();
        
        communityUser.username = sSubscription.AgentKey__c + 'test@test.com';
        communityUser.email = sSubscription.Public_Email__c;
        communityUser.TimeZoneSidKey = 'America/New_York';
        communityUser.LocaleSidKey='en_us';
        communityUser.EmailEncodingKey='UTF-8';       
        communityUser.LanguageLocaleKey='en_us'; 
        communityUser.LastName = sSubscription.Contact__r.FirstName;
        communityUser.FirstName = sSubscription.Contact__r.LastName;
        communityUser.FederationIdentifier = sSubscription.Name;
        communityUser.Alias = (sSubscription.Name.length() > 7) ? sSubscription.Name.substring(0, 7) : sSubscription.Name; 
        communityUser.ContactId = sSubscription.Contact__c;
        communityUser.isActive = true;
        communityUser.CommunityNickname = sSubscription.Name;
        
        Profile p = [SELECT id FROM Profile WHERE name =: 'Custom High Volume Portal User'];         
        communityUser.Profile = p;
        communityUser.ProfileId = p.id;
        insert(communityUser);
        }
        return communityUser;   
    }
    
    private Static Relationship__c createRelationship(String accountId, String contactId, String subscriptionId, String relationType) {
        Relationship__c r = new Relationship__c();
        r.Broker_Office__c = accountId;
        r.Related_Account__c = accountId;
        r.Contact__c = contactId;
        r.Subscription__c = subscriptionId;
        r.Relationship_Type__c = relationType;
        r.Status__c = 'Active';
        insert r; 
        
        return r;
    }
}