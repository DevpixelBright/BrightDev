trigger RETS_ProductOrder on RETS_Product_Order__c (before insert,after insert,before update,after update,after delete) {
     
    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;
    
    /*Updating agent,broker counts on subscrptions and brokerages*/
    if((Trigger.isAfter && Trigger.isUpdate) || Trigger.isDelete)
       RETS_ProcessProductOrders.UpdateSubAgentBrokerCounts(Trigger.new, Trigger.oldMap);
    
    Set<Id> subIds = new Set<Id>();
    Map<Id, Subscriptions__c> mSubs = new Map<Id, Subscriptions__c>();
    
    for(RETS_Product_Order__c order : Trigger.new){
        if(order.Agent__c != null)
            subIds.add(order.Agent__c);    
    }
    
    if(!subIds.isEmpty()){
        mSubs = new Map<Id, Subscriptions__c>([SELECT Id, status__c, status_change_reason__c,(SELECT id, name, start_date__c FROM RETS_Product_Orders__r WHERE Status__c = 'Active' Order by start_date__c desc) FROM Subscriptions__c where Id IN: subIds]);
    }
    
    if(trigger.isBefore){
        /* Copying billing exclusions from subproduct to order*/
        if(trigger.isInsert){
            for(RETS_Product_Order__c order :Trigger.new){
                if(order.status__c != 'In Progress')
                    order.status__c.addError('Product orders should be created in InProgress status');
            }
            RETS_ProcessProductOrders.updateRetsBillingExclusion(Trigger.New);
            
        }
        
        /* Updating order end date to current date when status is changed to inactive*/          
        if(trigger.isUpdate){
            for(RETS_Product_Order__c order :Trigger.new){
                if(Trigger.oldmap.get(order.Id).Status__c == 'Active' && order.Status__c == 'Inactive'){
                    if(mSubs.containsKey(order.Agent__c) && order.Status_Reason__c == 'Misreported'){
                        RETS_Product_Order__c oRets = order;
                        if(!mSubs.get(order.Agent__c).RETS_Product_Orders__r.isEmpty() && mSubs.get(order.Agent__c).RETS_Product_Orders__r[0].Start_Date__c > order.Start_Date__c){
                           oRets = mSubs.get(order.Agent__c).RETS_Product_Orders__r[0];
                        }
                        if(oRets.Start_Date__c < System.now().addDays(-30)){
                            order.End_Date__c = System.now().addDays(-30);
                        }else{
                            order.End_Date__c = oRets.Start_Date__c;
                        }
                    }else{
                    	order.End_Date__c = system.now();    
                    }
                    
                }else if(Trigger.oldmap.get(order.Id).Status__c == 'In Progress' && order.Status__c == 'Active'){
                    if(order.Start_Date__c == null)
                        order.Start_Date__c = system.now();
                    RETS_ProcessProductOrders.updateBrokerofRecord(Trigger.New);
                }
                
                if(order.RETS_Sub_Product__c != null){
                    RETS_Sub_Products__c subprod = [select id,name from RETS_Sub_Products__c where id =:order.RETS_Sub_Product__c ];
                      order.OnActivationSubProductName__c = subprod.name;
                }
                
                if(order.Is_External_Billing__c){
                    order.ZuoraIntegrationStatus__c='Skipped for Agent or Brokerage';
                    order.ZuoraVendorProductIntegrationStatus__c = 'Skipped';
                }else{
                    if(order.RETS_Billing_Exclusion__c != null ){
                        if(order.RETS_Billing_Exclusion__c.contains('Vendor'))
                            order.ZuoraVendorProductIntegrationStatus__c = 'Skipped';
                        
                        if(order.RETS_Billing_Exclusion__c.contains('Brokerage') && order.Brokerage__c != null)
                            order.ZuoraIntegrationStatus__c='Skipped for Agent or Brokerage';
                        
                        if(order.RETS_Billing_Exclusion__c.contains('Agent') && order.Agent__c != null)
                            order.ZuoraIntegrationStatus__c='Skipped for Agent or Brokerage';
                        
                    }
                }
                
                /*
                // added on 16th 
                if((Trigger.oldmap.get(order.Id).Status__c == 'Active' || Trigger.oldmap.get(order.Id).Status_Reason__c != 'Misreported') 
                    && order.Status__c == 'Inactive' && order.Status_Reason__c == 'Misreported' && order.Agent__c != null ){
                    RETS_ProcessProductOrders.validationOnMissReport(order, null);
                }
                else if(Trigger.oldmap.get(order.Id).Status__c == 'In Progress' && order.Status__c == 'Active'){
                    RETS_ProcessProductOrders.validationOnMissReport(null, order);
                }
                */
            }
        }
    }
    
    if(trigger.isafter){
        
        if(trigger.isInsert || trigger.isUpdate){ 
            if(Trigger.isInsert)
                RETS_ProcessProductOrders.UpdateSubAgentBrokerCounts(Trigger.new, null);
            
            for(RETS_Product_Order__c order : trigger.NEW){
                Boolean isBillable = false;
                Boolean isVendorBilling = true;
                if(trigger.isUpdate){
                    if(trigger.oldmap.get(order.Id).status__c != order.status__c ){
                        if(order.Status__c == 'Active' || order.Status__c == 'Inactive')
                            isBillable = true;                        
                        if(order.Status__c == 'Inactive'){
                            if(order.Status_Reason__c == 'Cancelled by Vendor' || order.Status_Reason__c == 'Cancelled by Subscriber'){
                                isVendorBilling = false;    
                            }
                        }
                    }
                }
                
                if(Trigger.isInsert){
                    /*Creates Zuora account if account doesnot exists for brokerage*/
                    if(order.brokerage__c !=null)
                      RETS_ZuoraSetup.setupZuoraBrokerage(order.brokerage__c);
                    
                    if(order.Status__c == 'Active' || order.Status__c == 'Inactive')
                        isBillable = true;
                }                
                
                 
                if(!order.Is_External_Billing__c && isBillable){ 
                    if(order.RETS_Billing_Exclusion__c != null ){
                        if(!order.RETS_Billing_Exclusion__c.contains('Vendor')){
                            if(isVendorBilling){
                                RETS_ProductOrder_Billing.createOrUpdateVendorSubscription(order.Id);
                            }
                        }	                        
                        if(!order.RETS_Billing_Exclusion__c.contains('Brokerage') && order.Brokerage__c != null)
                            RETS_ProductOrder_Billing.createOrUpdateBrokerageSubscription(order.Id);
                        
                        if(!order.RETS_Billing_Exclusion__c.contains('Agent') && order.Agent__c != null)
                            RETS_ProductOrder_Billing.createOrUpdateAgentSubscription(order.Id);
                    }
                    else{
                                                		
                        if(isVendorBilling
                           && mSubs.containsKey(order.Agent__c) 
                           && (mSubs.get(order.Agent__c).status_change_reason__c != 'Terminated' || mSubs.get(order.Agent__c).status_change_reason__c != 'Subscriber Requested'
                              || mSubs.get(order.Agent__c).status_change_reason__c != 'Broker Requested'))
                            RETS_ProductOrder_Billing.createOrUpdateVendorSubscription(order.Id);                       
                        if(order.Brokerage__c != null)
                            RETS_ProductOrder_Billing.createOrUpdateBrokerageSubscription(order.Id);
                        if(order.Agent__c != null 
                           && mSubs.containsKey(order.Agent__c) 
                           && (mSubs.get(order.Agent__c).status_change_reason__c != 'Terminated' || mSubs.get(order.Agent__c).status_change_reason__c != 'Subscriber Requested'
                              || mSubs.get(order.Agent__c).status_change_reason__c != 'Broker Requested'))
                            RETS_ProductOrder_Billing.createOrUpdateAgentSubscription(order.Id);
                    }                
                } 
        
            }    
           
        }        
    }
   
}