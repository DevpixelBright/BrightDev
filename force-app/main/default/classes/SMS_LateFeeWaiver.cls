/* 
 * Created By Mounika Nellutla
 * This class is to deal all late fee waiver stories.
*/
public class SMS_LateFeeWaiver {
    
    private Static SMS_ZuoraUtil zUtilInstance;
    private Static Zuora.zApi.LoginResult zLoginResult;
    
    //Method to identify the subscriptions which all updated the "Late Fee Waived" field
    public static void checkSubscriptionLateFee(List<Subscriptions__c> subscriptions, Map<Id, Subscriptions__c> oldSubscriptionsMap) {
        for(Subscriptions__c s : subscriptions) {
            if(s.Date_Waived__c != null && s.Date_Waived__c != oldSubscriptionsMap.get(s.Id).Date_Waived__c) {
                waiveOffSubscriptionLateFee(s.Name);
            }
        }
    }
    
    //Initial method to deal with the logic
    @future(callout = true)
    public static void waiveOffSubscriptionLateFee(String subId) {
        try {
            loginToZuora();
            String zAccountId = getZuoraAccountId(subId);
            Map<String, String> zInvoiceIds = getZuoraInvoices(zAccountId);
            System.debug('***zInvoiceIds:' + zInvoiceIds);
            if(zInvoiceIds.Size() > 0) {
            	Zuora.zObject lateFeeInvoiceItem = getLateFeeInvoiceItems(zInvoiceIds.keySet());
                if(lateFeeInvoiceItem != null) {
                    Boolean isAdjusted = getPreviousAdjustment(lateFeeInvoiceItem);
                    if(!isAdjusted) {
                    	adjustLateFeeInvoice(lateFeeInvoiceItem, zInvoiceIds);
                        System.debug('@@@@@@ Late fee adjsuted for the subscription');
                    }
                    else {
                        System.debug('@@@@@@ Late fee already adjusted for the invoice item');
                    	createNoOutstandingCase(subId);
                    }
                }
                else {
                   System.debug('@@@@@@ No outstanding invoice related to late fee');
                   createNoOutstandingCase(subId);
                }
            }
            else { 
                System.debug('@@@@@@ No outstanding invoices for the subscription');
            	createNoOutstandingCase(subId); 
            }
            
            SMS_ZuoraHistory.createSuccess('SMS_LateFeeWaiver',subId);
        }
        catch(Exception e) {
            //Exception case handler
            System.debug('@@@Exception:' + e.getMessage());
            SMS_ZuoraHistory.createError(e, 'SMS_LateFeeWaiver', subId);
        }
    }
    
    //Method to login into zuora
    private static void loginToZuora() {
        zUtilInstance = new SMS_ZuoraUtil();
        zLoginResult = zUtilInstance.zlogin();        
    }
    
    //Method to get related zuora accountId of the subscription.
    private static String getZuoraAccountId(String subId) {
        String zAccountsQuery = 'SELECT Id, ParentId FROM Account WHERE SubscriptionID__c = \'' + subId + '\'';
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(zAccountsQuery);

        if (zAccounts.Size() == 1)
            return (String)zAccounts[0].getValue('Id');
		else
            throw new CustomException('No related account found for subscription: ' + subId);    
    }
    
    //Method to get outstanding invoices for the zuora account related to subscription
    private static Map<String, String> getZuoraInvoices(String zAccountId) {
        Map<String, String> zInvoiceIds = new Map<String, String>();
        String zInvoiceQuery = 'SELECT Id,AccountId,Status,Balance,Amount,Status,CreatedById,InvoiceNumber,InvoiceDate,DueDate,PaymentAmount,TargetDate FROM Invoice WHERE Status=\'Posted\' AND Balance > 0 AND AccountId = \'' + zAccountId + '\'';
        List<Zuora.zObject> zInvoices = zUtilInstance.zquery(zInvoiceQuery);
        if(zInvoices.size() > 0) {
            for(Zuora.zObject zInvoice : zInvoices) {
                zInvoiceIds.put((String)zInvoice.getValue('Id'), (String)zInvoice.getValue('InvoiceNumber'));
            }
        }
        
        return zInvoiceIds;
    }

