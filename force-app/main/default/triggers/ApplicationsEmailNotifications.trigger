trigger ApplicationsEmailNotifications on MRIS_Application__c (before insert, after insert, after update) {
    List<MRIS_Application__c> newApplications = new List<MRIS_Application__c>();
    List<MRIS_Application__c> reminderApplications = new List<MRIS_Application__c>();
    List<MRIS_Application__c> expiryApplications = new List<MRIS_Application__c>();
    List<MRIS_Application__c> completedApplications = new List<MRIS_Application__c>();
    List<MRIS_Application__c> approvedApplications = new List<MRIS_Application__c>();
    List<MRIS_Application__c> approvedBrokerApplications = new List<MRIS_Application__c>();
    MRIS_Application__c oldApplication = new MRIS_Application__c();
    
    for(MRIS_Application__c application : trigger.new){
        
        if(application.Application_Type__c == 'New Agent' || application.Application_Type__c == 'Reinstatement' || application.Application_Type__c == 'Agent Transfer' || application.Application_Type__c == 'IDX and VOW Agent Request'){
            if(trigger.isInsert){
                
                if(application.Status__c == 'New'){
                    system.debug('**********************New Application'+application);
                    newApplications.add(application);  
                }
            }
            
            else{
                //MRIS_Application__c oldApplication = new MRIS_Application__c();
                oldApplication = trigger.oldMap.get(application.Id);
                if(application.Status__c == 'New' && (application.Reminder_Email__c && !oldApplication.Reminder_Email__c))
                    reminderApplications.add(application);
                else if(application.Status__c == 'Expired' && (oldApplication.Status__c != 'Approved' && oldApplication.Status__c != 'Reject' && application.Application_Type__c != 'Agent Transfer')) 
                    expiryApplications.add(application); 
                else {
                    if(application.Application_Type__c == 'Agent Transfer'){
                        if(application.Status__c == 'Completed' && oldApplication.Status__c == 'Approved' )
                            completedApplications.add(application);
                        else if(application.Status__c == 'Approved' && oldApplication.Status__c != 'Approved')
                            approvedApplications.add(application);
                    }
                    
                    if(application.Application_Type__c == 'Broker Authorization Request'){
                        if(application.Status__c == 'Approved' && oldApplication.Status__c != 'Approved')
                            approvedApplications.add(application);
                    }
                }   
                
            }
            
            
            
        }
    }
    system.debug('*****************New Application size ' +newApplications.size());
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        if(newApplications.size() > 0){
            EmailNotificationsbyPreferences apps = new EmailNotificationsbyPreferences();
            apps.sendNotificationEmail(newApplications);
        }
        if(reminderApplications.size() > 0){
            system.debug('***************** Reminder loop ');
            EmailNotificationsbyPreferences apps = new EmailNotificationsbyPreferences();
            apps.sendReminderEmail(reminderApplications);
        }
        if(expiryApplications.size() > 0){
            EmailNotificationsbyPreferences apps = new EmailNotificationsbyPreferences();
            apps.sendExpiryEmail(expiryApplications);
        }
        if(completedApplications.size() > 0){
            EmailNotificationsbyPreferences apps = new EmailNotificationsbyPreferences();
            apps.sendCompletedEmail(completedApplications);
        }
        if(approvedApplications.size() > 0){
            EmailNotificationsbyPreferences apps = new EmailNotificationsbyPreferences();
            apps.sendApprovedEmail(approvedApplications);
        }
    }
    if(Trigger.isBefore && Trigger.isInsert){
        PopulateBrokerdetailsHandler app = new PopulateBrokerdetailsHandler();
        app.findBOREmailId(Trigger.New);
    }
}