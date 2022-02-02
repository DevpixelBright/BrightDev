/*

*/
public without sharing class SubscriptionSetup {
    public static Subscriptions__c subscriptionCreation(MRIS_Application__c application, string trendLoginName){
    	
    	Savepoint sp = Database.setSavepoint();
    	try{
	    	if(application != null){
				
						                    
			    Subscriptions__c subscription = new Subscriptions__c(); 
			    List<Subscriptions__c> subs = new List<Subscriptions__c>() ;
			    subs = [SELECT Id, Name, Contact__c, Contact_Type__c, Subscription_Type__c, Status__c, Related_Location_Broker_Office__c,
                         City__c, State__c, QAS_Mailing_County__c, Zip__c, Private_Email__c, Primary_Phone__c, Mobile_Phone__c,
                         Contact__r.FirstName, Contact__r.LastName, Contact__r.Middle_Name__c, Contact__r.Nickname__c, Contact__r.Suffix__c,
                         TREND_Login_Name__c, Service_Jurisdiction__c, Billing_Jurisdiction__c 
                         FROM Subscriptions__c WHERE SFDC_Application__c = :application.Id]; 
			    
			    if(subs.size() > 0){
			        subscription = subs[0];
			    }      
			    else if(application.Status__c == 'Approved' && subs.size() == 0 ) {
			    
			        if(application.Service_Jurisdiction__c == 'TREND' && String.isBlank(trendLoginName))
			            throw new CustomException('Please enter TREND login name');
			        
			        if(application.Service_Jurisdiction__c == 'TREND' && String.isNotBlank(trendLoginName)) {
			            List<Subscriptions__c> trendUsers = [SELECT Id FROM Subscriptions__c WHERE TREND_Login_Name__c = :trendLoginName];
			            if(trendUsers.Size() > 0)
			                throw new CustomException('TREND login name already taken. Please enter different one.');    
			        }
					
					
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
							        where a.id=:application.Company_code__c];
			
			        //Set Application Status to Approved after creating the contact
			        Contact c = new Contact();
			        
			        c.FirstName = application.First_Name__c;
			        c.LastName = application.Last_Name__c;
			        c.Middle_Name__c = application.Middle_Name__c;
			        c.Suffix__c = application.Suffix__c;
			        c.Phone = application.Primary_Phone__c;
			        c.MobilePhone = application.Mobile_Phone__c;
			        c.Salutation = application.Salutation__c;
			        c.Voicemail__c = application.Voicemail__c;
			        c.VM_Ext__c = application.VM_Ext__c;
			        c.Nickname__c = application.Nickname__c;
			        c.Home_Fax__c = application.Home_Fax__c;
			        c.AccountId = application.Company_Code__c;
			        c.Email = application.Private_Email__c;
			        c.Public_Email__c = application.Public_Email__c;
			        c.Website__c = application.Website__c;
			        c.NRDS_ID__c = application.NRDS_ID__c;
			        c.Professional_Designations__c = application.Professional_Designations__c;
			        c.Disabilities__c = application.Disabilities__c;
			        c.Status__c = 'In Progress';
			        c.Agent_Office_Phone__c = application.Agent_Office_Phone__c;
			
			        c.City__c = application.Company_Code__r.City__c;
			        c.Zip__c = application.Company_Code__r.Zip__c;
			        c.County__c = application.Company_Code__r.County__c;
			        c.QAS_Mailing_County__c = application.Company_Code__r.QAS_Mailing_County__c;
			
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
			        c.Fax = application.Agent_Office_Fax__c;
			        c.Home_Fax__c = application.Home_Fax__c;
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
			        
			        c.Service_Jurisdiction__c = application.Service_Jurisdiction__c;
			        c.AddressValidationStatus__c = 'Not Required';
			
			        insert c;       
			
			        Subscriptions__c s = new Subscriptions__c();
			        s.Contact__c = c.Id;
			        s.SFDC_Application__c = application.Id;
			        s.City__c = application.Company_Code__r.City__c;
			        s.Zip__c = application.Company_Code__r.Zip__c;
			        s.County__c = application.Company_Code__r.County__c;
			        s.QAS_Mailing_County__c = application.Company_Code__r.QAS_Mailing_County__c;
			        s.Related_Location_Broker_Office__c = application.Company_Code__r.Id;
			        s.Subscription_Type__c = application.Subscription_Type__c;
			        s.Contact_Type__c = application.Type__c;
			        s.Public_Email__c = application.Public_Email__c;
			        s.Primary_Phone__c = application.Primary_Phone__c;
			        s.Home_Fax__c = application.Home_Fax__c;
			        s.Voicemail__c = application.Voicemail__c;
			        s.VM_Ext__c = application.VM_Ext__c;
			        s.Agent_Office_Phone__c = application.Agent_Office_Phone__c;
			        s.Fax__c = application.Agent_Office_Fax__c;
			        s.Home_Fax__c = application.Home_Fax__c;
			        s.Mobile_Phone__c = application.Mobile_Phone__c;
			        s.Home_Fax__c = application.Home_Fax__c;              
			        s.Website__c = application.Website__c;
			        s.Related_Location_Broker_Office__c = application.Company_Code__c;
			        s.Status__c = 'In Progress';
			        s.NRDS_ID__c = application.NRDS_ID__c;
			
			
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
			        s.Private_Email__c = application.Private_Email__c;
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
			        
			        s.Service_Jurisdiction__c = application.Service_Jurisdiction__c;
			        s.Billing_Jurisdiction__c = application.Service_Jurisdiction__c;
			        
			        /* BRIGHT billing jurisdiction logic based on office County */ 
			        if(application.Service_Jurisdiction__c == 'BRIGHT' && application.Company_Code__r.County__c != null) {
		                List<BRIGHT_Billing_Jurisdiction__c> countiesList = new List<BRIGHT_Billing_Jurisdiction__c>();
		                countiesList = [SELECT Id, Name, County__c, State__c, Billing_Jurisdiction__c 
		                                FROM   BRIGHT_Billing_Jurisdiction__c 
		                                WHERE  County__c = :application.Company_Code__r.County__c 
		                                AND    State__c = :application.Company_Code__r.State__c];
		                
		                if(countiesList.Size() > 0) 
	                   		s.Billing_Jurisdiction__c = countiesList[0].Billing_Jurisdiction__c;                   
			            
			        }
			        
			        
			        if(application.Service_Jurisdiction__c == 'TREND' && String.isNotBlank(trendLoginName))                                 
			            s.TREND_Login_Name__c = trendLoginName;
			        
			        
			        s.AddressValidationStatus__c = 'Not Required';
			        insert s;    
			
			        //Insert Association if exists
			        if (application.Association_Board_Affiliation__c != null) {
			            Related_Association__c ra = new Related_Association__c();
			            ra.Association__c = application.Association_Board_Affiliation__c;
			            ra.Primary__c  = true;
			            ra.Subscription__c = s.id;
			            ra.Status__c = 'Active';
			            insert ra;
			        }              
			
			        License__c l = new License__c();
			        l.Name = application.License_Number__c;
			        l.License_Expiration_Date__c = application.License_Expiration_Date__c;
			        l.License_State__c = application.License_State__c;
			        l.License_Type__c = application.License_Type__c;
			        l.Contact__c = c.id;
			        
			        if (!((null == application.License_Number__c) || ''.equals(application.License_Number__c))) {
			            insert l;
			            System.debug('application.License_Number__c -->' + application.License_Number__c);
			
			            Subscription_License__c sl = new Subscription_License__c(); 
			            sl.License__c = l.id;
			            sl.Subscription__c = s.id;  
			            insert sl;
			        }
			        
			        subscription = [SELECT   Id, Name, Contact__c, Contact_Type__c, Subscription_Type__c, Status__c, Related_Location_Broker_Office__c,
			                         City__c, State__c, QAS_Mailing_County__c, Zip__c, Private_Email__c, Primary_Phone__c, Mobile_Phone__c,
			                         Contact__r.FirstName, Contact__r.LastName, Contact__r.Middle_Name__c, Contact__r.Nickname__c, Contact__r.Suffix__c,
			                         TREND_Login_Name__c, Service_Jurisdiction__c, Billing_Jurisdiction__c   
					                 FROM Subscriptions__c 
					                 WHERE Id = :s.Id]; 
			        //isSubExist = true;
			        //showcontinue = false;
			        //showPaymentButton = true;
			        
			        application.Agent_Subscription_ID__c = s.id;
			        //application.Status__c = 'Completed';
			        update application;
			        
	        	}
	        	return subscription;
	        	
	    	}else
	    		return null;
    		
    	}
        Catch(Exception e) {
            Database.rollback(sp);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    	
	}
	
	public static void activateSubscription(MRIS_Application__c application, Subscriptions__c subscription) {
        try {
        	//Subscriptions__c subscription = new Subscriptions__c();
        	//subscription.Id = application.Agent_Subscription_ID__c;
        	
        	system.debug('---subscription in activate method--->'+subscription);
            if(subscription.Status__c == 'In Progress')
                subscription.Status__c = 'Active';
                
            if(subscription.Status__c == 'Inactive') {
                subscription.Status__c = 'Active';
                subscription.Status_Change_Reason__c = 'Reinstate';
                subscription.Date_Reinstated__c = Date.today();
            }
            //completing the application if the subcription is activated.
            if(application.Status__c != 'Completed'){
	            application.Status__c = 'Completed';
	            update application;
            }
            
            //if(subscription.ZuoraIntegrationWorkflowBypass__c == true && subscription.AddressValidationStatus__c == 'To be verify'){
	            subscription.ZuoraIntegrationWorkflowBypass__c = true;
	            subscription.AddressValidationStatus__c = 'To be verify';
	            update subscription;
            //}
            
            //showPayment = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Subscription activated successfully'));
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));    
        }
    }
	
	@future 
	public static void test(string applicationId){
		MRIS_Application__c application = [SELECT Id, 
                                                             Name, 
                                                             Status__c, 
                                                             Application_Expire_Date__c, 
                                                             Company_code__c, 
                                                             Suffix__c,
                                                             First_Name__c, 
                                                             Last_Name__c, 
                                                             Middle_Name__c, 
                                                             Mobile_Phone__c, 
                                                             Salutation__c, 
                                                             Voicemail__c, 
                                                             VM_Ext__c, 
                                                             Nickname__c, 
                                                             Primary_Phone__c, 
                                                             Agent_Office_Fax__c,
                                                             Private_Email__c, 
                                                             Public_Email__c, 
                                                             Website__c , 
                                                             NRDS_ID__c, 
                                                             Professional_Designations__c , 
                                                             Disabilities__c, 
                                                             Agent_Office_Phone__c, 
                                                             Company_Code__r.Name, 
                                                             Company_Code__r.City__c, 
                                                             Company_Code__r.Zip__c, 
                                                             Company_Code__r.County__c, 
                                                             Company_Code__r.State__c,
                                                             Company_Code__r.QAS_Mailing_County__c,  
                                                             Company_Code__r.Id, 
                                                             Subscription_Type__c, 
                                                             Type__c, 
                                                             Association_Board_Affiliation__c,
                                                             License_Number__c, 
                                                             Home_Fax__c,
                                                             Service_Jurisdiction__c,
                                                             Billing_Jurisdiction__c,
                                                             License_Expiration_Date__c, 
                                                             License_State__c, 
                                                             License_Type__c,
                                                             Agent_Subscription_ID__c,
                                                             Agent_Subscription_ID__r.Name, 
                                                             CreatedDate, 
                                                             Private_Phone__c, 
                                                             Application_Type__c,
                                                             City__c,
                                                             State__c,
                                                             County__c,
                                                             Zip__c 
                                                       FROM MRIS_Application__c
                                                       WHERE Id = :applicationId
                       ];
                       
		system.debug('--application-->'+application);
		
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
							        where a.id=:application.Company_code__c];
							        
		
		system.debug('---acct--->'+acct);
		
		//Set Application Status to Approved after creating the contact
			        Contact c = new Contact();
			        
			        c.FirstName = application.First_Name__c;
			        c.LastName = application.Last_Name__c;
			        c.Middle_Name__c = application.Middle_Name__c;
			        c.Suffix__c = application.Suffix__c;
			        c.Phone = application.Primary_Phone__c;
			        c.MobilePhone = application.Mobile_Phone__c;
			        c.Salutation = application.Salutation__c;
			        c.Voicemail__c = application.Voicemail__c;
			        c.VM_Ext__c = application.VM_Ext__c;
			        c.Nickname__c = application.Nickname__c;
			        c.Home_Fax__c = application.Home_Fax__c;
			        c.AccountId = application.Company_Code__c;
			        c.Email = application.Private_Email__c;
			        c.Public_Email__c = application.Public_Email__c;
			        c.Website__c = application.Website__c;
			        c.NRDS_ID__c = application.NRDS_ID__c;
			        c.Professional_Designations__c = application.Professional_Designations__c;
			        c.Disabilities__c = application.Disabilities__c;
			        c.Status__c = 'In Progress';
			        c.Agent_Office_Phone__c = application.Agent_Office_Phone__c;
			
			        c.City__c = application.Company_Code__r.City__c;
			        c.Zip__c = application.Company_Code__r.Zip__c;
			        c.County__c = application.Company_Code__r.County__c;
			        c.QAS_Mailing_County__c = application.Company_Code__r.QAS_Mailing_County__c;
			
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
			        c.Fax = application.Agent_Office_Fax__c;
			        c.Home_Fax__c = application.Home_Fax__c;
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
			        
			        c.Service_Jurisdiction__c = application.Service_Jurisdiction__c;
			        c.AddressValidationStatus__c = 'Not Required';
			
			        insert c;       
			
			        Subscriptions__c s = new Subscriptions__c();
			        s.Contact__c = c.Id;
			        s.SFDC_Application__c = application.Id;
			        s.City__c = application.Company_Code__r.City__c;
			        s.Zip__c = application.Company_Code__r.Zip__c;
			        s.County__c = application.Company_Code__r.County__c;
			        s.QAS_Mailing_County__c = application.Company_Code__r.QAS_Mailing_County__c;
			        s.Related_Location_Broker_Office__c = application.Company_Code__r.Id;
			        s.Subscription_Type__c = application.Subscription_Type__c;
			        s.Contact_Type__c = application.Type__c;
			        s.Public_Email__c = application.Public_Email__c;
			        s.Primary_Phone__c = application.Primary_Phone__c;
			        s.Home_Fax__c = application.Home_Fax__c;
			        s.Voicemail__c = application.Voicemail__c;
			        s.VM_Ext__c = application.VM_Ext__c;
			        s.Agent_Office_Phone__c = application.Agent_Office_Phone__c;
			        s.Fax__c = application.Agent_Office_Fax__c;
			        s.Home_Fax__c = application.Home_Fax__c;
			        s.Mobile_Phone__c = application.Mobile_Phone__c;
			        s.Home_Fax__c = application.Home_Fax__c;              
			        s.Website__c = application.Website__c;
			        s.Related_Location_Broker_Office__c = application.Company_Code__c;
			        s.Status__c = 'In Progress';
			        s.NRDS_ID__c = application.NRDS_ID__c;
			
			
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
			        s.Private_Email__c = application.Private_Email__c;
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
			        
			        s.Service_Jurisdiction__c = application.Service_Jurisdiction__c;
			        s.Billing_Jurisdiction__c = application.Service_Jurisdiction__c;
			        
			        /* BRIGHT billing jurisdiction logic based on office County */ 
			        if(application.Service_Jurisdiction__c == 'BRIGHT' && application.Company_Code__r.County__c != null) {
		                List<BRIGHT_Billing_Jurisdiction__c> countiesList = new List<BRIGHT_Billing_Jurisdiction__c>();
		                countiesList = [SELECT Id, Name, County__c, State__c, Billing_Jurisdiction__c 
		                                FROM   BRIGHT_Billing_Jurisdiction__c 
		                                WHERE  County__c = :application.Company_Code__r.County__c 
		                                AND    State__c = :application.Company_Code__r.State__c];
		                
		                if(countiesList.Size() > 0) 
	                   		s.Billing_Jurisdiction__c = countiesList[0].Billing_Jurisdiction__c;                   
			            
			        }
			        
			        
			        //if(application.Service_Jurisdiction__c == 'TREND' && String.isNotBlank(trendLoginName))                                 
			          //  s.TREND_Login_Name__c = trendLoginName;
			        
			        
			        s.AddressValidationStatus__c = 'Not Required';
			        insert s;
			
	}
	
public class CustomException extends Exception{}
}