trigger QASMRISApprovedDeferred on MRIS_Application__c ( before insert,  before update) {

//Exit trigger if records are inserted and/or updated by dataloader profile.
if (Utils.BypassValidationrules())return;

    for(MRIS_Application__c mris: Trigger.new){
        boolean check = false;
        if (Trigger.isUpdate) {
            MRIS_Application__c oldMRIS = Trigger.oldMap.get(mris.id);
            check = (mris.Status__c == 'Approved' && oldMRIS.Status__c != 'Approved' && mris.Application_Type__c == null);
            
        } else {
            check = (mris.Status__c == 'Approved' && mris.Application_Type__c == null);
        }
        System.debug('check---->' + check);
        if ((mris.Comments__c == null || mris.Comments__c == '') 
            && (mris.Status__c == 'Deferred')) {
                mris.comments__c.addError('Comments are required for this operation. Record was not saved');
        }
        
        System.debug('mris.Status__c -- >' + mris.Status__c);
     
        if(check){
           System.debug('code: ' + mris.Company_code__c);
                //Get Mailing and Billing address from account object
           Account acct = [Select a.Zip__c, a.Zip_4__c, a.Website, a.Unit__c, a.Unit_Type__c, a.Type,
           a.QAS_Billing_Country__c, a.QAS_Mailing_Country__c, a.QAS_Billing_County__c, a.QAS_Mailing_County__c, 
           a.QAS_Billing_Street_Direction__c, a.QAS_Mailing_Street_Direction__c, a.QAS_Billing_Street_Type__c, a.QAS_Mailing_Street_Type__c, 
           a.QAS_Billing_Unit_Type__c, a.QAS_Mailing_Unit_Type__c, a.QAS_Mailing_Record_Type__c, a.QAS_Mailing_POBox__c,
           a.QAS_Billing_Record_Type__c, a.QAS_Billing_POBox__c,  
           a.Trading_As__c, a.TickerSymbol, a.SystemModstamp, a.Street_Type__c, a.Street_Number__c, 
           a.Street_Number_Suffix__c, a.Street_Name__c, a.Street_Direction__c, a.Status__c, a.State__c, 
           a.SicDesc, a.Shareholder_Board__c, a.Rating, a.PrismCompanyOffice__c, a.PrismCompanyCode__c, 
           a.PrismAddressID__c, a.PrismAccountID__c, a.Phone, a.ParentId, a.PIN__c, a.OwnerId, a.OfficeKey__c, 
           a.Num_Active_Subs__c, a.Num_Active_Office_Sec_NC__c, a.Name, a.NRDS_ID__c, a.MasterRecordId, 
           a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.JigsawCompanyId, a.Jigsaw, a.IsDeleted, 
           a.IsCustomerPortal, a.Industry, a.Id, a.Fax, a.Description, a.Date_Terminated__c, a.Date_Joined__c, 
           a.CreatedDate, a.CreatedById, a.County__c, a.Country__c, a.Copy_Address_to_Billing__c,
           a.Company_Type__c, a.City__c, a.BrokerAddress__c, a.Box__c, a.Billing_Zip__c, a.Billing_Zip_4__c, 
           a.Billing_Unit_Type__c, a.Billing_Unit_Number__c, a.Billing_Street_Type__c, a.Billing_Street_Number__c,
           a.Billing_Street_Number_Suffix__c, a.Billing_Street_Name__c, a.Billing_Street_Direction__c,
           a.Billing_State__c, a.Billing_County__c, a.Billing_Country__c, a.Billing_City__c, a.Billing_Box__c, 
           a.Billing_Addl_Display_Name__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry,
           a.BillingCity, a.Addl_Display_Name__c, a.Account_Name__c, a.AccountSource 
           From Account a 
           where a.id=:mris.Company_code__c];
            
                //Set Application Status to Approved after creating the contact
                Contact c = new Contact();
                c.FirstName = mris.First_Name__c;
                c.LastName = mris.Last_Name__c;
                c.Middle_Name__c = mris.Middle_Name__c;
                c.Phone = mris.Primary_Phone__c;
                c.MobilePhone = mris.Mobile_Phone__c;
                c.Salutation = mris.Salutation__c;
                c.Voicemail__c = mris.Voicemail__c;
                c.VM_Ext__c = mris.VM_Ext__c;
                c.Nickname__c = mris.Nickname__c;
                c.Home_Fax__c = mris.Home_Fax__c;
                c.AccountId = mris.Company_Code__c;
                c.Email = mris.Private_Email__c;
                c.Public_Email__c = mris.Public_Email__c;
                c.Website__c = mris.Website__c;
                c.NRDS_ID__c = mris.NRDS_ID__c;
                c.Professional_Designations__c = mris.Professional_Designations__c;
                c.Disabilities__c = mris.Disabilities__c;
                c.Status__c = 'In Progress';
                c.Agent_Office_Phone__c = mris.Agent_Office_Phone__c;
                
                c.City__c = mris.Company_Code__r.City__c;
                c.Zip__c = mris.Company_Code__r.Zip__c;
                c.County__c = mris.Company_Code__r.County__c;
                c.QAS_Mailing_County__c = mris.Company_Code__r.QAS_Mailing_County__c;
                
                //insert Mailing address of Account to Contact
                c.Street_Number__c = acct.Street_Number__c;
                c.Street_Name__c = acct.Street_Name__c;
                c.Street_Type__c = acct.Street_Type__c;
                c.Street_Number_Suffix__c = acct.Street_Number_Suffix__c;
                c.Street_Direction__c = acct.Street_Direction__c;
                c.Unit_Type__c = acct.Unit_Type__c;
                c.Unit__c = acct.Unit__c;
                c.Addl_Display_Name__c = acct.Addl_Display_Name__c;
                c.Box__c = acct.Box__c;
                c.Zip__c = acct.Zip__c;
                c.Zip_4__c = acct.Zip_4__c;
                c.Fax = mris.Agent_Office_Fax__c;
                c.Home_Fax__c = mris.Home_Fax__c;
                c.City__c = acct.City__c;
                c.State__c = acct.State__c;
                c.County__c = acct.County__c;
                c.Country__c = acct.Country__c;
                c.QAS_Mailing_Country__c = acct.QAS_Mailing_Country__c; 
                c.QAS_Mailing_County__c = acct.QAS_Mailing_County__c; 
                c.QAS_Mailing_Street_Direction__c = acct.QAS_Mailing_Street_Direction__c; 
                c.QAS_Mailing_Street_Type__c = acct.QAS_Mailing_Street_Type__c; 
                c.QAS_Mailing_Unit_Type__c = acct.QAS_Mailing_Unit_Type__c; 
                c.QAS_Mailing_POBox__c = acct.QAS_Mailing_POBox__c;
                c.QAS_Mailing_Record_Type__c = acct.QAS_Mailing_Record_Type__c;
                                
                //insert Billing address of Account to Contact
                c.Billing_Street_Number__c = acct.Billing_Street_Number__c;
                c.Billing_Street_Name__c = acct.Billing_Street_Name__c;
                c.Billing_Street_Type__c = acct.Billing_Street_Type__c; 
                c.Street_Number_Suffix__c = acct.Street_Number_Suffix__c;               
                c.Billing_Street_Direction__c = acct.Billing_Street_Direction__c;
                c.Billing_Unit_Type__c = acct.Billing_Unit_Type__c;
                c.Billing_Box__c = acct.Billing_Box__c;
                c.Billing_Addl_Display_Name__c = acct.Billing_Addl_Display_Name__c;
                c.Billing_Zip__c = acct.Billing_Zip__c;
                c.Billing_Zip_4__c = acct.Billing_Zip_4__c;
                c.Zip_4__c = acct.Zip_4__c;
                c.Billing_City__c = acct.Billing_City__c;
                c.Billing_State__c = acct.Billing_State__c;
                c.Billing_County__c = acct.Billing_County__c;
                c.Billing_Country__c = acct.Billing_Country__c;
                c.QAS_Billing_Country__c = acct.QAS_Billing_Country__c; 
                c.QAS_Billing_County__c = acct.QAS_Billing_County__c;
                c.QAS_Billing_Street_Direction__c = acct.QAS_Billing_Street_Direction__c;
                c.QAS_Billing_Street_Type__c = acct.QAS_Billing_Street_Type__c;
                c.QAS_Billing_Unit_Type__c = acct.QAS_Billing_Unit_Type__c;
                c.QAS_Billing_POBox__c = acct.QAS_Billing_POBox__c;
                c.QAS_Billing_Record_Type__c = acct.QAS_Billing_Record_Type__c;
                
                //c.Date_Joined__c = mris.CreatedDate.date();
                //Date nextMonth = mris.CreatedDate.addMonths(1);
                //c.Date_Billing_Begins__c = nextMonth.toStartOfMonth();
                
                insert c;       
                
                Subscriptions__c s = new Subscriptions__c();
                s.Contact__c = c.Id;
                s.SFDC_Application__c = mris.Id;
                s.City__c = mris.Company_Code__r.City__c;
                s.Zip__c = mris.Company_Code__r.Zip__c;
                s.County__c = mris.Company_Code__r.County__c;
                s.QAS_Mailing_County__c = mris.Company_Code__r.QAS_Mailing_County__c;
                s.Related_Location_Broker_Office__c = mris.Company_Code__r.Id;
                s.Subscription_Type__c = mris.Subscription_Type__c;
                s.Contact_Type__c = mris.Type__c;
                s.Public_Email__c = mris.Public_Email__c;
                s.Primary_Phone__c = mris.Primary_Phone__c;
                s.Home_Fax__c = mris.Home_Fax__c;
                s.Voicemail__c = mris.Voicemail__c;
                s.VM_Ext__c = mris.VM_Ext__c;
                s.Agent_Office_Phone__c = mris.Agent_Office_Phone__c;
                s.Fax__c = mris.Agent_Office_Fax__c;
                s.Home_Fax__c = mris.Home_Fax__c;
                s.Mobile_Phone__c = mris.Mobile_Phone__c;
                s.Home_Fax__c = mris.Home_Fax__c;              
                s.Website__c = mris.Website__c;
                s.Related_Location_Broker_Office__c = mris.Company_Code__c;
                s.Status__c = 'In Progress';
                // added code for subs  
                s.NRDS_ID__c = mris.NRDS_ID__c;
               s.Service_Jurisdiction__c = 'BRIGHT'; 
                
                //insert Mailing address of Account to Subscription
                s.Street_Number__c = acct.Street_Number__c;
                s.Street_Name__c = acct.Street_Name__c;
                s.Street_Type__c = acct.Street_Type__c;
                s.Street_Number_Suffix__c = acct.Street_Number_Suffix__c;
                s.Street_Direction__c = acct.Street_Direction__c;
                s.Unit_Type__c = acct.Unit_Type__c;
                s.Unit__c = acct.Unit__c;
                s.Addl_Display_Name__c = acct.Addl_Display_Name__c;
                s.Box__c = acct.Box__c;
                s.Zip__c = acct.Zip__c;
                s.Zip_4__c = acct.Zip_4__c;
                s.City__c = acct.City__c;
                s.Private_Email__c = mris.Private_Email__c;
                s.State__c = acct.State__c;
                s.County__c = acct.County__c;
                s.Country__c = acct.Country__c;
                s.QAS_Mailing_Country__c = acct.QAS_Mailing_Country__c; 
                s.QAS_Mailing_County__c = acct.QAS_Mailing_County__c; 
                s.QAS_Mailing_Street_Direction__c = acct.QAS_Mailing_Street_Direction__c; 
                s.QAS_Mailing_Street_Type__c = acct.QAS_Mailing_Street_Type__c; 
                s.QAS_Mailing_Unit_Type__c = acct.QAS_Mailing_Unit_Type__c; 
                s.QAS_Mailing_POBox__c = acct.QAS_Mailing_POBox__c;
                s.QAS_Mailing_Record_Type__c = acct.QAS_Mailing_Record_Type__c; 
              
                
                //insert Billing address of Account to Subscription
                s.Billing_Street_Number__c = acct.Billing_Street_Number__c;
                s.Billing_Street_Name__c = acct.Billing_Street_Name__c;
                s.Billing_Street_Type__c = acct.Billing_Street_Type__c; 
                s.Street_Number_Suffix__c = acct.Street_Number_Suffix__c;               
                s.Billing_Street_Direction__c = acct.Billing_Street_Direction__c;
                s.Billing_Unit_Type__c = acct.Billing_Unit_Type__c;
                s.Billing_Box__c = acct.Billing_Box__c;
                s.Billing_Addl_Display_Name__c = acct.Billing_Addl_Display_Name__c;
                s.Billing_Zip__c = acct.Billing_Zip__c;
                s.Billing_Zip_4__c = acct.Billing_Zip_4__c;
                s.Zip_4__c = acct.Zip_4__c;
                s.Billing_City__c = acct.Billing_City__c;
                s.Billing_State__c = acct.Billing_State__c;
                s.Billing_County__c = acct.Billing_County__c;
                s.Billing_Country__c = acct.Billing_Country__c;
                s.QAS_Billing_Country__c = acct.QAS_Billing_Country__c; 
                s.QAS_Billing_County__c = acct.QAS_Billing_County__c;
                s.QAS_Billing_Street_Direction__c = acct.QAS_Billing_Street_Direction__c;
                s.QAS_Billing_Street_Type__c = acct.QAS_Billing_Street_Type__c;
                s.QAS_Billing_Unit_Type__c = acct.QAS_Billing_Unit_Type__c;
                s.QAS_Billing_POBox__c = acct.QAS_Billing_POBox__c;
                s.QAS_Billing_Record_Type__c = acct.QAS_Billing_Record_Type__c;
                
               insert s;    
               
               //Insert Association if exists
               if (mris.Association_Board_Affiliation__c != null) {
                    Related_Association__c ra = new Related_Association__c();
                    ra.Association__c = mris.Association_Board_Affiliation__c;
                    ra.Primary__c  = true;
                    ra.Subscription__c = s.id;
                    ra.Status__c = 'Active';
                    insert ra;
               }              
               
               License__c l = new License__c();
               l.Name = mris.License_Number__c;
               l.License_Expiration_Date__c = mris.License_Expiration_Date__c;
               l.License_State__c = mris.License_State__c;
               l.License_Type__c = mris.License_Type__c;
               l.Contact__c = c.id;
            if (!((null == mris.License_Number__c) || ''.equals(mris.License_Number__c))) {
                insert l;
                System.debug('mris.License_Number__c -->' + mris.License_Number__c);
               Subscription_License__c sl = new Subscription_License__c(); 
               sl.License__c = l.id;
               
               sl.Subscription__c = s.id;  
               
               insert sl;
               
            }
               
               
               
                //Link the Subscription to the Case
               List <Case> caseList = [Select c.Subscription_ID__c, 
               c.Id From Case c where c.MRIS_Application__c = :mris.id];
               System.debug('caseList.size() ----> ' + caseList.size());
               if (caseList.size() > 0) {
                    Case caseObj = caseList.get(0);
                    caseObj.Subscription_ID__c =  s.id; 
                    upsert caseObj;
               }
               
               mris.Agent_Subscription_ID__c = s.id;
            }   
            
        }


            
    

}