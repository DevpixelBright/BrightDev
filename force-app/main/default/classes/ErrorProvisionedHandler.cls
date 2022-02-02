public class ErrorProvisionedHandler {
    public static Boolean isFirstTime = true;
    public static void provProd(list<SMS_Provisioned_Product__c> newProv){
        List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                       FROM   QueueSobject 
                                       WHERE  SobjectType = 'Case' 
                                       AND    Queue.Name = 'SMS Product Team'
                                      ];
        List<SMS_Provisioned_Product__c> spps = [SELECT  Id, Order__c, 
                                                 Product_Type__c,
                                                 Product_Sub_Type__c,
                                                 Status_Message__c,
                                                 Product_Status__c,
                                                 Provisioned_Status__c,
                                                 Subscription__r.Contact__r.Name,
                                                 Subscription__r.Private_Email__c,
                                                 Subscription__c
                                                 FROM    SMS_Provisioned_Product__c
                                                 WHERE   Id =: newProv];
        Case createCase = new Case();
            for (SMS_Provisioned_Product__c spp : spps) {
                
                if(spp.Product_Type__c == 'CloudCMA' && (spp.Provisioned_Status__c == 'Error Provisioned' || spp.Provisioned_Status__c == 'Error Pending Provisioned')){
                    
                    createCase.First_Name__c = spp.Subscription__r.Contact__r.Name;
                    createCase.Private_Email__c = spp.Subscription__r.Private_Email__c;
                    createCase.Subject = 'Error on Cloud CMA provisioning';
                    createCase.Status = 'Not Started';
                    createCase.Description = spp.Id;
                    createCase.Case_Reason__c = 'Defect';
                    createCase.Product__c = 'Cloud CMA';
                    createCase.Product_Sub_Type__c = spp.Product_Sub_Type__c;
                    createCase.MRIS_Connect_Description__c = spp.Status_Message__c;
                    createCase.Category__c = 'Error on provisioning';
                    createCase.SMS_Provisioned_Product__c = spp.Id;
                    createCase.Subscription_ID__c = spp.Subscription__c;
                    createCase.OwnerId = queueIds[0].QueueId;
                    insert createCase;
                }
            }
    }
       /* if(spp.Product_Type__c == 'CloudCMA' && spp.Provisioned_Status__c == 'Error Deprovisioned' || spp.Provisioned_Status__c == 'Error Pending Deprovisioned'){
            
            Case createCase2 = new Case();
            createCase2.First_Name__c = spp.Subscription__r.Contact__r.Name;
            createCase2.Private_Email__c = spp.Subscription__r.Private_Email__c;
            createCase2.Subject = 'Error on Cloud CMA deprovisioning';
            createCase2.Status = 'Not Started';
            createCase2.Description = spp.Id;
            createCase2.Case_Reason__c = 'Defect';
            createCase2.Product__c = 'Cloud CMA';
            createCase2.Product_Sub_Type__c = spp.Product_Sub_Type__c;
            createCase2.MRIS_Connect_Description__c = spp.Status_Message__c;
            createCase2.Category__c = 'Error on deprovisioning';
            createCase2.SMS_Provisioned_Product__c = spp.Id;
            createCase2.Subscription_ID__c = spp.Subscription__c;
            createCase2.OwnerId = queueIds[0].QueueId;
            insert createCase2; 
        }
    }*/
   /* public static void provProdTC(list<SMS_Provisioned_Product__c> newProvTC){
        Custom_Content__c cc = new Custom_Content__c();
        cc = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
              where Type__c = 'Buy Now Terms and Conditions - Cloud CMA' AND Status__c = 'Published'];
        Custom_Content__c cc2 = new Custom_Content__c();
        cc2 = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
               where Type__c = 'Buy Now Terms and Conditions - Socialpro' AND Status__c = 'Published'];
        Custom_Content__c cc3 = new Custom_Content__c();
        cc3 = [SELECT Id, Version_Number__c, Status__c, Type__c, Content__c from Custom_Content__c 
               where Type__c = 'Buy Now Terms and Conditions - Authentisign' AND Status__c = 'Published'];
        
        SMS_Provisioned_Product__c sppTC = [SELECT  Id, Order__c, 
                                            Product_Type__c,
                                            Product_Sub_Type__c,
                                            Product_Status__c,
                                            Provisioned_Status__c, 
                                            Subscription__r.Contact__r.Name,
                                            Subscription__c
                                            FROM    SMS_Provisioned_Product__c
                                            WHERE   Id =: newProvTC];
        if(sppTC.Product_Type__c == 'CloudCMA' && cc.Status__c == 'Published')  {
            sppTC.T_C_accepted_by__c = sppTC.Subscription__r.Contact__r.Name;
            sppTC.T_C_acceptance_date__c = System.today();
            sppTC.T_C_version__c = cc.Version_Number__c; 
            update sppTC;
        }
        if(sppTC.Product_Type__c == 'Social Pro' && cc2.Status__c == 'Published')  {
            sppTC.T_C_accepted_by__c = sppTC.Subscription__r.Contact__r.Name;
            sppTC.T_C_acceptance_date__c = System.today();
            sppTC.T_C_version__c = cc2.Version_Number__c; 
            update sppTC;
        }
        if(sppTC.Product_Type__c == 'Authentisign' && cc3.Status__c == 'Published')  {
            sppTC.T_C_accepted_by__c = sppTC.Subscription__r.Contact__r.Name;
            sppTC.T_C_acceptance_date__c = System.today();
            sppTC.T_C_version__c = cc3.Version_Number__c; 
            update sppTC;
        }
        if(sppTC.Product_Type__c != 'Authentisign' || sppTC.Product_Type__c != 'Social Pro' || sppTC.Product_Type__c != 'CloudCMA')  {
            
        }
    }*/
   
}