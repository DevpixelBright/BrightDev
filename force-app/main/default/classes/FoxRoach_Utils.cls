/***********************************************************************************************
*       Class Name      : FoxRoach_Utils
*       Date            : 10/13/2021 (MM/DD/YYYY) 
*       Author          : Bala Krishna
*       Purpose         : This Apex Class is used to write all reusable methods related to FoxRoach
*       Change History  :
*       Date                      Programmer                     Reason
*       --------------------      -------------------    -------------------------
*       10/13/2021                 Bala Krishna                  Initial Version  
**************************************************************************************************/
public class FoxRoach_Utils 
{
    public static Account copyAccountData(FoxRoach_Modal.Account foxRoachAccount, Account sfAccount)
    {
        sfAccount.Account_Name__c = foxRoachAccount.officeName;
        
        return sfAccount;
    }
	public static Contact copyContactData(FoxRoach_Modal.Account foxRoachAccount, Contact sfContact)
    {
        string mockEmailPhone = 'xxxxxx';
        
        sfContact.Nickname__c 		= foxRoachAccount.firstName;
        sfContact.PreferredFirstName__c = foxRoachAccount.firstName;
        sfContact.FirstName 		= foxRoachAccount.firstName;
        sfContact.PreferredLastName__c = foxRoachAccount.lastName;
        sfContact.LastName 			= foxRoachAccount.lastName;
        sfContact.Email 			= foxRoachAccount.email	+ mockEmailPhone;
        sfContact.Public_Email__c 	= foxRoachAccount.email	+ mockEmailPhone;
        sfContact.City__c 			= foxRoachAccount.address.city;
        sfContact.State__c 			= foxRoachAccount.address.stateOrProvince;
        sfContact.Zip__c 			= foxRoachAccount.address.postalCode;
        sfContact.County__c 		= foxRoachAccount.address.country;
        if(foxRoachAccount.phoneNumbers != null && foxRoachAccount.phoneNumbers.size()>0)
        {
            sfContact.Phone 			= foxRoachAccount.phoneNumbers[0] + mockEmailPhone;
            sfContact.MobilePhone 		= foxRoachAccount.phoneNumbers[0] + mockEmailPhone;
        }
        
        return sfContact;
    }
    
    public static Subscriptions__c copySubscriptionData(FoxRoach_Modal.Account foxRoachAccount, Subscriptions__c sfSubscription)
    {
        string mockEmailPhone = 'xxxxxx'; 
        
        sfSubscription.FoxRoachID__c 	= String.valueof(foxRoachAccount.id);
        sfSubscription.Nickname__c 		= foxRoachAccount.firstName;
        sfSubscription.Private_Email__c = foxRoachAccount.email + mockEmailPhone;
        
        return sfSubscription;
    }
    //-----
    public static Subscriptions__c copySubscriptionData(FoxRoach_Account__c foxRoachAccount, Subscriptions__c sfSubscription)
    {
        string mockEmailPhone = 'xxxxxx'; 
        
        sfSubscription.FoxRoachID__c 	= foxRoachAccount.FoxRoachID__c;
        sfSubscription.Nickname__c 		= foxRoachAccount.FirstName__c;
        sfSubscription.Private_Email__c = foxRoachAccount.Email__c;
        
        return sfSubscription;
    }
    public static Contact copyContactData(FoxRoach_Account__c foxRoachAccount, Contact sfContact)
    {
        string mockEmailPhone = 'xxxxxx'; 
        
        sfContact.Nickname__c 	= foxRoachAccount.FirstName__c;
        sfContact.PreferredFirstName__c = foxRoachAccount.FirstName__c;
        sfContact.FirstName 	= foxRoachAccount.FirstName__c;
        
        sfContact.PreferredLastName__c = foxRoachAccount.FirstName__c;
        sfContact.LastName 	= foxRoachAccount.FirstName__c;
        
        sfContact.Email = foxRoachAccount.Email__c;
        sfContact.Public_Email__c 	= foxRoachAccount.Email__c;
        
        sfContact.City__c = foxRoachAccount.City__c;
        sfContact.State__c 	= foxRoachAccount.State__c;
        sfContact.Zip__c = foxRoachAccount.Zip__c;
        sfContact.Country__c 	= foxRoachAccount.Country__c;
        
        sfContact.Phone = foxRoachAccount.PhoneNumber__c;
        sfContact.MobilePhone 	= foxRoachAccount.PhoneNumber__c;
        
        return sfContact;
    }
    
