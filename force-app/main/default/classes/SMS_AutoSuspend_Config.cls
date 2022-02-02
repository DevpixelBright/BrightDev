public with sharing class SMS_AutoSuspend_Config {
   
    public String maximumAccounts { get; set; }
    public String amount { get; set; }
    public String days { get; set; }
    
    public Boolean isActive { get; set; }
    public String scheduleTime { get; set; }
    //public String includedServiceJurisdiction { get; set;}
    public String includedBillingJurisdiction { get; set;}
    
    public String scheduleHour { get; set; }
    public String scheduleMinute { get; set; }
    public String scheduleMeridiem { get; set; } 
    
    public List<String> leftSelectedBJs {get; set;}    
    public List<String> rightSelectedBJs { get; set;}
    public List<SelectOption> leftBJOptions{get; set;}
    public List<SelectOption> rightBJOptions{ get; set;}        
        
    //public List<String> leftSelectedSJs {get; set;}    
    //public List<String> rightSelectedSJs { get; set;}
    //public List<SelectOption> leftSJOptions{get; set;}   
    //public List<SelectOption> rightSJOptions{ get; set;}
    
    public integer picklistlength {get; set;}
    public List<AutoSuspendConfig> autoSuspendConfigs { get; set; }
    public SMS_AutoSuspend_Config__c editAutoSuspendConfig { get; set; }
    public Set<String> zSuspendAccountIds { get; set; }
    
    public Boolean isEdit { get; set; }
    public Boolean isEditSetting { get; set; }
    public Boolean isNotEdit { get; set; }
    public Boolean isResult { get; set; }
    public String editConfigId { get; set; }
    
    
    public List<SelectOption> hour { 
        get{
            List<SelectOption> options = new List<SelectOption>();
            
            for(Integer i = 0;i<13;i++){
                String k = String.ValueOf(i);
                if(k.length() != 2)
                    k = '0' + k;
                options.add(new SelectOption(k,k));
            }
            return options;
        } private set; }
    public List<SelectOption> minute { 
        get{
            List<SelectOption> options = new List<SelectOption>();
            
            for(Integer i = 0;i<60;i++){
                String k = String.ValueOf(i);
                if(k.length() != 2)
                    k = '0' + k;
                options.add(new SelectOption(k,k));
            }
            return options;
        } set; 
    }
    public List<SelectOption> meridiem { 
        get{
            List<SelectOption> options = new List<SelectOption>();             
            options.add(new SelectOption('AM','AM'));
            options.add(new SelectOption('PM','PM'));            
            return options;
        } set; 
    }
    

    public SMS_AutoSuspend_Config() {
        autoSuspendConfigs = new List<AutoSuspendConfig>();
        editAutoSuspendConfig = new SMS_AutoSuspend_Config__c();
        
        setConfigs();
        isEdit = false; 
        isEditSetting = false;
        isNotEdit = true;
        isResult = false;
        leftSelectedBJs = new List<String>();
        rightSelectedBJs = new List<String>();
        
    }
            
    /*
    public void selectSJClick(){
        system.debug('--sel sj click leftSelectedSJs--'+leftSelectedSJs);
        if(leftSelectedSJs.size() > 0){
           
            for(String SJ : leftSelectedSJs){
                 system.debug('--SJ--'+SJ);
                rightSJOptions.add(new SelectOption(SJ, SJ));                
                Integer i = leftSJOptions.indexOf(new SelectOption(SJ, SJ));
                if(i != -1)
                    leftSJOptions.remove(i);      
            }
        }
        rightSJOptions.sort();
        leftSJOptions.sort();
        leftSelectedSJs = new List<String>();
        rightSelectedSJs = new List<String>();
    }
    public void unselectSJclick(){
        
        system.debug('--sel sj click leftSelectedSJs--'+leftSelectedSJs);
        if(rightSelectedSJs.size() > 0){
           
            for(String SJ : rightSelectedSJs){
                 system.debug('--SJ--'+SJ);
                leftSJOptions.add(new SelectOption(SJ, SJ));                
                Integer i = rightSJOptions.indexOf(new SelectOption(SJ, SJ));
                if(i != -1)
                    rightSJOptions.remove(i);      
            }
        }
        rightSJOptions.sort();
        leftSJOptions.sort();
    }
    */
    
    public void selectBJClick(){
        
        system.debug('--sel Bj click leftSelectedBJs--'+leftSelectedBJs);
        if(leftSelectedBJs.size() > 0){
           
            for(String BJ : leftSelectedBJs){
                 system.debug('--BJ--'+BJ);
                rightBJOptions.add(new SelectOption(BJ, BJ));                
                Integer i = leftBJOptions.indexOf(new SelectOption(BJ, BJ));
                if(i != -1)
                    leftBJOptions.remove(i);      
            }
        }
        rightBJOptions.sort();
        leftBJOptions.sort();
        leftSelectedBJs = new List<String>();
        rightSelectedBJs = new List<String>();
    }
    public void unselectBJclick(){
        
        system.debug('--sel Bj click leftSelectedBJs--'+leftSelectedBJs);
        if(rightSelectedBJs.size() > 0){
           
            for(String BJ : rightSelectedBJs){
                 system.debug('--BJ--'+BJ);
                leftBJOptions.add(new SelectOption(BJ, BJ));                
                Integer i = rightBJOptions.indexOf(new SelectOption(BJ, BJ));
                if(i != -1)
                    rightBJOptions.remove(i);      
            }
        }
        rightBJOptions.sort();
        leftBJOptions.sort();
        leftSelectedBJs = new List<String>();
        rightSelectedBJs = new List<String>();
    }
    
    
    public PageReference editSetting() {
        isEditSetting = true;
        isNotEdit = false;
        return null;
    }
    
    public PageReference saveSetting() {
        SMS_AutoSuspend_Status__c setting = SMS_AutoSuspend_Status__c.getValues('Auto Suspend');
        
        if(scheduleHour.length() != 2)
            scheduleHour = '0' + scheduleHour ;
        if(scheduleMinute.length() != 2)
            scheduleMinute = '0' + scheduleMinute ; 
         
        
        if((setting.Schedule_Time__c != scheduleHour + ':' + scheduleMinute + scheduleMeridiem)) {
            setting.Schedule_Time__c = scheduleHour + ':' + scheduleMinute + scheduleMeridiem;
            
            List<CronTrigger> scheduledAutoSuspend  = [SELECT Id, OwnerId, CronExpression 
                                                       FROM   CronTrigger 
                                                       WHERE  CronExpression like '% AutoSuspend'];
                                                  
            for(CronTrigger cron : scheduledAutoSuspend)
                System.abortJob(cron.id);
                
            if(scheduleMeridiem == 'PM' && scheduleHour != '12') 
                scheduleHour = String.ValueOf(Integer.ValueOf(scheduleHour)  + 12);
                
            if(scheduleMeridiem == 'AM' && scheduleHour == '12')
                scheduleHour = '00';
                
            system.debug('*** Hour : ' + scheduleHour + ' - minute : ' + scheduleMinute);
            String scheduleTime = '0 ' + scheduleMinute + ' ' + scheduleHour + ' ? * MON,TUE,WED,THUR,FRI * AutoSuspend';
            system.debug('*** scheduleTime : ' + scheduleTime );
            System.schedule(scheduleTime , scheduleTime , new SMS_ScheduleAutoSuspend());
        }
        
        setting.IsActive__c = isActive ;
        
        
        /*
        includedServiceJurisdiction = null ;
        for(SelectOption SJ : rightSJOptions){
            if(String.isNotBlank(includedServiceJurisdiction))
                includedServiceJurisdiction = includedServiceJurisdiction + ',';
            includedServiceJurisdiction = includedServiceJurisdiction + SJ.getValue();  
        }
        */
        
        includedBillingJurisdiction = null ;
        system.debug('---rightBJOptions--->'+rightBJOptions);
        for(SelectOption BJ : rightBJOptions){
            if(String.isNotBlank(includedBillingJurisdiction))
                includedBillingJurisdiction = includedBillingJurisdiction + ',';
            includedBillingJurisdiction = includedBillingJurisdiction + BJ.getValue();  
        }
        //setting.ExcludedServiceJurisdictions__c = includedServiceJurisdiction.removeStart('null');
        if(includedBillingJurisdiction != null)
        setting.IncludedBillingJurisdictions__c = includedBillingJurisdiction.removeStart('null');
        system.debug('Settings: ' +  setting);
        
        
        update setting;
        setConfigs();
        isEditSetting = false;
        isNotEdit = true; 
        return null;
    }
    
    public PageReference editConfig() {
        system.debug('*** editConfigId : ' + editConfigId);
        editAutoSuspendConfig = [SELECT id,
                                        Day_of_Week__c,IsSuspend__c,
                                        Threshold_Accounts__c,
                                        Threshold_Amount__c,
                                        Threshold_Days__c 
                                 FROM   SMS_AutoSuspend_Config__c 
                                 WHERE id = :editConfigId];
        isEdit = true;
        isNotEdit = false;
        isResult = false;
        return null;
    }
    
    public PageReference saveConfig() {
        system.debug('---editAutoSuspendConfig-->'+editAutoSuspendConfig);
        update editAutoSuspendConfig;
        setConfigs();
        isEdit = false;
        isNotEdit = true;
        isResult = false;
        return null;
    }
    
    public PageReference cancel() {
        isEdit = false;
        isEditSetting = false; 
        isNotEdit = true;
        isResult = false;
        maximumAccounts = null;
        amount = null;
        days = null;
        setConfigs();     
        return null;
    }
    
    public PageReference runAutoSuspension() {
        if(String.isNotBlank(days) && String.isNotBlank(amount) && String.isNotBlank(maximumAccounts)) {
              SMS_SuspendAccounts_Zuora.suspendAccounts(maximumAccounts, amount, days);
             
             isResult = true;
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Ad hoc Auto Suspension run is initiated'));
             /*maximumAccounts = null;
             amount = null;
             days = null;*/cancel();
        }            
        else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter all the three Threshold Values'));
        }   
        
        return null;
    }
    
    private void setConfigs() {
        autoSuspendConfigs.clear();
        for(SMS_AutoSuspend_Config__c config : [SELECT id,Day_of_Week__c,IsSuspend__c,Threshold_Accounts__c,Threshold_Amount__c,Threshold_Days__c FROM  SMS_AutoSuspend_Config__c ORDER BY Name]) {
            AutoSuspendConfig temp = new AutoSuspendConfig();
            temp.autoSuspendConfig = config;
            temp.edit = 'Edit';
            autoSuspendConfigs.add(temp);            
        }
        
        isActive = SMS_AutoSuspend_Status__c.getValues('Auto Suspend').IsActive__c; 
        scheduleHour  =  SMS_AutoSuspend_Status__c.getValues('Auto Suspend').Schedule_Time__c.substring(0,2); 
        scheduleMinute =  SMS_AutoSuspend_Status__c.getValues('Auto Suspend').Schedule_Time__c.substring(3,5); 
        scheduleMeridiem =  SMS_AutoSuspend_Status__c.getValues('Auto Suspend').Schedule_Time__c.substring(5,7);
        
        includedBillingJurisdiction = SMS_AutoSuspend_Status__c.getValues('Auto Suspend').IncludedBillingJurisdictions__c;
        rightSelectedBJs = new List<String>();
        if(includedBillingJurisdiction != null)
        	rightSelectedBJs.addAll(includedBillingJurisdiction.split(','));
        
               
        /*
        includedServiceJurisdiction = SMS_AutoSuspend_Status__c.getValues('Auto Suspend').ExcludedServiceJurisdictions__c;
        rightSelectedSJs = new List<String>();
        if(includedServiceJurisdiction != null)
        	rightSelectedSJs.addAll(includedServiceJurisdiction.split(','));

		Schema.DescribeFieldResult SJfield = Subscriptions__c.Service_Jurisdiction__c.getDescribe();
        List<Schema.PicklistEntry> SJvalues = SJfield.getPicklistValues();        
        rightSJOptions = new List<SelectOption>(); 
        leftSJOptions = new List<SelectOption>(); 
        for(Schema.PicklistEntry e : SJvalues) {
            String SJ = e.getValue();
            if(rightSelectedSJs.contains(SJ))
                rightSJOptions.add(new SelectOption(e.getValue(), e.getValue()));
            else
                leftSJOptions.add(new SelectOption(e.getValue(), e.getValue()));
        }
        */
        
        Schema.DescribeFieldResult BJfield = Subscriptions__c.Billing_Jurisdiction__c.getDescribe();
        List<Schema.PicklistEntry> BJvalues = BJfield.getPicklistValues();
        rightBJOptions = new List<SelectOption>(); 
        leftBJOptions = new List<SelectOption>();
        picklistlength = BJvalues.size();
        for(Schema.PicklistEntry e : BJvalues) {
            String BJ = e.getValue();
            if(rightSelectedBJs.contains(BJ))
                rightBJOptions.add(new SelectOption(e.getValue(), e.getValue()));
            else
                leftBJOptions.add(new SelectOption(e.getValue(), e.getValue()));
        }
        rightBJOptions.sort();
        leftBJOptions.sort();
        leftSelectedBJs = new List<String>();
        rightSelectedBJs = new List<String>();
        
    }
    
    public class AutoSuspendConfig {
        public SMS_AutoSuspend_Config__c autoSuspendConfig { get; set; }
        public String edit { get; set; }
    }
}