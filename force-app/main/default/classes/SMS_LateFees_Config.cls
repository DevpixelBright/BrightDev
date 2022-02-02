public with sharing class SMS_LateFees_Config {
   
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
    
    public List<String> selectedBJs {get; set;}
    public List<SelectOption> selectedBJOptions { get; set;}
    public List<String> notSelectedBJs {get; set;}
    public List<SelectOption> notSelectedBJOptions { get; set;}
    
    
    //public List<String> selectedSJs { get; set;}
    //public List<SelectOption> selectedSJOptions { get; set;}
    //public List<String> notSelectedSJs { get; set;}
    //public List<SelectOption> notSelectedSJOptions { get; set;} 
    
    public List<LateFeesConfig> LateFeesConfigs { get; set; }
    public SMS_Late_Fees_Config__c editLateFeesConfig { get; set; }
    
    public Boolean isEdit { get; set; }
    public Boolean isEditSetting { get; set; }
    public Boolean isNotEdit { get; set; }
    public String editConfigId { get; set; }
    private String zLateFeeProductName;
    public integer picklistlength {get; set;}
    
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
        }  set; }
        
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
        } set; }
        
    public List<SelectOption> meridiem { 
        get{
            List<SelectOption> options = new List<SelectOption>();             
            options.add(new SelectOption('AM','AM'));
            options.add(new SelectOption('PM','PM'));            
            return options;
        } set; }    
        
    
    public SMS_LateFees_Config() {
        LateFeesConfigs = new List<LateFeesConfig>();
        editLateFeesConfig = new SMS_Late_Fees_Config__c();
        zLateFeeProductName = SMS_LateFees_Status__c.getall().values()[0].Name;
        
        setConfigs();
        isEdit = false; 
        isEditSetting = false;
        isNotEdit = true;        
    }
    
    public PageReference editSetting() {
        isEditSetting = true;
        isNotEdit = false;
        return null;
    }
    
    public PageReference saveSetting() {
        SMS_LateFees_Status__c setting = SMS_LateFees_Status__c.getValues(zLateFeeProductName);         
        
        if(scheduleHour.length() != 2)
            scheduleHour = '0' + scheduleHour ;
        if(scheduleMinute.length() != 2)
            scheduleMinute = '0' + scheduleMinute ; 
                
                   
         if(setting.IsActive__c != isActive || (setting.Schedule_Time__c != scheduleHour + ':' + scheduleMinute + scheduleMeridiem)) {
            setting.Schedule_Time__c = scheduleHour + ':' + scheduleMinute + scheduleMeridiem;
            
            List<CronTrigger> scheduledLateFees  = [SELECT Id, OwnerId, CronExpression 
                                                    FROM   CronTrigger 
                                                    WHERE  CronExpression like '% LateFees'
                                                   ];
                                                  
            for(CronTrigger cron : scheduledLateFees)
                System.abortJob(cron.id);
                
            if(scheduleMeridiem == 'PM' && scheduleHour != '12') 
                scheduleHour = String.ValueOf(Integer.ValueOf(scheduleHour)  + 12);
                
            if(scheduleMeridiem == 'AM' && scheduleHour == '12')
                scheduleHour = '00';
                
            system.debug('*** Hour : ' + scheduleHour + ' - minute : ' + scheduleMinute);
            String scheduleTime = '0 ' + scheduleMinute + ' ' + scheduleHour + ' ? * MON,TUE,WED,THUR,FRI * LateFees';
            system.debug('*** scheduleTime : ' + scheduleTime );
            System.schedule(scheduleTime , scheduleTime , new SMS_LateFees_Schedule());
        }
        
        setting.IsActive__c = isActive;
        
        /*
        includedServiceJurisdiction = null;
        for(SelectOption SJ : selectedSJOptions){
            if(String.isNotBlank(includedServiceJurisdiction))
                includedServiceJurisdiction = includedServiceJurisdiction + ',';
            includedServiceJurisdiction = includedServiceJurisdiction + SJ.getValue();  
        }
		
		if(includedServiceJurisdiction != null)
        setting.IncludedServiceJurisdictions__c = includedServiceJurisdiction.removeStart('null');
        */
        
        includedBillingJurisdiction = null;
        for(SelectOption BJ : selectedBJOptions){
            if(String.isNotBlank(includedBillingJurisdiction))
                includedBillingJurisdiction = includedBillingJurisdiction + ',';
            includedBillingJurisdiction = includedBillingJurisdiction + BJ.getValue();  
        }        
        
        if(includedBillingJurisdiction != null)
        setting.IncludedBillingJurisdictions__c = includedBillingJurisdiction.removeStart('null');
        system.debug('Settings: ' +  setting);
        update setting;
        
        setConfigs();
        isEditSetting = false;
        isNotEdit = true; 
        return null;
    }
    
    /*
    public void addSJ(){
        if(notSelectedSJs.size() > 0){              
            for(String SJ : notSelectedSJs){
                selectedSJOptions.add(new SelectOption(SJ, SJ));                
                Integer i = notSelectedSJOptions.indexOf(new SelectOption(SJ, SJ));
                if(i != -1)
                    notSelectedSJOptions.remove(i);      
            }
        }
        selectedSJOptions.sort();
        notSelectedSJOptions.sort();
        selectedSJs = new List<String>();
        notSelectedSJs = new List<String>();  
    }
    
    public void removeSJ(){
        if(selectedSJs.size() > 0){             
            for(String SJ : selectedSJs){
                notSelectedSJOptions.add(new SelectOption(SJ, SJ));
                Integer i = selectedSJOptions.indexOf(new SelectOption(SJ, SJ));
                if(i != -1)
                    selectedSJOptions.remove(i);      
            }
        }
        selectedSJOptions.sort();
        notSelectedSJOptions.sort();
        selectedSJs = new List<String>();
        notSelectedSJs = new List<String>();
    }
    */
    
    public void addBJ(){
        if(notSelectedBJs.size() > 0){              
            for(String BJ : notSelectedBJs){
                selectedBJOptions.add(new SelectOption(BJ, BJ)); 
                Integer i = notSelectedBJOptions.indexOf(new SelectOption(BJ, BJ));
                if(i != -1)
                    notSelectedBJOptions.remove(i); 
            }
        }
        selectedBJOptions.sort();
        notSelectedBJOptions.sort();
        selectedBJs = new List<String>();
        notSelectedBJs = new List<String>();     
    }
    public void removeBJ(){
        if(selectedBJs.size() > 0){             
            for(String BJ : selectedBJs){
                notSelectedBJOptions.add(new SelectOption(BJ, BJ));
                Integer i = selectedBJOptions.indexOf(new SelectOption(BJ, BJ));
                if(i != -1)
                    selectedBJOptions.remove(i);        
            }
        }
        selectedBJOptions.sort();
        notSelectedBJOptions.sort();
        selectedBJs = new List<String>();
        notSelectedBJs = new List<String>();   
    }
    
    public PageReference editConfig() {
        system.debug('*** editConfigId : ' + editConfigId);
        editLateFeesConfig = [SELECT id,
                                     Day_of_Week__c,Is_Active__c,
                                     Threshold_Accounts__c,
                                     Threshold_Amount__c,
                                     Threshold_Days__c 
                              FROM   SMS_Late_Fees_Config__c 
                              WHERE  id = :editConfigId];
        isEdit = true;
        isNotEdit = false;
        return null; 
    }
    
    public PageReference saveConfig() {
        update editLateFeesConfig;
        setConfigs();
        isEdit = false;
        isNotEdit = true;
        return null;
    }
    
    public PageReference cancel() {
        isEdit = false;
        isEditSetting = false; 
        isNotEdit = true;
        maximumAccounts = null;
        amount = null;
        days = null;
        setConfigs();     
        return null;
    }
    
    public PageReference runLateFeesAssessment() {
        if(String.isNotBlank(days) && String.isNotBlank(amount) && String.isNotBlank(maximumAccounts)) {
             /*
             List<Zuora__CustomerAccount__c> lateFeeExpiredBillAccs = new List<Zuora__CustomerAccount__c>();
             Date expiryDate = Date.today().addDays(-Integer.ValueOf(days));
             
             for(Zuora__CustomerAccount__c lateFeeExpired : [SELECT id,Name,LateFees_ChargeDate__c
                                                             FROM   Zuora__CustomerAccount__c
                                                             WHERE  LateFees_ChargeDate__c < :expiryDate                                       
                                                            ]){
                 lateFeeExpired.LateFees_ChargeDate__c = null;
                 lateFeeExpiredBillAccs.add(lateFeeExpired);
             } 
             update lateFeeExpiredBillAccs;*/
             system.debug('*** maximumAccounts : ' + maximumAccounts + '*** amount :' + amount + '*** days :' + days );
             Database.executeBatch(new SMS_LateFees_Zuora(maximumAccounts, amount, days),5);
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Ad hoc Late Fees Assessment run is initiated'));
             cancel();

        }            
        else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Enter all the three Threshold Values'));
        }   
        
        return null;
    }
    
    private void setConfigs() {
        LateFeesConfigs.clear();
        for(SMS_Late_Fees_Config__c config : [SELECT id,Day_of_Week__c,Is_Active__c,Threshold_Accounts__c,Threshold_Amount__c,Threshold_Days__c FROM  SMS_Late_Fees_Config__c ORDER BY Name]) {
            LateFeesConfig temp = new LateFeesConfig();
            temp.LateFeesConfig = config;
            temp.edit = 'Edit';
            LateFeesConfigs.add(temp);            
        }
         
        
        isActive = SMS_LateFees_Status__c.getValues(zLateFeeProductName).IsActive__c;        
        scheduleHour  =  SMS_LateFees_Status__c.getValues(zLateFeeProductName).Schedule_Time__c.substring(0,2); 
        scheduleMinute =  SMS_LateFees_Status__c.getValues(zLateFeeProductName).Schedule_Time__c.substring(3,5); 
        scheduleMeridiem =  SMS_LateFees_Status__c.getValues(zLateFeeProductName).Schedule_Time__c.substring(5,7);
        
         /*
        includedServiceJurisdiction = SMS_LateFees_Status__c.getValues(zLateFeeProductName).IncludedServiceJurisdictions__c;
        selectedSJs = new List<String>();
        if(includedServiceJurisdiction != null)
        selectedSJs.addAll(includedServiceJurisdiction.split(','));
        notSelectedSJs = new List<String>(); 
       
        Schema.DescribeFieldResult SJfield = Subscriptions__c.Service_Jurisdiction__c.getDescribe();
        List<Schema.PicklistEntry> SJvalues = SJfield.getPicklistValues();        
        selectedSJOptions = new List<SelectOption>(); 
        notSelectedSJOptions = new List<SelectOption>(); 
        for(Schema.PicklistEntry e : SJvalues) {
            String SJ = e.getValue();
            if(selectedSJs.contains(SJ))
                selectedSJOptions.add(new SelectOption(e.getValue(), e.getValue()));
            else
                notSelectedSJOptions.add(new SelectOption(e.getValue(), e.getValue()));
        }
        */
        
        includedBillingJurisdiction = SMS_LateFees_Status__c.getValues(zLateFeeProductName).IncludedBillingJurisdictions__c;
        selectedBJs = new List<String>();
        if(includedBillingJurisdiction != null)
        selectedBJs.addAll(includedBillingJurisdiction.split(','));
        notSelectedBJs = new List<String>();
        
        Schema.DescribeFieldResult BJfield = Subscriptions__c.Billing_Jurisdiction__c.getDescribe();
        List<Schema.PicklistEntry> BJvalues = BJfield.getPicklistValues();
        selectedBJOptions = new List<SelectOption>(); 
        notSelectedBJOptions = new List<SelectOption>();
        picklistlength = BJvalues.size();
        for(Schema.PicklistEntry e : BJvalues) {
            String BJ = e.getValue();
            if(selectedBJs.contains(BJ))
                selectedBJOptions.add(new SelectOption(e.getValue(), e.getValue()));
            else
                notSelectedBJOptions.add(new SelectOption(e.getValue(), e.getValue()));
        }
        selectedBJOptions.sort();
        notSelectedBJOptions.sort();
        //selectedSJs = new List<String>();
        selectedBJs = new List<String>();

    }
    
    public class LateFeesConfig {
        public SMS_Late_Fees_Config__c LateFeesConfig { get; set; }
        public String edit { get; set; }
    }
}