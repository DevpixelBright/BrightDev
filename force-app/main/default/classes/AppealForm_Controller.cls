public class AppealForm_Controller {
    /*public String First Name { get; set;}
    public String Last Name { get; set; } 
    public String Subscriber ID { get; set; }
    public String Email { get; set; } 
    public String Broker Code Affiliation { get; set; } 
    public String MLS Number { get; set; }
    public String Dates of Fine { get; set; }
    public String Fine Amount { get; set; }
    public String Property Address { get; set; } 
    public String City { get; set; } 
    public String State { get; set; }
    public String Reason for Appeal { get; set; }*/
    public String FineId { get; set;}
    public Compliance_Fine__c lst { get; set;}
    public Attachment Fine { get; set; }
    public case newcase {get; set;}
    public String msg { get; set; }


    
        
    public AppealForm_Controller(){
        
        FineId = ApexPages.currentPage().getParameters().get('id');
        
        list<Compliance_Fine__c> lstCompliancefine = [Select  Id, Name, Date_of_Fine__c, Fine_Amount__c, Subscription__r.Name,Broker_Of_Record__c,
                                                      		  Broker_Of_Record__r.Name, Full_Address__c, Agent_Name__c, 
                                                      		  Agent_Name__r.FirstName, Agent_Name__r.LastName,
                                                              Subscription__r.Private_Email__c,Subscription__r.City__c,
                                                              Subscription__r.State__c, MLS_Number__c,
                                                              Violation_Type_ID__c, Violation_Customer__c
                                                      From 	 Compliance_Fine__c	 
                                                      Where	 Id =: FineId ];
        
        lst = lstCompliancefine[0];
       
    
        fine = new Attachment(); 
        
        Attachment a = new Attachment();
        a.Name = fine.Name;
        a.Body = fine.Body;
        // insert a;
        
        
    }
    public void submitAppealForm(){
        try{
            
            List<QueueSobject> queueIds = [SELECT Id, QueueId 
                                           FROM   QueueSobject 
                                           WHERE  SobjectType = 'Case' 
                                           AND    Queue.DeveloperName = 'Appeals'];
            newcase = new Case();
            newCase.OwnerId = queueIds[0].QueueId;
            newcase.Origin ='Fine Appeal Form';
            newcase.Product__c='TBD';
            newcase.Status = 'Not Started';
            newcase.Category__c = 'TBD';
            newcase.MLS_Number__c = lst.MLS_Number__c;
            newcase.Fine_Amount__c = lst.Fine_Amount__c;
            newcase.Property_Street_Address__c = lst.Full_Address__c;
            newcase.Property_City__c = lst.Subscription__r.City__c;
            
            insert newcase;
            
        }
        catch(Exception e) {
            msg = e.getMessage(); 
            
        } 
    }
        public class CustomException extends Exception {}

}