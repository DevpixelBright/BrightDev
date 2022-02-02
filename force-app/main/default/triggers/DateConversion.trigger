trigger DateConversion on Team_Members__c (before update) {
    /*
    List<Team_Members__c> teamDate = new List<Team_Members__c>();
    for(Team_Members__c team :trigger.New){
        if(trigger.oldMap.get(team.Id).Updated_Date__c != team.Updated_Date__c){
            if(team.Updated_Date__c != null){
                Datetime dt = team.Updated_Date__c;
                system.debug('***dt'+dt);
                String dtEST = dt.format('dd-MM-yyyy', 'EST');
                system.debug('***dtEST'+dtEST);
                String[] strDate = dtEST.split('-');
                Integer myIntDate = integer.valueOf(strDate[0]);
                Integer myIntMonth = integer.valueOf(strDate[1]);
                Integer myIntYear = integer.valueOf(strDate[2]);
                Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                team.Start_Date__c = d;
                system.debug('***team.Start_Date__c'+team.Start_Date__c);
                teamDate.add(team);   
            }
        }
    }
    */
}