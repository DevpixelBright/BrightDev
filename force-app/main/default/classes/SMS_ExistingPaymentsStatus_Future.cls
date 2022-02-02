public class SMS_ExistingPaymentsStatus_Future {
    
    @future
    public static void updateStatus(Set<String> processedPayments, Set<String> failedPayments) {
        try{
            System.debug(processedPayments + ',' + failedPayments);
            
            List<SMS_ExternalPayments__c> externalPayments = new List<SMS_ExternalPayments__c>();
            if(processedPayments.Size() > 0) {
                for(String paymentId : processedPayments) {
                    SMS_ExternalPayments__c obj = new SMS_ExternalPayments__c();
                    obj.Status__c = 'Processed';
                    obj.Id = paymentId;                 
                    externalPayments.add(obj);
                }
            }
            update externalPayments;
        }
        catch(Exception e) {
        
        }
    }
    
}