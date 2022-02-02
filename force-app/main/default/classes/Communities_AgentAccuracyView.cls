public class Communities_AgentAccuracyView {
    public String subscriptionId { get; set;}
    public List<complianceFinesWrapper> lstcomplianceFinesWrapper {get; set;}
    public String finalComplianceWrap {get; set;}
    
    public Communities_AgentAccuracyView(){
        
            subscriptionId = ApexPages.currentPage().getParameters().get('id');
            if (String.IsBlank(subscriptionId))
                throw new CustomException('Invalid MRIS Subscription ID: No Subscription ID found ' );
            
            
            List<Compliance_Violation__c> lstComplianceViolations = [Select Id, Name, MLS_Number__c, Fine_Total__c, Violation__c, Subscription__c, Subscription__r.Name, 
                                                                    (Select Id, Name, Date_of_Fine__c, Fine_Amount__c, Last_Date_to_Appeal__c, Notification_Type__c, Status__c,
                                                                     Compliance_Violation__r.MLS_Number__c, Violation_Type_ID__c, Violation_Customer__c
                                                                     From Compliance_Fines__r order by Name desc) 
                                                                    From Compliance_Violation__c 
                                                                    Where Subscription__c != null 
                                                                    And Subscription__r.Name =: subscriptionId 
                                                                    And createdDate >= last_n_months:6
                                                                    order by createdDate desc 
                                                                    ];
        system.debug('---sub--'+subscriptionId+'---lstComplianceViolations--->'+lstComplianceViolations);
            lstcomplianceFinesWrapper = new List<complianceFinesWrapper>();
            
            if(lstComplianceViolations == null || lstComplianceViolations.isEmpty())
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Compliance fines'));
            
            for(Compliance_Violation__c com: lstComplianceViolations){
                if(com.Compliance_Fines__r != null && !com.Compliance_Fines__r.isEmpty()){
                    
                    system.debug('---com.Compliance_Fines__r--->'+com.Compliance_Fines__r);
                    complianceFinesWrapper objWrap = new complianceFinesWrapper();
                    //List<Compliance_Fine__c> lstfines = new List<Compliance_Fine__c>();
                    
                    boolean haveMoreFines = false;
                    String remainingFinesTable = '<div class="arrow-up"></div><div class="slide-down"><table class="table table-striped table-bordered ">';
                        remainingFinesTable += '<thead>'+
                                                '<tr class="innertableheader">'+
                                                    '<th>MLS#</th>'+
                                                    '<th>Violation Type</th>'+
                                                    '<th>Violation No</th>'+
                                                    '<th>Notification Type</th>'+
                                                    '<th>Notification Date</th>'+
                                                    '<th>Fine Amount</th>'+
                                                    '<th>Status</th>'+
                                                    '<th>Last Day of Appeal</th>'+
                                                    '<th</th>'+
                                                '</tr>'+
                                                '</thead><tbody>';
                    
                    system.debug('******** Compliance fines:' + com.Compliance_Fines__r);
                    String innerTableTitle = '';
                    Integer i =0;
                    for(Compliance_Fine__c fine: com.Compliance_Fines__r) {
                        system.debug('---fine.Notification_Type__c-->'+fine.Notification_Type__c+'---'+fine.Last_Date_to_Appeal__c);
                        
                        if(i > 0) {
                            
                            //lstfines.add(fine);
                            
                            remainingFinesTable += '<tr class="innershown">';
                            
                            
                            if(innerTableTitle == ''){
                                innerTableTitle = 'List of violations for the type ';
                                remainingFinesTable += '<td class="innerspan" colspan="2" >'+innerTableTitle;
                                
                                if(fine.Violation_Customer__c != null){
                                    //remainingFinesTable += fine.Violation_Customer__c ;
                                    remainingFinesTable += objWrap.violationType;
                                }
                                else
                                    remainingFinesTable += 'No Photo';
                                
                                remainingFinesTable += '</td>';
                            }
                            else
                                remainingFinesTable += '<td class="innerspan" colspan="2"></td>';
                            
                            
                            remainingFinesTable += '<td>' + fine.Name+'</td>';
                                                  
                            
                            if(fine.Notification_Type__c != null)
                                remainingFinesTable += '<td>' + fine.Notification_Type__c +'</td>';
                            else
                                remainingFinesTable += '<td></td>';
                            
                            if(fine.Date_of_Fine__c != null)
                                remainingFinesTable += '<td>' + fine.Date_of_Fine__c.format() +'</td>';
                            else
                                remainingFinesTable += '<td></td>';        
                             
                            if(fine.Fine_Amount__c != null) {
                                if(fine.Fine_Amount__c < 0)
                                    remainingFinesTable += '<td>' + '-$' + String.valueOf(fine.Fine_Amount__c * -1) +'</td>';
                                else 
                                    remainingFinesTable += '<td>' + '$' + String.valueOf(fine.Fine_Amount__c) +'</td>';    
                            }
                            else 
                                remainingFinesTable += '<td></td>';                            
                             
                            
                            remainingFinesTable += '<td>' + fine.status__c +'</td>';
                            
                            if(fine.Last_Date_to_Appeal__c != null)
                                remainingFinesTable += '<td>' + fine.Last_Date_to_Appeal__c.format() +'</td>';
                            else
                                remainingFinesTable += '<td></td>';
                            
                            remainingFinesTable += '<td></td>';
                            
                            remainingFinesTable += '</tr>';
                            
                            haveMoreFines = true;                       

                        }
                        else{
                            //objWrap.latestComplianceFine = fine;
                            objWrap.mlsNumber = fine.Compliance_Violation__r.MLS_Number__c;
                            objWrap.violationType = fine.Violation_Customer__c;
                            objWrap.violationNo = fine.Name;
                            objWrap.notificationType = fine.Notification_Type__c;
                            objWrap.notificationDate = fine.Date_of_Fine__c != null ? fine.Date_of_Fine__c.format() : String.valueOf(fine.Date_of_Fine__c);
                            if(fine.Fine_Amount__c != null) {
                                if(fine.Fine_Amount__c < 0)
                                    objWrap.fineAmount = '-$' + String.valueOf(fine.Fine_Amount__c * -1);
                                else 
                                    objWrap.fineAmount = '$' + String.valueOf(fine.Fine_Amount__c);    
                            }
                            else 
                                objWrap.fineAmount = null; 
                            objWrap.status = fine.status__c;
                            objWrap.lastDayToAppeal = fine.Last_Date_to_Appeal__c != null ? fine.Last_Date_to_Appeal__c.format() : String.valueOf(fine.Last_Date_to_Appeal__c);
                            if(fine.status__c == 'Pending' && fine.Last_Date_to_Appeal__c > Date.today()) 
                                objWrap.displayAppeal = true;
                            else
                                objWrap.displayAppeal = false;                            
                        }
                        
                        i++;
                    }
                    
                    if(haveMoreFines == true){
                        remainingFinesTable += '</tbody></table></div>';
                        objWrap.childViolations = remainingFinesTable;
                    }
                    //else{
                        //remainingFinesTable += '<tr><td>0 Fines</td></tr></table></div>';
                        //objWrap.childViolations = remainingFinesTable;
                    //}
                    //objWrap.remainingComplianceFines = lstfines;
                    lstcomplianceFinesWrapper.add(objWrap);
                    system.debug('---lstcomplianceFinesWrapper--'+lstcomplianceFinesWrapper);
                }
                
            }
             system.debug('*****'+lstcomplianceFinesWrapper);
            system.debug('---wrapper sizer-->'+lstcomplianceFinesWrapper.size()+'--wrapper->'+lstcomplianceFinesWrapper);
            finalComplianceWrap = JSON.serialize(lstcomplianceFinesWrapper);
        
        
    }
    
    public class complianceFinesWrapper{
        //public Compliance_Fine__c latestComplianceFine{get; set;}
        //public List<Compliance_Fine__c> remainingComplianceFines {get; set;}
        public String childViolations {get; set;}
        
        public String mlsNumber {get; set;}
        public String violationType {get; set;}
        public String violationNo {get; set;}
        public String notificationType {get; set;}
        public String notificationDate {get; set;}
        public String fineAmount {get; set;}
        public String status {get; set;}
        public String lastDayToAppeal {get; set;}
        public boolean displayAppeal { get; set; }
        //public String buttonStr{get; set;}
        
    }
    public class CustomException extends Exception {}
}