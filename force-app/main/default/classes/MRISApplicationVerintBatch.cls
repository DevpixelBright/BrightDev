/**
* @author: smilligan@rainamker-llc.com
* @date:  2012-05-14
* This batch process will generate 2 csv files containing Verint Open and Closed Cases 
**/
global class MRISApplicationVerintBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String query = '';
    
    global boolean erroredBatch = false;
    
    final String sourceSystem = 'SalesForce#Case';
        
    Integer numOfOpenCases;
    Integer numOfClosedCases;
    Date dt;
    
    String emailAddress = '';
    
    global static String fileHeader = 'Source System.SourceMeasure, OrgID, AgentID, Date Opened ,Case#, Status' + '\n';
     
    global String closedCaseFile = fileHeader;
    global String openCaseFile = fileHeader; 
    global String OrgID = '';
    global String strConvertedDate;
    
       
    global  Database.Querylocator start(Database.BatchableContext bc) {
        
        try{
                        
            String numOfdays =  '-' + System.Label.MRIS_VERINT_BATCH_RUN_DAY;
         
            Integer k= integer.valueOf(numOfdays);
    
            dt = Date.Today().addDays(k);

            Time tm = Time.newInstance(0,0,0,0);
            DateTime dttm = DateTime.newInstanceGMT(dt, tm);
            String sdttm = dttm.formatGMT('yyyy-MM-dd') + 'T' + dttm.formatGMT('HH:mm:ss.SSS') + 'Z';

            Time endtm = Time.newInstance(23,59,0,0);
            DateTime edttm = DateTime.newInstanceGMT(dt, endtm);
            string sedttm = edttm.formatGMT('yyyy-MM-dd') + 'T' + edttm.formatGMT('HH:mm:ss.SSS') + 'Z';

            query = 'SELECT Status, ClosedDate, CreatedDate, CaseNumber , CreatedBy.Name, LastModifiedBy.Name FROM CASE WHERE (Status <> '  + '\'' + 'Completed' + '\'' +  '  AND CreatedDate > ' + sdttm + ' and CreatedDate < ' + sedttm + ') OR ( Status = '   + '\'' + 'Completed' + '\'' +   ' AND closedDate > ' + sdttm + ' and ClosedDate < ' + sedttm + ')';
            Organization [] orgList = [SELECT Id FROM Organization limit 1];
        
            if(orgList.size() > 0) 
                OrgID = orgList[0].id;
        
    
            System.debug('VERINT BATCH TESTER:  query: ' + query);
        
        
            }catch(System.Unexpectedexception e){
            
               // sendErrorEmail();
                String abortJobID = BC.getJobId();
                System.abortJob(abortJobID);    
            
                return null;
                    
           } 
        
         return Database.getQueryLocator(query);
                  
    }
     
      
   global void execute(Database.BatchableContext BC, List<Case> cases){
    
        System.debug('TESTER: execute(Database.BatchableContext BC, List<Case> cases) ');
    
        numOfOpenCases = 0;
        numOfClosedCases = 0;
        
        for(Case c: cases){
            
            if(c.Status != 'Completed'){
                
                String openString = sourceSystem + ', ' + OrgID + ',';
                
                if(c.CreatedBy.Name !=null)
                        openString = openString + c.CreatedBy.Name + ',';
                else
                        openString = openString  + ',';

                openString = openString + string.valueOf(c.CreatedDate) + ',';
                
                        
                
                if(c.CaseNumber !=null)
                        openString = openString + string.valueOf(c.CaseNumber) + ',';
                else
                        openString = openString  + ','; 
                        
                if(c.Status !=null)
                        openString = openString + string.valueOf(c.Status) + '\n';
                else
                        openString = openString  + ',' + '\n';                                          
                
                openCaseFile = openCaseFile + openString;
                numOfOpenCases++;
                
                
                                
            } else{
                
                String closeString = sourceSystem + ', ' + OrgID + ',';                 
                
                if(c.LastModifiedBy.Name !=null)
                        closeString = closeString + c.LastModifiedBy.Name + ',';
                else
                        closeString = closeString  + ',';

                if(c.ClosedDate !=null)
                        closeString = closeString + string.valueOf(c.CreatedDate) + ',';
                else
                        closeString = closeString  + ',';                   
                
                if(c.CaseNumber !=null)
                        closeString = closeString + string.valueOf(c.CaseNumber) + ',';
                else
                        closeString = closeString  + ',';   
                        
                if(c.Status !=null)
                        closeString = closeString + string.valueOf(c.Status) + '\n';
                else
                        closeString = closeString  + ',' + '\n';                        
                        
                closedCaseFile = closedCaseFile + closeString;
                numOfClosedCases++;                 
            }
            
        }
        //System.debug('TESTER: open cases TEXT: ' + openCaseFile + ' NUM# ' + numOfOpenCases);
        
    }   
   
   
   global void finish(Database.BatchableContext BC){
     
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        Date runDate = Date.TODAY();    
        
        String dataDateStr = 'runDateNull';
        
        if(dt!=null){
            dataDateStr = String.valueOf(dt);
        }
        
        emailAddress = System.Label.MRIS_VERINT_BATCH_EMAIL_ADDR;
                
        // Setup attachment for Open cases
        Messaging.EmailFileAttachment csvOpenCases = new Messaging.EmailFileAttachment();       
        blob openCaseFileBlob = blob.valueOf(openCaseFile);
        string openCaseFileName= 'OpenCases.' + dataDateStr + '.csv';       
        
        csvOpenCases.setFileName(openCaseFileName);
        csvOpenCases.setBody(openCaseFileBlob);     
        
        
        // Setup attachment for Closed cases
        Messaging.EmailFileAttachment csvClosedCases = new Messaging.EmailFileAttachment();     
        blob closedCaseFileBlob = blob.valueOf(closedCaseFile);
        string closedCaseFileName= 'ClosedCases.' + dataDateStr + '.csv';       
        
        csvClosedCases.setFileName(closedCaseFileName);
        csvClosedCases.setBody(closedCaseFileBlob);     
        
                
        // Setup Message to send attachments
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> (emailAddress.split(',',0));
        
        
        
        email.setSubject('MRIS Verint Batch Cases for ' + dataDateStr  +   ' ' + a.Status);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvOpenCases, csvClosedCases});
        
 
        Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});     
    
 
   }
   /**
   private void sendErrorEmail(){
 
         
      emailAddress = System.Label.MRIS_VERINT_BATCH_EMAIL_ADDR;         
         
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new list<string> (emailAddress.split(',',0));
      mail.setToAddresses(toAddresses );
      mail.setSubject('MRIS VERINT BTACH FAILURE FOR TODAY');
      mail.setPlainTextBody('The batch Apex job processed failures.');

      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });          
                
   }
   */
   @isTest
   private static void  testMRISApplicationVerintBatch(){
    
    
     Test.startTest();
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();
        Contact c1 = new Contact();
        c1.Email = 'email@something.com';
        c1.FirstName = 'Test';
        c1.LastName = 'Contact';
        c1.Public_Email__c = 'email@something.com';
        c1.Salutation = 'Mr.';
        c1.Zip__c = '22182';
        c1.City__c = 'Herndon';
        c1.County__c = 'Fairfax';
        insert c1;
        
        
        
        
        
        Account a12 = new Account();
        a12.name = 'ADC1234';
        a12.type = 'Residential';
        a12.Account_Name__c = 'Test Account';
        a12.City__c = 'Herndon';
        a12.Zip__c = '20171';
        a12.company_type__c = 'Broker Office';
        a12.QAS_Mailing_County__c = 'Fairfax';
        a12.County__c = 'Fairfax';
        a12.Street_Type__c = '';
        a12.Billing_Street_Type__c = 'BLFS';
        a12.QAS_Mailing_Street_Type__c ='test';
        insert a12;        
        
          //create broker office
        Account a = new Account();
        a.name = 'ABT1234';
        a.type = 'Residential';
        a.Account_Name__c = 'Test Account';
        a.City__c = 'Herndon';
        a.Zip__c = '20171';
        a.QAS_Mailing_County__c = 'Fairfax';
        a.County__c = 'Fairfax';
        a.Street_Type__c = '';
        a.Billing_Street_Type__c = 'BLFS';
        a.QAS_Mailing_Street_Type__c ='test'; 
        a.parentid = a12.id;     
        insert a;

        Entitlement em = new Entitlement();
        em.Name = 'sunday';
        em.AccountId = a.id;
        insert(em);

        MRIS_Application__c app = new MRIS_Application__c();
        app.Company_Code__c = a.Id;
        insert(app);
        
        Test.setReadOnlyApplicationMode(false);
        Case ca = new Case();
        ca.Origin = 'Email'; 
        ca.Description='from unit test';
        ca.Subject ='testing trigger';
        ca.Status='New';
        ca.ContactId = c1.Id;
        ca.EntitlementId = em.id;
        ca.MRIS_Application__c = app.id;
        

      //  ca.CreatedDate = system.now();
      //Insert the case record that cause the trigger to execute
       insert(ca);
       
       
        Case ca2 = new Case();
        ca2.Origin = 'Email'; 
        ca2.Description='from unit test';
        ca2.Subject ='testing trigger';
        ca2.Status='New';
        ca2.ContactId = c1.Id;
        ca2.EntitlementId = em.id;
        ca2.MRIS_Application__c = app.id;    
        insert(ca2);
        
        ca2.Status = 'Completed';
        
        upsert(ca2);
       
        Case ca3 = new Case();
        ca3.Origin = 'Email'; 
        ca3.Description='from unit test';
        ca3.Subject ='testing trigger';
        //ca3.Status='New';
        ca3.ContactId = c1.Id;
        ca3.EntitlementId = em.id;
        //ca2.MRIS_Application__c = app.id;   
            
        insert(ca3);
        
        Case ca4 = new Case();
        ca4.Origin = 'Email'; 
        ca4.Description='from unit test';
        ca4.Subject ='testing trigger';
        //ca3.Status='Completed';
        ca4.ContactId = c1.Id;
        ca4.EntitlementId = em.id;
        //ca2.MRIS_Application__c = app.id;   
            
        insert(ca4);        
        
        MRISApplicationVerintBatch batchRun = new MRISApplicationVerintBatch();
        ID batchprocessid = Database.executeBatch(batchRun);    
                    
        AsyncApexJob a1 = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchprocessid];
        System.debug('\n\nFinal results are: '+a1);
        System.AssertEquals('Queued', a1.status);
        System.AssertEquals(0, a1.NumberOfErrors);
            
        Test.stopTest();        
   }
    
   
   

}