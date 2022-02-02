global class ComplianceScheduledEmail implements Schedulable {

   global void execute(SchedulableContext SC) {
      //subsEmail();
   }
 /*  
   
      //Determines subscriptions meeting fine notification (date) requirements,
     // then call email process
    
   global static void subsEmail(


) {
      String dts = '';

      
         // check for mail day values
       
      Compliance_Appeal_Config__c ca = 
         [select id,mail_days1__c,mail_days2__c,mail_days3__c 
          from Compliance_Appeal_Config__c limit 1];

      if (ca.mail_days1__c != 0) dts +=
         String.valueOf(Date.today().addDays(-(Integer)ca.mail_days1__c)).substring(0,10) + ',';
      if (ca.mail_days2__c != 0) dts +=
         String.valueOf(Date.today().addDays(-(Integer)ca.mail_days2__c)).substring(0,10) + ',';
      if (ca.mail_days3__c != 0) dts +=
         String.valueOf(Date.today().addDays(-(Integer)ca.mail_days3__c)).substring(0,10) + ',';

      
        //  no days configured -- exit
       
      if (dts.length() == 0) return;
      //System.debug('dt!!!!!!!!!!!!: ' + dts);

      
        //  get all subs requiring email
       
      String qry = 'select Subscription__c ' +
         'from Compliance_Fine__c ' +
         'where status__c = \'Pending\' ' +
         'and date_of_fine__c in (' + dts.substring(0,dts.length()-1) + ') ' +
         'group by Subscription__c,  Subscription__r.name, Subscription__r.Private_Email__c';
 
      List<AggregateResult> arl = Database.query(qry);
      set<Id> subIdSet = new set<Id>();

      for(AggregateResult a: arl) {
//         System.debug('sub!!!!!!!!!!!!: ' + a.get('Subscription__c'));
         subIdSet.add((Id)a.get('Subscription__c'));
      }
      mailSubids(subIdSet);
   }

   
    //  email compliance message to each subscription in given list
    
   global static void mailSubids(set<Id> subIdSet) {
      
        //  check for mail day values
       
      Compliance_Appeal_Config__c ca = 
         [select id, Appeal_Timer__c from Compliance_Appeal_Config__c limit 1];

      
       //  select all the fines by subscription
       
      List<Compliance_Fine__c> cfl = 
         [ select id, name, MLS_Number__c, Date_of_Fine__c, Fine_Amount__c, Violation_Customer__c,
           Subscription__r.name, Subscription__r.Private_Email__c, Subscription__r.contact__c, 
           Last_Date_to_Appeal__c, Agent_Name__r.name, Subscription__c, status__c,
           Subscription__r.contact__r.email
           from Compliance_Fine__c
           where (Subscription__c in :subIdSet) 
           and status__c in ('Pending','Under Appeal')
           order by Subscription__r.name, Date_of_Fine__c, MLS_Number__c ];

      List<Messaging.SingleEmailMessage> mails = 
         new List<Messaging.SingleEmailMessage>();
      Messaging.SingleEmailMessage m1 = null;
      String fEmail = 'fineappeals@mris.net';
      String body = '';
      String cfLst = '';
      
      
       //   Get email template
       
      EmailTemplate eTmp;
      try {
         eTmp = [ select id, Subject, HtmlValue, Body 
                  from EmailTemplate where name = 'Compliance_Notification'];          
      } catch (Exception e) {
         System.debug('Email Template missing!!!');
      }

     
      //  contstruct emails
       
      String s1 = '';
      for(Compliance_Fine__c c1: cfl) {
         if(!s1.equals(c1.Subscription__r.name)) {
            s1 = c1.Subscription__r.name;
            endMail(mails,m1,body.replace('CF_LST',cfLst));
            
            
             // start a new email
             
            m1 = new Messaging.SingleEmailMessage();
            m1.setTargetObjectId(c1.Subscription__r.contact__c);
            m1.setReplyTo(fEmail);
            m1.setSaveAsActivity(true);
            m1.setWhatId(c1.Subscription__c);
            m1.setSubject(eTmp.Subject);
            m1.setHtmlBody(body);

            // D-02274 - SF automatically sends to contact email, so only add sub email if different
            if(!c1.Subscription__r.Private_Email__c.equals(c1.Subscription__r.contact__r.email)) {
               m1.setToAddresses(new List<String> {c1.Subscription__r.Private_Email__c});
            }

            for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
               if(owa.Address.contains(fEmail)) m1.setOrgWideEmailAddressId(owa.id);
            }

            body = eTmp.HtmlValue;
            body = body.replace('MRIS_ID',c1.Subscription__r.name);
            body = body.replace('CONTACT_NM',c1.Agent_Name__r.name);
            body = body.replace('B_DAYS',ca.Appeal_Timer__c.toPlainString());
            body = body.replace('SID_TAG',c1.Subscription__c);
            cfLst = '';
         }
         cfLst += '<tr><td>' + 
                  c1.Date_of_Fine__c.format() + ' </td><td>' +
                  c1.name + ' </td><td>' + 
                  c1.Fine_Amount__c + ' </td><td>' + 
                  c1.Violation_Customer__c + ' </td><td>' +
                  c1.MLS_Number__c +  '</td><td>' + 
                  c1.Last_Date_to_Appeal__c.format() + '</td><td>' 
                  + ((c1.Status__c.equals('Pending')) ? 'No' : 'Yes') + ' </td></tr>'
                  ;
      }
      body = body.replace('CF_LST',cfLst);
//m1.setToAddresses(new List<String> {'melvin.kean@mris.net'});
      endMail(mails,m1,body);
      Messaging.sendEmail(mails);
   }

   // check for end of mail and add to list
   global static void endMail(List<Messaging.SingleEmailMessage> mails,
      Messaging.SingleEmailMessage m1, String body) {
      if (m1 != null) {
         m1.setHtmlBody(body);
         mails.add(m1);
      }      
   }
   
   global static void mailTest2() {
      set<Id> subIdSet = new set<Id>();
      subIdSet.add('a06Z000000CxtmI');
      mailSubids(subIdSet);
   }
   global static void mailTest() {
      List<Messaging.SingleEmailMessage> mails = 
         new List<Messaging.SingleEmailMessage>();
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      
      List<String> sendTo = new List<String>();
      sendTo.add('melvin.kean@mris.net');
      mail.setToAddresses(sendTo);
      mail.setReplyTo('foo@bar.com');
      mail.setSubject('Test subject');
      String body = 'This is a test message.';
      mail.setHtmlBody(body);
      mails.add(mail);
      
      Messaging.sendEmail(mails);
   }*/
}