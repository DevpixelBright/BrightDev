public class VendorCommunity_ManageVendor{

    public String id { get; private set; }
    public Boolean initialLoad { get; private set; }
    public Boolean hasError { get; private set; }
    public String cancelUrl { get; private set; }

    public Boolean debugMode { get; private set; }
    public Boolean isBrightLogin { get; set; }

    public List<AccountData> lstaccountsData { get; set; }
    public string vendorId {get; set;}
    public VendorCommunity_ManageVendor() {
        initialLoad = true;

        String debug = ApexPages.currentPage().getParameters().get('debug');
        
        debugMode = String.IsNotBlank(debug) && Boolean.valueOf(debug);
        
        isBrightLogin = true;
    }
    
    public void loadAccounts() {
        initialLoad = false;
        hasError = false;

        try {
            this.lstAccountsData = new List<accountData>();

            List<User> currentUser = [SELECT   FederationIdentifier, contactId, Contact.Name 
                                        FROM     User 
                                        WHERE    Id = :Userinfo.getUserId()
                                        ];
                   
            if (currentUser.size() == 0)
                throw new CustomException('Invalid Vendor ID: No Current User found >> ' + Userinfo.getUserId()); 

                        
            List<Contact> userContact = [SELECT  Id, Name, Account.Name
                                            FROM    Contact
                                            WHERE   Id =: currentUser[0].ContactId 
                                            And Status__c = 'Active' 
                                            And Account.Status__c = 'Active'
                                            And Account.Type = 'RETS'
                                            ];
        
        if (userContact.size() == 0) return;
        vendorId = userContact[0].Account.Name;
            List<String> categories = new List<String> {
                'contact_information',
                'product_line',
                'VendorCommunity_PaymentMethods',
                'VendorCommunity_Paybalances',
                'vendor_invoices',
                 //, 'Listing_Transfer'
                'office_information'
                //,'reconciliation_files'
                    
            };
            if(isBrightLogin)
                categories.add('mls_settings');
            
            for (String category : categories) {
                accountData accountDataObj = new accountData();
                accountDataObj.Category = category;
                accountDataObj.Id = userContact[0].Account.Name;
                accountDataObj.displayText = userContact[0].Account.Name;
                this.lstaccountsData.add(accountDataObj);              
            }
                
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));     
            hasError = true;
        }
    }

    public class AccountData {
        public String Category { get; set; }
        public String Id { get; set; }
        public String displayText { get; set; }
    }
    
    private void log(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }
        
    public class CustomException extends Exception {}
}