    public static FoxRoach_Sync_Log__c updateLogAddAttachment(FoxRoach_Sync_Log__c fLog)
    {
        fLog.Name = 'FoxRoachLog-'+String.valueof([SELECT count() FROM FoxRoach_Sync_Log__c]+1);
        
        integer contactSyncCount =0;
        integer subSyncCount =0;
        integer subFailCount =0;
        integer subNewCount =0;
        integer agentCount =0;
        integer offCount =0;
        integer offSyncCount =0;
        integer offFailCount =0;
        integer offInactiveCount =0;
        integer offNotInSFCount =0;
        
        string officeBodyStr = 'FoxRoach Office Id,Office Name,Sync Type,Sync Status,Reason\n';
        for(FoxRoach_Office__c fOffice : [SELECT Name, Office_Id__c, Sync_Type__c, Sync_Status__c, Reason__c FROM FoxRoach_Office__c ORDER BY Sync_Type__c]){
            offCount++;
            if(fOffice.Sync_Status__c == 'Success' && fOffice.Sync_Type__c == 'Active'){
                offSyncCount++;
            }else if(fOffice.Sync_Status__c == 'Fail'){
                offFailCount++;
            }else if(fOffice.Sync_Type__c == 'Inactive'){
                offInactiveCount++;
            }else{
                offNotInSFCount++;
            }
            string offsyncStatus = string.isBlank(fOffice.Sync_Status__c) ? '' : fOffice.Sync_Status__c;
            string offsyncReason = string.isBlank(fOffice.Reason__c) ? '' : fOffice.Reason__c;
            officeBodyStr += fOffice.Office_Id__c+','+fOffice.Name+','+fOffice.Sync_Type__c+','+offsyncStatus+','+offsyncReason+'\n';
        }
        fLog.Office_Count__c = offCount;//[SELECT count() FROM FoxRoach_Office__c];
        fLog.Office_Sync_Count__c = offSyncCount;//[SELECT count() FROM FoxRoach_Office__c WHERE Sync_Type__c='Active' AND Sync_Status__c LIKE '%Success%'];
        fLog.Office_Failed_Count__c = offFailCount;
        fLog.Office_Inactive_Count__c = offInactiveCount;
        fLog.Office_Not_In_SF_Count__c = offNotInSFCount;
        
        string subBodyStr = 'FoxRoach Id,Office Name,Subscription Sync Type,Subscription Sync Status,Contact Sync Status,Reason\n';
        for(FoxRoach_Account__c fra : [SELECT FoxRoachID__c,Office_Name__c,Subscription_Sync_Type__c, Subscription_Sync_Status__c,Contact_Sync_Status__c,Reason__c FROM FoxRoach_Account__c]){
            agentCount++;
            if(fra.Subscription_Sync_Type__c == 'Sync Create' && 
               string.isNotBlank(fra.Subscription_Sync_Status__c) && 
               fra.Subscription_Sync_Status__c.contains('Success')){
                subNewCount++;
            }
            if(string.isNotBlank(fra.Contact_Sync_Status__c) && fra.Contact_Sync_Status__c.contains('Success')){
                contactSyncCount++;
            }
            if(string.isNotBlank(fra.Subscription_Sync_Status__c) && fra.Subscription_Sync_Status__c.contains('Success')){
                subSyncCount++;
            }else if(string.isNotBlank(fra.Subscription_Sync_Status__c) && fra.Subscription_Sync_Status__c.contains('Fail')){
                subFailCount++;
            }
            string subSyncType = string.isBlank(fra.Subscription_Sync_Type__c) ? '' : fra.Subscription_Sync_Type__c;
            string subSyncStatus = string.isBlank(fra.Subscription_Sync_Status__c) ? '' : fra.Subscription_Sync_Status__c;
            string consyncStatus = string.isBlank(fra.Contact_Sync_Status__c) ? '' : fra.Contact_Sync_Status__c;
            string subsyncReason = string.isBlank(fra.Reason__c) ? '' : fra.Reason__c;
            
            subBodyStr += fra.FoxRoachID__c+','+fra.Office_Name__c+','+subSyncType+','+subSyncStatus+','+consyncStatus+','+subsyncReason+'\n';
        }
        fLog.Account_Count__c = agentCount;
        fLog.Contact_Sync_Count__c = contactSyncCount;
        fLog.Subscription_Sync_Count__c = subSyncCount;
        fLog.Subscriptions_Failed__c = subFailCount;
        fLog.Subscriptions_New__c = subNewCount;
        
        upsert fLog;
        
        Blob officeBodyBlob=Blob.valueOf(officeBodyStr); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title=fLog.Name+'-Offices', 
            PathOnClient =fLog.Name+'-Offices.csv',
            VersionData = officeBodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_1_1 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink1 = new ContentDocumentLink();
        contentlink1.LinkedEntityId = fLog.id;
        contentlink1.contentdocumentid = contentVersion_1_1.contentdocumentid;
        contentlink1.ShareType = 'V';
        insert contentlink1;
        
        Blob subBodyBlob=Blob.valueOf(subBodyStr); 
        ContentVersion contentVersion_2 = new ContentVersion(
            Title=fLog.Name+'-Agents', 
            PathOnClient =fLog.Name+'-Agents.csv',
            VersionData = subBodyBlob, 
            origin = 'H'
        );
        insert contentVersion_2;
        
        ContentVersion contentVersion_2_1 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_2.Id LIMIT 1];
        
        ContentDocumentLink contentlink2 = new ContentDocumentLink();
        contentlink2.LinkedEntityId = fLog.id;
        contentlink2.contentdocumentid = contentVersion_2_1.contentdocumentid;
        contentlink2.ShareType = 'V';
        insert contentlink2;
        
        return fLog;
    }
}