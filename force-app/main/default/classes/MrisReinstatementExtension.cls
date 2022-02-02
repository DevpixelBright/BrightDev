public class MrisReinstatementExtension {
    // this class was copy+pasted from MRISApplicationExtension2
    // price changes timelines required quick & dirty solution
        
    private String NonRealtorSelection;
    private string RealtorSelection;
    private String OfficeSecretaryNCSelection;
    private String LicenseTypeSelection;
    private MRIS_Application__c application;
    public String BrokerCode{get;set;}
    public Account BrokerInfo{get;set;}
    public String renderedAs{get;set;}
    public String SubscriptionId{get;set;}//Used for the confirmation screen by number
    //Map of Field Names and Description of that field
    Map<String,Schema.SObjectField> fields;
    //Variable used to fire off Javascript confirmation
    public Boolean Print{get;set;}
    public List<Account> Associations;
    public String selectedAssociation{get;set;}
    private Account NonShareHolder;
    public String AppraiserCode{get;set;}
    public Subscriptions__c Subscription{get;set;}
    public String AgentCode{get;set;}
    
    public MrisReinstatementExtension(Apexpages.StandardController controller)
    {
        if (application == null)
        {
            application = new MRIS_Application__c();
            application.RecordTypeId = FindReinstatementRecordType();
        }
        SetUp();
    }
    public void SetUp()
    {
        //Populate Association
        Associations = [SELECT
        Account.Id,
        Account.Name,
        Account.Account_Name__c,
        Account.Shareholder_Board__c
        FROM Account
        WHERE Account.Type = 'Association'
        AND Account.Status__c = 'Active'];
        //throw new myException(string.valueof(Associations.size()));
        for (Account a:this.Associations)
        {
                if (a.Account_Name__c.toLowerCase().contains('none chosen'))
                {
                        NonShareHolder = a;
                        break;
                }
        }
        if (RealtorSelection == null) //initialize radio selects and Subscription Types
        {
                RealtorSelection = 'Yes';
                OfficeSecretaryNCSelection = 'No';
                LicenseTypeSelection = 'Associate Broker';
                this.application.Subscription_Type__c = 'Personal Assistant to Appraiser';
                this.SubscriptionId = '4';
                if (NonShareHolder != null)
                        this.application.Association_Board_Affiliation__c = NonShareHolder.Id;
                else
                        this.application.Association_Board_Affiliation__c = null;
        }
                if (Apexpages.currentPage().getParameters().get('id') != null && Apexpages.currentPage().getParameters().get('id') != '')
        {
                renderedAs = 'pdf';
                //Get all fields
                String fieldNames ='';
                for (String s: GetFieldNames('MRIS_Application__c'))
                {
                        fieldNames += s+',';
                }
                fieldNames = fieldNames.substring(0,fieldNames.length() - 1);                   
                //Get the Application Information for saved Id
                String query = 'SELECT '+fieldNames+' FROM MRIS_Application__c WHERE MRIS_Application__c.Id =\''+Apexpages.currentPage().getParameters().get('id')+'\'';
                this.application = Database.query(query);
                Account temp = [SELECT
                Account.Id,
                Account.Name
                FROM Account
                WHERE Account.Id =: this.application.Company_Code__c];
                this.BrokerCode = temp.Name;
                //Populate Company Information for printing
                LookupBrokerCode();
                //Populate Subscription Information for printing
                if (this.application.Agent_Subscription_ID__c != null)
                {
                        Subscriptions__c tempsub = [SELECT
                        Subscriptions__c.Id,
                        Subscriptions__c.Name,
                        Subscriptions__c.AgentKey__c
                        FROM Subscriptions__c
                        WHERE Subscriptions__c.Id =: this.application.Agent_Subscription_ID__c];
                        //JGP 11/30/2012 PDF Agent Information Incorrect Fix
                        //this.AppraiserCode = tempsub.AgentKey__c;
                        this.AppraiserCode = tempsub.Name;
                        LookupAppraiserCode();
                }
                Print = false;
               //SM Code Fix June 6 - License Display in PDF
                this.LicenseTypeSelection = this.application.License_Type__c;              
               // SM changes end                
                //Determine the Correct Radio Button Answers ect for printing
                if (this.application.Subscription_Type__c != null)
                {
                    //JGP 10/14/2012 Added in || this.application.Subscription_Type__c.toLowerCase().contains('licensee/non realtor') for correct print out
                        if (!this.application.Subscription_Type__c.toLowerCase().contains('realtor') || this.application.Subscription_Type__c.toLowerCase().contains('licensee/non realtor'))
                        {
                                RealtorSelection = 'No';
                                this.NonRealtorSelection = this.application.Subscription_Type__c;
                                
                        }
                }
                if (this.application.Association_Board_Affiliation__c != null)
                {
                        for (Account a:this.Associations)
                        {
                                if (a.Id == this.application.Association_Board_Affiliation__c)
                                {
                                        this.selectedAssociation = a.Account_Name__c;
                                        System.debug('selected association --> ' + this.selectedAssociation);
                                }
                        }
                }
        }
        else
        {
                setSubscription();
                renderedAs = 'html';
                Print = false;
        }
    }
    public String getRealtorSelection(){return this.RealtorSelection;}
    public void setRealtorSelection(String s){this.RealtorSelection = s;}
    public String getNonRealtorSelection(){return this.NonRealtorSelection;}
    public void setNonRealtorSelection(String s){this.NonRealtorSelection = s;}
    public String getOfficeSecretaryNCSelection(){return this.OfficeSecretaryNCSelection;}
    public void setOfficeSecretaryNCSelection(String s){this.OfficeSecretaryNCSelection = s;}
    public String getLicenseTypeSelection(){return this.LicenseTypeSelection;}
    public void setLicenseTypeSelection(String s){this.LicenseTypeSelection = s;} 
 
        public List<SelectOption> getNonRealtor()
        {
                List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption('','Please Select'));
                options.add(new SelectOption('Licensed Real Estate Agent','Licensed Real Estate Agent'));
                options.add(new SelectOption('Personal Assistant','Personal Assistant'));
                options.add(new SelectOption('Office Secretary','Office Secretary'));
                return options;
        }
    
    public List<SelectOption> getLicenseType()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Associate Broker','Associate Broker'));
        options.add(new SelectOption('Salesperson','Salesperson'));
        return options;
    }
    
    public List<SelectOption> getRealtor()
    {
        return new List<SelectOption>{new SelectOption('Yes','Yes'),new SelectOption('No','No')};
    }
    public List<SelectOption> getAssociations()
    {
        List<SelectOption> retval = new List<SelectOption>();
        for (Account a:Associations)
        {
                retval.add(new SelectOption(a.Account_Name__c,a.Account_Name__c));
        }
        retval = SortOptionList(retval);
        return retval;
    }
    public MRIS_Application__c getApplication(){return this.application;}
    public void setApplication(MRIS_Application__c app){this.application = app;}

    public Boolean getshowRealtor()
    {
        return this.RealtorSelection.toLowerCase() == 'yes';
    }
    public String getshortExpDate()
    {
        if (this.application.License_Expiration_Date__c != null)
        {
                return this.application.License_Expiration_Date__c.format();
        }
        else return null;
    }
    public Boolean getshowPDF(){return this.renderedAs == 'pdf';}
    public void setshowPDF(Boolean b){}
    
   
    
    public boolean getshowSecretaryQuestion()
    {
        return (this.NonRealtorSelection == 'Office Secretary');
    }
    public Boolean getshowPersonalAssistant()
    {
        return (this.NonRealtorSelection == 'Personal Assistant');
    }
    //JGP 10/18/2012 Corrected issue with the NonRealtorSelection - 
    // when retrieving this value from the database it's looking for the 'licensed real estate agent'
    // wording on the Subscription type, however it's saved as 'Licensee/Non Realtor' subscription type in
    // the database. Added the additional subscription type to the license show/printing criteria
    public Boolean getshowRealEstate()
    {
        return (this.NonRealtorSelection == 'Licensed Real Estate Agent' || this.RealtorSelection.toLowerCase() == 'yes' || this.NonRealtorSelection == 'Licensee/Non Realtor');
    }
    public Boolean getshowFooter()
    {
        return (this.NonRealtorSelection == 'Licensed Real Estate Agent' || this.RealtorSelection.toLowerCase() == 'yes');
    }
    public void setSubscription()
    {
        System.debug('Realtor Selection --> ' + RealtorSelection);  
        if (RealtorSelection == 'Yes')
        {
                Boolean shareHolder;
                integer rum = 0;
                for (Account a:this.Associations)
                {
                        System.debug('Account Name/Selected Assoc --> ' + a.Account_Name__c+'/'+this.selectedAssociation);
                        if (a.Account_Name__c == this.selectedAssociation)
                        {
                            shareholder = false; 
                            rum = 1;                     
                                System.debug('Shareholder Board? --> ' + a.Shareholder_Board__c);
                                if (a.Shareholder_Board__c == 'Yes')
                                {
                                        shareHolder = true;
                                        rum = 2;
                                        break;
                                }
                                else
                                {
                                        break;
                                        rum = 3;
                                }
                        }

                }
                if (shareHolder == true)
                {
                        this.application.Subscription_Type__c = 'Realtor/Shareholder';
                        this.application.Type__c  = 'Agent';
                        this.SubscriptionId = '10';
                }
                else
                {
                        this.application.Subscription_Type__c = 'Realtor/Non Shareholder';
                        this.SubscriptionId = '9';
                        this.application.Type__c  = 'Agent';
                        if (NonShareHolder != null)
                                this.application.Association_Board_Affiliation__c = NonShareHolder.Id;
                        else
                                this.application.Association_Board_Affiliation__c = null;
                }
        }
        else
        {
                if (NonRealtorSelection != '')
                {
                        if (NonRealtorSelection == 'Licensed Real Estate Agent')
                        {
                                this.application.Subscription_Type__c = 'Licensee/Non Realtor';
                                this.application.Type__c  = 'Agent';
                                this.SubscriptionId = '8';
                                if (NonShareHolder != null)
                                                this.application.Association_Board_Affiliation__c = NonShareHolder.Id;
                                        else
                                                this.application.Association_Board_Affiliation__c = null;
                        }
                        else if (NonRealtorSelection == 'Personal Assistant')
                        {
                                this.application.Subscription_Type__c = 'Personal Assistant';
                                this.SubscriptionId = '7';
                                this.application.Type__c  = 'Assistant';
                        }
                        else if (NonRealtorSelection == 'Office Secretary')
                        {
                                this.application.Type__c  = 'Staff';
                                if (OfficeSecretaryNCSelection == 'Yes')
                                {
                                        this.application.Subscription_Type__c = 'Office Secretary - NC';
                                        this.SubscriptionId = '6';
                                }
                                else
                                {
                                        this.application.Subscription_Type__c = 'Office Secretary';
                                        this.SubscriptionId = '5';
                                }
                        }
                }
        }
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Subscription Id: '+this.SubscriptionId));
    }
    public Pagereference LookupBrokerCode()
    {
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Code Entered: '+this.CompanyCode));
        //RAIN0001
        if (this.BrokerCode != '' && this.BrokerCode != null)
        {
                List<Account> companyLookup = new List<Account>();
                companyLookup = [SELECT
                Account.Id,
                Account.Account_Name__c,
                Account.Street_Name__c,
                Account.Street_Number__c, 
                Account.Street_Type__c,  
                Account.Street_Direction__c,              
                Account.City__c,
                Account.State__c,
                Account.County__c,
                Account.Zip__c,
                Account.BrokerAddress__c
                FROM Account
                WHERE Account.Name =: this.BrokerCode];
                if (companyLookup.size() > 0)
                {
                        this.application.Company_Code__c = companyLookup[0].Id;
                        
                        this.BrokerInfo = companyLookup[0];
                        //concatenation is not needed using formula field                                             
                            
                }
                else
                {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Code Not Found!'));
                        this.BrokerInfo = null;
                        this.application.Company_Code__c = null;
                }
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Code Id Found: '+this.application.Company_Code__c));
        }
        else
                this.BrokerInfo = null;
        return null;
    }
    public Pagereference LookupAppraiserCode()
    {
        if (this.AppraiserCode != '' && this.AppraiserCode != null)
        {
                        //See if the Appraiser is found Subscription.AgentKey
                        List<Subscriptions__c> sub = new List<Subscriptions__c>();
                        sub = [SELECT
                        Subscriptions__c.Id,
                        Subscriptions__c.Name,
                        Subscriptions__c.AgentKey__c,
                        Subscriptions__c.Contact__c,
                        Subscriptions__c.Contact__r.FirstName,
                        Subscriptions__c.Contact__r.LastName
                        FROM Subscriptions__c
                        WHERE Subscriptions__c.Name =: this.AppraiserCode and Subscriptions__c.Status__c='Active'
                            and Subscriptions__c.Contact_Type__c = 'Agent'];
                        if (sub.size() > 0)
                        {
                                Subscription = sub[0];
                                this.application.Agent_Subscription_ID__c = sub[0].Id;
                        }
                        else
                        {
                                Subscription = null;
                                this.application.Agent_Subscription_ID__c = null;
                        }
        }
        else
        {
                Subscription = null;
                this.application.Agent_Subscription_ID__c = null;
        }
        return null;
    }
    public String getAppraiserName()
    {
        if (this.Subscription != null)
        {
                return (this.Subscription.Contact__r.FirstName +' '+this.Subscription.Contact__r.LastName);
        }
        else return null;
    }
    public void setAppraiserName(String s){}
    public Pagereference Save()
    {
            try
        {
                if (NonRealtorSelection == 'Licensed Real Estate Agent' || this.RealtorSelection.toLowerCase() == 'yes')
                {
                        //Create License Expiration
                        Integer month = 0;
                        if (application.Date_Expires_Month__c != null && application.Date_Expires_Month__c != '')
                        {
                                if (application.Date_Expires_Month__c.toLowerCase().contains('jan'))
                                {
                                        month = 1;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('feb'))
                                {
                                        month = 2;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('mar'))
                                {
                                        month = 3;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('apr'))
                                {
                                        month = 4;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('may'))
                                {
                                        month = 5;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('june'))
                                {
                                        month = 6;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('july'))
                                {
                                        month = 7;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('aug'))
                                {
                                        month = 8;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('sept'))
                                {
                                        month = 9;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('oct'))
                                {
                                        month = 10;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('nov'))
                                {
                                        month = 11;
                                }
                                else if (application.Date_Expires_Month__c.toLowerCase().contains('dec'))
                                {
                                        month = 12;
                                }
                        }
                        
                        if (this.application.Date_Expires_Year__c != null && this.application.Date_Expires_Year__c != '')
                                this.application.License_Expiration_Date__c = date.parse(month+'/1/'+this.application.Date_Expires_Year__c);
                        this.application.License_Type__c = LicenseTypeSelection;
                        
                }
                if (this.selectedAssociation != '')
                {
                        //Find the Account so we can save it to the record
                        for (Account a:this.Associations)
                        {
                                if (a.Account_Name__c == this.selectedAssociation)
                                {
                                        this.application.Association_Board_Affiliation__c = a.Id;
                                        break;
                                }
                        }
                }
            this.application.Status__c = 'Reinstatement';
            insert(this.application);
            MRISApplicationCase.Create(this.application);
            Print = true;
            return null;            
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops! '+e.getMessage()+ ' ' + e.getStackTraceString()));
            return null;
        }
     }
     public Pagereference Print()
     {
        try
        {
            Pagereference page = ApexPages.currentPage();
            page.getParameters().put('id',this.application.Id);
            page.setRedirect(true);
            return page;            
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops! '+e.getMessage()+ ' ' + e.getStackTraceString()));
            return null;
        }
     }
     private List<String> GetFieldNames(String objectname)
     {
        List<String> retval = new List<String>();
        //Use GlobalDescribe to get a list of all available Objects
        Map<String,Schema.Sobjecttype> gd = Schema.getGlobalDescribe();
        Set<String> objectKeys = gd.keySet();
        for (String objectKey:objectKeys) //Iterate through all of the objects until we get to the one we need
        {
                if (objectKey == objectname.toLowerCase()) //Object exists, get field names
            {
                Schema.SObjectType systemObjectType = gd.get(objectKey);
                Schema.DescribeSObjectResult r = systemObjectType.getDescribe();
                Map<String, Schema.SObjectField> M = r.fields.getMap();
                Set <String>fieldNames = M.keySet();
                fields = new Map<String,Schema.SObjectField>();
                //Create a copy of the Map with the Display Name, and Properties for retreival in the Selection
                for (String fieldName:fieldNames)
                {
                        //For each field, Add to List
                    Schema.SObjectField field = M.get(fieldName);
                    Schema.DescribeFieldResult fieldDesc = field.getDescribe();                                     
                    //retval.add(fieldDesc.getLabel()); //Adds the Salesforce UI label to listing
                    retval.add(fieldDesc.getName()); //Adds the Salesforce UI label to listing
                    fields.put(fieldDesc.getLabel(),field);
                }
             }
         }                               
         return retval;
        }
    public static List<SelectOption> SortOptionList(List<SelectOption> ListToSort)
    {
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();
        integer pivot = ListToSort.size() / 2;
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        for(SelectOption x : ListToSort)
        {
            if(x.getLabel() <= pivotValue.getLabel())
                Less.add(x);
            else if(x.getLabel() > pivotValue.getLabel()) Greater.add(x);   
        }
        List<SelectOption> returnList = new List<SelectOption> ();
        returnList.addAll(SortOptionList(Less));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(Greater));
        return returnList; 
    }
        public class myException extends Exception{}
        

        public static Id FindReinstatementRecordType()
        {
                List<RecordType> rt = [select Id from RecordType where SobjectType = 'MRIS_Application__c' and IsActive = true and DeveloperName = 'MRIS_Reinstatement_Application' limit 1];
                if(rt.size() == 0) return '';
                return rt.get(0).Id;
        }
       
}