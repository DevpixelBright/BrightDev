public class RETS_ProcessProductOrders {
    public static void UpdateSubAgentBrokerCounts(list<RETS_Product_Order__c> newPOs, map<Id,RETS_Product_Order__c> oldPOs){
        set<string> setAgentIds = new set<string>();
        set<string> setBrokerIds = new set<string>();
        set<string> setRetsVOIds = new set<string>();
        
        system.debug('----newPOs--->'+newPOs);
        system.debug('----oldPOs--->'+oldPOs);
        
        if(newPOs != null ){                            // for update
            for(RETS_Product_Order__c po : newPOs){
                
                system.debug('---Related_Location_Broker_Office__c-->'+po.Agent__r.Related_Location_Broker_Office__c);
                if(po.Is_External_Billing__c == false && 
                    ( (oldPos == Null && po.Status__c == 'Active') || (oldPOs != Null && po.Status__c != oldPOs.get(po.id).Status__c))){
                    
                    system.debug('---po---'+po);
                    // if Vendor Product has Billing exclusion (Agent/Brokerage), product count should not be updated on Agent or Brokerage
                    if( po.Agent__c != null && (po.RETS_Billing_Exclusion__c == null || (po.RETS_Billing_Exclusion__c != null && !(po.RETS_Billing_Exclusion__c.contains('Agent'))))){
                        setAgentIds.add(po.Agent__c);
                    }
                    if(po.Brokerage__c != null && (po.RETS_Billing_Exclusion__c == null || ( po.RETS_Billing_Exclusion__c != null && !(po.RETS_Billing_Exclusion__c.contains('Brokerage'))))){
                        setBrokerIds.add(po.Brokerage__c);
                    }
                    setRetsVOIds.add(po.Vendor_Product__c);
                }
            }
        }
        
        else if(newPOs == null && oldPOs != null){          // for delete
            for(RETS_Product_Order__c po : oldPOs.values()){
                if(po.Is_External_Billing__c == true){
                    if( po.Agent__c != null && (po.RETS_Billing_Exclusion__c == null || ( po.RETS_Billing_Exclusion__c != null && !(po.RETS_Billing_Exclusion__c.contains('Agent'))))){
                        setAgentIds.add(po.Agent__c);
                    }
                    if( po.Brokerage__c != null && (po.RETS_Billing_Exclusion__c == null || ( po.RETS_Billing_Exclusion__c != null && !(po.RETS_Billing_Exclusion__c.contains('Brokerage'))))){
                        setBrokerIds.add(po.Brokerage__c);
                    }
                    setRetsVOIds.add(po.Vendor_Product__c);
                }
            }
        }
        
        system.debug('----setAgentIds--->'+setAgentIds);
        system.debug('----setBrokerIds--->'+setBrokerIds);
        system.debug('----setRetsVOIds--->'+setRetsVOIds);
        
        // update order product count on Agent(Subscription)
        if(!setAgentIds.isEmpty()){
            list<Subscriptions__c> lstSubs = [Select Id, RETS_Product_Count__c,  (Select Id From RETS_Product_Orders__r Where Status__c = 'Active') 
                                                From Subscriptions__c 
                                                Where Id in: setAgentIds];
            
            for(Subscriptions__c sub : lstSubs){
                sub.RETS_Product_Count__c = sub.RETS_Product_Orders__r.size();
            }
            update lstSubs;
            lstSubs.clear();
        }
        
        // update product count on Brokerage(Account)
        if(!setBrokerIds.isEmpty()){
            list<Account> lstBrokerages = [Select Id, RETS_Product_Count__c, (Select Id From RETS_Product_Orders_Brokerage__r Where Status__c = 'Active') 
                                                From Account 
                                                Where Id in: setBrokerIds];
            
            system.debug('--lstBrokerages outside--'+lstBrokerages);
            for(Account brok : lstBrokerages){
                brok.RETS_Product_Count__c = brok.RETS_Product_Orders_Brokerage__r.size();
            }
            update lstBrokerages;
            lstBrokerages.clear();
        }
        
        //update Broker Count and Agent count on Vendor Product(Account)
        if(!setRetsVOIds.isEmpty()){
            
            AggregateResult[] groupedResults = [Select count(Agent__c) ag, count(Brokerage__c) br, Vendor_Product__c 
                                                From RETS_Product_Order__c 
                                                Where Vendor_Product__c in: setRetsVOIds And Status__c = 'Active' 
                                                group by Vendor_Product__c];
            
            list<Account> lstVProds = new list<Account>();
            set<string> existingVPs = new set<string>();
            for(AggregateResult aggr : groupedResults){
                Account objVP = new Account();
                objVP.id = (Id)aggr.get('Vendor_Product__c');
                objVP.RETS_Agent_Count__c = integer.valueOf(aggr.get('ag'));
                objVP.RETS_Broker_Count__c = (integer)aggr.get('br');
                existingVPs.add(objVP.id);
                lstVProds.add(objVP);
            }
            
            system.debug('---alstVProds-->'+lstVProds);
            system.debug('---existingVPs-->'+existingVPs);
            
            if(!lstVProds.isEmpty()){               // when Active Order is Inactivated, if some Products are found with Active and some are Inactive/Inprogress for Rets account, make counts as 0 for Inactive/Inprogress Accounts.
                for(string str : setRetsVOIds){
                    if(!existingVPs.contains(str)){
                        system.debug('---existingVPs in not empty-->'+str);
                        Account objVP = new Account();
                        objVP.id = str;
                        objVP.RETS_Agent_Count__c = 0;
                        objVP.RETS_Broker_Count__c = 0;
                        lstVProds.add(objVP);
                    }
                }
            }
            else if(lstVProds.isEmpty()){           // when Active Order is Inactivated, if no Products are found with Active for Rets account, make counts as 0.
                for(string str : setRetsVOIds){
                    system.debug('---existingVPs in empty-->'+str);
                    Account objVP = new Account();
                    objVP.id = str;
                    objVP.RETS_Agent_Count__c = 0;
                    objVP.RETS_Broker_Count__c = 0;
                    lstVProds.add(objVP);
                }
            }
            
            if(!lstVProds.isEmpty())
                update lstVProds;
            lstVProds.clear();
        }
    }
    
    //copying billing exclusipns from subproduct to order 
    public static void updateRetsBillingExclusion(list<RETS_Product_Order__c> listProductOrders ){
        if(listProductOrders != null && !listProductOrders.isEmpty()){
            
            system.debug('----listProductOrders--in if->'+listProductOrders);
            set<string> subProdIds = new set<string>();
            for(RETS_Product_Order__c ord : listProductOrders){
                subProdIds.add(ord.RETS_Sub_Product__c);
            }
            
            map<string, RETS_Sub_Products__c> mapSubIdSubProd = new map<string, RETS_Sub_Products__c>();
            for(RETS_Sub_Products__c sub : [Select Id, RETS_Billing_Exclusion__c From RETS_Sub_Products__c Where id in : subProdIds]){
                mapSubIdSubProd.put(sub.Id, sub);
            }
            subProdIds.clear();

            for(RETS_Product_Order__c ord : listProductOrders){         //copying billing exclusipns from subproduct to order
                //system.debug('----ord--->'+ord);
                if(mapSubIdSubProd.containsKey(ord.RETS_Sub_Product__c) && mapSubIdSubProd.get(ord.RETS_Sub_Product__c) != null )
                ord.RETS_Billing_Exclusion__c = mapSubIdSubProd.get(ord.RETS_Sub_Product__c).RETS_Billing_Exclusion__c;
            }
            mapSubIdSubProd.clear();
        }
    }
    
    public static void updateBrokerofRecord(list<RETS_Product_Order__c> newPOs){
        for(RETS_Product_Order__c po: newPOs){
            set<string> OfficeIds = new set<string>();
            

            
            if(po.Agent__c != null){
                Subscriptions__c sub = [Select id, Related_Location_Broker_Office__c, Related_Location_Broker_Office__r.ParentId  from Subscriptions__c 
                                    Where id = :po.Agent__c And Related_Location_Broker_Office__c != null];
                OfficeIds.add(sub.Related_Location_Broker_Office__c);
            
                if(String.isNotBlank(sub.Related_Location_Broker_Office__r.ParentId))
                    officeIds.add(sub.Related_Location_Broker_Office__r.ParentId);
            }
            system.debug('---bef bro--->'+officeIds);
            if(po.Brokerage__c != null){
                OfficeIds.add(po.Brokerage__c);
                Account a = [SELECT Id,Name, ParentId FROM Account WHERE Id = :po.Brokerage__c];
                if(String.isNotBlank(a.ParentId))
                    officeIds.add(a.ParentId);
                system.debug('---a.ParentId--->'+a.ParentId);
            }
            Set<String> allOfficeIds = new Set<String>();
            for(Account a : [SELECT Id,Name,ParentId FROM Account WHERE Id IN :officeIds]){
                allOfficeIds.add(a.Id);
                if(String.isNotBlank(a.ParentId))
                    allOfficeIds.add(a.ParentId);
            }
            system.debug('---officeIds--->'+officeIds);
            for(Relationship__c relationship : [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId, Broker_Office__r.Name,
                                              Subscription__c, Subscription__r.Name, Subscription__r.Contact__c, Subscription__r.Contact__r.Name , Subscription__r.Related_Location_Broker_Office__c
                                      FROM    Relationship__c
                                      WHERE   Relationship_Type__c IN ('Broker Of Record')
                                      AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                      AND     Broker_Office__c IN :allOfficeIds
                                      AND    Status__c = 'Active'
                                      ])
            {
                system.debug('---relationship--->'+relationship.Subscription__r.Contact__r.Name);
                po.Broker_Of_Record__c = relationship.Subscription__r.Contact__r.Name;
                po.OnActivationBrokerofRecord__c = relationship.Subscription__c;
                if(po.Agent__c!=null)
                  po.OnActivationAgentOffice__c = relationship.Subscription__r.Related_Location_Broker_Office__c;
                
            }
                
        }
        /*set<string> agentIds = new set<string>();
        set<string> OfficeIds = new set<string>();
        for(RETS_Product_Order__c po: newPOs){
            if(po.Agent__c != null)
                agentIds.add(po.Agent__c);
            if(po.Brokerage__c != null)
                OfficeIds.add(po.Brokerage__c);
        }
        
        for(Subscriptions__c sub : [Select id, Related_Location_Broker_Office__c, Related_Location_Broker_Office__r.ParentId  from Subscriptions__c 
                                    Where id in: agentIds And Related_Location_Broker_Office__c != null]){
            OfficeIds.add(sub.Related_Location_Broker_Office__c);
            if(String.isNotBlank())
        }
        
        map<string, string> mapOfficeBOR = new map<string, string>();
        for(Relationship__c relationship : [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId, Broker_Office__r.Name,
                                              Subscription__c, Subscription__r.Name, Subscription__r.Contact__r.Name  
                                      FROM    Relationship__c
                                      WHERE   Relationship_Type__c IN ('Broker Of Record')
                                      AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )])
        {
            mapOfficeBOR.put(relationship.Broker_Office__c, relationship.Subscription__r.Contact__r.Name);
            mapOfficeBOR.put(relationship.Subscription__c, relationship.Subscription__r.Contact__r.Name);
        }
        
        for(RETS_Product_Order__c po : newPOs){
            if(po.Agent__c != null && mapOfficeBOR != null && mapOfficeBOR.containsKey(po.Agent__c) && mapOfficeBOR.get(po.Agent__c) != null)
                po.Broker_Of_Record__c = mapOfficeBOR.get(po.Agent__c);
            else if(po.Brokerage__c != null && mapOfficeBOR != null && mapOfficeBOR.containsKey(po.Brokerage__c) && mapOfficeBOR.get(po.Brokerage__c) != null)
                po.Broker_Of_Record__c = mapOfficeBOR.get(po.Brokerage__c);
        }*/
    }
    
	public static void validationOnMissReport(RETS_Product_Order__c newAgentPO, RETS_Product_Order__c newAllPO){
	    
	    system.debug('----newAgentPO-->'+newAgentPO+'---newAllPO--->'+newAllPO);
	    string query = 'Select Name, Agent__c, Brokerage__c, Start_Date__c From RETS_Product_Order__c Where ( Agent__c =: newAgentPO.Agent__c';
	    
	    list<RETS_Product_Order__c> lstPreviousOrd;
		if(newAgentPO != null && newAgentPO.id != null ){
			
			query += ') And createdDate >: newAgentPO.createdDate';
			
			lstPreviousOrd = [Select Name, Agent__c, Brokerage__c, Vendor_Product__c, Start_Date__c
															From RETS_Product_Order__c 
															Where Agent__c =: newAgentPO.Agent__c 
															And Start_Date__c >: newAgentPO.Start_Date__c 
															And createdDate >: newAgentPO.createdDate 
															order by createdDate desc limit 1];
			/*if(lstPreviousOrd != null && !lstPreviousOrd.isEmpty()){
				
				newAgentPO.addError('There is an Order '+lstPreviousOrd[0].Name+' with highest Start Date');
			}*/
		}
		if(newAllPO != null && newAllPO.Id != null ){
			query += ' Or Brokerage__c =: newAllPO.Brokerage__c) And createdDate <: newAllPO.createdDate';
			lstPreviousOrd = [Select Name, Agent__c, Brokerage__c, Vendor_Product__c, Start_Date__c
															From RETS_Product_Order__c 
															Where (Agent__c =: newAllPO.Agent__c Or Brokerage__c =: newAllPO.Brokerage__c) 
															And Start_Date__c >: newAllPO.Start_Date__c 
															And createdDate <: newAllPO.createdDate 
															order by createdDate desc limit 1];
			
		}
		
		query += ' And Start_Date__c >: newAllPO.Start_Date__c order by createdDate desc limit 1';
		
		system.debug('---query -->'+query);
		//Database.query(query);
		if(lstPreviousOrd != null && !lstPreviousOrd.isEmpty()){
			newAllPO.addError('There is an Order '+lstPreviousOrd[0].Name+' with highest Start Date');
		}
	}
}