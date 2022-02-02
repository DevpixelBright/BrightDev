@isTest
public class SMS_AutoSuspend_Config_Test {
    public static testMethod void SMS_AutoSuspend_Config_Controller_Test() {
        PageReference pageRef = Page.SMS_AutoSuspend_Config;
        Test.setCurrentPage(pageRef);
        
        List<SMS_AutoSuspend_Config__c> autoSuspendList = new List<SMS_AutoSuspend_Config__c>();
        
        SMS_AutoSuspend_Config__c autoSuspend = new SMS_AutoSuspend_Config__c();
        autoSuspend.IsSuspend__c = true;
        autoSuspend.Day_of_Week__c = 'Monday';
        autoSuspend.Threshold_Accounts__c = 10;
        autoSuspend.Threshold_Amount__c = 25;
        autoSuspend.Threshold_Days__c = 45;
        autoSuspend.IsSuspend__c = true;
        autoSuspendList.add(autoSuspend);
        
        SMS_AutoSuspend_Config__c autoSuspend1 = new SMS_AutoSuspend_Config__c();
        autoSuspend1.IsSuspend__c = true;
        autoSuspend1.Day_of_Week__c = 'Friday';
        autoSuspend1.Threshold_Accounts__c = 10;
        autoSuspend1.Threshold_Amount__c = 25;
        autoSuspend1.Threshold_Days__c = 45;
        autoSuspend1.IsSuspend__c = true;
        autoSuspendList.add(autoSuspend1);
        
        SMS_AutoSuspend_Config__c autoSuspend2 = new SMS_AutoSuspend_Config__c();
        autoSuspend2.IsSuspend__c = true;
        autoSuspend2.Day_of_Week__c = 'Tuesday';
        autoSuspend2.Threshold_Accounts__c = 10;
        autoSuspend2.Threshold_Amount__c = 25;
        autoSuspend2.Threshold_Days__c = 45;
        autoSuspend2.IsSuspend__c = true;
        autoSuspendList.add(autoSuspend2);
        
        SMS_AutoSuspend_Config__c autoSuspend3 = new SMS_AutoSuspend_Config__c();
        autoSuspend3.IsSuspend__c = true;
        autoSuspend3.Day_of_Week__c = 'Wednesday';
        autoSuspend3.Threshold_Accounts__c = 10;
        autoSuspend3.Threshold_Amount__c = 25;
        autoSuspend3.Threshold_Days__c = 45;
        autoSuspend3.IsSuspend__c = true;
        autoSuspendList.add(autoSuspend3);
        
        SMS_AutoSuspend_Config__c autoSuspend4 = new SMS_AutoSuspend_Config__c();
        autoSuspend4.IsSuspend__c = true;
        autoSuspend4.Day_of_Week__c = 'Thursday';
        autoSuspend4.Threshold_Accounts__c = 10;
        autoSuspend4.Threshold_Amount__c = 25;
        autoSuspend4.Threshold_Days__c = 45;
        autoSuspend4.IsSuspend__c = true;
        autoSuspendList.add(autoSuspend4);                                
        
        insert autoSuspendList;
        
        
        SMS_AutoSuspend_Status__c setting = new SMS_AutoSuspend_Status__c();
        setting.Name = 'Auto Suspend';
        setting.IsActive__c = true;
        setting.Schedule_Time__c = '10:00PM';
        insert setting;
        
        String scheduleTime = '0 9 2 ? * MON,TUE,WED,THUR,FRI * AutoSuspend';
        System.schedule(scheduleTime , scheduleTime , new SMS_ScheduleAutoSuspend());        
        
        SMS_AutoSuspend_Config controller = new SMS_AutoSuspend_Config();
        
        controller.editSetting();
        
        controller.isActive = true;
        controller.scheduleHour = '9';
        controller.scheduleMinute = '0';
        controller.scheduleMeridiem = 'PM';
        controller.saveSetting();
        
        controller.editConfigId = autoSuspend4.Id;
        controller.editConfig();
        controller.cancel();
        controller.editConfig();
        controller.saveConfig();
        
        controller.maximumAccounts = '10';
        controller.amount = '50';
        controller.days = '10';
        controller.runAutoSuspension();
        
        controller.maximumAccounts = null;
        controller.amount = '50';
        controller.days = '10';
        controller.runAutoSuspension();        
    }
}