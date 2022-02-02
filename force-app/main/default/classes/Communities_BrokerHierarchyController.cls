public class Communities_BrokerHierarchyController {
    
    @AuraEnabled
    public static Account getDetails(String subId){
        
        try 
        {
            system.debug('subId-4565011---'+subId);
            List<Relationship__c> relationships = new List<Relationship__c>();
            relationships = [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId, Broker_Office__r.Name,
                             Subscription__r.Name, Subscription__r.Contact__r.Name, Subscription__r.Contact__r.Id
                             FROM    Relationship__c
                             WHERE   Relationship_Type__c IN ('Broker Of Record', 'Authorized Signer', 'Office Manager')
                             AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                             AND     Subscription_ID__c = :subId 
                            ];
            
            List<String> parentIds = new List<String>();
            system.debug('relationships-->'+relationships);
            for(Relationship__c relationship : relationships){
                system.debug('** relationship.Broker_Office__r.ParentId: ' + relationship.Broker_Office__r.ParentId);
                system.debug('** relationship.Broker_Office__c: ' + relationship.Broker_Office__c);
                
                if(String.IsNotBlank(relationship.Broker_Office__r.ParentId))
                    parentIds.add(relationship.Broker_Office__r.ParentId);            
                
                if(String.IsNotBlank(relationship.Broker_Office__c))
                    parentIds.add(relationship.Broker_Office__c);
            }
            List<Account> relatedAccounts = new List<Account>(); 
            relatedAccounts = [SELECT Id, ParentId, Name,Brand__c,HoldingCompany__c
                               FROM   Account
                               WHERE  (ParentId IN :parentIds OR Id IN :parentIds) AND Status__c = 'Active' and Company_Type__c='Broker Office'
                              ];
            
            return relatedAccounts[0];
            
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));  
            throw new AuraHandledException(e.getMessage());           
        }
    }
    
    @AuraEnabled 
    public static Map<String, String> getBrandFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Account.Brand__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    @AuraEnabled 
    public static Map<String,List<String>> getHoldingCompanyFieldValue(){
        Map<String,List<String>> dependentPicklist = new Map<String,List<String>>();
        Map<String,Brokerage_Attribute__c> holdingCompanyValues=Brokerage_Attribute__c.getAll();
		for(Brokerage_Attribute__c m:holdingCompanyValues.values())
		{
    		if(!dependentPicklist.containsKey(m.Brand__c))
            {
        		dependentPicklist.put(m.Brand__c,new List<String>{m.Holding_Company__c});
   			 }else{
        		dependentPicklist.get(m.Brand__c).add(m.Holding_Company__c);
    		}
 		}
        system.debug('dependentPicklist==>'+dependentPicklist);
        return dependentPicklist;
    }
    
    @AuraEnabled 
    public static void updateBrokerInformation(String accountId, string brandValue, string companyValue, string userId){
        List<Account> updateaccounts = new List<Account>();
        string userName;
        List<User> user=[Select Id,Name from user where Id=:userId];
        if(user.size()>0){
            userName=user[0].Name;
        }
        system.debug('accountId---'+accountId);
        //List<Account> accts = [Select Id, Brand__c,HoldingCompany__c from Account where (ParentId =:accountId OR Id =:accountId)];
        List<Account> accts = [Select Id, Brand__c,HoldingCompany__c from Account where Id =:accountId];
        if(accts.size()>0)
        {
            if(brandValue!=null)
            {
                accts[0].Brand__c=brandValue;
            }
            if(companyValue!=null)
            {
                accts[0].HoldingCompany__c=companyValue; 
            }
            accts[0].Broker_Hierarchy_updated_By__c= 'Information updated by '+userName+' on '+system.today().format();
            //accts[0].Validation_Rule_Time_Stamp__c = system.now();
            updateaccounts.add(accts[0]);	
        }
        if(updateaccounts.size()>0)
        {
            Database.update(updateaccounts);
        }
        
        
    }
    
    @AuraEnabled
    public static List<Account> findHierarchyData(string recId){
        List<Account> accList = new List<Account>();
        string queryString = 'select id,name,type,industry,parentId,Account_Name__c,Street_Name__c,Street_Type__c,City__c,State__c,Zip__c from Account ';
        List<String> currentParent      = new List<String>{};
            Integer level               = 0;
        Boolean endOfStructure      = false;
        currentParent.add(recId);
        system.debug('**********topMostparent:'+ currentParent);
        //Loop though all children
        string finalQueryString = '';
        List<Account>  queryOutput = new List<Account> ();
        while ( !endOfStructure ){  
            if( level == 0 ){
                finalQueryString = queryString + ' where Status__c = \'Active\' and Type!=\'Non Core Parent\' and id IN : CurrentParent ORDER BY ParentId  Limit 1000';
            } 
            else {
                finalQueryString = queryString + ' where Status__c = \'Active\' and Type!=\'Non Core Parent\' and ParentID IN : CurrentParent ORDER BY ParentId desc Limit 1000';
            }
            system.debug('********finalQueryString:'+finalQueryString);
            if(finalQueryString != null && finalQueryString !=''){
                try{
                    if(Limits.getLimitQueries()-Limits.getQueries()>0){
                        queryOutput = database.query(finalQueryString);
                        system.debug('***hierarchy level:'+level);
                    }else{
                        system.debug('****endOfStructure is true as SOQL limit reaches:');
                        endOfStructure = true;
                    }
                }catch(exception ex){ 
                    endOfStructure = true;
                }
            }
            system.debug('**queryOutput size:'+queryOutput);
            if( queryOutput.size() == 0 ){
                endOfStructure = true;
            }
            else{
                currentParent.clear();
                //iterating through query output
                for ( Integer i = 0 ; i < queryOutput.size(); i++ ){
                    currentParent.add(queryOutput[i].Id);
                    accList.add(queryOutput[i]);
                }
            }
            level++;
        }
        system.debug('**********accList:'+accList);
        return accList;
    }
    
   /* @AuraEnabled
    public static Map<String, List<String>> SelectListController(string brandValue){
        Map<String, List<String>> picklistMap = new  Map<String, List<String>> ();
        //system.debug('dependentPicklist111==>'+dependentPicklist);
        //List<String> HoldingValues=dependentPicklist.get(brandValue);
        //system.debug('HoldingValues--->'+HoldingValues);
        Map<String, String> options = new Map<String, String>();
        picklistMap.put('Berkshire Hathaway HomeServices',new List<String>{'HomeServices of America', 'HSF Affiliates'});
        picklistMap.put('Coldwell Banker Real Estate',new List<String>{'Realogy Brokerage Group', 'Realogy Franchise Group'});
        picklistMap.put('Sotheby’s International Reality',new List<String>{'Realogy Brokerage Group', 'Realogy Franchise Group'});
        picklistMap.put('Weichert REALTORS',new List<String>{'Weichert Company Owned', 'Weichert Franchise Group'});
        picklistMap.put('Better Homes and Gardens Real Estate',new List<String>{'Realogy Franchise Group'});
        picklistMap.put('Century 21',new List<String>{'Realogy Franchise Group'});
        picklistMap.put('ERA Real Estate',new List<String>{'Realogy Franchise Group'});
        picklistMap.put('Long & Foster Real Estate',new List<String>{'HomeServices of America','HSF Affiliates'});
        picklistMap.put('Prudential Real Estate',new List<String>{'HomeServices of America','HSF Affiliates'});
        picklistMap.put('Real Living Real Estate',new List<String>{'HomeServices of America','HSF Affiliates'});
        picklistMap.put('eXp Realty',new List<String>{'eXp World Holdings'});
        picklistMap.put('Howard Hanna Real Estate Services',new List<String>{'Howard Hanna Company Owned','Howard Hanna Franchising'});
        return picklistMap;
    }*/
    
    @AuraEnabled 
    public static Boolean getParentAccount(String subId){
        
        List<Relationship__c> relationships = [SELECT  Id, Relationship_Type__c, Broker_Office__c, Broker_Office__r.ParentId, Broker_Office__r.Name,
                                               Subscription__r.Name, Subscription__r.Contact__r.Name, Subscription__r.Contact__r.Id
                                               FROM    Relationship__c
                                               WHERE   Relationship_Type__c IN ('Broker Of Record','Authorized Signer')
                                               AND     ( Relationship_End_Date__c = null OR Relationship_End_Date__c >= TODAY )
                                               AND     Subscription_ID__c = :subId 
                                              ];
        List<String> parentIds = new List<String>();
        
        for(Relationship__c relationship : relationships){
            system.debug('relationships-->'+relationship.Relationship_Type__c);
           /* if(relationship.Relationship_Type__c == 'Broker Of Record'){  
                if(String.IsNotBlank(relationship.Broker_Office__r.ParentId))
                    parentIds.add(relationship.Broker_Office__r.ParentId);  */          
                
                if(String.IsNotBlank(relationship.Broker_Office__c))
                    parentIds.add(relationship.Broker_Office__c);
            //}
        }
        List<Account> relatedAccounts = new List<Account>(); 
        relatedAccounts = [SELECT Id, ParentId, Name,Brand__c,HoldingCompany__c
                           FROM   Account
                           WHERE  (Id IN :parentIds) AND Status__c = 'Active' and Company_Type__c='Broker Office' and parentId=null
                          ];
        
        system.debug('relatedAccounts---'+relatedAccounts);
            if(relatedAccounts.size()>0 && relatedAccounts[0]!=null){
                return false;
            }else{
                return true;
            }
    }
    
}