    //Method to get any late fee invoice items outstanding
    private static Zuora.zObject getLateFeeInvoiceItems(Set<String> zInvoiceIds) {
        String invoiceItemQuery = 'SELECT Id,ChargeAmount,ChargeDate,InvoiceId,ProductName,ProductId FROM InvoiceItem WHERE ';
        Boolean isNotFirst = false;
        Zuora.zObject lateFeeInvoiceItem = null;
        
        for(String zInvoice : zInvoiceIds) { 
            if (isNotFirst)
                invoiceItemQuery += ' OR ';            
            
            invoiceItemQuery += 'InvoiceId = \'' + zInvoice + '\'';
            isNotFirst = true;
        }       
        
        
        SMS_LateFees_Status__c setting = SMS_LateFees_Status__c.getValues('Late Fees');
        String zLateFeeProductName = SMS_LateFees_Status__c.getall().values()[0].Name;
        
        
        List<Zuora.zObject> zInvoiceItems = zUtilInstance.zquery(invoiceItemQuery);
        for(Zuora.zObject zInvoiceItem : zInvoiceItems) {
            System.debug('@@@zInvoiceItem:' + zInvoiceItem);
            //Product Id has to update from settings
            if((String)zInvoiceItem.getValue('ProductName') == zLateFeeProductName && Double.valueOf(zInvoiceItem.getValue('ChargeAmount')) > 0) {
            	lateFeeInvoiceItem = zInvoiceItem;
                break;
            }
        }

		return lateFeeInvoiceItem;        
    }
    
    //Method to check any existing adjustment happend on the invoice or not
    private static boolean getPreviousAdjustment(Zuora.zObject lateFeeInvoiceItem) {
        String zInvoiceAdjustmentQuery = 'SELECT Id,InvoiceId,SourceId FROM InvoiceItemAdjustment WHERE SourceId = \'' + (String)lateFeeInvoiceItem.getValue('Id') + '\'';
        List<Zuora.zObject> zInvoiceAdjsuments = zUtilInstance.zquery(zInvoiceAdjustmentQuery);
        if(zInvoiceAdjsuments.size() > 0) 
            return true;
        
        return false;        
    }    
    
    //Method to do invoice adjustment on late fee invoice
    public static void adjustLateFeeInvoice(Zuora.zObject lateFeeInvoiceItem, Map<String, String> zInvoiceIds) {
        List<Zuora.zObject> zInvoiceAdjustments = new List<Zuora.zObject>();
        String todayDate = DateTime.now().format('yyyy-MM-dd', 'PST');
        Zuora.zObject adjustment = new Zuora.zObject('InvoiceItemAdjustment');
        adjustment.setValue('AdjustmentDate', todayDate);
        adjustment.setValue('Amount', Double.valueOf(lateFeeInvoiceItem.getValue('ChargeAmount')));
        adjustment.setValue('InvoiceNumber', zInvoiceIds.get((String)lateFeeInvoiceItem.getValue('InvoiceId')));
        adjustment.setValue('Comment', 'Late Fee Waiver');
        adjustment.setValue('SourceId', (String)lateFeeInvoiceItem.getValue('Id'));
        adjustment.setValue('SourceType', 'InvoiceDetail');
        adjustment.setValue('Type', 'Credit');
        zInvoiceAdjustments.add(adjustment);
        List<Zuora.zApi.SaveResult> zSaveResultList = zUtilInstance.zcreate(zInvoiceAdjustments); 
        for (Zuora.zApi.SaveResult result : zSaveResultList) {
           System.debug('@@@result:' + result);
            if (!result.Success)
                throw new CustomException('Failed to create invoice item adjustment.');
        }        
    }
    
    //Method to create a case that the late fee invoice has been paid and is no longer an open balance.
    private static void createNoOutstandingCase(String subId) {
        List<group> queueIds = [SELECT Id FROM  group WHERE  DeveloperName = 'Billing'];
        List<Subscriptions__c> subscriptions = [SELECT Id, Name FROM Subscriptions__c WHERE Name =: subId];
        Case c = new Case();
        c.MLS__c = 'BRIGHT';
        c.OwnerId = queueIds[0].Id;
        c.Subscription_ID__c = subscriptions[0].Id;
        c.Origin = 'Self Service';
        c.Subject = System.Label.SMS_LateFee_Waiver_Subject; //'Request Late fee Waiver';
        c.Product__c = 'Billing';
        c.Category__c = 'Credit/Waiver';
        insert c;
    }

    public Class CustomException extends Exception {}  
}