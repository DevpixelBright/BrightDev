trigger QAScombinedAccountTrigger on Account (before insert, before update) {

    if (Utils.BypassValidationrules())
        return;
    
    if (!executionFlowUtility.accountUpdate)
        return;

    if(Utils.ByPassPersonAccounts(trigger.new)) 
        return;
    // this is for data management account
     //if(Utils.ByPassDataManagementAccounts(trigger.new)) 
     //  return;
    
    /* QAS required code */    
     //QAS_NA.RecordStatusSetter.InvokeRecordStatusSetterConstrained(trigger.new, trigger.old, trigger.IsInsert, 2); 
    
    /* Smart Street Address Validation*/ 
    SSV_AddressValidation.setAddressValidationStatus(trigger.oldMap, trigger.New, trigger.isInsert);    
    
    /* Mandatory fields validation */
    List<String> accoutNames = new List<String>();
    /* List for validation of cs address components */
    List<String> cities = new List<String>();
    List<String> states = new List<String>();
    List<String> streetDirections = new List<String>();
    List<String> counties = new List<String>();
    List<String> streetTypes = new List<String>();
    List<String> streetUnitTypes = new List<String>();
    List<String> cityLongValue = new List<String>();
    List<String> countyLongValue = new List<String>();
    
    /* Street type mapping */
    Map<String, String> streetTypesMap = new Map<String, String> {
        'BLFS' => 'UNDEFINED, UNDEF','BLTY' => 'UNDEFINED, UNDEF','BRKS' => 'UNDEFINED, UNDEF','BGS' => 'UNDEFINED, UNDEF',
        'CTRS' => 'UNDEFINED, UNDEF','CIRS' => 'UNDEFINED, UNDEF','CLF' => 'UNDEFINED, UNDEF', 'CMNS' => 'UNDEFINED, UNDEF',
        'CVS' => 'UNDEFINED, UNDEF','DRS' => 'UNDEFINED, UNDEF','EXTS' => 'UNDEFINED, UNDEF', 'FLT' => 'UNDEFINED, UNDEF',
        'FRDS' => 'UNDEFINED, UNDEF','FRGS' => 'UNDEFINED, UNDEF', 'GDN' => 'UNDEFINED, UNDEF','GLNS' => 'UNDEFINED, UNDEF',
        'GRNS' => 'UNDEFINED, UNDEF','GRVS' => 'UNDEFINED, UNDEF','HBRS' => 'UNDEFINED, UNDEF','JCTS' => 'UNDEFINED, UNDEF',
        'LGTS' => 'UNDEFINED, UNDEF', 'LF' => 'UNDEFINED, UNDEF','MNRS' => 'UNDEFINED, UNDEF','MTWY' => 'UNDEFINED, UNDEF',
        'OPAS' => 'UNDEFINED, UNDEF','PARK' => 'UNDEFINED, UNDEF','PKWY' => 'UNDEFINED, UNDEF','PNE' => 'UNDEFINED, UNDEF',
        'PTS' => 'UNDEFINED, UNDEF','PRTS' => 'UNDEFINED, UNDEF','RAMP' => 'UNDEFINED, UNDEF','RPD' => 'UNDEFINED, UNDEF',
        'RDGS' => 'UNDEFINED, UNDEF','RDS' => 'UNDEFINED, UNDEF','RUE' => 'UNDEFINED, UNDEF','SKWY' => 'UNDEFINED, UNDEF',
        'SPUR' => 'UNDEFINED, UNDEF','SQS' => 'UNDEFINED, UNDEF','TRWY' => 'UNDEFINED, UNDEF','TRAK' => 'UNDEFINED, UNDEF',
        'TRFY' => 'UNDEFINED, UNDEF','UPAS' => 'UNDEFINED, UNDEF','UNS' => 'UNDEFINED, UNDEF','VLYS' => 'UNDEFINED, UNDEF',
        'VLGS' => 'UNDEFINED, UNDEF','WALK' => 'UNDEFINED, UNDEF','WAYS' => 'UNDEFINED, UNDEF','WL' => 'UNDEFINED, UNDEF',
        'ST' => 'STREET, ST','ALY' => 'ALLEY, ALY','ANX' => 'ANNEX, ANX','ARC' => 'ARCADE, ARC','AVE' => 'AVENUE, AVE',
        'BYU' => 'BAYOU, BYU','BCH ' => 'BEACH, BCH','BLF ' => 'BLUFF, BLF','BTM' => 'BOTTOM, BTM','BLVD' => 'BOULEVARD, BLVD',
        'BR' => 'BRANCH, BR','BRG' => 'BRIDGE, BRG','BRK' => 'BROOK, BRK','BG' => 'BURG, BG','BYP' => 'BYPASS, BYP',
        'CP' => 'CAMP, CP','CYN' => 'CANYON, CYN','CPE' => 'CAPE, CPE','CSWY' => 'CAUSEWAY, CSWY','CTR' => 'CENTER, CTR',
        'CIR' => 'CIRCLE, CIR','CLFS' => 'CLIFFS, CLFS','CLB' => 'CLUB, CLB','CMN' => 'COMMON, COM','COR' => 'CORNER, COR',
        'CORS' => 'CORNERS, CORS','CRSE' => 'COURSE, CRSE','CT' => 'COURT, CT','CTS' => 'COURTS, CTS','CV' => 'COVE, CV',
        'CRK' => 'CREEK, CRK','CRES' => 'CRESCENT, CRES','XING' => 'CROSSING, XING','XRD' => 'CROSSROAD, XRD',
        'XRDS' => 'CROSSROADS, XRDS','CURV' => 'CURVE, CURV','DL' => 'DALE, DL','DM' => 'DAM, DM','DV' => 'DIVIDE, DV',
        'DR' => 'DRIVE, DR','EST' => 'ESTATE, EST','ESTS' => 'ESTATES, ESTS','EXPY' => 'EXPRESSWAY, EXPY','EXT' => 'EXTENSION, EXT',
        'FALL' => 'FALL, FL','FLS' => 'FALLS, FLS','FRY' => 'FERRY, FRY','FLD' => 'FIELD, FLD','FLDS' => 'FIELDS, FLDS',
        'FLTS' => 'FLATS, FLT','FRD' => 'FORD, FRD','FRST' => 'FOREST, FRST','FRG' => 'FORGE, FRG','FRK' => 'FORK, FRK',
        'FRKS' => 'FORKS, FRKS','FT' => 'FORT, FT','FWY' => 'FREEWAY, FWY','GDNS' => 'GARDENS, GDNS','GTWY' => 'GATEWAY, GTWY',
        'GLN' => 'GLEN, GLN','GRN' => 'GREEN, GRN','GRV' => 'GROVE, GRV','HBR' => 'HARBOR, HBR','HVN' => 'HAVEN, HVN',
        'HTS' => 'HEIGHTS, HTS','HWY' => 'HIGHWAY, HWY','HOLW' => 'HOLLOW, HOLW','INLT' => 'INLET, INLT','IS' => 'ISLAND, ISL',
        'ISS' => 'ISLANDS, ISS','ISLE' => 'ISLE, ISLE','JCT' => 'JUNCTION, JCT','KY' => 'KEY, KY','KYS' => 'KEYS, KYS',
        'KNL' => 'KNOLL, KNL','KNLS' => 'KNOLLS, KNLS','LK' => 'LAKE, LK','LKS' => 'LAKES, LKS','LAND' => 'LAND, LAND',
        'LNDG' => 'LANDING, LNDG','LN' => 'LANE, LN','LGT' => 'LIGHT, LGT','LCK' => 'LOCK, LCK','LCKS' => 'LOCKS, LCKS',
        'LDG' => 'LODGE, LDG','LOOP' => 'LOOP, LOOP','MALL' => 'MALL, MALL','MNR' => 'MANOR, MNR','MDW' => 'MEADOW, MDW',
        'MDWS' => 'MEADOWS, MDWS','MEWS' => 'MEWS, MEWS','ML' => 'MILL, ML','MLS' => 'MILLS, MLS','MSN' => 'MISSION, MSN',
        'MT' => 'MOUNT, MT','MTN' => 'MOUNTAIN, MTN','MTNS' => 'MOUNTAINS, MTNS','NCK' => 'NECK, NCK','ORCH' => 'ORCHARD, ORCHT',
        'OVAL' => 'OVAL, OVAL','PARK' => 'PARK, PARK','PKWY' => 'PARKWAY, PKWY','PASS' => 'PASS, PASS','PSGE' => 'PASSAGE, PSGE',
        'PATH' => 'PATH, PATH','PIKE' => 'PIKE, PIKE','PNES' => 'PINES, PNES','PL' => 'PLACE, PL','PLN' => 'PLAIN, PLN',
        'PLNS' => 'PLAINS, PLNS','PLZ' => 'PLAZA, PLZ','PT' => 'POINT, PT','PRT' => 'PORT, PRT','PR' => 'PRAIRIE, PR',
        'RADL' => 'RADIAL, RADL','RNCH' => 'RANCH, RNCH','RPDS' => 'RAPIDS, RPDS','RST' => 'REST, RST','RDG' => 'RIDGE, RDG',          
        'RIV' => 'RIVER, RIV','RD' => 'ROAD, RD','RTE' => 'ROUTE, RTE','ROW' => 'ROW, ROW','RUN' => 'RUN, RUN',
        'SHL' => 'SHOAL, SHL','SHLS' => 'SHOALS, SHLS','SHR' => 'SHORE, SHR','SPG' => 'SPRING, SPG','SPGS' => 'SPRINGS, SPGS',
        'SPUR' => 'SPUR, SPUR','SQ' => 'SQUARE, SQ','STA' => 'STATION, STA','STRA' => 'STRAVENUE, STV','STRM' => 'STREAM, STRM',
        'STS' => 'STREETS, STS','SMT' => 'SUMMIT, SMT','TER' => 'TERRACE, TER','TRCE' => 'TRACE, TRCE','TRL' => 'TRAIL, TRL',
        'TRLR' => 'TRAILER, TRLR','TUNL' => 'TUNNEL, TUNL','TPKE' => 'TURNPIKE, TPKE','UN' => 'UNION, UN','VLY' => 'VALLEY, VLY',
        'VIA' => 'VIADUCT, VIA','VW' => 'VIEWS, VWS','VLG' => 'VILLAGE, VLG','VL' => 'VILLE, VL','VIS' => 'VISTA, VIS',
        'WALK' => 'WALK, WALK','WALL' => 'WALL, WL','WAY' => 'WAY, WAY','WLS' => 'WELLS, WLS','BLFS' => 'BLUFFS , BLFS',
        'BRKS' => 'BROOKS , BRKS','BGS' => 'BURGS , BGS','CTRS' => 'CENTERS , CTRS','CIRS' => 'CIRCLES , CIRS',
        'CLF' => 'CLIFF , CLF','CMNS' => 'COMMONS , CMNS','CVS' => 'COVES , CVS','DRS' => 'DRIVES , DRS',
        'EXTS' => 'EXTENSIONS , EXTS','FLT' => 'FLAT , FLT','FRDS' => 'FORDS , FRDS','FRGS' => 'FORGES , FRGS',
        'GDN' => 'GARDEN , GDN','GLNS' => 'GLENS , GLNS','GRNS' => 'GREENS , GRNS','GRVS' => 'GROVES , GRVS',
        'HBRS' => 'HARBORS , HBRS','JCTS' => 'JUNCTIONS , JCTS','LGTS' => 'LIGHTS , LGTS','LF' => 'LOAF , LF',
        'MNRS' => 'MANORS , MNRS','MTWY' => 'MOTORWAY , MTWY','OPAS' => 'OVERPASS , OPAS','PNE' => 'PINE , PNE',
        'PTS' => 'POINTS , PTS','PRTS' => 'PORTS , PRTS ','RAMP' => 'RAMP , RAMP','RPD' => 'RAPID , RPD','RDGS' => 'RIDGES , RDGS ',
        'RDS' => 'ROADS , RDS','RUE' => 'RUE , RUE','SKWY' => 'SKYWAY , SKWY','SQS' => 'SQUARES , SQS',
        'TRWY' => 'THROUGHWAY , TRWY','TRAK' => 'TRACK , TRAK','TRFY' => 'TRAFFICWAY , TRFY','UPAS' => 'UNDERPASS , UPAS ',
        'UNS' => 'UNIONS , UNS ','VLYS' => 'VALLEYS , VLYS','VLGS' => 'VILLAGES , VLGS','WAYS' => 'WAYS , WAYS',
        'WL' => 'WELL , WL'                                           
    };
    
    /* Mailing directions */
    Map<String, String> streetDirectionsMap = new Map<String, String> {
        'N' => 'N, NORTH', 'E' => 'E, EAST', 'S' => 'S, SOUTH', 'W' => 'W, WEST', 'NE' => 'NE, NORTHEAST', 'SE' => 'SE, SOUTHEAST', 
        'NW' => 'NW, NORTHWEST', 'SW' => 'SW, SOUTHWEST'
    };
    
    /* Mailing unit types */
    Map<String, String> unitTypesMap = new Map<String, String> {
        'APT' => 'APT, APARTMENT','BSMT' => 'BSMT, BASEMENT','BLDG' => 'BLDG, BUILDING','DEPT' => 'DEPT, DEPARTMENT',
        'FL' => 'FL, FLOOR','FRNT' => 'FRNT, FRONT','HNGR' => 'HNGR, HANGAR','KEY' => 'KEY, KEY','LBBY' => 'LBBY, LOBBY',
        'LOT' => 'LOT, LOT','LOWR' => 'LOWR, LOWER','OFC' => 'OFC, OFFICE','PH' => 'PH, PENTHOUSE','PIER' => 'PIER, PIER',
        'REAR' => 'REAR, REAR','RM' => 'RM, ROOM','SIDE' => 'SIDE, SIDE','SLIP' => 'SLIP, SLIP','SPC' => 'SPC, SPACE',
        'STOP' => 'STOP, STOP','STE' => 'STE, SUITE','TRLR' => 'TRLR, TRAILER','UNIT' => 'UNIT, UNIT','UPPR' => 'UPPR, UPPER'        
    };
    
    /* Get Admin User to update account owner */
    //User u = [SELECT Id, Name FROM User WHERE Name = 'Admin User'];                      
        
    for(Account a : Trigger.new) {  
        if(String.isBlank(a.Primary_Service_Jurisdiction__c)) 
            a.Primary_Service_Jurisdiction__c = 'MRIS';

        if(a.QAS_Mailing_POBox__c != null && !a.QAS_Mailing_POBox__c.isNumeric())
            a.addError('POBox should be numeric!');
             
        if(a.QAS_Mailing_County__c == null && a.County__c == null)
            a.adderror('County is a mandatory field');
            
        if(!a.Copy_Address_to_Billing__c && a.QAS_Billing_POBox__c != null && !a.QAS_Billing_POBox__c.isNumeric())
            a.addError('Billing POBox should be numeric!'); 
            
        
        if(a.QAS_Mailing_Street_Type__c != null && streetTypesMap.get(a.QAS_Mailing_Street_Type__c.toUpperCase()) != null) 
            a.Street_Type__c = streetTypesMap.get(a.QAS_Mailing_Street_Type__c.toUpperCase());
        else
           a.Street_Type__c = 'UNDEFINED, UNDEF';
           
                   
        if(a.QAS_Mailing_Street_Direction__c != null && streetDirectionsMap.get(a.QAS_Mailing_Street_Direction__c.toUpperCase()) != null) 
            a.Street_Direction__c = streetDirectionsMap.get(a.QAS_Mailing_Street_Direction__c.toUpperCase());
      
        if(a.QAS_Mailing_Unit_Type__c != null && unitTypesMap.get(a.QAS_Mailing_Unit_Type__c.toUpperCase()) != null) 
            a.Unit_Type__c = unitTypesMap.get(a.QAS_Mailing_Unit_Type__c.toUpperCase());
                                                               
        /* County update */
        if(a.QAS_Mailing_County__c == 'DISTRICT OF COLUMBIA')
            a.County__c = 'WASHINGTON';
        else if(a.QAS_Mailing_County__c != null)
            a.County__c = a.QAS_Mailing_County__c;
            
        /* Country update */
        if(a.QAS_Mailing_Country__c == 'USA')
            a.Country__c = 'UNITED STATES OF AMERICA';
        if(a.QAS_Mailing_Country__C == 'CAN')
            a.Country__c = 'CANADA';  
            
        /* POBOX fill */ 
        if(a.QAS_Mailing_Record_Type__c == 'P') {
            if(a.QAS_Mailing_POBox__c != null) {
                String mailingPOBox = a.QAS_Mailing_POBox__c;
                
                if((mailingPOBox).contains('PO BOX'))
                    mailingPOBox = mailingPOBox.remove('PO BOX ');
                      
                a.QAS_Mailing_POBox__c = mailingPOBox;
                a.Addl_Display_Name__c = a.QAS_Mailing_POBox__c;
            }
            a.Street_Type__c = '';
            a.Street_Direction__c = '';
            a.Unit_Type__c = '';
        }
        else
            a.Addl_Display_Name__c = ''; 
        
        /* Copy billing address flag is set to true */
        if(a.Copy_Address_to_Billing__c == true) {
            a.Billing_Addl_Display_Name__c = a.Addl_Display_Name__c;
            a.Billing_Box__c = a.Box__c;
            a.Billing_City__c = a.City__c;
            a.QAS_Billing_Country__c = a.QAS_Mailing_Country__c;
            a.QAS_Billing_County__c = a.QAS_Mailing_County__c;
            a.Billing_State__c = a.State__c;
            a.QAS_Billing_Street_Direction__c = a.QAS_Mailing_Street_Direction__c;
            a.Billing_Street_Name__c = a.Street_Name__c;
            a.Billing_Street_Number__c = a.Street_Number__c;
            a.Billing_Street_Number_Suffix__c = a.Street_Number_Suffix__c;
            a.QAS_Billing_Street_Type__c = a.QAS_Mailing_Street_Type__c;
            a.Billing_Unit_Number__c = a.Unit__c;
            a.QAS_Billing_Unit_Type__c = a.QAS_Mailing_Unit_Type__c;
            a.Billing_Zip__c = a.Zip__c;
            a.Billing_Zip_4__c = a.Zip_4__c;
            a.QAS_Billing_POBox__c = a.QAS_Mailing_POBox__c;
            a.QAS_Billing_Record_Type__c = a.QAS_Mailing_Record_Type__c;
            
            a.Billing_Street_Type__c = a.Street_Type__c;
            a.Billing_Street_Direction__c = a.Street_Direction__c;
            a.Billing_Unit_Type__c = a.Unit_Type__c; 
            a.Billing_County__c = a.County__c;
            a.Billing_Country__c = a.Country__c;           
        }
        else {
            /* Street type mapping */
            if(a.QAS_Billing_Street_Type__c != null && streetTypesMap.get(a.QAS_Billing_Street_Type__c) != null) 
                a.Billing_Street_Type__c = streetTypesMap.get(a.QAS_Billing_Street_Type__c);
            else
               a.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
              
            
            /* Billing street directions mapping */ 
            if(a.QAS_Billing_Street_Direction__c != null && streetDirectionsMap.get(a.QAS_Billing_Street_Direction__c) != null) 
                a.Billing_Street_Direction__c = streetDirectionsMap.get(a.QAS_Billing_Street_Direction__c);
            
            /* Billing unit type mapping */
            if(a.QAS_Billing_Unit_Type__c != null && unitTypesMap.get(a.QAS_Billing_Unit_Type__c) != null) 
                a.Billing_Unit_Type__c = unitTypesMap.get(a.QAS_Billing_Unit_Type__c);
            
            /* Billing county update */
            if(a.QAS_Billing_County__c == 'DISTRICT OF COLUMBIA')
                a.Billing_County__c = 'WASHINGTON';
            else if(a.QAS_Billing_County__c != null)
                a.Billing_County__c = a.QAS_Billing_County__c; 
            
            /* Billing country update */    
            if(a.QAS_Billing_Country__c == 'USA')
                a.Billing_Country__c ='UNITED STATES OF AMERICA';
            if(a.QAS_Billing_Country__C == 'CAN')
                a.Billing_Country__c = 'CANADA';
                
            if(a.QAS_Billing_Record_Type__c == 'P') {
                if(a.QAS_Billing_POBox__c != null) {
                    String billingPOBox = a.QAS_Billing_POBox__c;
                    
                    if((billingPOBox).contains('PO BOX'))
                        billingPOBox = billingPOBox.remove('PO BOX ');
                  
                    a.QAS_Billing_POBox__c = billingPOBox;
                    a.Billing_Addl_Display_Name__c = a.QAS_Billing_POBox__c;
                }
                a.Billing_Street_Type__c = '';
                a.Billing_Street_Direction__c = '';
                a.Billing_Unit_Type__c = '';
            }
            else
                a.Billing_Addl_Display_Name__c = '';              
        }     
        
        /* Add account names to list for name validation */
        accoutNames.add(a.Name); 
        if(String.isNotBlank(a.City__c))
            cities.add(a.City__c);
        if(String.isNotBlank(a.State__c))
            states.add(a.State__c);
        if(String.isNotBlank(a.Street_Direction__c))
            streetDirections.add(a.Street_Direction__c);
        if(String.isNotBlank(a.County__c))
            counties.add(a.County__c);
        if(String.isNotBlank(a.Street_Type__c))
            streetTypes.add(a.Street_Type__c);
        if(String.isNotBlank(a.Unit_Type__c))
            streetUnitTypes.add(a.Unit_Type__c);
        if(String.isNotBlank(a.City__c) && String.isNotBlank(a.County__c) && String.isNotBlank(a.State__c)) 
            cityLongValue.add(a.City__c + '-' + a.County__c + '-' + a.State__c);   
        //    
        if(String.isNotBlank(a.County__c) && String.isNotBlank(a.State__c)) 
        countyLongValue.add(a.County__c + '-' + a.State__c);   
        //                
        
        System.debug('*** streetDirections:' + streetDirections);
        
        if(trigger.isUpdate) {
            if (Trigger.oldMap.get(a.Id).Shareholder_Board__c != a.Shareholder_Board__c) {
               System.debug('*** Shareholder has changed: ' + a.id);
               if(a.CS_Shareholder_ID__c != null && !'Yes'.equals(a.Shareholder_Board__c)) {
                  a.CS_Shareholder_ID__c = null;
               }
            }
            
        if('Active'.equals(Trigger.oldMap.get(a.Id).Status__c) && 'Inactive'.equals(a.Status__c)) {
            a.CS_AccountTypeRole_ID__c = null;
            a.Date_Terminated__c = Date.today();
        }
        
            string todayDate = DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');           
           // a.SourceModificationTimestamp__c = todayDate;
       }
        
        /* Workflow field update on account - replacement */ 
        a.BrokerAddress__c = a.Full_Street_Address__c;
        //a.OwnerId = u.Id;
                                                      
    }     

    /* Check whether account names already exists or not */
    List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE Name IN :accoutNames];
    System.debug('*** existingAccounts:' + existingAccounts);
    System.debug('*** states:' + states);
    
    /* Get cs address validation results */
    Set<String> csCityValidationResult = new Set<String>();
    Set<String> csStateValidationResult = new Set<String>();   
    Set<String> csStreetDirectionValidationResult = new Set<String>();
    Set<String> csCountyValidationResult = new Set<String>();
    Set<String> csStreetTypeValidationResult = new Set<String>();
    Set<String> csStreetUnitTypeValidationResult = new Set<String>();
    Set<String> cityLongValueValidationResult = new Set<String>();
    
    if(cities.Size() > 0)
        csCityValidationResult = AddressUtility.validateCSCity('ACCOUNT', cities);
    if(states.Size() > 0)
        csStateValidationResult = AddressUtility.validateCSState('ACCOUNT', states); 
    if(streetDirections.Size() > 0)
        csStreetDirectionValidationResult = AddressUtility.validateCSStreetDirection('ACCOUNT', streetDirections);
    if(counties.Size() > 0)
        //csCountyValidationResult = AddressUtility.validateCSCounty('ACCOUNT', counties);
        csCountyValidationResult = AddressUtility.validateCSCounty('ACCOUNT', countyLongValue);
    if(streetTypes.Size() > 0)
        csStreetTypeValidationResult = AddressUtility.validateCSStreetType('ACCOUNT', streetTypes);
    if(streetUnitTypes.Size() > 0)
        csStreetUnitTypeValidationResult = AddressUtility.validateCSStreetUnitTypes('ACCOUNT', streetUnitTypes);
    if(cityLongValue.Size() > 0)
        cityLongValueValidationResult = AddressUtility.validateCSCityAll('ACCOUNT', cityLongValue);
        
    System.debug('*** csStreetDirectionValidationResult :' + csStreetDirectionValidationResult);

    for (Account a : Trigger.new) {
        Integer accCount = 0;
        for(Account existingAccount : existingAccounts) {
            if((Trigger.isInsert && existingAccount.Name == a.name) || (Trigger.isUpdate && existingAccount.Id != a.Id && existingAccount.Name == a.name))
                accCount++;
        }
        
        if (accCount > 0) 
            a.adderror('The Office ID "' + a.name + '" already exists.  Please enter a new Office ID');         
        
        system.debug('a.Primary_Service_Jurisdiction__c: ' + a.Primary_Service_Jurisdiction__c);
        system.debug('a.Secondary_Service_Jurisdiction__c : ' + a.Secondary_Service_Jurisdiction__c );

        if((a.Primary_Service_Jurisdiction__c != 'MRIS' && a.Secondary_Service_Jurisdiction__c != 'MRIS') &&
           (String.isNotBlank(a.Primary_Service_Jurisdiction__c))
          ){
            system.debug('Bypass if not MRIS: ' + a.Id);
            continue;    
        }  
             
        if(csCityValidationResult.Size() > 0 && !(csCityValidationResult.Contains(a.City__c)))
            a.adderror('Invalid City "' + a.City__c + '". ' + 'Does not match with Cornerstone');
            
        if(csStateValidationResult.Size() > 0 && !(csStateValidationResult.Contains(a.State__c)))
            a.adderror('Invalid State "' + a.State__c+ '". ' + 'Does not match with Cornerstone'); 
            
        if(csStreetDirectionValidationResult.Size() > 0 && !(csStreetDirectionValidationResult.Contains(a.Street_Direction__c)))
            a.adderror('Invalid Street Direction "' + a.Street_Direction__c + '". ' + 'Does not match with Cornerstone'); 
        //if(csCountyValidationResult.Size() > 0 && !(csCountyValidationResult.Contains(a.County__c)))    
        if(csCountyValidationResult.Size() > 0 && !(csCountyValidationResult.Contains(a.County__c+'-' + a.State__c)))
            a.adderror('Invalid County "' + a.County__c+ '". ' + 'Does not match with Cornerstone');
        
          
        if(a.Street_Type__c != 'UNDEFINED, UNDEF' && csStreetTypeValidationResult.Size() > 0 && !(csStreetTypeValidationResult.Contains(a.Street_Type__c))) {
            System.debug('*** a.Street_Type__c:' + a.Street_Type__c);
            a.adderror('Invalid Street Type "' + a.Street_Type__c+ '". ' + 'Does not match with Cornerstone');
        }
            
        if(csStreetUnitTypeValidationResult.Size() > 0 && !(csStreetUnitTypeValidationResult.Contains(a.Unit_Type__c)))
            a.adderror('Unit Type "' + a.Unit_Type__c+ '". ' + 'Does not match with Cornerstone'); 
            
        /* Added for B-03924 */
        if(cityLongValueValidationResult.Size() > 0 && !(cityLongValueValidationResult.Contains(a.City__c + '-' + a.County__c + '-' + a.State__c))) 
            a.adderror('Invalid City-County-State "' + a.City__c.toUpperCase() + '-' + a.County__c.toUpperCase() + '-' + a.State__c.toUpperCase() + '". ' + 'Does not match with Cornerstone');                                                                               
   }
    
    /* Before update validation process*/
    map<String,Integer> getChildAccounts{
        get{
            if(getChildAccounts == null){
                getChildAccounts = new map<String,Integer>();
                    for(AggregateResult acc:[SELECT count(id),parentId FROM Account WHERE Status__c = 'Active' AND parentId IN:Trigger.newMap.keySet() group by parentId]){
                        getChildAccounts.put(String.valueOf(acc.get('parentId')),Integer.valueOf(acc.get('expr0')));
                    }
            }
            return getChildAccounts;
        } private set;
    }    
    
    if(trigger.isUpdate) { 
       
        map<Id,Account> objAccounts = new map<Id,Account>([Select Company_Type__c,Num_Active_Subs__c, Num_Active_Office_Sec_NC__c,Status__c, 
        (Select Name,Status__c,Subscription_type__c,Contact_Type__c,Primary__c From Subscriptions__r where status__c='Active'), 
        (Select Name,Status__c From Contacts where status__c='Active') From Account where id IN:Trigger.new]);
    
        /*Itrate all updatable Account*/
        for (Account ac: objAccounts.values()) {
            if(Trigger.newMap.get(ac.Id).Status__c.equalsIgnoreCase('Inactive') && Trigger.oldMap.get(ac.Id).Status__c.equalsIgnoreCase('Active')) {
                if('Broker Office'.equals(ac.Company_Type__c) && getChildAccounts.get(ac.Id) != null) {
                    if(getChildAccounts.get(ac.Id) > 0) {
                        Trigger.newMap.get(ac.Id).addError('Broker Office must not be deactivated until all the branch offices for the Broker office are inactive.');
                        break;
                    }
                }
                for(subscriptions__c s:ac.Subscriptions__r) {                
                    if(s.Primary__c) {
                        Trigger.newMap.get(ac.Id).addError('The Account cannot be inactivated with Active Primary Subscriptions('+s.Name+
                        ').Please verify that all Primary Subscriptions have been inactivated before proceeding.');
                        break;
                    }else{
                        Trigger.newMap.get(ac.Id).addError('The Account cannot be inactivated with Active Contacts/Subscriptions. Please verify all Contacts/Subscriptions are inactivated before proceeding.');
                        break;
                    }           
                }
                for(Contact c:ac.Contacts) {
                    Trigger.newMap.get(ac.Id).addError('The Account cannot be inactivated with Active Contacts/Subscriptions. Please verify all Contacts/Subscriptions are inactivated before proceeding.');
                    break;                                  
                }
            }
            /*else {
                for(Account a: Trigger.new) {
                    a.Num_Active_Office_Sec_NC__c  = 0;
                    a.Num_Active_Subs__c = 0;
                    for(subscriptions__c s:objAccounts.get(a.Id).Subscriptions__r) {
                        if('Active'.equalsIgnoreCase(s.Status__c) && 'Office Secretary - NC'.equals(s.Subscription_type__c)) 
                            a.Num_Active_Office_Sec_NC__c++;
                            
                        if('Active'.equalsIgnoreCase(s.Status__c) 
                        && ('Realtor/Shareholder'.equals(s.Subscription_Type__c) 
                        || 'Realtor/Non Shareholder'.equals(s.Subscription_Type__c)
                        || 'Licensee/Non Realtor'.equals(s.Subscription_Type__c))
                        && ('Agent'.equals(s.Contact_Type__c)
                        || 'Broker'.equals(s.Contact_Type__c)
                        || 'Office Manager'.equals(s.Contact_Type__c))) {  
                            a.Num_Active_Subs__c++;
                        }
                    }
                } 
            } */                  
        }                                
    }
     
}