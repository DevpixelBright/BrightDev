public with sharing class AddressUtility{

/*
    Bulkify and Improvise Code to query Cornerstone Mappings.
    Instead of querying for each type and each record of Account or Subscription,
    receive a list of address types and query cornerstone. Even then we will be having 
    6 different queries for each execution, but will reduce 100's of queries while running in bulk.
*/
    public static Map<String,String> queryCornerstoneMappings(String typeOfAttr, Set<String> typeNames) {
        List<CornerstoneMappings__c> crsMappings = new List<CornerstoneMappings__c>();        
        Map<String,String> csIdTNames = new Map<String,String>();
        
        system.debug('&&&& typeOfAttr : ' + typeOfAttr);
        system.debug('&&&& typeNames : ' + typeNames);
            
        crsMappings =  [SELECT Type__c, TypeName__c, CornerstoneID__c 
                        FROM   CornerstoneMappings__c
                        WHERE  Type__c = :typeOfAttr 
                        AND    TypeName__c IN :typeNames 
                       ];
        
        for(CornerstoneMappings__c crsm : crsMappings){
            csIdTNames.put(crsm.TypeName__c.toUpperCase(),crsm.CornerstoneID__c);
            system.debug('&&&& csMapping: ' + crsm );
        }
        
        return csIdTNames;           
    }
    
    public static Map<String,String> queryCMLongValue(String typeOfAttr, Set<String> longValues){
        List<CornerstoneMappings__c> crsMappings = new List<CornerstoneMappings__c>();
        Map<String,String> csIdTNames = new Map<String,String>();
        
        system.debug('&&&& Long typeOfAttr : ' + typeOfAttr);
        system.debug('&&&& Long typeNames : ' + longValues);
        
        crsMappings = [SELECT CornerstoneID__c, LongValue__c 
                       FROM   CornerstoneMappings__c 
                       WHERE  Type__c = :typeOfAttr 
                       AND    LongValue__c IN :longValues];
                       
        for(CornerstoneMappings__c crsm : crsMappings){
            csIdTNames.put(crsm.LongValue__c.toUpperCase(),crsm.CornerstoneID__c);
            system.debug('&&&& csMapping: ' + crsm );
        }
        
        return csIdTNames;        
    }
    
    public static Set<String> validateCSCity(String objectType, List<String> cities) {
        Set<String> validCities = new Set<String>();        
        Map<String,String> csCities = new Map<String,String>();
        
        if(cities.Size() > 0) {
            for(String city : cities) 
               csCities.put(city.toUpperCase(),city);
            
            Map<String,String> csMappings = new Map<String,String>();
            if ('ACCOUNT'.equals(objectType)) 
                csMappings = queryCornerstoneMappings('Office/city',csCities.keyset());
            else if ('SUBSCRIPTION'.equals(objectType))
                csMappings = queryCornerstoneMappings('Agent/city',csCities.keyset());
            else
                System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);           
            
            for(String city : csCities.keyset()){
                String csId = csMappings.get(city);
                if(String.isNotBlank(csId))
                    validCities.add(csCities.get(city));
            }
        }
        return validCities;
    }
    
    public static Set<String> validateCSCityAll(String objectType, List<String> longValues) {
        Map<String,String> csLongValues = new Map<String,String>();
        Set<String> validLongValues = new Set<String>();
        
        // EM changes start here comment out--
        /* 
        if(longValues.Size() > 0) {        
          for(String longValue : longValues)
             csLongValues.put(longValue.toUpperCase(),longValue);           
              Map<String,String> csMappings = new Map<String,String>();
              if ('ACCOUNT'.equals(objectType))
              csMappings = queryCMLongValue('Office/city',csLongValues.keyset());
               else if ('SUBSCRIPTION'.equals(objectType))
               csMappings = queryCMLongValue('Agent/city',csLongValues.keyset());
               else
                System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
             for(String longValue : csLongValues.keyset()){
                 String csId = csMappings.get(longValue);
                if(String.isNotBlank(csId))
                
                    validLongValues.add(csLongValues.get(longValue));           
           }  
          } 
          
        */
        //end of comments out
        
        //  EM start - 8-8-2016 - new code - we are retiring validations for cities           
          
           if(longValues.Size() > 0) {
             for(String longValue : longValues){
              validLongValues.add(longValue);
            }
           }
       // end - 8-8-2016 - new code - we basically return the same value - no validations  
        
        
       
        return validLongValues;
    }

    public static Set<String> validateCSState(String objectType, List<String> states) {
        Map<String,String> csStates = new Map<String,String>();
        Set<String> validStates = new Set<String>();
        
        if(states != null) {
            for(String state : states){
            System.debug('*** states:' + states);
               if('UN'.equals(state.toUpperCase()))
                   validStates.add(state);
               else
                   csStates.put(state.toUpperCase(),state);
               
            }
            
            Map<String,String> csMappings = new Map<String,String>();
            if ('ACCOUNT'.equals(objectType)) 
                csMappings = queryCornerstoneMappings('Office/state', csStates.keyset());
            else if ('SUBSCRIPTION'.equals(objectType))
                csMappings = queryCornerstoneMappings('Agent/state', csStates.keyset());
            else
                System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
            
            for(String state : csStates.keyset()){
                String csId = csMappings.get(state);
                if(String.isNotBlank(csId))
                    validStates.add(csStates.get(state));
            }
        }
        
        return validStates;
    }
    
    public static Set<String> validateCSStreetDirection(String objectType,List<String> streetDirections) {
        Map<String,String> csStreetDirections = new Map<String,String>();
        Set<String> validStreetDirections = new Set<String>();
        
        if(streetDirections.Size() > 0) {
            for(String streetDirection : streetDirections) 
               csStreetDirections.put(streetDirection.toUpperCase().split(', ')[1],streetDirection);
            
            Map<String,String> csMappings = new Map<String,String>();
            if ('ACCOUNT'.equals(objectType))
                csMappings = queryCornerstoneMappings('Office/streetDirections',csStreetDirections.keyset());
            else if ('SUBSCRIPTION'.equals(objectType))
                csMappings = queryCornerstoneMappings('Agent/streetDirections',csStreetDirections.keyset());
            else 
                System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
            
            for(String streetDirection : csStreetDirections.keyset()){
                String csId = csMappings.get(streetDirection);
                if(String.isNotBlank(csId))
                    validStreetDirections.add(csStreetDirections.get(streetDirection));
            }
        }
        return validStreetDirections;
    }
    
    public static Set<String> validateCSCounty(String objectType, List<String> counties) {
        Map<String,String> csCounties = new Map<String,String>();
        Set<String> validCounties = new Set<String>();
        
        if(counties.Size() > 0) {
            for(String county : counties) 
               csCounties.put(county.toUpperCase().split(', ')[0],county);
            
            Map<String,String> csMappings = new Map<String,String>();
            if ('ACCOUNT'.equals(objectType)) 
            //  csMappings = queryCornerstoneMappings('Office/county',csCounties.keyset());
                csMappings = queryCMLongValue('Office/county',csCounties.keyset());
                
            else if ('SUBSCRIPTION'.equals(objectType))
              // csMappings = queryCornerstoneMappings('Agent/county',csCounties.keyset());
                 csMappings = queryCMLongValue('Agent/county',csCounties.keyset());
            else
                System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
            
            for(String county : csCounties.keyset()){
                String csId = csMappings.get(county);
                if(String.isNotBlank(csId))
                    validCounties.add(csCounties.get(county));
            }
        }
        return validCounties;
    }
    
    public static Set<String> validateCSCountry(String objectType,List<String> countries) {
        Map<String,String> csCountries = new Map<String,String>();
        Set<String> validCountries = new Set<String>();
        
        if(countries.Size() > 0) {
            for(String country : countries){
                if('UNITED STATES'.equals(country.toUpperCase()))
                    validCountries.add(country);
                else
                    csCountries.put(country.toUpperCase(),country);  
            } 
            
            Map<String,String> csMappings = new Map<String,String>();
            if ('ACCOUNT'.equals(objectType)) 
                csMappings = queryCornerstoneMappings('Office/country',csCountries.keyset());
            else if ('SUBSCRIPTION'.equals(objectType))
                csMappings = queryCornerstoneMappings('Agent/country',csCountries.keyset());
            else 
                System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
            
            for(String country : csCountries.keyset()){
                String csId = csMappings.get(country);
                if(String.isNotBlank(csId))
                    validCountries.add(csCountries.get(country));
            }
        }
        return validCountries;  
    }
    
    public static Set<String> validateCSStreetType(String objectType,List<String> streetTypes) {
        Map<String,String> csStreetTypes = new Map<String,String>();
        Set<String> validStreetTypes = new Set<String>();
        
        if(streetTypes.Size() > 0) {
            for(String streetType : streetTypes) 
               csStreetTypes.put(streetType.toUpperCase().split(', ')[0],streetType);
            
            Map<String,String> csMappings = new Map<String,String>();
            if ('ACCOUNT'.equals(objectType)) 
                csMappings = queryCornerstoneMappings('Office/streetTypes',csStreetTypes.keyset());
            else if ('SUBSCRIPTION'.equals(objectType))
                csMappings = queryCornerstoneMappings('Agent/streetTypes',csStreetTypes.keyset());
            else
                System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
            
            for(String streetType : csStreetTypes.keyset()){
                String csId = csMappings.get(streetType);
                if(String.isNotBlank(csId))
                    validStreetTypes.add(csStreetTypes.get(streetType));
            }
        }
        return validStreetTypes;
    }

    public static Set<String> validateCSStreetUnitTypes(String objectType,List<String> streetUnits) {
        Map<String,String> csStreetUnits = new Map<String,String>();
        Set<String> validStreetUnits = new Set<String>();
        
        if(streetUnits.Size() > 0) {
            for(String streetUnit : streetUnits) 
               csStreetUnits.put(streetUnit.toUpperCase().split(', ')[0],streetUnit);
            
            Map<String,String> csMappings = new Map<String,String>();
            
            if ('ACCOUNT'.equals(objectType)) 
                csMappings = queryCornerstoneMappings('Office/unitDesignation',csStreetUnits.keyset());
            else if ('SUBSCRIPTION'.equals(objectType))
                csMappings = queryCornerstoneMappings('Agent/unitDesignation',csStreetUnits.keyset());
            else
                System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
            
            for(String streetUnit : csStreetUnits.keyset()){
                String csId = csMappings.get(streetUnit);
                if(String.isNotBlank(csId))
                    validStreetUnits.add(csStreetUnits.get(streetUnit));
            }
        }
        return validStreetUnits;
    }
    
    public static Map<String,String> getCSState(Map<String, String> states, String objectType) {    
        Map<String, String> csStates = new Map<String, String>(); 
        Map<String, String> validCSStates = new Map<String, String>();
        
        if(states.Size() > 0) {
            for(String state : states.keySet()) {       
                String csState = state.toUpperCase();
                if('UN'.equals(state)) {
                    if('UNITED STATES'.equals(states.get(state)))
                        csState = 'US-UN';
                    else if('CANADA'.equals(states.get(state)))
                        csState = 'CA-UN';
                    else
                        csState = 'UN-UN';
                }
                csStates.put(csState, state);
            }
            
            Map<String,String> csMappings = new Map<String,String>();
            if ('ACCOUNT'.equals(objectType))
                csMappings = queryCornerstoneMappings('Office/state', csStates.keySet());
            else if ('SUBSCRIPTION'.equals(objectType))
                csMappings = queryCornerstoneMappings('Agent/state', csStates.keySet());
            else
                System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
            
            for(String state : csMappings.keyset()){
                String csId = csMappings.get(state);
                if(String.isNotBlank(csId))
                    validCSStates.put(csStates.get(state), csId);
            }        
        }
        return validCSStates;
    } 
    
    public static Map<String,String> getCSStreetDirection(List<String> streetDirectionList, String objectType) {
        Map<String, String> csDirections = new Map<String, String>();
        Map<String, String> validCSDirections = new Map<String, String>();
        
        if (!(streetDirectionList.Size() > 0))
            return validCSDirections;
            
        for(String streetDirection : streetDirectionList) 
           csDirections.put(streetDirection.toUpperCase().split(', ')[1], streetDirection);               
        
        Map<String,String> csMappings = new Map<String,String>();
        if ('ACCOUNT'.equals(objectType)) 
            csMappings = queryCornerstoneMappings('Office/streetDirections', csDirections.keySet());
        else if ('SUBSCRIPTION'.equals(objectType))
            csMappings = queryCornerstoneMappings('Agent/streetDirections', csDirections.keySet());
        else 
            System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
        
        for(String streetDirection : csMappings.keyset()){
            String csId = csMappings.get(streetDirection);
            if(String.isNotBlank(csId))
                validCSDirections.put(csDirections.get(streetDirection), csId);
        }         
        
        return validCSDirections;
    }
    
    public static Map<String,String> getCSCounty(List<String> countyList, String objectType) {
        Map<String, String> csCounty = new Map<String, String>();
        Map<String, String> validCSCounty = new Map<String, String>();
          
        if ((countyList.Size() > 0)){           
            
        for(String county : countyList)
         csCounty.put(county.toUpperCase(), county);            

        Map<String,String> csMappings = new Map<String,String>();
        if ('ACCOUNT'.equals(objectType))                 
            //csMappings = queryCornerstoneMappings('Office/county', csCounty.keySet());
             csMappings = queryCMLongValue('Office/county', csCounty.keySet());
        else if ('SUBSCRIPTION'.equals(objectType))
            //csMappings = queryCornerstoneMappings('Agent/county', csCounty.keySet());
            csMappings = queryCMLongValue('Agent/county', csCounty.keySet());
        else       
            System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
        
        for(String county : csMappings.keyset()){
            String csId = csMappings.get(county);
            if(String.isNotBlank(csId)){
               
                validCSCounty.put(csCounty.get(county), csId);}
        }       
        }  
        
        return validCSCounty;
    }
    
    public static Map<String,String> getCSCountry(List<String> countryList, String objectType) {
        Map<String, String> csCountry = new Map<String, String>();
        Map<String, String> validCSCountry = new Map<String, String>();
        
        if (!(countryList.Size() > 0))
            return validCSCountry;

        for(String country : countryList) { 
            String countryStr = country.toUpperCase();          
            if ('UNITED STATES'.equals(countryStr))
                countryStr = 'UNITED STATES OF AMERICA';
            
            csCountry.put(countryStr.toUpperCase(), country);
        }

        Map<String,String> csMappings = new Map<String,String>();
        if ('ACCOUNT'.equals(objectType)) 
            csMappings = queryCornerstoneMappings('Office/country', csCountry.keySet());
        else if ('SUBSCRIPTION'.equals(objectType))
            csMappings = queryCornerstoneMappings('Agent/country', csCountry.keySet());
        else
            System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
        
        for(String country : csMappings.keyset()){
            String csId = csMappings.get(country);
            if(String.isNotBlank(csId))
                validCSCountry.put(csCountry.get(country), csId);
        }         
        
        return validCSCountry;
    }
    
    public static Map<String,String> getCSStreetType(List<String> streetTypeList, String objectType) {
        Map<String, String> csStreetTypes = new Map<String, String>();
        Map<String, String> validCSStreetTypes = new Map<String, String>();        
              
        if (!(streetTypeList.Size() > 0))
            return validCSStreetTypes;

        for(String streetType : streetTypeList)            
            csStreetTypes.put(streetType.toUpperCase().split(', ')[0], streetType);

        Map<String,String> csMappings = new Map<String,String>();
        if ('ACCOUNT'.equals(objectType))
            csMappings = queryCornerstoneMappings('Office/streetTypes', csStreetTypes.keySet());
        else if ('SUBSCRIPTION'.equals(objectType))
            csMappings = queryCornerstoneMappings('Agent/streetTypes', csStreetTypes.keySet());
        else 
            System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
        
        for(String streetType : csMappings.keyset()){
            String csId = csMappings.get(streetType);
            if(String.isNotBlank(csId))
                validCSStreetTypes.put(csStreetTypes.get(streetType), csId);
        }         
        
        return validCSStreetTypes;
    }
    
    public static Map<String,String> getCSStreetUnitTypes(List<String> streetUnitList, String objectType) {
        Map<String, String> csStreetUnitTypes = new Map<String, String>();
        Map<String, String> validCSStreetUnitTypes = new Map<String, String>();             
        
        if (!(streetUnitList.Size() > 0))
            return validCSStreetUnitTypes;

        for(String streetUnitType : streetUnitList)            
            csStreetUnitTypes.put(streetUnitType.toUpperCase().split(', ')[0], streetUnitType);
              
        Map<String,String> csMappings = new Map<String,String>();
        if ('ACCOUNT'.equals(objectType)) 
            csMappings = queryCornerstoneMappings('Office/unitDesignation', csStreetUnitTypes.keySet());
        else if ('SUBSCRIPTION'.equals(objectType))
            csMappings = queryCornerstoneMappings('Agent/unitDesignation', csStreetUnitTypes.keySet());
        else 
            System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
        
        for(String streetUnitType : csMappings.keyset()){
            String csId = csMappings.get(streetUnitType);
            if(String.isNotBlank(csId))
                validCSStreetUnitTypes.put(csStreetUnitTypes.get(streetUnitType), csId);
        }        
        
        return validCSStreetUnitTypes;
    }  
    
    public static Map<String, String> getCSCityAll(List<String> longValues, String objectType) {
        Map<String,String> csLongValues = new Map<String,String>();
        Map<String,String> validLongValues = new Map<String,String>();
        //
        //  EM retiring this code 8-8-2016
        /*
        if(longValues.Size() > 0) {
            for(String longValue : longValues)
                csLongValues.put(longValue.toUpperCase(),longValue);
            
            Map<String,String> csMappings = new Map<String,String>();
            if ('ACCOUNT'.equals(objectType)) {
                csMappings = queryCMLongValue('Office/city',csLongValues.keyset());
            } else if ('SUBSCRIPTION'.equals(objectType)){
                csMappings = queryCMLongValue('Agent/city',csLongValues.keyset());
            } else {
                System.debug('Error in the objectType.  The object type is not recognized --> ' + objectType);
            }
            
            for(String longValue : csLongValues.keyset()){
                String csId = csMappings.get(longValue);
                if(String.isNotBlank(csId))
                    validLongValues.put(csLongValues.get(longValue), csId);
            }
        }
        */
          // 
         //EM end retiring this code 8-8-2016
         
        //EM new code - 8-8-2016
        
        if(longValues.Size() > 0) {
            for(String longValue : longValues)
                csLongValues.put(longValue.toUpperCase(),longValue);
                
          for(String longValue : csLongValues.keyset()){               
               String CityValue= longValue.left(longValue.indexOf('-'));
               validLongValues.put(csLongValues.get(longValue), CityValue);
           }
         }
         // EM end - new code
        return validLongValues;
    }                          
}