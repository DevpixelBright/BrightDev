public class Communities_AgentAccuracy_Print_export{
    public String subscriptionId { get; set;}
    public list<complianceFinesWrapper> lstcomplianceFinesWrapper {get; set;}
    
    public Communities_AgentAccuracy_Print_export() {
        try{
            subscriptionId = ApexPages.currentPage().getParameters().get('id');
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: No Subscription ID found ' );
            
            list<Compliance_Violation__c> lstComplianceViolations = [Select Id, Name, MLS_Number__c, Fine_Total__c, Violation__c, Subscription__c, Subscription__r.Name, 
                                                                     (Select Id, Name, Date_of_Fine__c, Fine_Amount__c, Last_Date_to_Appeal__c, Notification_Type__c, Status__c,
                                                                      Compliance_Violation__r.MLS_Number__c, Violation_Type_ID__c, Violation_Customer__c, 
                                                                      Violation_Number_Formatted__c
                                                                      From Compliance_Fines__r order by createdDate desc) 
                                                                     From Compliance_Violation__c 
                                                                     Where Subscription__c != null 
                                                                     And Subscription__r.Name =: subscriptionId 
                                                                     And createdDate >= last_n_months:6
                                                                     order by createdDate desc 
                                                                    ];
            
            lstcomplianceFinesWrapper = new list<complianceFinesWrapper>();
            
            if(lstComplianceViolations == null || lstComplianceViolations.isEmpty())
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Compliance fines'));
            for(Compliance_Violation__c com: lstComplianceViolations){
                if(com.Compliance_Fines__r != null && !com.Compliance_Fines__r.isEmpty()){
                    
                    system.debug('---com.Compliance_Fines__r--->'+com.Compliance_Fines__r);
                    
                    boolean haveMoreFines = false;
                    string remainingFinesTable = '<div class="arrow-up"></div><div class="slide-down"><table class="table table-striped table-bordered">';
                    for(Compliance_Fine__c fine: com.Compliance_Fines__r){
                        complianceFinesWrapper objWrap = new complianceFinesWrapper();
                        objWrap.mlsNumber = fine.Compliance_Violation__r.MLS_Number__c;
                        objWrap.violationType = fine.Violation_Customer__c;
                        
                        String violationNumber = fine.Name;
                        if(fine.Violation_Number_Formatted__c != null){
                            violationNumber = fine.Violation_Number_Formatted__c;
                        }
                        else{
                            Integer countOfHypen = violationNumber.countMatches('-');
                            if(countOfHypen == 2)
                                violationNumber = violationNumber.substringBeforeLast('-');
                            
                            fine.Violation_Number_Formatted__c = violationNumber;
                        }
                        //objWrap.violationNo = fine.Name;
                        objWrap.violationNo = violationNumber;
                            
                        objWrap.notificationType = fine.Notification_Type__c;
                        objWrap.notificationDate = fine.Date_of_Fine__c != null ? fine.Date_of_Fine__c.format() : string.valueOf(fine.Date_of_Fine__c);
                        
                        if(fine.Fine_Amount__c != null) {
                            if(fine.Fine_Amount__c < 0)
                                objWrap.fineAmount = '-$' + string.valueOf(fine.Fine_Amount__c * -1);
                            else 
                                objWrap.fineAmount = '$' + string.valueOf(fine.Fine_Amount__c);    
                        }
                        else 
                            objWrap.fineAmount = null;    
                        
                        
                        objWrap.status = fine.status__c;
                        objWrap.lastDayToAppeal = fine.Last_Date_to_Appeal__c != null ? fine.Last_Date_to_Appeal__c.format() : string.valueOf(fine.Last_Date_to_Appeal__c);
                        lstcomplianceFinesWrapper.add(objWrap);
                        
                    }
                    system.debug('lstcomplianceFinesWrapper'+ lstcomplianceFinesWrapper); 
                }
            }
        }
        catch(Exception e){
            system.debug('--exception--->'+e.getMessage());
        } 
    }
    public class complianceFinesWrapper{
        public String subscriptionId { get; set; }
        public string mlsNumber {get; set;}
        public string violationType {get; set;}
        public string violationNo {get; set;}
        public string notificationType {get; set;}
        public string notificationDate {get; set;}
        public string fineAmount {get; set;}
        public string status {get; set;}
        public string lastDayToAppeal {get; set;}
    }
    public class CustomException extends Exception {}       
}