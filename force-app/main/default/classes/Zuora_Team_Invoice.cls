public class Zuora_Team_Invoice {
    private enum zOperation { zCREATE, zUPDATE }
    private static SMS_ZuoraUtil zUtilInstance;
    public static  Zuora.zApi.LoginResult zLoginResult;
    private Static Zuora.zApi.SaveResult zSaveResult;
    public static List<Zuora.zApi.AmendRequest> amendRequestList;
    public static List<Zuora.zApi.SubscribeRequest> subRequestList;
    public static Map<string, Teams__c> zAccIdTeamMap;
    
    public static String zsubID {get;set;}
    public static String zRateplanId {get;set;}
    
    private Static List<String> zSubscriptionIDs;
    
    @future(callout=true)
    public Static void createTeamSubscriptionRequest(list<string> teamIds){
        list<Teams__c> teamList = new list<Teams__c>();
        try{
            zUtilInstance = new SMS_ZuoraUtil();
            Zuora.zApi.LoginResult zLoginResult = zUtilInstance.zlogin();
            
            teamList = [SELECT Id,Team_Lead_Sub_ID__c, Office_ID__c, Start_Date__c, Name,Team_Name__c, 
                        Team_Lead__r.Primary_Subscription__r.Name, Team_Lead__r.Primary_Subscription__c FROM Teams__c 
                        WHERE Team_Lead_Sub_ID__c != null AND Team_Option__c = 'Premium' AND Id IN :teamIds];
            zAccIdTeamMap = new Map<string, Teams__c>();
            for(Teams__c team : teamList){
                String zAccountId = findZSubscriptionId(team.Team_Lead_Sub_ID__c);   
                system.debug('zAccountId---'+zAccountId);
                
                if(String.isBlank(zAccountId)){
                    SMS_ZuoraCreateParentOrChildAccount.createParentOrChildAccount(team.Team_Lead_Sub_ID__c);
                    throw new CustomException('Zuora Account not present for the Team Lead Subscription Id');
                }
                else{
                    zAccIdTeamMap.put(zAccountId, team);
                }
            }
            system.debug('zAccIdTeamMap---'+zAccIdTeamMap);
            if(!zAccIdTeamMap.isEmpty()){
                createZuoraTeamSubscription(zAccIdTeamMap);
            }
        }
        catch(Exception e){
            system.debug('createTeamSubscriptionRequest failed '+e.getStackTraceString());
            for(Teams__c eachTeam : teamList){
                SMS_ZuoraHistory.createError(e, 'Zuora_Team_Invoice, Team Subscription Request', eachTeam.Team_Lead__r.Primary_Subscription__c);
            }
        }    
    }
    
    @Future(callout = true)
    Public static void createOrUpdateTeamSubscription(set<string> teamIds){
        
        system.debug('****teamIds--'+teamIds);
        zUtilInstance = new SMS_ZuoraUtil(); 
        zLoginResult = zUtilInstance.zlogin();
        
        Map<string, integer> subTeamCountMap = new Map<string, integer>();
        Map<string, Date> subTeamStartDateMap = new Map<string, Date>();
        Map<string, Teams__c> teamLeadSubTeamMap = new Map<string, Teams__c>();
        for(AggregateResult ar : [SELECT Team_Name__r.Team_Lead_Sub_ID__c, Team_Name__r.Start_Date__c, count(Id)teamCount FROM Team_Members__c 
                                  WHERE Team_Name__r.Team_Lead_Sub_ID__c != null 
                                  AND Member_Type__c IN ('Agent','Broker','Office Manager') 
                                  AND Subscription_ID__r.Status__c IN ('Active') 
                                  AND Status_of_Invitation__c = 'Accepted' 
                                  AND Status_of_team__c ='Active' 
                                  AND Team_Name__c IN :teamIds 
                                  AND Team_Name__r.Start_Date__c != null 
                                  AND Team_Name__r.Team_Option__c = 'Premium' 
                                  AND Start_Date__c != null 
                                  GROUP BY Team_Name__r.Team_Lead_Sub_ID__c, Team_Name__r.Start_Date__c])
        {
            string subId = (string)ar.get('Team_Lead_Sub_ID__c');
            date startDate = (Date)ar.get('Start_Date__c');
            integer teamCount = (integer)ar.get('teamCount');
            if(!subTeamCountMap.containsKey(subId)){
                subTeamCountMap.put(subId, 0);
            }
            subTeamCountMap.put(subId, subTeamCountMap.get(subId) + teamCount);
            if(!subTeamStartDateMap.containsKey(subId)){
                subTeamStartDateMap.put(subId, startDate);
            }                          
        }
        //list<Teams__c> teams = ;
        for(Teams__c eachTeam : [SELECT Name, Team_Name__c, Team_Lead_Sub_ID__c, Team_Lead__r.Primary_Subscription__c, 
                                 Next_Renewal_Date__c FROM Teams__c WHERE Id IN :teamIds]){
            teamLeadSubTeamMap.put(eachTeam.Team_Lead_Sub_ID__c, eachTeam);
        }
        Id sfSubscriptionId;	// = (teams != null && teams.size()>0) ? teams[0].Team_Lead__r.Primary_Subscription__c : null;
        system.debug('subTeamCountMap---'+subTeamCountMap);
        system.debug('subTeamStartDateMap---'+subTeamStartDateMap);
        
        zSubscriptionIDs = new List<String>();
        subRequestList  = new List<Zuora.zApi.SubscribeRequest>();
        amendRequestList = new List<Zuora.zApi.AmendRequest>();
        
        try{
            for(string subscriptionId : subTeamCountMap.keySet())
            {   
                if(teamLeadSubTeamMap.containskey(subscriptionId)){
                    sfSubscriptionId = teamLeadSubTeamMap.get(subscriptionId).Team_Lead__r.Primary_Subscription__c;
                }
                String effectiveDate;
                String nextBillDate;
                
                if(subTeamStartDateMap.containskey(subscriptionId)){
                    Date subStartDate = subTeamStartDateMap.get(subscriptionId);
                    effectiveDate =  subStartDate.year()+'-'+String.valueof(subStartDate.month()).leftPad(2,'0')+'-'+string.valueof(subStartDate.day()).leftPad(2,'0')+'T00:00:00';
                    nextBillDate = fetchNextBillDate(subStartDate);
                }
                
                //String zProdID = '';
                String zProductRatePlanId = ''; 
                String zProductRatePlanChargeId='';
                String description = '';
                
                zsubID = null;
                getZuoraDetails(subscriptionId);
                Integer teamCount = subTeamCountMap.get(subscriptionId);
                description = (teamLeadSubTeamMap.get(subscriptionId) != null) ? 'Team Name : '+teamLeadSubTeamMap.get(subscriptionId).Name+';' : '';
                description += (teamCount == null || teamCount == 0) ? ' No Active Team' : ' Team Size : '+teamCount;
                
                system.debug('zsubID--'+zsubID);
                //zProdID = Team_Rate_Plans__c.getInstance('Team').Zuora_Product_Id__c;
                zProductRatePlanId = Team_Rate_Plans__c.getInstance('Team').Zuora_Product_Rate_Plan_Id__c;
                zProductRatePlanChargeId = Team_Rate_Plans__c.getInstance('Team').Zuora_Product_Rate_Plan_Charge_Id__c;
                Zuora.zApi.AmendRequest amendrequest = getProductAmendmentRequest(zsubID, zProductRatePlanId, 
                                                                                  zProductRatePlanChargeId, teamCount, description,
                                                                                  effectiveDate, nextBillDate, 'UpdateProduct');
                system.debug('Team Product update amendRequest :' + amendrequest );
                amendRequestList.add(amendrequest);
                teamLeadSubTeamMap.get(subscriptionId).Next_Renewal_Date__c = nextBillDate.substring(0, 10);
            }
            if(!amendRequestList.isEmpty()){
                Zuora.zApi.AmendResult amendResults = zUtilInstance.zamend(amendRequestList);
                
                SMS_ZuoraHistory.processZResults(amendResults, 'Zuora_Team_Invoice', sfSubscriptionId);
                system.debug('amendResults :' + amendResults );
                amendRequestList.clear();
                //IRON-5334 Update Next Renewal Date on Teams Record
                update teamLeadSubTeamMap.values();
            }
            
        }catch (Exception e){
            system.debug('error message '+e.getStackTraceString());
            SMS_ZuoraHistory.createError(e, 'Zuora_Team_Invoice, Team Subscription: ', sfSubscriptionId);
        }
    }
    
    private Static void createZuoraTeamSubscription(Map<string, Teams__c> zAccIdTeamMap){
        system.debug('inside createZuoraTeamSubscription---'+zAccIdTeamMap);
        
        String zProductId = Team_Rate_Plans__c.getInstance('Team').Zuora_Product_Id__c;
        String zProductRatePlanId = Team_Rate_Plans__c.getInstance('Team').Zuora_Product_Rate_Plan_Id__c;
        String zProductRatePlanChargeId = Team_Rate_Plans__c.getInstance('Team').Zuora_Product_Rate_Plan_Charge_Id__c;        
        String description = 'Team setup not started';
        list<Zuora.zApi.SubscribeRequest> teamSubRequests = new list<Zuora.zApi.SubscribeRequest>();
        for(string zAccountId : zAccIdTeamMap.keyset()){
            description = 'Team Name : '+zAccIdTeamMap.get(zAccountId).Name+'; '+description;
            Zuora.zApi.SubscribeRequest request = getZuoraSubscriptionRequest(zAccountId, zProductRatePlanId, zProductRatePlanChargeId,description, zAccIdTeamMap.get(zAccountId));   
            teamSubRequests.add(request);
        }
        system.debug('teamSubRequests---'+teamSubRequests);
        if(!teamSubRequests.isEmpty()){
            List<Zuora.zApi.SubscribeResult> results = zUtilInstance.zsubscribe(teamSubRequests);
            system.debug('results---'+results);
            SMS_ZuoraHistory.processZResults(results, 'Zuora_Team_Invoice', null);
            //TODO Pass subscription Id
        }
    }
    
    private Static Zuora.zApi.SubscribeRequest getZuoraSubscriptionRequest(String zAccountId, 
                                                                           String zProductRatePlanId,
                                                                           String zProductRatePlanChargeId,
                                                                           String description,
                                                                           Teams__c sTeam) 
    {   
        String effectiveDate =  sTeam.Start_Date__c.year()+'-'+String.valueof(sTeam.Start_Date__c.month()).leftPad(2,'0')+'-'+string.valueof(sTeam.Start_Date__c.day()).leftPad(2,'0')+'T00:00:00';
        String nextBillDate = fetchNextBillDate(sTeam.Start_Date__c);
        system.debug('effectiveDate---'+effectiveDate);
        Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
        
        request.ZAccount = new Zuora.zObject('Account');
        request.ZAccount.setValue('Id', zAccountId);
        
        request.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
        request.SubscribeOptions.GenerateInvoice = false;
        request.SubscribeOptions.ProcessPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        
        request.SubscriptionData = new Zuora.zApi.SubscriptionData();
        
        Zuora.zObject subscription = new Zuora.zObject('Subscription');
        subscription.setValue('ContractEffectiveDate', effectiveDate);
        subscription.setValue('ServiceActivationDate', nextBillDate);
        subscription.setValue('TermType', 'TERMED');    
        subscription.setValue('AutoRenew', true);
        subscription.setValue('IsCore__c', false);
        
        subscription.setValue('InitialTerm', '2');
        subscription.setValue('RenewalTerm', '1');
        subscription.setValue('AutoRenew', true);
        
        request.SubscriptionData.Subscription = subscription;
        
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');       
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);       
        
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId',zProductRatePlanChargeId);
        ratePlanCharge.setValue('Description', description);
        ratePlanCharge.setValue('Quantity', '0');
        
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData }); 
        
        ratePlanDataList.add(ratePlanData);
        request.SubscriptionData.RatePlanData = ratePlanDataList;           
        
        return request;                 
    }
    @TestVisible 
    private Static Zuora.zApi.AmendRequest getProductAmendmentRequest(String zSubscriptionId, 
                                                                      String zProductRatePlanId, 
                                                                      String zProductRatePlanChargeId, 
                                                                      Decimal quantity, 
                                                                      String description, 
                                                                      String effectiveDate,
                                                                      string nextBillDate,
                                                                      String reqType) 
    {
        
        Zuora.zApi.AmendRequest request = new Zuora.zApi.AmendRequest();
        request.Amendments = new List <Zuora.zObject>();
        
        List<Zuora.zObject> ratePlanDataList = new List<Zuora.zObject>();
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', zProductRatePlanId);        
        ratePlan.setValue('AmendmentSubscriptionRatePlanId',zRateplanId);
        
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId',zProductRatePlanChargeId);
        ratePlanCharge.setValue('Description', description);
        ratePlanCharge.setValue('Quantity', quantity);
        
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
        
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanData.setValue('RatePlanChargeData', new Zuora.ZObject[] { ratePlanChargeData });
        ratePlanDataList.add(ratePlanData);
        
        Zuora.zObject amendment = new Zuora.zObject('Amendment');
        amendment.setValue('Name', 'Update Team Size');
        amendment.setValue('SubscriptionId',zSubscriptionId);
        
        amendment.setValue('Type', reqType);
        amendment.setValue('RatePlanData',ratePlanData);
        
        amendment.setValue('Status', 'Completed');
        system.debug('effectiveDate---'+effectiveDate);
        system.debug('nextBillDate---'+nextBillDate);
        amendment.setValue('ContractEffectiveDate', nextBillDate);
        amendment.setValue('EffectiveDate', effectiveDate);
        amendment.setValue('ServiceActivationDate', nextBillDate);            
        
        request.Amendments.add(amendment);
        
        request.AmendOptions = new Zuora.zApi.AmendOptions();
        request.AmendOptions.generateInvoice = false;        
        request.AmendOptions.processPayments = false;
        
        request.PreviewOptions = new Zuora.zApi.PreviewOptions();
        request.PreviewOptions.EnablePreviewMode = false;
        
        return request;
    }
    
    private Static Zuora.zApi.SaveResult callZuora(zOperation operation, Zuora.zObject content) {
        List<Zuora.zObject> zObjectList = new List<Zuora.zObject> { content };
            List<Zuora.zApi.SaveResult> zSaveResultList;
        zSaveResult = new Zuora.zApi.SaveResult();
        
        system.debug('** content :' + content );
        
        if (operation == zOperation.zCREATE) {
            zSaveResultList = zUtilInstance.zcreate(zObjectList); //will be used while writing test classes
        }
        else if (operation == zOperation.zUPDATE){
            zSaveResultList = zUtilInstance.zupdate(zObjectList); //will be used while writing test classes
        }
        else
            throw new CustomException('Illegal Zuora Operation');
        
        system.debug('*** zSaveResultList : ' + zSaveResultList);
        zSaveResult = !zSaveResultList.isEmpty() && zSaveResultList[0].Success ? zSaveResultList[0] : null;
        
        return zSaveResult;
    }
    
    private Static String findZSubscriptionId(String subscriptionId){
        String query = 'SELECT Id, Status FROM Account WHERE SubscriptionID__c LIKE \'' + subscriptionId + '%\'';
        
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(query); //will be used while writing test classes
        system.debug('*** zAccounts :' + zAccounts );
        
        if(zAccounts.size() > 0)
            return (String)zAccounts[0].getValue('Id');
        else
            return null;            
    }
    
    private static void getZuoraDetails(String subscribId){
        String accountQuery = 'SELECT Id,Name FROM Account WHERE ';
        accountQuery += ' SubscriptionID__c LIKE \'%'+ subscribId + '%\'';
        
        system.debug('***accountQuery'+accountQuery);
        List<Zuora.zObject> zAccounts = zUtilInstance.zquery(accountQuery);
        if (!(zAccounts.Size() == 1)) 
            throw new CustomException('Zuora account does not exist'); 
        
        Integer a = 0;
        string zAccId = String.valueOf(zAccounts[0].getValue('Id'));
        String currentDate = DateTime.now().format('yyyy-MM-dd');
        
        String subQuery = 'SELECT Id, Name, InitialTerm, IsCore__c, TermEndDate, TermType, TermStartDate, Status FROM Subscription WHERE AccountId = \'' + zAccId + '\' AND IsCore__c = false AND AutoRenew = true AND Status=\'Active\' AND TermEndDate >= \'' + currentDate + '\' AND TermStartDate <= \'' + currentDate + '\'';
        List<Zuora.zObject> zSubscriptions = zUtilInstance.zquery(subQuery);
        system.debug('zsubscriptions : '+zSubscriptions);
        
        for (Zuora.zObject zSubscription : zSubscriptions) {
            system.debug('****'+zSubscription.getValue('Id'));
            zSubscriptionIDs.add(String.valueOf(zSubscription.getValue('Id')));
        }
        String ratePlansQuery = 'SELECT Id, Name, ProductRatePlanId, SubscriptionId FROM RatePlan WHERE ';
        system.debug('****ratePlansQuery'+ratePlansQuery);
        for (String zSubscriptionId : zSubscriptionIDs) {
            if (a != 0)
                ratePlansQuery += ' OR ';        
            
            ratePlansQuery += 'SubscriptionId = \'' + zSubscriptionId + '\'';
            a++;
        }
        system.debug('***Rate plan qury is '+ratePlansQuery);
        if(a != 0){
            
            List<Zuora.zObject> zRatePlans = zUtilInstance.zquery(ratePlansQuery);
            if (!(zRateplans.Size() > 0)) 
                throw new CustomException('Zuora Rateplan not found');
            system.debug('***zRatePlans '+zRatePlans);
            for(Zuora.zObject zRatePlan : zRatePlans) {
                if(String.valueof(zRatePlan.getValue('ProductRatePlanId')) == Team_Rate_Plans__c.getInstance('Team').Zuora_Product_Rate_Plan_Id__c){
                    zsubID = String.valueOf(zRatePlan.getValue('SubscriptionId'));
                    zRateplanId = String.valueOf(zRatePlan.getValue('Id'));
                    break;
                }
            }
            system.debug('****zRateplanId  '+zRateplanId);
            system.debug('***zsubID   '+zsubID);
        }
    }
    public static string fetchNextBillDate(Date date1){
        list<string> dateParts = system.today().format().split('/');
        Date nextBillDate = Date.newInstance(Integer.valueof(dateParts[2]), Integer.valueof(dateParts[0]), date1.day());
        if(Date.newInstance(Integer.valueof(dateParts[2]), Integer.valueof(dateParts[0]), Integer.valueof(dateParts[1])) >= nextBillDate){
            nextBillDate = nextBillDate.addMonths(1);
        }
        return nextBillDate.year()+'-'+String.valueof(nextBillDate.month()).leftPad(2,'0')+'-'+string.valueof(nextBillDate.day()).leftPad(2,'0')+'T00:00:00';
    }
    public class CustomException extends Exception {}
}