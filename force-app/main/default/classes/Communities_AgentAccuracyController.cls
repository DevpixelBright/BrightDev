public class Communities_AgentAccuracyController {
    public String subscriptionId { get; set;}
    public String vioNumber {get; set;}
    public list<complianceFinesWrapper> lstcomplianceFinesWrapper {get; set;}
    public string finalComplianceWrap {get; set;}
    public String caseNumber { get; set; }
    public String violationNumber { get; set; }
    public Boolean ifCaseExists {get; set;}
    public list<Case> lCase {get;set;}
        
    public Communities_AgentAccuracyController(){                
        
        subscriptionId = ApexPages.currentPage().getParameters().get('id');
		ifCaseExists = false;        
        system.debug('subscription id:- ' + subscriptionId);
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
        system.debug('---sub--'+subscriptionId+'---lstComplianceViolations--->'+lstComplianceViolations);
        lstcomplianceFinesWrapper = new list<complianceFinesWrapper>();
        
        if(lstComplianceViolations == null || lstComplianceViolations.isEmpty())
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Compliance fines'));
        
        for(Compliance_Violation__c com: lstComplianceViolations){
            if(com.Compliance_Fines__r != null && !com.Compliance_Fines__r.isEmpty()){
                
                system.debug('---com.Compliance_Fines__r--->'+com.Compliance_Fines__r);
                complianceFinesWrapper objWrap = new complianceFinesWrapper();
                
                boolean haveMoreFines = false;
                string remainingFinesTable = '<div class="arrow-up"></div><div class="slide-down"><table class="table table-striped table-bordered ">';
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
                string innerTableTitle = '';
                Integer i =0;
                for(Compliance_Fine__c fine: com.Compliance_Fines__r) {
                    system.debug('---fine.Notification_Type__c-->'+fine.Notification_Type__c+'---'+fine.Last_Date_to_Appeal__c);
                    
                                        
                    //String violationNumber = fine.Violation_Number_Formatted__c != null ? fine.Violation_Number_Formatted__c : '';
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
                    
                    if(i > 0) {
                        remainingFinesTable += '<tr class="innershown">';
                        
                        if(innerTableTitle == ''){
                            innerTableTitle = 'List of violations for the type ';
                            remainingFinesTable += '<td class="innerspan" colspan="2" >'+innerTableTitle;
                            
                            if(fine.Violation_Customer__c != null){
                                remainingFinesTable += objWrap.violationType;
                            }
                            else
                                remainingFinesTable += 'No Photo';
                            
                            remainingFinesTable += '</td>';
                        }
                        else
                            remainingFinesTable += '<td class="innerspan" colspan="2"></td>';
                        
                        
                        remainingFinesTable += '<td>' + violationNumber+'</td>';
                        
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
                                remainingFinesTable += '<td>' + '-$' + string.valueOf(fine.Fine_Amount__c * -1) +'</td>';
                            else 
                                remainingFinesTable += '<td>' + '$' + string.valueOf(fine.Fine_Amount__c) +'</td>';    
                        }
                        else 
                            remainingFinesTable += '<td></td>';                            

                        string temp = (fine.status__c == null || fine.status__c == 'null' || fine.status__c == 'Null') ? '' : fine.status__c;
                        system.debug('--temp--'+temp);
                        
                        remainingFinesTable += '<td>' + ((fine.status__c == null || fine.status__c == 'null' || fine.status__c == 'Null') ? '' : fine.status__c) +'</td>';
                        
                        if(fine.Last_Date_to_Appeal__c != null)
                            remainingFinesTable += '<td>' + fine.Last_Date_to_Appeal__c.format() +'</td>';
                        else
                            remainingFinesTable += '<td></td>';
                        
                        if((fine.status__c == 'Pending' && fine.Last_Date_to_Appeal__c >= Date.today() && fine.Notification_Type__c == 'Fine Notice') || 
                           (fine.status__c == 'Pending' && fine.Last_Date_to_Appeal__c >= Date.today() && fine.Notification_Type__c == 'Immediate Fine Notice' && fine.Fine_Amount__c > 0) ||
                           (fine.status__c == 'Pending' && fine.Last_Date_to_Appeal__c >= Date.today() && fine.Notification_Type__c == 'Fine Notice (Agent Violation)' && fine.Fine_Amount__c > 0) ||
                           (fine.status__c == 'Pending' && fine.Last_Date_to_Appeal__c >= Date.today() && fine.Notification_Type__c == 'Immediate Fine Notice (Agent Violation)' && fine.Fine_Amount__c > 0)){
                            remainingFinesTable += '<td><button class="appealbutton" id="violation" onclick="saveCaseDetails(\''+fine.Name+'\'); return false;" >Appeal</button></td>';
                               
                        }else{
                            remainingFinesTable += '<td></td>';
                        }
                        
                        remainingFinesTable += '</tr>';
                        haveMoreFines = true;                       
                        
                    }
                    else{
                        objWrap.fineName = fine.Name;
                        objWrap.mlsNumber = fine.Compliance_Violation__r.MLS_Number__c;
                        objWrap.violationType = fine.Violation_Customer__c;
                        //objWrap.violationNo = violationNumber;
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
                        objWrap.status = (fine.status__c == null || fine.status__c == 'null' || fine.status__c == 'Null' ? '' : fine.Status__c);
                        objWrap.lastDayToAppeal = fine.Last_Date_to_Appeal__c != null ? fine.Last_Date_to_Appeal__c.format() : string.valueOf(fine.Last_Date_to_Appeal__c);
                        if((fine.status__c == 'Pending' && fine.Last_Date_to_Appeal__c >= Date.today() && fine.Notification_Type__c == 'Fine Notice') || 
                           (fine.status__c == 'Pending' && fine.Last_Date_to_Appeal__c >= Date.today() && fine.Notification_Type__c == 'Immediate Fine Notice' && fine.Fine_Amount__c > 0) ||
                           (fine.status__c == 'Pending' && fine.Last_Date_to_Appeal__c >= Date.today() && fine.Notification_Type__c == 'Fine Notice (Agent Violation)' && fine.Fine_Amount__c > 0) ||
                           (fine.status__c == 'Pending' && fine.Last_Date_to_Appeal__c >= Date.today() && fine.Notification_Type__c == 'Immediate Fine Notice (Agent Violation)' && fine.Fine_Amount__c > 0))
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
                lstcomplianceFinesWrapper.add(objWrap);
                system.debug('---lstcomplianceFinesWrapper--'+lstcomplianceFinesWrapper);
            }
        }
        system.debug('*****'+lstcomplianceFinesWrapper);
        system.debug('---wrapper sizer-->'+lstcomplianceFinesWrapper.size()+'--wrapper->'+lstcomplianceFinesWrapper);
        finalComplianceWrap = JSON.serialize(lstcomplianceFinesWrapper);

    }
         
    @RemoteAction
    public static string fetchCases(String violationNumber) {
        system.debug('violationNumber--'+violationNumber);
        List<group> queueIds = [SELECT Id FROM  group WHERE  DeveloperName = 'Appeals'];
        User u = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        String caseNumber='';
        List<Case> lCase = new List<Case>();
        lCase = [SELECT Id,CaseNumber, Origin, Subscription_ID__c,Type_of_Violation__c, ContactId, OwnerId, Status, Product__c
                 FROM   Case 
                 WHERE Status = 'Not Started' 
                 AND Subject = 'Appeals Form'
                 AND Origin = 'Fine Appeal Form'
                 AND Product__c = 'Compliance'
                 AND ContactId =: u.ContactId 
                 AND OwnerId=:queueIds[0].Id 
                 AND Violation_Number__c = :violationNumber
                ];
        system.debug('*****CASESSSSSSSS******'+lCase);

        if(lCase.size()>0){
            caseNumber = lCase[0].CaseNumber;
        }
        return caseNumber;
    }
    
    public class complianceFinesWrapper{
        public string childViolations {get; set;}        
        public string mlsNumber {get; set;}
        public string violationType {get; set;}
        public string violationNo {get; set;}
        public string fineName {get; set;}
        public string notificationType {get; set;}
        public string notificationDate {get; set;}
        public string fineAmount {get; set;}
        public string status {get; set;}
        public string lastDayToAppeal {get; set;}
        public boolean displayAppeal { get; set; }       
    }
    public class CustomException extends Exception {}
}