public class AccuracyIssueFormPR_Controller {

    public String taxId { get; set; } 
    public String propertyAddress { get; set; }
    public String fromName { get; set; } 
    public String topic { get; set; } 
    public String description { get; set; }
    public String msg { get; set; }
    public case newcase {get; set;}
    public Subscriptions__c subscription {get;set;}
    public String subscriptionId { get; set; }
    public Map<String,String> topicCategories { get; set;}
    
    public List<SelectOption> topics{
        get{
            topics = new List<SelectOption>();
            List<SelectOption> options = new List<SelectOption>();
            List<String> categories = new List<String>();
            categories.addAll(topicCategories.keyset());         
            categories.sort();
            
            for(String category : categories){
                options.add(new Selectoption(category, category));
            }
            
            return options;
                
        }
        set;
    }
    
    public AccuracyIssueFormPR_Controller() {
        subscription = New Subscriptions__c();  
        
        topicCategories = new Map<String, String>{'Address Data' => 'Address Data',
                                                  'Characteristic Data' => 'Prop Char Data',
                                                  'Flood Data' => 'Flood Data',
                                                  'General Function' => 'General Function',
                                                  'Geo-Code & Census Data' => 'Geo-Code & Census Info',
                                                  'Incorrect or Missing Data' => 'Incorrect/Missing Data',
                                                  'Incorrect or No MLS Link' => 'Bad/No MLS Link',
                                                  'Labels & Exports' => 'Labels-Export',
                                                  'Mortgage Data' => 'Mortgage Inquiry',
                                                  'Other Incorrect/Missing Data' => 'Other Incorrect/Missing Data',
                                                  'Owner Data' => 'Owner Data',
                                                  'Sale Data' => 'Sale Data',
                                                  'Searching' => 'Search and Report',
                                                  'Street Map' => 'Street Map',
                                                  'Subdivision Data' => 'Subdivision Data',
                                                  'Tax & Assessment Data' => 'Tax/Assessment Data',
                                                  'Tax Maps' => 'Tax Maps'        
                                                };   
        
        if(ApexPages.currentPage().getParameters().get('taxid') != null)
            taxId = ApexPages.currentPage().getParameters().get('taxid');
        
        if(ApexPages.currentPage().getParameters().get('address') != null)
            propertyAddress = ApexPages.currentPage().getParameters().get('address');
        
        if(ApexPages.currentPage().getParameters().get('from') != null){
            fromName = ApexPages.currentPage().getParameters().get('from');
            
            
            subscriptionId = fromName.split('\\(')[1].split('\\)')[0];
            system.debug('---subId-->'+subscriptionId );
            try{
                validateSubscription();
            }
            catch(Exception e){
                msg = e.getMessage(); 
            }          
        }          
    }
    
    public PageReference submitAccuracyForm() {
        
        try {
            validateSubscription();
            List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                           FROM   QueueSobject 
                                           WHERE  SobjectType = 'Case' 
                                           AND    Queue.DeveloperName = 'Public_Records'];
   
            newcase = new Case();
            newCase.OwnerId = queueIds[0].QueueId;
            newcase.Origin ='Accuracy Issue';
            newcase.Subject='Accuracy Issue - ' + propertyAddress;
            newcase.Status = 'Not Started';
            newcase.Description = description;
            newcase.Tax_ID__c = taxId;
           
            newcase.Subscription_ID__c = subscription.id;
            newcase.contactId = subscription.Contact__c;
            newcase.Related_Account__c = subscription.Related_Location_Broker_Office__c;                
            newcase.Listing_Agent__c = subscription.Name;           
            
            newcase.MLS__c = 'BRIGHT';            
            newcase.Product__c = 'Public Records';
            newcase.Category__c = topicCategories.get(topic);            
            
            insert newcase;
            
            newcase = [SELECT caseNumber From Case Where id =: newcase.Id];
            
            PageReference ref = new PageReference('/apex/AccuracyIssuePRPdf');
            ref.setRedirect(false);
            Blob reportPdf = Page.AccuracyIssuePRPdf.getContentAsPDF();
            Attachment att = new Attachment();
            att.Body = reportPdf;
            att.name = 'AccuracyIssue.pdf';
            att.ParentId = newcase.id;
            insert att;
            return ref;
            
        }
        catch(Exception e) {
            msg = e.getMessage(); 
            return null;
        }        
    }
    
    public void validateSubscription(){
        list<Subscriptions__c> subscriptions = [SELECT Id,Name, Contact__c, 
                                                       Related_Location_Broker_Office__c,
                                                       Related_Location_Broker_Office__r.Name,
                                                       Related_Location_Broker_Office__r.Account_Name__c 
                                                FROM   Subscriptions__c 
                                                WHERE  Name =: subscriptionId
                                               ];
        
        if(subscriptions != null && subscriptions.size() >0 )
            subscription = subscriptions[0];      
        else
            throw new CustomException('Invalid Subscription: ' + fromName);
    }
    
    public class CustomException extends Exception {}
}