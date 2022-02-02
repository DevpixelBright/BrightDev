public Class SMS_ZuoraMockDataGenerator {
    public static Boolean emptyResult = false;
    public static String isCore = 'true';
    public Static Integer zNumOfResults = 1; 
    public Static Map<String, String> preDefinedValues = new Map<String, String>();
    public Static Map<String, Boolean> zObjectEmptyResult = new Map<String, Boolean>();
    
    private static Map<String, Map<String, Zuora.zSchema.zFieldDescription>> allZFeildDescription {
        get {
            if (allZFeildDescription == null) {
                allZFeildDescription =  Zuora.zSchema.getAllzFieldDescription();
            }
            return allZFeildDescription;
        }
        private set ;
    }
    
    public static List<Zuora.zObject> generateTestData(String zObjectName, List<String> zFieldNames, List<String> zConditions){
        System.Debug('*** zObjectName: ' + zObjectName);
        System.Debug('*** zFieldNames: ' + zFieldNames);
        System.Debug('*** zConditions: ' + zConditions);
        
        Map<String, String> zConditionalValues = new Map<String, String>();
        //Integer zNumOfResults = 3;
        List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
        
        if (emptyResult)
            return zObjectList;
            
        if (zObjectEmptyResult.get(zObjectName) != null)
            return zObjectList;
            
        if (zConditions.Size() > 0) {
            for (String zCondition : zConditions) {
                zCondition = zCondition.deleteWhitespace();
                zCondition = zCondition.replace('\'','');
                
                List<String> parts = new List<String>();
                if (zCondition.indexOf('=') > 0 && zCondition.indexOf('!=') < 0 && zCondition.indexOf('<=') < 0 && zCondition.indexOf('>=') < 0) {
                   parts = zCondition.split('=');
                   System.Debug('### parts :' + parts);
                   System.Debug('### parts :' + zObjectName);
                   System.Debug('### parts :' + parts[0]);
                   System.Debug('### parts :' + allZFeildDescription.get(zObjectName).get(parts[0]));
                   if (allZFeildDescription.get(zObjectName).get(parts[0]) != null) {
                       System.debug('Working');
                       if ((allZFeildDescription.get(zObjectName).get(parts[0]).FieldType == 'zObject' || parts[0] == 'SubscriptionID__c') && zNumOfResults == 1)
                            zNumOfResults = 1;
                   }
                }
                if (zCondition.indexOf('>') > 0) {
                    zCondition = zCondition.replace('>=', '>');
                    parts = zCondition.split('>');
                    if (allZFeildDescription.get(zObjectName).get(parts[0]).FieldType == 'int')
                        parts[1] = String.valueOf(Decimal.valueOf(parts[1]) + 1);
                    if (allZFeildDescription.get(zObjectName).get(parts[0]).FieldType == 'decimal') 
                        parts[1] = String.valueOf(Decimal.valueOf(parts[1]) + 1.01);         
                }
                if (zCondition.indexOf('<') > 0) {
                    zCondition = zCondition.replace('<=', '<');
                    parts = zCondition.split('<');
                    if (allZFeildDescription.get(zObjectName).get(parts[0]).FieldType == 'int')
                        parts[1] = String.valueOf(Decimal.valueOf(parts[1]) - 1); 
                     if (allZFeildDescription.get(zObjectName).get(parts[0]).FieldType == 'decimal') 
                        parts[1] = String.valueOf(Decimal.valueOf(parts[1]) - 1.01);         
                } 
                if (zCondition.indexOf('LIKE') > 0) {
                    zCondition = zCondition.replace('%', '');
                    parts = zCondition.split('LIKE');       
                } 
                if (parts.Size() == 2)                      
                    zConditionalValues.put(parts[0], parts[1]);
            }       
        }      
        
        
        for (Integer i=1; i<=zNumOfResults; i++) {
            Zuora.zObject zObject = new Zuora.zObject(zObjectName);  
            for (String zField : zFieldNames) {
                zField = zField.deleteWhitespace(); 
                try {
                    String feildType = allZFeildDescription.get(zObjectName).get(zField).FieldType;
                    System.debug(zField + ',' +feildType);
                    if (String.isNotBlank(zConditionalValues.get(zField))){
                        if(feildType == 'decimal')
                            zObject.setValue(zField, Decimal.valueOf(zConditionalValues.get(zField)));
                        else
                            zObject.setValue(zField, zConditionalValues.get(zField));
                    }
                    else {
                        if(feildType.equals('decimal'))
                            zObject.setValue(zField, 123.45);
                        else if(feildType.equals('string'))
                            zObject.setValue(zField, zObjectName + string.valueof(i));
                        else if(feildType.equals('boolean'))
                            zObject.setValue(zField, true);
                        else if(feildType.equals('int'))
                            zObject.setValue(zField, 3);
                        else if(feildType.equals('zObject'))
                            zObject.setValue(zField, generateRandomString());
                        else if(feildType.equals('dateTime'))
                            zObject.setValue(zField, Datetime.now().addDays(-2));
                        else if(feildType.equals('date')){
                            //zObject.setValue(zField, (Date)Datetime.now().addDays(-2));
                            zObject.setValue(zField, Date.valueOf(DateTime.now().addDays(-2).format('yyyy-MM-dd')));
                        }
                        else                
                            zObject.setValue(zField, generateRandomString());
                            
                        if (zField.equals('TermType'))
                            zObject.setValue(zField, 'TERMED');
                        if (zField.equals('Status'))
                            zObject.setValue(zField, 'Active'); 
                        if (zField.equals('IsCore__c'))
                            zObject.setValue(zField, isCore); 
                        if (zField.equals('TermEndDate'))
                            zObject.setValue(zField, Datetime.now().addDays(2));
                        //if (zField.equals('Id') && String.isNotBlank(Id))  
                        //    zObject.setValue(zField, Id); 
                            
                        if (preDefinedValues.Size() > 0) {
                            if (preDefinedValues.containsKey(zField))
                                zObject.setValue(zField, preDefinedValues.get(zField));
                        }                       
                                                                      
                    }
                }
                catch(Exception e) {
                    //zObject.setValue(zField, '1234567');
                }
            }
            zObjectList.add(zObject);
        }
        System.Debug('*** zObjectList: '+ zObjectList);
        
        return zObjectList;
    }
    
    private static String generateRandomString() {
        Integer len = 15;
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        return key.substring(0,len);    
    }
}