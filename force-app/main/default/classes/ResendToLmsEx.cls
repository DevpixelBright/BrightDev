public with sharing class ResendToLmsEx {

    private final ApexPages.StandardController ctl;
    private Subscriptions__c sub;
    private List<Related_Association__c> assoc;
    private List<Relationship__c> relation;

    private static String subInactiveMsg = 'This subscription cannot be sent to MRIS-U because it is not active. If you activate this subscription, it will automatically sync with MRIS-U.';
    private static String syncProblemMsg = 'A problem occurred while performing the sync. Please escalate to CRM Support including the Status message below.';

    public Boolean ShowResendButton { get; set; }
    public Boolean ShowStatusBlock { get; set; }
    public String StatusMessage { get; set; }

    public ResendToLmsEx(ApexPages.StandardController controller) {
        ctl = controller;
        sub = (Subscriptions__c)ctl.getRecord();

        Subscriptions__c s = [select Id, Name, Status__c, Resend_to_LMS_Flag__c from Subscriptions__c where Id = :sub.Id];
        sub = s;

        ShowResendButton = true;
        ShowStatusBlock = false;
        
        if(sub != null) {
            checkStatus();
        } else {
            ShowResendButton = false;
            return;
        }
        
        assoc = [select Id, Status__c, Primary__c, Resend_to_LMS_Flag__c from Related_Association__c where Primary__c = true and Subscription__c = :sub.Id];
        relation = [select Id, Status__c, Relationship_Type__c, Resend_to_LMS_Flag__c from Relationship__c where Relationship_Type__c in ('Broker Of Record','Office Manager','Authorized Signer') and Subscription__c = :sub.Id]; 
    }
    
    private void checkStatus() {
        if(sub.Status__c != 'Active') {
            ShowResendButton = false;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.WARNING, 'Subscription Status Problem', subInactiveMsg);
            ApexPages.addMessage(msg);
        }
    }
    
    public void ResendSub() {
        ShowStatusBlock = true;
    
        if(sub.Resend_To_LMS_Flag__c == null) {
            sub.Resend_To_LMS_Flag__c = 1;
        } else { 
            sub.Resend_To_LMS_Flag__c += 1;
        }

        for(Related_Association__c a : assoc) {
            if(a.Resend_To_LMS_Flag__c == null) {
                a.Resend_To_LMS_Flag__c = 1;
            } else { 
                a.Resend_To_LMS_Flag__c += 1;
            }
        }
        
        for(Relationship__c r : relation) {
            if(r.Resend_To_LMS_Flag__c == null) {
                r.Resend_To_LMS_Flag__c = 1;
            } else { 
                r.Resend_To_LMS_Flag__c += 1;
            }
        }
        
        try {
            update sub;
            update assoc;
            update relation;
        } catch(Exception ex) {
            StatusMessage = ex.getTypeName() + '<br/>' + ex.getMessage() + '<br/>' + ex.getStackTraceString();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Sync Problem', syncProblemMsg));
            return;
        }
        
        StatusMessage = 'Success';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Sync completed', 'The subscriber was successfully sent to MRIS-U.'));
    }
}