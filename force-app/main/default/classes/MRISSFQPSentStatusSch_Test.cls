@isTest
private class MRISSFQPSentStatusSch_Test{
    
    private static testMethod void doTestOne(){     
        
        SFQPConnector__c sfqpc = new SFQPConnector__c();
        sfqpc.ObjectType__c = 'Account';
        sfqpc.QPMessage__c = 'Success';
        sfqpc.QPStatus__c = 'Sent';
        insert sfqpc;        
        
        System.debug('*** sfqpc : ' + sfqpc);   
    
        Datetime currentTime = system.now().addMinutes(1);
        
        String day = string.valueOf(currentTime.day());
        String month = string.valueOf(currentTime.month());
        String hour = string.valueOf(currentTime.hour());
        String minute = string.valueOf(currentTime.minute());
        String second = string.valueOf(currentTime.second());
        String year = string.valueOf(currentTime.year());
        
        String strJobName = 'MRISSFQPSentStatusSch -' + String.ValueOf(Math.random());
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
    
        MRISSFQPSentStatusSch sz = new MRISSFQPSentStatusSch();
        String jobID = system.schedule(strJobName, strSchedule , sz);
        
        MRISSFQPSentStatus b = new MRISSFQPSentStatus(); 
        database.executebatch(b); 
        
    }
}