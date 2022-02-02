trigger ComplianceFineBeforeUpdateInsert on Compliance_Fine__c (before insert, before update) {
    
    Integer aTimer = (Integer)[select id, Appeal_Timer__c
                               from Compliance_Appeal_Config__c limit 1].Appeal_Timer__c;
    
    List<Compliance_Violation__c> cvLst = new List<Compliance_Violation__c>();
    
    // load subscriptions and violations
    Set<String> brokerIds = new Set<String>();
    Set<String> subIds = new Set<String>();
    Set<String> vIds = new Set<String>();
    Set<String> fIds = new Set<String>();
    Set<String> ViolationIds = new Set<String>();
    for (Compliance_Fine__c compFine: trigger.new) {
        subIds.add(compFine.Subscription_ID__c);
        
        String vId = compFine.name.replaceAll('-.*','');
        if (!vIds.contains(vId)) vIds.add(vId);
        if (fIds.contains(compFine.name)) 
            compFine.addError('Fine number not unique: ' + compFine.name);
        fIds.add(compFine.name);
        
        if(compFine.Notification_Type__c == 'Subsequent Fine Notice'){
            ViolationIds.add(vId);
        }
        
        // following code updates Violation_Number_Formatted__c field by removing numbers from 2nd hyphen of the violationNumber
        String violationNumber = compFine.Name;
        Integer countOfHypen = violationNumber.countMatches('-');
        
        if(countOfHypen == 2)
            violationNumber = violationNumber.substringBeforeLast('-');
        
        compFine.Violation_Number_Formatted__c = violationNumber;
    }
    if (trigger.isInsert) {
        // check for duplicate inserts
        for (Compliance_Fine__c cf1: [ Select name, id 
                                      from Compliance_Fine__c where name in :fIds ]) {
                                          for (Compliance_Fine__c cf2: trigger.new) {
                                              if (cf1.name.equals(cf2.name)) 
                                                  cf2.addError('Fine number already exist: ' + cf1.name);
                                          }
                                      }
    }
    Map<String, Subscriptions__c> subs = new Map<String, Subscriptions__c>();
    for (Subscriptions__c s1 : [Select Name,id,Related_Location_Broker_Office__c,contact__c
                                FROM Subscriptions__c WHERE Name in :subIds]) {
                                    subs.put(s1.name, s1); 
                                    if (s1.Related_Location_Broker_Office__c != null) 
                                        brokerIds.add(s1.Related_Location_Broker_Office__c);
                                }
    
    // load brokers and ofc mgrs
    Map<String, id> borIds = new Map<String, id>();
    Map<String, id> omIds  = new Map<String, id>();
    for (Relationship__c r1 :  [ Select Subscription__c, Relationship_Type__c, Broker_Office__c
                                FROM Relationship__c WHERE Broker_Office__c in :brokerIds AND status__c = 'Active']) {
                                    if (r1.Relationship_Type__c.startsWith('Broker Of Record'))
                                        borIds.put(r1.Broker_Office__c,r1.Subscription__c);
                                    if (r1.Relationship_Type__c.equals('Office Manager'))
                                        omIds.put(r1.Broker_Office__c,r1.Subscription__c);
                                }
    
    // load/verify existing violations
    Map<String, Compliance_Violation__c> vId2 = new Map<String, Compliance_Violation__c>();
    for (Compliance_Violation__c cv : [Select name,id,Subscription__c,Date_of_Fine__c,
                                       Subscription_ID__c,MLS_Number__c,Violation__c
                                       FROM Compliance_Violation__c WHERE Name in :vIds]) {
                                           vid2.put(cv.name,cv);
                                       }
    
    Map<String,Date> fineNoticeMap = new Map<String,Date>();
    system.debug('ViolationIds---'+ViolationIds);
    for (Compliance_Fine__c compFine: [SELECT Id, Date_of_Fine__c, Last_Date_to_Appeal__c,Compliance_Violation__c, Compliance_Violation__r.Name FROM Compliance_Fine__c 
                                       WHERE Compliance_Violation__r.Name IN :ViolationIds AND Notification_Type__c = 'Fine Notice' AND Date_of_Fine__c != null]) {
                                           fineNoticeMap.put(compFine.Compliance_Violation__r.Name, CompFine.Last_Date_to_Appeal__c);
                                       }
    system.debug('fineNoticeMap---'+fineNoticeMap);
    for (Compliance_Fine__c compFine: trigger.new) {
        String vName = compFine.Name.replaceAll('-.*','');
        // pending condition?
        if(compFine.QC_Fine_Code__c != null && compFine.QC_Fine_Code__c.startsWith('QC') && 
           !compFine.QC_Fine_Code__c.equals('QCDATA0') && String.isEmpty(compFine.Status__c)) 
            compFine.Status__c = 'Pending';
        
        if (compFine.Status__c == 'Pending') {
            
            if(compFine.Notification_Type__c == 'Subsequent Fine Notice'){
                if( fineNoticeMap != null && fineNoticeMap.containskey(compFine.Name.replaceAll('-.*',''))){
                    system.debug('***compFine.Last_Date_to_Appeal__c'+compFine.Last_Date_to_Appeal__c);
                    compFine.Last_Date_to_Appeal__c = fineNoticeMap.get(vName);
                }
                else{
                    compFine.addError('There is no Fine Notice for Violation - '+compFine.Name);
                }
            }
            else if (compFine.Date_of_Fine__c != null)
                compFine.Last_Date_to_Appeal__c = compFine.Date_of_Fine__c + 20;
            
            
            // set Bill Date -- based on custom setting timer
            compFine.Bill_Date__c = compFine.Last_Date_to_Appeal__c + 1;            
            if (compFine.Finance_override__c || compFine.Bill_Now__c ||
                compFine.Bill_date__c <= date.today()) {
                    compFine.Status__c = 'Ready to Bill';
                }
        }
        
        // get violation text
        compFine.Violation_Customer__c = ComplianceUtil.violation2customer(compFine.Violation__c);
        
        // set the fine amount based on the fine code
        compFine.Fine_Amount__c = ComplianceUtil.fineCode2amt(compFine.QC_Fine_Code__c);
        
        // set fields derived from subscription
        if (subs.get(compFine.Subscription_ID__c) != null) {
            compFine.Subscription__c = subs.get(compFine.Subscription_ID__c).id;
            compFine.Broker__c = subs.get(compFine.Subscription_ID__c).Related_Location_Broker_Office__c;
            compFine.Agent_Name__c = subs.get(compFine.Subscription_ID__c).contact__c;
        }
        
        // set relationship fields
        compFine.Broker_Of_Record__c = borIds.get(compFine.Broker__c);
        compFine.Office_Manager__c = omIds.get(compFine.Broker__c);
        
        String vId = compFine.name.replaceAll('-.*','');
        Compliance_Violation__c cv = vId2.get(vId);
        
        if (cv == null) cv = new Compliance_Violation__c();
        cv.name = vId;
        cv.Subscription__c = compFine.Subscription__c;
        cv.Date_of_Fine__c = compFine.Date_of_Fine__c;
        cv.Subscription_ID__c = compFine.Subscription_ID__c;
        cv.MLS_Number__c = compFine.MLS_Number__c;
        cv.Violation__c = compFine.Violation__c;
        
        // unique violation?
        Boolean vUniq = true;
        for (Compliance_Violation__c cv1 : cvLst) {
            if (vId.equals(cv1.name)) {
                vUniq = false;
            }
        }
        if (vUniq) cvLst.add(cv);
    }
    upsert cvLst;
    
    // set violation ids
    for (Compliance_Fine__c compFine: trigger.new) {
        String vId = compFine.name.replaceAll('-.*','');
        for (Compliance_Violation__c cv : cvLst) {
            if (vId.equals(cv.name)) {
                compFine.Compliance_Violation__c = cv.id;
            }
        }
    }
    
    /*****
*****   Send to Billing
*****/
    
    List<string> toBeBilledIds = new List<String>();
    for(Compliance_Fine__c cFine : trigger.new){
        if(trigger.isInsert) {
            if(cFine.Status__c == 'Ready to Bill') {
                toBeBilledIds.add(cFine.Id);
                cFine.Zuora_Status__c = 'Sent'; 
                system.debug('*** Insert ');           
            }
        }
        else {
            if(cFine.Status__c == 'Ready to Bill' && trigger.oldMap.get(cFine.id).Status__c != 'Ready to Bill'){
                toBeBilledIds.add(cFine.Id);
                cFine.Zuora_Status__c = 'Sent';
                system.debug('*** Update ');  
            }
        }
    }
    if (toBeBilledIds.Size() > 0) {
        SMS_ComplinaneFine_Zuora obj = new SMS_ComplinaneFine_Zuora(toBeBilledIds);
        Database.executeBatch(obj, 1);
        system.debug('*** SMS_ComplinaneFine_Zuora called');  
    }   
}