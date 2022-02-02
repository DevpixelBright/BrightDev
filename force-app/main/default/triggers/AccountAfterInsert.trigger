trigger AccountAfterInsert on Account (after insert,after update) {

    /* Exit trigger if records are inserted and/or updated by dataloader profile. */
    if (Utils.BypassValidationrules())
        return;

    /* Exit trigger if records are inserted and/or updated are not of Businness account record type. */
    if (Utils.ByPassPersonAccounts(trigger.new)) 
        return;
        
    /* Exit trigger if records are inserted and/or updated are DataManagement Accounts */
    //if(Utils.ByPassDataManagementAccounts(trigger.new)) 
    //    return;        

    if (!executionFlowUtility.accountUpdate) 
        return;
        
    executionFlowUtility.accountUpdate = false;

    /* QAS required code */
    //QAS_NA.CAAddressCorrection.ExecuteCAAsyncForTriggerConfigurationsOnly(trigger.new);
    
    if(trigger.isUpdate)
    {
        system.debug('---->after update');
        LT_ValidateListingRequests.validateOffices(trigger.oldMap, trigger.newMap);
    	UpdateBrokerageAttributes.updateRelatedAccounts(trigger.oldMap, trigger.newMap);
    }

    /* Call the future method with the list of Account objects */
    Map<Id,String> newJsonAccountString = new Map<Id,String>();
    Map<Id,String> oldJsonAccountString = new Map<Id,String>();

    for (Account a: Trigger.new) { 
        
        //below code is commented for SAL-2406 GAIL's comment.
        /*if (newJsonAccountString.size() == 5 && oldJsonAccountString.size() == 0) { 
            AccountProcessingUtility.sendAccountsToQueueProcessor('INSERT', newJsonAccountString,null ); 
            newJsonAccountString = new Map<Id,String>();
        }   

        if (newJsonAccountString.size() == 5 && oldJsonAccountString.size() == 5) {
            AccountProcessingUtility.sendAccountsToQueueProcessor('UPDATE', newJsonAccountString,oldJsonAccountString );     
            newJsonAccountString = new Map<Id,String>();
            oldJsonAccountString = new Map<Id,String>();
        }*/
        
        
        
        if(Trigger.isUpdate) {
            System.debug('*** a.Trigger.oldMap.get(a.id).MDS_Status__c): ' + Trigger.oldMap.get(a.id).MDS_Status__c);
            System.debug('*** a.Trigger.oldMap.get(a.id).Status__c): ' + Trigger.oldMap.get(a.id).Status__c);
        }
        
        if((a.Primary_Service_Jurisdiction__c != 'MRIS' && a.Secondary_Service_Jurisdiction__c != 'MRIS') &&
           (String.isNotBlank(a.Primary_Service_Jurisdiction__c) && a.Type != 'Association')
          ){
            system.debug('Bypass if not MRIS: ' + a.Id);
            continue;    
        }       

        /* If it is insert mode and the account status is inactive/active */    
        if (Trigger.isInsert && ('Inactive'.equals(a.Status__c) || 'Active'.equals(a.Status__c))) {
            /* This office is not yet created in cornerstone.  So create a new office */
            newJsonAccountString.put(a.id,JSON.serialize(a));
        } 
        else if (Trigger.isUpdate 
                && (a.MDS_Status__c == null || a.MDS_Status__c.equals(Trigger.oldMap.get(a.id).MDS_Status__c)) 
                && ('In Progress'.equals(Trigger.oldMap.get(a.id).Status__c) || 'Incomplete'.equals(Trigger.oldMap.get(a.id).Status__c)) 
                && ('Inactive'.equals(a.Status__c) || 'Active'.equals(a.Status__c)) 
                && Utils.isNull(a.OfficeKey__c)) {

            /* This office is not yet created in cornerstone.  So create a new one */
            newJsonAccountString.put(a.id,JSON.serialize(a));       
            
        } 
        else if (Trigger.isUpdate 
                && (a.MDS_Status__c == null || a.MDS_Status__c.equals(Trigger.oldMap.get(a.id).MDS_Status__c)) 
                && Utils.isNotNull(a.OfficeKey__c) 
                && ((Trigger.oldMap.get(a.id).Account_Name__c != a.Account_Name__c)
                ||(Trigger.oldMap.get(a.id).Addl_Display_Name__c != a.Addl_Display_Name__c)
                ||(Trigger.oldMap.get(a.id).Billing_Addl_Display_Name__c != a.Billing_Addl_Display_Name__c)
                ||(Trigger.oldMap.get(a.id).Billing_Box__c != a.Billing_Box__c)
                ||(Trigger.oldMap.get(a.id).Billing_City__c != a.Billing_City__c)
                ||(Trigger.oldMap.get(a.id).Billing_Country__c != a.Billing_Country__c)
                ||(Trigger.oldMap.get(a.id).Billing_County__c != a.Billing_County__c)
                ||(Trigger.oldMap.get(a.id).Billing_State__c  != a.Billing_State__c)
                ||(Trigger.oldMap.get(a.id).Billing_Street_Direction__c != a.Billing_Street_Direction__c)
                ||(Trigger.oldMap.get(a.id).Billing_Street_Name__c != a.Billing_Street_Name__c)
                ||(Trigger.oldMap.get(a.id).Billing_Street_Number_Suffix__c != a.Billing_Street_Number_Suffix__c)
                ||(Trigger.oldMap.get(a.id).Billing_Unit_Number__c != a.Billing_Unit_Number__c)
                ||(Trigger.oldMap.get(a.id).Billing_Unit_Type__c != a.Billing_Unit_Type__c)
                ||(Trigger.oldMap.get(a.id).Billing_Zip_4__c != a.Billing_Zip_4__c)
                ||(Trigger.oldMap.get(a.id).Billing_Zip__c != a.Billing_Zip__c)
                ||(Trigger.oldMap.get(a.id).BillingCity != a.BillingCity)
                ||(Trigger.oldMap.get(a.id).BillingCountry != a.BillingCountry)
                ||(Trigger.oldMap.get(a.id).BillingPostalCode != a.BillingPostalCode)
                ||(Trigger.oldMap.get(a.id).BillingState != a.BillingState)
                ||(Trigger.oldMap.get(a.id).BillingStreet != a.BillingStreet)
                ||(Trigger.oldMap.get(a.id).Box__c != a.Box__c)
                ||(Trigger.oldMap.get(a.id).BrokerAddress__c != a.BrokerAddress__c)
                ||(Trigger.oldMap.get(a.id).City__c != a.City__c)
                ||(Trigger.oldMap.get(a.id).CONTACT1FAX__c != a.CONTACT1FAX__c)
                ||(Trigger.oldMap.get(a.id).CONTACT1NAME__c != a.CONTACT1NAME__c)
                ||(Trigger.oldMap.get(a.id).CONTACT1OFFICEPHONE__c != a.CONTACT1OFFICEPHONE__c)
                ||(Trigger.oldMap.get(a.id).CONTACT1TITLE__c != a.CONTACT1TITLE__c)
                ||(Trigger.oldMap.get(a.id).Copy_Address_to_Billing__c != a.Copy_Address_to_Billing__c)
                ||(Trigger.oldMap.get(a.id).Country__c != a.Country__c)
                ||(Trigger.oldMap.get(a.id).County__c != a.County__c)
                ||(Trigger.oldMap.get(a.id).CUSTOMERADDRESSLINE1__c != a.CUSTOMERADDRESSLINE1__c)
                ||(Trigger.oldMap.get(a.id).CUSTOMERADDRESSLINE2__c != a.CUSTOMERADDRESSLINE2__c)
                ||(Trigger.oldMap.get(a.id).CUSTOMEREMAIL__c != a.CUSTOMEREMAIL__c)
                ||(Trigger.oldMap.get(a.id).CUSTOMERFAX__c != a.CUSTOMERFAX__c)
                ||(Trigger.oldMap.get(a.id).CUSTOMEROFFICEPHONE__c != a.CUSTOMEROFFICEPHONE__c)
                ||(Trigger.oldMap.get(a.id).CUSTOMERPOSTALCODE__c != a.CUSTOMERPOSTALCODE__c)
                ||(Trigger.oldMap.get(a.id).Date_Joined__c != a.Date_Joined__c)
                ||(Trigger.oldMap.get(a.id).Date_Terminated__c != a.Date_Terminated__c)
                ||(Trigger.oldMap.get(a.id).Office_Email__c != a.Office_Email__c)
                ||(Trigger.oldMap.get(a.id).Fax != a.Fax)
                ||(Trigger.oldMap.get(a.id).Full_Street_Address__c != a.Full_Street_Address__c)
                ||(Trigger.oldMap.get(a.id).Name != a.Name)
                ||(Trigger.oldMap.get(a.id).Phone != a.Phone)
                ||(Trigger.oldMap.get(a.id).PIN__c != a.PIN__c)
                ||(Trigger.oldMap.get(a.id).Zip_4__c != a.Zip_4__c)
                ||(Trigger.oldMap.get(a.id).Zip__c != a.Zip__c)
                ||(Trigger.oldMap.get(a.id).Unit__c != a.Unit__c)
                ||(Trigger.oldMap.get(a.id).Unit_Type__c != a.Unit_Type__c)
                ||(Trigger.oldMap.get(a.id).Website != a.Website)
                ||(Trigger.oldMap.get(a.id).Trading_As__c != a.Trading_As__c)
                ||(Trigger.oldMap.get(a.id).TickerSymbol != a.TickerSymbol)
                ||(Trigger.oldMap.get(a.id).State__c != a.State__c)
                ||(Trigger.oldMap.get(a.id).Street_Type__c != a.Street_Type__c)
                ||(Trigger.oldMap.get(a.id).Street_Number_Suffix__c != a.Street_Number_Suffix__c)
                ||(Trigger.oldMap.get(a.id).Street_Number__c != a.Street_Number__c)
                ||(Trigger.oldMap.get(a.id).Street_Name__c != a.Street_Name__c)
                ||(Trigger.oldMap.get(a.id).Street_Direction__c != a.Street_Direction__c)
                ||(Trigger.oldMap.get(a.id).Shareholder_Board__c != a.Shareholder_Board__c)
                ||(Trigger.oldMap.get(a.id).Type != a.Type)
                ||(Trigger.oldMap.get(a.id).Company_Type__c != a.Company_Type__c)
                ||(Trigger.oldMap.get(a.id).ParentID != a.ParentID)
                ||(Trigger.oldMap.get(a.id).Status__c != a.Status__c)
                ||(Trigger.oldMap.get(a.id).State__c != a.State__c))){
                    /* Pure update */
                    System.debug('*** Old Values: ' + Trigger.oldMap.get(a.id));
                    System.debug('*** New Values: ' + a);
                    System.debug('*** Will be an office update');
                    newJsonAccountString.put(a.id,JSON.serialize(a));
                    oldJsonAccountString.put(a.id,JSON.serialize(Trigger.oldMap.get(a.id)));
        }
    }
    
    try {
		
        //below code is commented for SAL-2406 GAIL's comment.
        /* Any kind of inserts will be handled here */
        //if (newJsonAccountString.size() > 0 && oldJsonAccountString.size() == 0) 
          //  AccountProcessingUtility.sendAccountsToQueueProcessor('INSERT', newJsonAccountString,null );    
        
        /* Any kind of updates will be handled here */
        //if (newJsonAccountString.size() > 0 && oldJsonAccountString.size() > 0) 
          //  AccountProcessingUtility.sendAccountsToQueueProcessor('UPDATE', newJsonAccountString,oldJsonAccountString );            
    } 
    catch(AsyncException ex) {
        executionFlowUtility.accountUpdate = true;
        Trigger.new[0].adderror(ex.getMessage());
        throw ex;
    }
    
    executionFlowUtility.accountUpdate = true;
}