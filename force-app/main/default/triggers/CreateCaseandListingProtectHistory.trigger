trigger CreateCaseandListingProtectHistory on Account (after update) 
{
    System.debug('CreateCaseandListingProtectHistory Entry : Number of Queries used in this apex code so far: ' + Limits.getQueries());
    if (Utils.BypassValidationrules())return;
    System.debug('CreateCaseandListingProtectHistory : Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
    List<Id> accountId = new List<Id>();
    List<Case> cases = new List<Case>();
    List<Listing_Protect_Program_History__c> listingHistory = new List<Listing_Protect_Program_History__c>();
    List<Relationship__c> relationship = new List<Relationship__c>();
    
    System.debug('CreateCaseandListingProtectHistory 1 : Number of Queries used in this apex code so far: ' + Limits.getQueries());
     
    for(Account a : Trigger.new)
    {
        if(trigger.oldMap.get(a.id).Listing_Protect_Program__c != a.Listing_Protect_Program__c)
        {
            accountId.add(a.id);    
        }    
    }
    
    System.debug('CreateCaseandListingProtectHistory 2 : Number of Queries used in this apex code so far: ' + Limits.getQueries());
    
    if(accountId.isEmpty() == false) {
        QueueSobject queueLevel3 = [Select Id, Queue.Name,Queue.ID from QueueSobject  where Queue.Name = 'Level 3'];
        
        relationship = [select id,Name,
                               Subscription__c,
                               Subscription__r.Private_Email__c,
                               Subscription__r.Contact__c,
                               Subscription__r.Contact__r.Name,
                               Relationship_Type__c,
                               Broker_Office__c,
                               Broker_Office__r.Listing_Protect_Program__c,
                               Broker_Office__r.Name,
                               Broker_Office__r.BOR_Initials__c                      
                        from Relationship__c 
                        where Relationship_Type__c = 'Broker of Record' 
                              and Broker_Office__c in :accountId
                              and (Relationship_End_Date__c = null OR Relationship_End_Date__c >= :system.today())
                              and Subscription__r.Primary__c = true];
        
        System.debug('CreateCaseandListingProtectHistory 3 : Number of Queries used in this apex code so far: ' + Limits.getQueries());
                              
        for(Relationship__c r : relationship)
        {
            Case c = new Case();
            String optPrevious = r.Broker_Office__r.Listing_Protect_Program__c ? 'Opt Out' : 'Opt In';
            String optCurrent = r.Broker_Office__r.Listing_Protect_Program__c ? 'Opt In' : 'Opt Out';
            
            c.AccountId = r.Broker_Office__c;
            c.ContactId = r.Subscription__r.Contact__c;
            c.Subscription_ID__c = r.Subscription__c;
            c.Product__c = 'Listing Protect Program';
            
            c.Category__c = r.Broker_Office__r.Listing_Protect_Program__c ? 'Request Opt In' : 'Request Opt Out';
            
            c.Subject = 'Broker Opt In / Opt Out';
            c.Status = 'Not Started';
            c.Origin = 'Self Service'; 
            c.OwnerID = queueLevel3.Queue.id;
            c.Description = String.format(
                'Listing Protect program change request from {0} to {1} for {2} requested by {3}',
                new String[] {optPrevious, optCurrent, r.Broker_Office__r.Name, r.Subscription__r.Contact__r.Name});
            
            cases.add(c);        
        }
        insert cases ;
        
         System.debug('CreateCaseandListingProtectHistory 4 : Number of Queries used in this apex code so far: ' + Limits.getQueries());
         
        Integer i = 0;
        for(Relationship__c r : relationship)
        {
            Listing_Protect_Program_History__c cph = new Listing_Protect_Program_History__c();
            cph.BOR_Name__c = r.Subscription__r.Contact__r.Name;
            cph.Office_ID__c = r.Broker_Office__c;
            cph.BOR_Email_ID__c = r.Subscription__r.Private_Email__c;
            cph.Subscription_ID__c = r.Subscription__c;
            cph.Case_ID__c = cases[i++].id;
            cph.BOR_Initials__c = r.Broker_Office__r.BOR_Initials__c;
            if(r.Broker_Office__r.Listing_Protect_Program__c)
            {
                cph.Current_Selection__c = 'Opt In';
                cph.Previous_Selection__c = 'Opt Out';
            }
            else
            {
                cph.Current_Selection__c = 'Opt Out';
                cph.Previous_Selection__c = 'Opt In';
            }
            listingHistory.add(cph);
        }
        insert listingHistory;  
         System.debug('CreateCaseandListingProtectHistory Final : Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
}