public class CaseTriggerHandler {
    /*public static boolean runOnce = true;
    
    public static void caseApprove(List<Case> lstCases, Map<Id,Case> mapCase){
        system.debug('*****runOnce'+runOnce);
        system.debug('*****lstCases'+lstCases);
        if(runOnce){
            runOnce = false;
            set<String> ca = new set<String>();
            List<Case> toBeUpdated = new List<Case>();
            List<group> queueIds = [SELECT Id FROM  group WHERE  DeveloperName = 'Broker_Authorization'];
            system.debug('*****mapCase'+mapCase);
            for(Case c: lstcases){
                system.debug('*****c'+c);
                if(c.OwnerId == queueIds[0].Id){
                    system.debug('*****c'+c);
                    if(c.Status != mapCase.get(c.Id).Status && c.Status == 'Approved'){
                        toBeUpdated.add(c);
                        system.debug('*****toBeUpdated'+toBeUpdated);
                    }
               }
            }
            List<Case> lCase = [SELECT Id, MRIS_Application__r.Vendor_Office_ID__c FROM Case where  Id =:toBeUpdated];
            List<RETS_Product_Order__c> lOrders = new List<RETS_Product_Order__c>();
            for(Case oCase : toBeUpdated){
                RETS_Product_Order__c order = new RETS_Product_Order__c();   
                order.Agent__c = oCase.Subscription_ID__c;
                order.Vendor_Product__c = lCase[0].MRIS_Application__r.Vendor_Office_ID__c;
                order.URL__c = oCase.URL_Address__c;
                order.Status__c = 'In Progress';
                order.Start_Date__c = system.now();
                lOrders.add(order);
            }
            system.debug('*****lOrders'+lOrders);
            insert lOrders;  
            
            for(RETS_Product_Order__c actOrders : lOrders){
                actOrders.Status__c = 'Active';
            }
            update lOrders;
        }    
    }*/
    
}