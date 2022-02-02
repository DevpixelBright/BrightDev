@istest(seealldata = true)
public class ErrorProvisionedHandlerTest {
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                       FROM   QueueSobject 
                                       WHERE  SobjectType = 'Case' 
                                       AND    Queue.Name = 'SMS Product Team'
                                      ];
private static void createAccount(String type,String name){
        account = new Account();
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
        insert account; 
    }
    
    private static void createContact(String accountId){
        contact = new Contact();
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
        contact.Professional_Designations__c = 'ABR;CCIM;CIPS';
        contact.PrimaryMLS__c ='Garden State MLS';
        contact.AdditionalMLS__c ='Coastal MLS' ;
        insert contact;  
    }
    private Static void createSubscription(String accountId, String contactId){
        
        subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Alexandria';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        
        //subscription.Date_Terminated__c =  (System.Now().addDays(-2)).Date();
        insert subscription; 
        system.debug('Subscription id '+subscription.Id);
    }
    private static testMethod void createCase(){
        List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                       FROM   QueueSobject 
                                       WHERE  SobjectType = 'Case' 
                                       AND    Queue.Name = 'SMS Product Team'
                                      ];
        createAccount('Association','XYZ124');
        createContact(account.Id); 
        contact.State__c = 'VA';
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        createCC_CloudCMA();
        createCC_SocialPro();
        createCC_Authentisign();
        SMS_Provisioned_Product__c ssp = new SMS_Provisioned_Product__c();
        ssp.Product_Type__c = 'CloudCMA';
        ssp.Product_Sub_Type__c = 'CloudCMA 1 Year';
        ssp.Provisioned_Status__c = 'Error Provisioned';
        ssp.Subscription__c = subscription.id;
        ssp.Status_Message__c = 'Test';
        ssp.Private_Email__c = subscription.Private_Email__c;
        insert ssp;
        
        if(ssp.Product_Type__c == 'CloudCMA' && ssp.Provisioned_Status__c == 'Error Provisioned'){
            Case createCase = new Case();
            //createCase.First_Name__c = ssp.Subscription__r.Contact__r.Name;
            createCase.Private_Email__c = ssp.Subscription__r.Private_Email__c;
            createCase.Subject = 'Error on Cloud CMA provisioning';
            createCase.Status = 'Not Started';
            createCase.Description = ssp.Id;
            createCase.Case_Reason__c = 'Defect';
            createCase.Product__c = 'Cloud CMA';
            createCase.Product_Sub_Type__c = ssp.Product_Sub_Type__c;
            createCase.MRIS_Connect_Description__c = ssp.Status_Message__c;
            createCase.Category__c = 'Error on provisioning';
            createCase.SMS_Provisioned_Product__c = ssp.Id;
            createCase.Subscription_ID__c = ssp.Subscription__c;
            createCase.OwnerId = queueIds[0].QueueId;
            insert createCase; 
        }
    } 
    private static testMethod void createCase2(){
        List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                       FROM   QueueSobject 
                                       WHERE  SobjectType = 'Case' 
                                       AND    Queue.Name = 'SMS Product Team'
                                      ];
        createAccount('Association','XYZ124');
        createContact(account.Id); 
        contact.State__c = 'VA';
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        createCC_CloudCMA();
        createCC_SocialPro();
        createCC_Authentisign();
        SMS_Provisioned_Product__c ssp = new SMS_Provisioned_Product__c();
        ssp.Product_Type__c = 'CloudCMA';
        ssp.Product_Sub_Type__c = 'CloudCMA 1 Year';
        ssp.Provisioned_Status__c = 'Error Deprovisioned';
        ssp.Subscription__c = subscription.id;
        ssp.Status_Message__c = 'Test';
        ssp.Private_Email__c = subscription.Private_Email__c;
        insert ssp;
        if(ssp.Product_Type__c == 'CloudCMA' && ssp.Provisioned_Status__c == 'Error Deprovisioned'){
            Case createCase = new Case();
            //createCase.First_Name__c = ssp.Subscription__r.Contact__r.Name;
            createCase.Private_Email__c = ssp.Subscription__r.Private_Email__c;
            createCase.Subject = 'Error on Cloud CMA deprovisioning';
            createCase.Status = 'Not Started';
            createCase.Description = ssp.Id;
            createCase.Case_Reason__c = 'Defect';
            createCase.Product__c = 'Cloud CMA';
            createCase.Product_Sub_Type__c = ssp.Product_Sub_Type__c;
            createCase.MRIS_Connect_Description__c = ssp.Status_Message__c;
            createCase.Category__c = 'Error on deprovisioning';
            createCase.SMS_Provisioned_Product__c = ssp.Id;
            createCase.Subscription_ID__c = ssp.Subscription__c;
            createCase.OwnerId = queueIds[0].QueueId;
            insert createCase; 
        }
    } 
    private static testMethod void createCase3(){
        List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                       FROM   QueueSobject 
                                       WHERE  SobjectType = 'Case' 
                                       AND    Queue.Name = 'SMS Product Team'
                                      ];
        createAccount('Association','XYZ124');
        createContact(account.Id); 
        contact.State__c = 'VA';
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        createCC_CloudCMA();
        createCC_SocialPro();
        createCC_Authentisign();
        SMS_Provisioned_Product__c ssp = new SMS_Provisioned_Product__c();
        ssp.Product_Type__c = 'CloudCMA';
        ssp.Product_Sub_Type__c = 'CloudCMA 1 Year';
        ssp.Provisioned_Status__c = 'Error Pending Provisioned';
        ssp.Subscription__c = subscription.id;
        ssp.Status_Message__c = 'Test';
        ssp.Private_Email__c = subscription.Private_Email__c;
        insert ssp;
        if(ssp.Provisioned_Status__c == 'Error Pending Provisioned'&&ssp.Previous_Provisioned_Status__c=='Pending Provisioned'){
            Case createCase = new Case();
            //createCase.First_Name__c = ssp.Subscription__r.Contact__r.Name;
            createCase.Private_Email__c = ssp.Subscription__r.Private_Email__c;
            createCase.Subject = 'Error on Cloud CMA deprovisioning';
            createCase.Status = 'Not Started';
            createCase.Description = ssp.Status_Message__c;
            createCase.Case_Reason__c = 'Defect';
            createCase.Product__c = 'Cloud CMA';
            createCase.Product_Sub_Type__c = ssp.Product_Sub_Type__c;
            createCase.MRIS_Connect_Description__c = ssp.Status_Message__c;
            createCase.Category__c = 'Error on deprovisioning';
            createCase.SMS_Provisioned_Product__c = ssp.Id;
            createCase.Subscription_ID__c = ssp.Subscription__c;
            createCase.OwnerId = queueIds[0].QueueId;
            insert createCase; 
        }
    } 
    private static testMethod void createCase4(){
        List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                       FROM   QueueSobject 
                                       WHERE  SobjectType = 'Case' 
                                       AND    Queue.Name = 'SMS Product Team'
                                      ];
        createAccount('Association','XYZ124');
        createContact(account.Id); 
        contact.State__c = 'VA';
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        createCC_CloudCMA();
        createCC_SocialPro();
        createCC_Authentisign();
        SMS_Provisioned_Product__c ssp = new SMS_Provisioned_Product__c();
        ssp.Product_Type__c = 'CloudCMA';
        ssp.Product_Sub_Type__c = 'CloudCMA 1 Year';
        ssp.Provisioned_Status__c = 'Error Pending Deprovisioned';
        ssp.Subscription__c = subscription.id;
        ssp.Status_Message__c = 'Test';
        ssp.Private_Email__c = subscription.Private_Email__c;
        insert ssp;
        if(ssp.Provisioned_Status__c == 'Error Pending Deprovisioned' && ssp.Previous_Provisioned_Status__c == 'Pending Deprovisioned'){
            Case createCase = new Case();
            //createCase.First_Name__c = ssp.Subscription__r.Contact__r.Name;
            createCase.Private_Email__c = ssp.Subscription__r.Private_Email__c;
            createCase.Subject = 'Error on Cloud CMA deprovisioning';
            createCase.Status = 'Not Started';
            createCase.Description = ssp.Status_Message__c;
            createCase.Case_Reason__c = 'Defect';
            createCase.Product__c = 'Cloud CMA';
            createCase.Product_Sub_Type__c = ssp.Product_Sub_Type__c;
            createCase.MRIS_Connect_Description__c = ssp.Status_Message__c;
            createCase.Category__c = 'Error on deprovisioning';
            createCase.SMS_Provisioned_Product__c = ssp.Id;
            createCase.Subscription_ID__c = ssp.Subscription__c;
            createCase.OwnerId = queueIds[0].QueueId;
            insert createCase; 
        }
    } 
    private static testMethod void createProvProd(){
         List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                       FROM   QueueSobject 
                                       WHERE  SobjectType = 'Case' 
                                       AND    Queue.Name = 'SMS Product Team'
                                      ];
        createAccount('Association','XYZ124');
        createContact(account.Id); 
        contact.State__c = 'VA';
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        createCC_CloudCMA();
        createCC_SocialPro();
        createCC_Authentisign();
        SMS_Provisioned_Product__c ssp = new SMS_Provisioned_Product__c();
        ssp.Product_Type__c = 'CloudCMA';
        ssp.Product_Sub_Type__c = 'CloudCMA 1 Year';
        ssp.Provisioned_Status__c = 'Error Pending Provisioned';
        ssp.Subscription__c = subscription.id;
        ssp.Status_Message__c = 'Test';
        ssp.Private_Email__c = subscription.Private_Email__c;
        insert ssp;
        SMS_Provisioned_Product__c ssp2 = new SMS_Provisioned_Product__c();
        ssp2.Product_Type__c = 'CloudCMA';
        ssp2.Product_Sub_Type__c = 'CloudCMA 1 Year';
        ssp2.Provisioned_Status__c = 'Pending Provisioned';
        ssp2.Subscription__c = subscription.id;
        ssp2.Status_Message__c = 'Test';
        ssp2.Private_Email__c = subscription.Private_Email__c;
        insert ssp2;
    }
	private static testMethod void createProvProd2(){
        createAccount('Association','XYZ124');
        createContact(account.Id); 
        contact.State__c = 'VA';
        createSubscription(account.Id, contact.Id);
        subscription.Status__c = 'Active';
        update  subscription;
        createCC_CloudCMA();
        createCC_SocialPro();
        createCC_Authentisign();
        SMS_Provisioned_Product__c ssp2 = new SMS_Provisioned_Product__c();
        ssp2.Product_Type__c = 'CloudCMA';
        ssp2.Product_Sub_Type__c = 'CloudCMA 1 Year';
        ssp2.Provisioned_Status__c = 'Error Provisioned';
        ssp2.Subscription__c = subscription.id;
        ssp2.Status_Message__c = 'Test';
        ssp2.Private_Email__c = subscription.Private_Email__c;
        insert ssp2;
        SMS_Provisioned_Product__c sppTC = [SELECT  Id, Order__c, 
                                            Product_Type__c,
                                            Product_Sub_Type__c,
                                            Product_Status__c,
                                            Provisioned_Status__c, 
                                            Subscription__r.Contact__r.Name,
                                            Subscription__c
                                            FROM    SMS_Provisioned_Product__c
                                            WHERE   Id =:ssp2.id];
        sppTC.T_C_accepted_by__c = sppTC.Subscription__r.Contact__r.Name;
            sppTC.T_C_acceptance_date__c = System.today();
            sppTC.T_C_version__c = 'BNTC 1.0'; 
            update sppTC;
        
    }
      private static void createCC_CloudCMA(){
       List<Custom_Content__c> cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
              where Type__c = 'Buy Now Terms and Conditions - Cloud CMA' AND Status__c = 'Published'];
        if(cc.size() == 0){
        Custom_Content__c cc2 = new Custom_Content__c();
        cc2.Version_Number__c = 'BNTC 1.0';
        cc2.Status__c ='Published';
        cc2.Type__c = 'Buy Now Terms and Conditions - Cloud CMA';
        cc2.Content__c ='Test';
        insert cc2;
        }
    }
private static void createCC_SocialPro(){
   List<Custom_Content__c> cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
              where Type__c = 'Buy Now Terms and Conditions - Socialpro' AND Status__c = 'Published'];
        if(cc.size() == 0){
        Custom_Content__c cc2 = new Custom_Content__c();
        cc2.Version_Number__c = 'BNTCSocialPro 1.0';
        cc2.Status__c ='Published';
        cc2.Type__c = 'Buy Now Terms and Conditions - Socialpro';
        cc2.Content__c ='Test';
        insert cc2;
        }
    }
    private static void createCC_Authentisign(){
       List<Custom_Content__c> cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
              where Type__c = 'Buy Now Terms and Conditions - Authentisign' AND Status__c = 'Published'];
        if(cc.size() == 0){
        Custom_Content__c cc2 = new Custom_Content__c();
        cc2.Version_Number__c = 'BNTCAuthentisign 1.0';
        cc2.Status__c ='Published';
        cc2.Type__c = 'Buy Now Terms and Conditions - Authentisign';
        cc2.Content__c ='Test';
        insert cc2;
        }
    }
}