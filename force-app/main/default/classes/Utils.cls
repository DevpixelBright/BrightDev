/**
* @author: klanka@rainamker-llc.com
* @date:  2012-05-01
* Utility class
**/
public with sharing class Utils {
    
    
    /**
    *  This is a utility method to check for null values
    * @param s String
    * @return boolean true is null otherwise false
    */
    public static boolean isNull(String s){
        if (null == s || 'null'.equalsIgnoreCase(s) || ''.equals(s)) {
            return true;
        }
        return false; 
    }
    
    /**
    *  This is a utility method to check for null values
    * @param s String
    * @return boolean false is null otherwise true
    */
    public static boolean isNotNull(String s){
        return !isNull(s);
    }
    
    public static boolean isValidBoolean(String s){
        if ('true'.equals(s) || 'false'.equals(s)){
            return true;
        } 
        return false;
    }
    
    /**
    *  Generate random numbers
    *  @return Long - a random number
    **/
    public static Long getRandomNumber(){
        return System.currentTimeMillis() + (Long) (Math.random() * 1000000000) ;
    }
    
    public static String convertDateTimeToISOFormat(Datetime dt) {
        String strDt =  dt.format('yyyy-MM-dd HH:mm:ss');
        return strDt.replace(' ', 'T');
    }
    
    public static String decimalToString(Decimal d){
        String s = '' + d;
                    if (s.contains('.0')){
                        s = s.substring(0,s.indexOf('.0'));
                    }
                    
                    return s;
    }
    
    public static String splitByDigits(String s) {
        
        
         s = s.replaceFirst('(?=\\d)', ',');
        if (s.length() > 0) {
            if (','.equals(s.substring(0, 1))) {
                s = s.substring(1);
            }
        }
        return s;
       
        //return s.replaceFirst('(?=\\d)', ',');
    }
    //JGP 12/18/2012 Addition of Static Custom Setting Read to prevent multiple calls from several triggers
    // attempting to retrieve this custom setting information
    
    // For anyone who comes along in the future, this code is bad for three reasons:
    // a) the static property is unnecessary because Salesforce will cache custom settings internally. Every getInstance() doesn't necessarily generate a SOQL call. 
    // b) if you try to manipulate the value of the custom setting in code during a transaction, this unnecessary "caching" will screw you up.
    // c) grabbing the setting at the profile level makes no sense. You should pretty much always call getInstance() and let SFDC find you the best settings.
    private static Boolean BypassResult{get;set;}
    public static Boolean BypassValidationrules()
    {
        
        if (BypassResult == null)
        {
            System.debug('Fetching Bypass Validation Rules from database, SOQL Call');
            Bypass_Validation_rules__c bypass = Bypass_Validation_rules__c.getInstance(UserInfo.getProfileId());
            if (bypass != null && bypass.Disable_Validation_Rules__c )
            {
                    BypassResult = true;
            }
            else
                BypassResult = false;
        }
    
        return BypassResult;
    }
    
    
    // this will grab the value correctly
    public static Boolean DisableAllTriggers {
        get {
            Bypass_Validation_rules__c bypass = Bypass_Validation_rules__c.getInstance();
            return bypass.Disable_Validation_Rules__c;
        }
    }
        
    public static Boolean ByPassPersonAccounts(List<Account> accounts) {
        List<Account> businessAccounts = new List<Account>();
   
        for(Account sAccount : accounts) {
        if(!sAccount.IsPersonAccount)
            businessAccounts.add(sAccount);
        }
        
        if(businessAccounts.size() == 0) {
            system.debug('*** ByPassPersonAccounts - true');
            return true;
        }
        else {
            system.debug('*** ByPassPersonAccounts - false');
            return false;
        }
            
        /*
        //Commented for testing purposes
        // Code to byPass only Zuora Integration Person Accounts
        List<RecordType> personRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Zuora Integration Account'];
        List<Account> businessAccounts = new List<Account>();
   
        for(Account sAccount : accounts) {
        if(sAccount.RecordTypeId != personRecordType[0].id)
            businessAccounts.add(sAccount);
        }
        
        if(businessAccounts.size() == 0) {
            system.debug('*** ByPassPersonAccounts - true');
            return true;
            }
        else {
            system.debug('*** ByPassPersonAccounts - false');
            return false;
            }
        */
    }
    
    
    
        public static Boolean ByPassDataManagementAccounts(List<Account> accounts) {
        List<RecordType> AccountRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Data Management'];
        ID AccountRecTypeId = AccountRecordType[0].id;
        List<Account> NotDataManagementAccounts = new List<Account>();
   
        for(Account sAccount : accounts) {
        if(sAccount.RecordTypeId != AccountRecTypeId )
            NotDataManagementAccounts.add(sAccount);
        }
        
        if(NotDataManagementAccounts.size() == 0) {
            system.debug('*** ByPassDataManagementAccounts - true');
            return true;
        }
        else {
            system.debug('*** ByPassDataManagementAccounts - false');
            return false;
        }
            
        
    }
    @isTest
    static void testNull() {
        String s;
        System.assert(Utils.isNull(s));
        System.assert(!Utils.isNotNull(s));
        s = 'true';
        System.assert(!Utils.isNull(s));
        System.assert(Utils.isNotNull(s));
        
        System.assert(Utils.isValidBoolean(s));
        
        s = 't';
        System.assert(!Utils.isValidBoolean(s));
        
        Long num = Utils.getRandomNumber();
        
    }
    
    @isTest
    static void testDatetime() {
        System.assert(Utils.isNotNull(Utils.convertDateTimeToISOFormat(DateTime.now())));
    }
    
      @isTest
    static void testSplitDigits() {
        System.assert('1234'.equals(Utils.splitByDigits('1234')));
        System.assert('FD,1234'.equals(Utils.splitByDigits('FD1234')));
    }
    
    @isTest
    static void getBypassValidationStatus()
    {
        BypassValidationrules();
    }

}