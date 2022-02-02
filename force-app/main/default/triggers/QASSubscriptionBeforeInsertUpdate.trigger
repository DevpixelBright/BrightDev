trigger QASSubscriptionBeforeInsertUpdate on Subscriptions__c (before insert, before update) {
/*
    This trigger has been added to improvise the current trigger QASSubscriptionBeforeInsertUpdate
*/

    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;
    
    // QAS required code
    //QAS_NA.RecordStatusSetter.InvokeRecordStatusSetterConstrained(trigger.new,trigger.old,trigger.IsInsert,2);
    
    /* Smart Street Address Validation*/ 
    SSV_AddressValidation.setAddressValidationStatus(trigger.oldMap, trigger.New, trigger.isInsert);       
    
    
    if(trigger.isBefore && trigger.isUpdate){
        // update conversion fields on subscription
        ConversionTransit.subscriptionConversionFieldsUpdate(trigger.oldMap, trigger.NewMap);
        //SubscriptionTriggerHandler.inactivateRetsProductOrder(trigger.NewMap);
    }
    
    Set<String> RLBOIds = new Set<String>();
    Map<String, Integer> RLOBSizeMap = new Map<String, Integer>();
    List<Subscriptions__c> RETSSubs = new List <Subscriptions__c>();
    Integer counter = 0;
    List<String> contactIds = new List<String>();
    Map<String,Contact> subContacts = new Map<String,Contact>();
    
    List<Contact> updatedContacts = new List<Contact>();
    
    List<String> csCities = new List<String>();
    List<String> csStates = new List<String>();
    List<String> csCounties = new List<String>();
    List<String> csCityAll = new List<String>();
    List<String> csCountyAll = new List<String>();
    
    List<String> csCountries = new List<String>();    
    List<String> csStreetDirections = new List<String>();
    List<String> csStreetTypes = new List<String>();
    List<String> csStreetUnitTypes = new List<String>();
    
    Set<String> validCities = new Set<String>();
    Set<String> validStates = new Set<String>();
    Set<String> validCounties = new Set<String>();
    Set<String> validCSCountyAll = new Set<String>();    
    Set<String> validStreetDirections = new Set<String>(); 
    Set<String> validStreetTypes = new Set<String>();
    Set<String> validStreetUnitTypes = new Set<String>();
    Set<String> validCSCityAll = new Set<String>(); 
    
    /*
        Feild Mappings
        1. QAS_Mailing_Street_Type__c = Street_Type__c
        2. QAS_Mailing_Street_Direction__c = Street_Direction__c 
        3. QAS_Mailing_Unit_Type__c = Unit_Type__c 
        4. QAS_Billing_Street_Type__c = Billing_Street_Type__c 
        5. QAS_Billing_Street_Direction__c = Billing_Street_Direction__c 
        6. QAS_Billing_Unit_Type__c = Billing_Unit_Type__c 
        7. QAS_Mailing_County__c = County__c 
        8. QAS_Billing_County__c = Billing_County__c 
        9. QAS_Mailing_Country__c = Country__c 
        10. QAS_Billing_Country__c = Billing_Country__c 

    */
    
    Map<String,String> streetTypesMap = new Map<String,String> {
    'BLFS'=>'UNDEFINED, UNDEF','BRKS'=>'UNDEFINED, UNDEF','BLTY'=>'UNDEFINED, UNDEF','BGS'=>'UNDEFINED, UNDEF','CTRS'=>'UNDEFINED, UNDEF',
    'CIRS'=>'UNDEFINED, UNDEF','CLF'=>'UNDEFINED, UNDEF','CMNS'=>'UNDEFINED, UNDEF','CVS'=>'UNDEFINED, UNDEF','DRS'=>'UNDEFINED, UNDEF',
    'EXTS'=>'UNDEFINED, UNDEF','FLT'=>'UNDEFINED, UNDEF','FRDS'=>'UNDEFINED, UNDEF','FRGS'=>'UNDEFINED, UNDEF','GDN'=>'UNDEFINED, UNDEF',
    'GLNS'=>'UNDEFINED, UNDEF','GRNS'=>'UNDEFINED, UNDEF','GRVS'=>'UNDEFINED, UNDEF','HBRS'=>'UNDEFINED, UNDEF','JCTS'=>'UNDEFINED, UNDEF',
    'LGTS'=>'UNDEFINED, UNDEF','LF'=>'UNDEFINED, UNDEF','MNRS'=>'UNDEFINED, UNDEF','MTWY'=>'UNDEFINED, UNDEF','OPAS'=>'UNDEFINED, UNDEF',
    'PARK'=>'UNDEFINED, UNDEF','PKWY'=>'UNDEFINED, UNDEF','PNE'=>'UNDEFINED, UNDEF','PTS'=>'UNDEFINED, UNDEF','PRTS'=>'UNDEFINED, UNDEF',
    'RAMP'=>'UNDEFINED, UNDEF','RPD'=>'UNDEFINED, UNDEF','RDGS'=>'UNDEFINED, UNDEF','RDS'=>'UNDEFINED, UNDEF','RUE'=>'UNDEFINED, UNDEF',
    'SKWY'=>'UNDEFINED, UNDEF','SPUR'=>'UNDEFINED, UNDEF','SQS'=>'UNDEFINED, UNDEF','TRWY'=>'UNDEFINED, UNDEF','TRAK'=>'UNDEFINED, UNDEF',
    'TRFY'=>'UNDEFINED, UNDEF','UPAS'=>'UNDEFINED, UNDEF','UNS'=>'UNDEFINED, UNDEF','VLYS'=>'UNDEFINED, UNDEF','VLGS'=>'UNDEFINED, UNDEF',
    'WALK'=>'UNDEFINED, UNDEF','WAYS'=>'UNDEFINED, UNDEF','ST'=>'STREET, ST','ALY'=>'ALLEY, ALY','ANX'=>'ANNEX, ANX','ARC'=>'ARCADE, ARC',
    'AVE'=>'AVENUE, AVE','BYU'=>'BAYOU, BYU','BCH'=>'BEACH, BCH','BLF'=>'BLUFF, BLF','BTM'=>'BOTTOM, BTM','BLVD'=>'BOULEVARD, BLVD',
    'BR'=>'BRANCH, BR','BRG'=>'BRIDGE, BRG','BRK'=>'BROOK, BRK','BG'=>'BURG, BG','BYP'=>'BYPASS, BYP','CP'=>'CAMP, CP','CYN'=>'CANYON, CYN',
    'CPE'=>'CAPE, CPE','CSWY'=>'CAUSEWAY, CSWY','CTR'=>'CENTER, CTR','CIR'=>'CIRCLE, CIR','CLFS'=>'CLIFFS, CLFS','CLB'=>'CLUB, CLB',
    'CMN'=>'COMMON, COM','COR'=>'CORNER, COR','CORS'=>'CORNERS, CORS','CRSE'=>'COURSE, CRSE','CT'=>'COURT, CT','CTS'=>'COURTS, CTS',
    'CV'=>'COVE, CV','CRK'=>'CREEK, CRK','CRES'=>'CRESCENT, CRES','XING'=>'CROSSING, XING','XRD'=>'CROSSROAD, XRD','XRDS'=>'CROSSROADS, XRDS',
    'CURV'=>'CURVE, CURV','DL'=>'DALE, DL','DM'=>'DAM, DM','DV'=>'DIVIDE, DV','DR'=>'DRIVE, DR','EST'=>'ESTATE, EST','ESTS'=>'ESTATES, ESTS',
    'EXPY'=>'EXPRESSWAY, EXPY','EXT'=>'EXTENSION, EXT','FALL'=>'FALL, FL','FLS'=>'FALLS, FLS','FRY'=>'FERRY, FRY','FLD'=>'FIELD, FLD',
    'FLDS'=>'FIELDS, FLDS','FLTS'=>'FLATS, FLT','FRD'=>'FORD, FRD','FRST'=>'FOREST, FRST','FRG'=>'FORGE, FRG','FRK'=>'FORK, FRK',
    'FRKS'=>'FORKS, FRKS','FT'=>'FORT, FT','FWY'=>'FREEWAY, FWY','GDNS'=>'GARDENS, GDNS','GTWY'=>'GATEWAY, GTWY','GLN'=>'GLEN, GLN',
    'GRN'=>'GREEN, GRN','GRV'=>'GROVE, GRV','HBR'=>'HARBOR, HBR','HVN'=>'HAVEN, HVN','HTS'=>'HEIGHTS, HTS','HWY'=>'HIGHWAY, HWY',
    'HOLW'=>'HOLLOW, HOLW','INLT'=>'INLET, INLT','IS'=>'ISLAND, ISL','ISS'=>'ISLANDS, ISS','ISLE'=>'ISLE, ISLE','JCT'=>'JUNCTION, JCT',
    'KY'=>'KEY, KY','KYS'=>'KEYS, KYS','KNL'=>'KNOLL, KNL','KNLS'=>'KNOLLS, KNLS','LK'=>'LAKE, LK','LKS'=>'LAKES, LKS','LAND'=>'LAND, LAND',
    'LNDG'=>'LANDING, LNDG','LN'=>'LANE, LN','LGT'=>'LIGHT, LGT','LCK'=>'LOCK, LCK','LCKS'=>'LOCKS, LCKS','LDG'=>'LODGE, LDG','LOOP'=>'LOOP, LOOP',
    'MALL'=>'MALL, MALL','MNR'=>'MANOR, MNR','MDW'=>'MEADOW, MDW','MDWS'=>'MEADOWS, MDWS','MEWS'=>'MEWS, MEWS','ML'=>'MILL, ML','MLS'=>'MILLS, MLS',
    'MSN'=>'MISSION, MSN','MT'=>'MOUNT, MT','MTN'=>'MOUNTAIN, MTN','MTNS'=>'MOUNTAINS, MTNS','NCK'=>'NECK, NCK','ORCH'=>'ORCHARD, ORCHT',
    'OVAL'=>'OVAL, OVAL','PARK'=>'PARK, PARK','PKWY'=>'PARKWAY, PKWY','PASS'=>'PASS, PASS','PSGE'=>'PASSAGE, PSGE','PATH'=>'PATH, PATH',
    'PIKE'=>'PIKE, PIKE','PNES'=>'PINES, PNES','PL'=>'PLACE, PL','PLN'=>'PLAIN, PLN','PLNS'=>'PLAINS, PLNS','PLZ'=>'PLAZA, PLZ','PT'=>'POINT, PT',
    'PRT'=>'PORT, PRT','PR'=>'PRAIRIE, PR','RADL'=>'RADIAL, RADL','RNCH'=>'RANCH, RNCH','RPDS'=>'RAPIDS, RPDS','RST'=>'REST, RST','RDG'=>'RIDGE, RDG',
    'RIV'=>'RIVER, RIV','RD'=>'ROAD, RD','RTE'=>'ROUTE, RTE','ROW'=>'ROW, ROW','RUN'=>'RUN, RUN','SHL'=>'SHOAL, SHL','SHLS'=>'SHOALS, SHLS',
    'SHR'=>'SHORE, SHR','SPG'=>'SPRING, SPG','SPGS'=>'SPRINGS, SPGS','SPUR'=>'SPUR, SPUR','SQ'=>'SQUARE, SQ','STA'=>'STATION, STA','STRA'=>'STRAVENUE, STV',
    'STRM'=>'STREAM, STRM','STS'=>'STREETS, STS','SMT'=>'SUMMIT, SMT','TER'=>'TERRACE, TER','TRCE'=>'TRACE, TRCE','TRL'=>'TRAIL, TRL','TRLR'=>'TRAILER, TRLR',
    'TUNL'=>'TUNNEL, TUNL','TPKE'=>'TURNPIKE, TPKE','UN'=>'UNION, UN','VLY'=>'VALLEY, VLY','VIA'=>'VIADUCT, VIA','VW'=>'VIEWS, VWS','VLG'=>'VILLAGE, VLG',
    'VL'=>'VILLE, VL','VIS'=>'VISTA, VIS','WALK'=>'WALK, WALK','WALL'=>'WALL, WL','WAY'=>'WAY, WAY','WLS'=>'WELLS, WLS','BLFS'=>'BLUFFS , BLFS',
    'BRKS'=>'BROOKS , BRKS','BGS'=>'BURGS , BGS','CTRS'=>'CENTERS , CTRS','CIRS'=>'CIRCLES , CIRS','CLF'=>'CLIFF , CLF','CMNS'=>'COMMONS , CMNS',
    'CVS'=>'COVES , CVS','DRS'=>'DRIVES , DRS','EXTS'=>'EXTENSIONS , EXTS','FLT'=>'FLAT , FLT','FRDS'=>'FORDS , FRDS','FRGS'=>'FORGES , FRGS',
    'GDN'=>'GARDEN , GDN','GLNS'=>'GLENS , GLNS','GRNS'=>'GREENS , GRNS','GRVS'=>'GROVES , GRVS','HBRS'=>'HARBORS , HBRS','JCTS'=>'JUNCTIONS , JCTS',
    'LGTS'=>'LIGHTS , LGTS','LF'=>'LOAF , LF','MNRS'=>'MANORS , MNRS','MTWY'=>'MOTORWAY , MTWY','OPAS'=>'OVERPASS , OPAS','PNE'=>'PINE , PNE',
    'PTS'=>'POINTS , PTS','PRTS'=>'PORTS , PRTS','RAMP'=>'RAMP , RAMP','RPD'=>'RAPID , RPD','RDGS'=>'RIDGES , RDGS','RDS'=>'ROADS , RDS',
    'RUE'=>'RUE , RUE','SKWY'=>'SKYWAY , SKWY','SQS'=>'SQUARES , SQS','TRWY'=>'THROUGHWAY , TRWY','TRAK'=>'TRACK , TRAK','TRFY'=>'TRAFFICWAY , TRFY',
    'UPAS'=>'UNDERPASS , UPAS','UNS'=>'UNIONS , UNS','VLYS'=>'VALLEYS , VLYS','VLGS'=>'VILLAGES , VLGS','WAYS'=>'WAYS , WAYS','WL'=>'WELL , WL'};                                            
    
    Map<String,String> streetDirectionsMap = new Map<String,String>{
        'N'=>'N, NORTH','E'=>'E, EAST','S'=>'S, SOUTH','W'=>'W, WEST',
        'NE'=>'NE, NORTHEAST','SE'=>'SE, SOUTHEAST','NW'=>'NW, NORTHWEST','SW'=>'SW, SOUTHWEST'};

    Map<String,String> unitTypesMap = new Map<String,String>{
        'APT'=>'APT, APARTMENT','BSMT'=>'BSMT, BASEMENT','BLDG'=>'BLDG, BUILDING','DEPT'=>'DEPT, DEPARTMENT','FL'=>'FL, FLOOR',
        'FRNT'=>'FRNT, FRONT','HNGR'=>'HNGR, HANGAR','KEY'=>'KEY, KEY','LBBY'=>'LBBY, LOBBY','LOT'=>'LOT, LOT','LOWR'=>'LOWR, LOWER',
        'OFC'=>'OFC, OFFICE','PH'=>'PH, PENTHOUSE','PIER'=>'PIER, PIER','REAR'=>'REAR, REAR','RM'=>'RM, ROOM','SIDE'=>'SIDE, SIDE',
        'SLIP'=>'SLIP, SLIP','SPC'=>'SPC, SPACE','STOP'=>'STOP, STOP','STE'=>'STE, SUITE','TRLR'=>'TRLR, TRAILER','UNIT'=>'UNIT, UNIT',
        'UPPR'=>'UPPR, UPPER'};  
    
    List<Subscriptions__c> trendSubscriptions = new List<Subscriptions__c>();
    List<Subscriptions__c> brightSubscriptions = new List<Subscriptions__c>();
    
    for(Subscriptions__c subscription : Trigger.new) {
        if(String.isBlank(subscription.Service_Jurisdiction__c))
            subscription.Service_Jurisdiction__c = 'MRIS';
            
        if(String.isBlank(subscription.Billing_Jurisdiction__c))
            subscription.Billing_Jurisdiction__c = 'MRIS';
            system.debug('*****subscription'+subscription);
            
            
        if(trigger.IsUpdate){
            if(subscription.Status__c == 'Active' && trigger.oldMap.get(subscription.id).Status__c == 'Inactive' && trigger.oldMap.get(subscription.id).Status_Change_Reason__c == 'Suspended'){
                subscription.Suspend_to_Active__c = true;
            }else{
                subscription.Suspend_to_Active__c = false;
            }
           
            if(subscription.Service_Jurisdiction__c == 'TREND' && subscription.Status__c == 'Active' && trigger.oldMap.get(subscription.id).Status__c != 'Active')
                trendSubscriptions.add(subscription);
            else if(subscription.Service_Jurisdiction__c == 'BRIGHT' && subscription.Status__c == 'Active' && trigger.oldMap.get(subscription.id).Status__c != 'Active')
                brightSubscriptions.add(subscription);
            
            string todayDate = DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            subscription.SourceModificationTimestamp__c = todayDate;   
        }        
        
        if(subscription.Related_Location_Broker_Office__c != null) {
            RLBOIds.add(subscription.Related_Location_Broker_Office__c);
        }
        
        contactIds.add(subscription.Contact__c);
        
        if(subscription.Copy_Address_to_Billing__c == true){
           subscription.Billing_Addl_Display_Name__c = subscription.Addl_Display_Name__c;
           subscription.Billing_Box__c = subscription.Box__c;
           subscription.Billing_City__c = subscription.City__c;
           subscription.QAS_Billing_Country__c = subscription.QAS_Mailing_Country__c;
           subscription.QAS_Billing_County__c = subscription.QAS_Mailing_County__c;
           subscription.Billing_State__c = subscription.State__c;
           subscription.QAS_Billing_Street_Direction__c = subscription.QAS_Mailing_Street_Direction__c;
           subscription.Billing_Street_Name__c = subscription.Street_Name__c;
           subscription.Billing_Street_Number__c = subscription.Street_Number__c;
           subscription.Billing_Street_Suffix__c = subscription.Street_Number_Suffix__c;
           subscription.QAS_Billing_Street_Type__c = subscription.QAS_Mailing_Street_Type__c;
           subscription.Billing_Unit_Number__c = subscription.Unit__c;
           subscription.QAS_Billing_Unit_Type__c = subscription.QAS_Mailing_Unit_Type__c;
           subscription.Billing_Zip__c = subscription.Zip__c;
           subscription.Billing_Zip_4__c = subscription.Zip_4__c;
           subscription.QAS_Billing_POBox__c = subscription.QAS_Mailing_POBox__c;
           subscription.QAS_Billing_Record_Type__c = subscription.QAS_Mailing_Record_Type__c;
        }
        
        /* Street Type */
        if(subscription.QAS_Mailing_Street_Type__c != null && streetTypesMap.get(subscription.QAS_Mailing_Street_Type__c.toUpperCase()) != null) 
            subscription.Street_Type__c = streetTypesMap.get(subscription.QAS_Mailing_Street_Type__c.toUpperCase());
        else
            subscription.Street_Type__c = 'UNDEFINED, UNDEF';
            
        if(subscription.QAS_Billing_Street_Type__c != null && streetTypesMap.get(subscription.QAS_Billing_Street_Type__c.toUpperCase()) != null) 
            subscription.Billing_Street_Type__c = streetTypesMap.get(subscription.QAS_Billing_Street_Type__c.toUpperCase());
        else
            subscription.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
            
        /* Street Direction */    
        if(subscription.QAS_Mailing_Street_Direction__c != null && streetDirectionsMap.get(subscription.QAS_Mailing_Street_Direction__c.toUpperCase()) != null) 
            subscription.Street_Direction__c = streetDirectionsMap.get(subscription.QAS_Mailing_Street_Direction__c.toUpperCase());
        else
            subscription.Street_Direction__c = '';  
            
        if(subscription.QAS_Billing_Street_Direction__c != null && streetDirectionsMap.get(subscription.QAS_Billing_Street_Direction__c.toUpperCase()) != null) 
            subscription.Billing_Street_Direction__c = streetDirectionsMap.get(subscription.QAS_Billing_Street_Direction__c.toUpperCase());
        else
            subscription.Billing_Street_Direction__c = ''; 
            
        /* Unit Type */   
        if(subscription.QAS_Mailing_Unit_Type__c != null && unitTypesMap.get(subscription.QAS_Mailing_Unit_Type__c.toUpperCase()) != null) 
            subscription.Unit_Type__c = unitTypesMap.get(subscription.QAS_Mailing_Unit_Type__c.toUpperCase());
        else
            subscription.Unit_Type__c = ''; 
            
        if(subscription.QAS_Billing_Unit_Type__c != null && unitTypesMap.get(subscription.QAS_Billing_Unit_Type__c.toUpperCase()) != null) 
            subscription.Billing_Unit_Type__c = unitTypesMap.get(subscription.QAS_Billing_Unit_Type__c.toUpperCase());
        else
            subscription.Billing_Unit_Type__c = '';                    
        
        /* County update */
        if(subscription.QAS_Mailing_County__c == 'DISTRICT OF COLUMBIA')
            subscription.County__c = 'WASHINGTON';
        else if(subscription.QAS_Mailing_County__c != null)
            subscription.County__c = subscription.QAS_Mailing_County__c;
        else if(subscription.County__c == NULL)
            subscription.addError('County is a mandatory field');
            
        if(subscription.QAS_Billing_County__c == 'DISTRICT OF COLUMBIA')
            subscription.Billing_County__c = 'WASHINGTON';
        else if(subscription.QAS_Billing_County__c != null)
            subscription.Billing_County__c = subscription.QAS_Billing_County__c; 
            
        /* Country update */
        if(subscription.QAS_Mailing_Country__c == 'USA')
            subscription.Country__c = 'UNITED STATES OF AMERICA';
        if(subscription.QAS_Mailing_Country__C == 'CAN')
            subscription.Country__c = 'CANADA';
                
        if(subscription.QAS_Billing_Country__c == 'USA')
            subscription.Billing_Country__c ='UNITED STATES OF AMERICA';
        if(subscription.QAS_Billing_Country__C == 'CAN')
            subscription.Billing_Country__c = 'CANADA'; 
            
        /* Fill in POBOX */ 
        if(subscription.QAS_Mailing_Record_Type__c == 'P'){
            String mailingPOBox = '';
            if(subscription.QAS_Mailing_POBox__c != null)
                mailingPOBox = subscription.QAS_Mailing_POBox__c;
            
            if((mailingPOBox).contains('PO BOX'))
                mailingPOBox = mailingPOBox.remove('PO BOX');
            
            subscription.QAS_Mailing_POBox__c = mailingPOBox;
            subscription.Addl_Display_Name__c = subscription.QAS_Mailing_POBox__c;
            subscription.Street_Type__c = '';
            subscription.Street_Direction__c = '';
            subscription.Unit_Type__c = '';
        }
        else
            subscription.Addl_Display_Name__c = ' ';        
        
        if(subscription.QAS_Billing_Record_Type__c == 'P'){
            String billingPOBox = '';
            if(subscription.QAS_Billing_POBox__c != null)
                billingPOBox = subscription.QAS_Billing_POBox__c;
            if((billingPOBox).contains('PO BOX'))
                billingPOBox = billingPOBox.remove('PO BOX ');
              
            subscription.QAS_Billing_POBox__c = billingPOBox;
            subscription.Billing_Addl_Display_Name__c = subscription.QAS_Billing_POBox__c;
            subscription.Billing_Street_Type__c = '';
            subscription.Billing_Street_Direction__c = '';
            subscription.Billing_Unit_Type__c = '';
        }
        else
            subscription.Billing_Addl_Display_Name__c = ' ';          
        
        /* Validate feilds for NULL values*/
        
        system.debug('*****subscription'+subscription);
               
        if (Utils.isnotNull(subscription.Agent_Office_Phone__c))
            subscription.Agent_Office_Phone__c = subscription.Agent_Office_Phone__c.trim();

        if (Utils.isnotNull(subscription.NRDS_ID__c))
            subscription.NRDS_ID__c = subscription.NRDS_ID__c.trim();

        if (Utils.isNotNull(subscription.Billing_Box__c))
            subscription.Billing_Box__c = subscription.Billing_Box__c.trim();

        if (Utils.isNotNull(subscription.Addl_Display_Name__c))
            subscription.Addl_Display_Name__c = subscription.Addl_Display_Name__c.trim();

        if (Utils.isNotNull(subscription.Billing_City__c))
            subscription.Billing_City__c = subscription.Billing_City__c.trim();

        if (Utils.isNotNull(subscription.Billing_County__c))
            subscription.Billing_County__c = subscription.Billing_County__c.trim();

        if (Utils.isNotNull(subscription.Billing_Country__c))
            subscription.Billing_Country__c = subscription.Billing_Country__c.trim();

        if (Utils.isNotNull(subscription.Billing_State__c))
            subscription.Billing_State__c = subscription.Billing_State__c.trim();

        if (Utils.isNotNull(subscription.Billing_Street_Direction__c))
            subscription.Billing_Street_Direction__c = subscription.Billing_Street_Direction__c.trim();

        if (Utils.isNotNull(subscription.Billing_Street_Name__c))
            subscription.Billing_Street_Name__c = subscription.Billing_Street_Name__c.trim();

        if (Utils.isNotNull(subscription.Billing_Street_Number__c))
            subscription.Billing_Street_Number__c = subscription.Billing_Street_Number__c.trim();

        if (Utils.isNotNull(subscription.Billing_Street_Suffix__c))
            subscription.Billing_Street_Suffix__c = subscription.Billing_Street_Suffix__c.trim();

        if (Utils.isNotNull(subscription.Billing_Street_Type__c))
            subscription.Billing_Street_Type__c = subscription.Billing_Street_Type__c.trim();

        if (Utils.isNotNull(subscription.Mobile_Phone__c))
            subscription.Mobile_Phone__c = subscription.Mobile_Phone__c.trim();

        if (Utils.isNotNull(subscription.Billing_Unit_Number__c))
            subscription.Billing_Unit_Number__c = subscription.Billing_Unit_Number__c.trim();

        if (Utils.isNotNull(subscription.Billing_Unit_Type__c))
            subscription.Billing_Unit_Type__c = subscription.Billing_Unit_Type__c.trim();

        if (Utils.isNotNull(subscription.Billing_Zip_4__c))
            subscription.Billing_Zip_4__c = subscription.Billing_Zip_4__c.trim();

        if (Utils.isNotNull(subscription.Billing_Zip__c))
            subscription.Billing_Zip__c = subscription.Billing_Zip__c.trim();

        if (Utils.isNotNull(subscription.City__c))
            subscription.City__c = subscription.City__c.trim();

        if (Utils.isNotNull(subscription.County__c))
            subscription.County__c = subscription.County__c.trim();
 
        if (Utils.isNotNull(subscription.Country__c))
            subscription.Country__c = subscription.Country__c.trim();

        if (Utils.isNotNull(subscription.State__c))
            subscription.State__c = subscription.State__c.trim();

        if (Utils.isNotNull(subscription.Street_Direction__c))
            subscription.Street_Direction__c = subscription.Street_Direction__c.trim();

        if (Utils.isNotNull(subscription.Street_Name__c))
            subscription.Street_Name__c = subscription.Street_Name__c.trim();

        if (Utils.isNotNull(subscription.Street_Number__c))
            subscription.Street_Number__c = subscription.Street_Number__c.trim();

        if (Utils.isNotNull(subscription.Street_Number_Suffix__c))
            subscription.Street_Number_Suffix__c = subscription.Street_Number_Suffix__c.trim();

        if (Utils.isNotNull(subscription.Street_Type__c))
            subscription.Street_Type__c = subscription.Street_Type__c.trim();

        if (Utils.isNotNull(subscription.Unit__c))
            subscription.Unit__c = subscription.Unit__c.trim();

        if (Utils.isNotNull(subscription.Unit_Type__c))
            subscription.Unit_Type__c = subscription.Unit_Type__c.trim();

        if (Utils.isNotNull(subscription.Zip_4__c))
            subscription.Zip_4__c = subscription.Zip_4__c.trim();

        if (Utils.isNotNull(subscription.Zip__c))
            subscription.Zip__c = subscription.Zip__c.trim();        
        
        if(String.isNotBlank(subscription.City__c))
            csCities.add(subscription.City__c);
        if(String.isNotBlank(subscription.State__c))
            csStates.add(subscription.State__c);
        if(String.isNotBlank(subscription.County__c))
            csCounties.add(subscription.County__c);
            
           //change by EM 08/10/2016
        if(String.isNotBlank(subscription.County__c) && String.isNotBlank(subscription.State__c) ){          
           csCountyAll.add(subscription.County__c + '-' + subscription.State__c);
         }
          // end of change  
        if(String.isNotBlank(subscription.Street_Direction__c))
            csStreetDirections.add(subscription.Street_Direction__c);
        if(String.isNotBlank(subscription.Street_Type__c))
            csStreetTypes.add(subscription.Street_Type__c);
        if(String.isNotBlank(subscription.Unit_Type__c))
            csStreetUnitTypes.add(subscription.Unit_Type__c);
        
        if(String.isNotBlank(subscription.City__c) && String.isNotBlank(subscription.State__c) && String.isNotBlank(subscription.County__c)){
            String lval = subscription.City__c + '-' + subscription.County__c + '-' + subscription.State__c;
            csCityAll.add(lval);
        }    
    }
    
    if(trendSubscriptions.size() > 0)
        TRENDUtility.processSubscriptions(trendSubscriptions);
        
    if(brightSubscriptions.size() > 0)
        BRIGHTUtility.processSubscriptions(brightSubscriptions);
    
    RETSSubs = [SELECT Id, Related_Location_Broker_Office__c from Subscriptions__c 
                WHERE  Related_Location_Broker_Office__c = :RLBOIds
                AND    Related_Location_Broker_Office__r.Type='RETS' 
                AND    Status__c = 'Active'
               ];
    
    for(Subscriptions__c subscription : RETSSubs){
        if(null != RLOBSizeMap.get(subscription.Related_Location_Broker_Office__c)){
            counter = RLOBSizeMap.get(subscription.Related_Location_Broker_Office__c)+1;
            RLOBSizeMap.put(subscription.Related_Location_Broker_Office__c,counter);
        }
        else
            RLOBSizeMap.put(subscription.Related_Location_Broker_Office__c,1);
    }
    
    for(Contact contact : [SELECT Id,AccountId, Nickname__c FROM Contact WHERE Id IN :contactIds]){
        subContacts.put(contact.Id,contact);
    }
    
    /* Address Validations */
    validCities = AddressUtility.validateCSCity('SUBSCRIPTION',csCities);
    validStates = AddressUtility.validateCSState('SUBSCRIPTION',csStates);
    // EM Changed here
    // validCounties = AddressUtility.validateCSCounty('SUBSCRIPTION',csCounties);
    validCSCountyAll = AddressUtility.validateCSCounty('SUBSCRIPTION',csCountyAll);    
    //end of changes
    validStreetDirections = AddressUtility.validateCSStreetDirection('SUBSCRIPTION',csStreetDirections);
    validStreetTypes = AddressUtility.validateCSStreetType('SUBSCRIPTION',csStreetTypes);
    validStreetUnitTypes = AddressUtility.validateCSStreetUnitTypes('SUBSCRIPTION',csStreetUnitTypes);
    validCSCityAll = AddressUtility.validateCSCityAll('SUBSCRIPTION',csCityAll);
    
    system.debug('&&&& validCities : ' + validCities );
    system.debug('&&&& validStates : ' + validStates );
    //system.debug('&&&& validCounties : ' + validCounties );
    system.debug('&&&& validCounties : ' + validCSCountyAll );
    //
    system.debug('&&&& validStreetDirections : ' + validStreetDirections );
    system.debug('&&&& validStreetTypes : ' + validStreetTypes );
    system.debug('&&&& validStreetUnitTypes : ' + validStreetUnitTypes );
    system.debug('&&&& validCSCityAll : ' + validCSCityAll);                                                     
    
    for (Subscriptions__c subscription : Trigger.new){   
             
        if(String.isBlank(subscription.Service_Jurisdiction__c) || subscription.Service_Jurisdiction__c == 'MRIS'){
            /*  Address Validations */          
            if(String.isNotBlank(subscription.City__c) && !validCities.contains(subscription.City__c))
                subscription.adderror('Invalid City "' + subscription.City__c + '". ' + 'Does not match with Cornerstone');
            
            if (String.isNotBlank(subscription.State__c) && !validStates.contains(subscription.State__c))
                subscription.adderror('Invalid State "' + subscription.State__c + '". ' + 'Does not match with Cornerstone');
    
            if (String.isNotBlank(subscription.Street_Direction__c) && !validStreetDirections.contains(subscription.Street_Direction__c))
                subscription.adderror('Invalid Street Direction "' + subscription.Street_Direction__c + '"". ' + 'Does not match with Cornerstone');
           //EM change 08-10-2016
            //if (String.isNotBlank(subscription.County__c) && !validCounties.contains(subscription.County__c))
             //   subscription.adderror('Invalid County "' + subscription.County__c + '". ' + 'Does not match with Cornerstone');
                
            if (String.isNotBlank(subscription.County__c) && String.isNotBlank(subscription.State__c)&& !validCSCountyAll.contains(subscription.County__c + '-' + subscription.State__c)){
                String lval = subscription.County__c + '-' + subscription.State__c;
                //subscription.adderror('Invalid County-State "' + lval.toUpperCase() +'". ' + 'Does not match with Cornerstone');
                }
    
           // End of change
           
            if (subscription.Street_Type__c != 'UNDEFINED, UNDEF' && String.isNotBlank(subscription.Street_Type__c) && !validStreetTypes.contains(subscription.Street_Type__c))
                subscription.adderror('Invalid Street Type "' + subscription.Street_Type__c+ '".' + 'Does not match with Cornerstone');
    
            if (String.isNotBlank(subscription.Unit_Type__c) && !validStreetUnitTypes.contains(subscription.Unit_Type__c))
                subscription.adderror('Invalid Unit Type "' + subscription.Unit_Type__c + '". ' + 'Does not match with Cornerstone');
                
            // Added for - B-03924
            if(String.isNotBlank(subscription.City__c) && String.isNotBlank(subscription.State__c) && String.isNotBlank(subscription.County__c)){
                String lval = subscription.City__c + '-' + subscription.County__c + '-' + subscription.State__c;
                System.debug('&&&& lval: ' + lval);
                if (!validCSCityAll.contains(lval))
                    subscription.adderror('Invalid City-County-State "' + lval.toUpperCase() + '". ' + 'Does not match with Cornerstone.SubId: ');
            } 
        }
        
        if (Trigger.isUpdate) {
            Subscriptions__c sOld = Trigger.oldMap.get(subscription.id);
            if ('Active'.equals(subscription.Status__c) && 'Inactive'.equals(sOld.status__C)) {
                subscription.Date_Reinstated__c = Date.today();
            } else if ('Inactive'.equals(subscription.Status__c) && 'Active'.equals(sOld.status__C)) {
                subscription.Date_Terminated__c = Date.today();
            }   
        }        

        /* Validate Related Location Broker Office */
        Integer RLOBsize = RLOBSizeMap.get(subscription.Related_Location_Broker_Office__c);
        if(null != RLOBsize){
            if (RLOBsize > 0 && Trigger.isInsert)
                subscription.addError('RETS Office cannot have more than one Subscription');
            else  if (RLOBsize > 1 && Trigger.isUpdate)
                subscription.addError('RETS Office cannot have more than one Subscription');
        }
        else {
            if(subscription.Related_Location_Broker_Office__r.Type=='RETS' && subscription.status__c == 'Active')
                RLOBSizeMap.put(subscription.Related_Location_Broker_Office__c,1);
        }
        
        
        Contact contact = subContacts.get(subscription.Contact__c);
        /* Update NickName */
        if(String.isBlank(subscription.Nickname__c)) 
            subscription.Nickname__c = contact.Nickname__c;
                           
        if (subscription.Primary__c && executionFlowUtility.contactUpdate) {
            contact.AccountId = subscription.Related_Location_Broker_Office__c;
            
            if (contact.Primary_Subscription__c == null)
                contact.Primary_Subscription__c = subscription.id;
            
            contact.Status__c = subscription.Status__c;
            contact.Agent_Office_Phone__c = subscription.Agent_Office_Phone__c;
            contact.Addl_Display_Name__c = subscription.Addl_Display_Name__c;
            contact.Billing_Addl_Display_Name__c = subscription.Billing_Addl_Display_Name__c;
            contact.Billing_Box__c = subscription.billing_Box__c;
            contact.Billing_City__c = subscription.Billing_City__c;
            contact.Zip__c  = subscription.zip__c;
            contact.Zip_4__c = subscription.Zip_4__c;
            contact.Voicemail__c = subscription.Voicemail__c;
            contact.VM_Ext__c = subscription.VM_Ext__c;
            contact.Unit__c = subscription.Unit__c;
            contact.Street_Number_Suffix__c = subscription.Street_Number_Suffix__c;
            contact.Street_Number__c = subscription.Street_Number__c;
            contact.Street_Name__c = subscription.Street_Name__c;
            contact.State__c = subscription.State__c;
            contact.Phone = subscription.Primary_Phone__c;
            contact.Home_Fax__c = subscription.Home_Fax__c;
            contact.Copy_Address_to_Billing__c = subscription.Copy_Address_to_Billing__c;
            contact.City__c = subscription.City__c;
            contact.Billing_State__c = subscription.Billing_State__c;
            contact.Billing_Street_Name__c = subscription.Billing_Street_Name__c;
            contact.Billing_Street_Number__c = subscription.Billing_Street_Number__c;
            contact.Billing_Street_Number_Suffix__c  = subscription.Billing_Street_Suffix__c;
            contact.OtherPhone = subscription.Pager__c;
            contact.MobilePhone = subscription.Mobile_Phone__c;
            contact.Fax = subscription.Fax__c;
            contact.QAS_Billing_Country__c = subscription.QAS_Billing_Country__c;
            contact.QAS_Billing_County__c = subscription.QAS_Billing_County__c;
            contact.QAS_Billing_Unit_Type__c = subscription.QAS_Billing_Unit_Type__c;
            contact.QAS_Billing_Street_Type__c = subscription.QAS_Billing_Street_Type__c;
            contact.QAS_Billing_Street_Direction__c = subscription.QAS_Billing_Street_Direction__c;
            contact.QAS_Billing_POBox__c =  subscription.QAS_Billing_POBox__c;
            contact.QAS_Billing_Record_Type__c = subscription.QAS_Billing_Record_Type__c;
            contact.QAS_Mailing_County__c = subscription.QAS_Mailing_County__c;
            contact.QAS_Mailing_Country__c = subscription.QAS_Mailing_Country__c;
            contact.QAS_Mailing_Street_Direction__c = subscription.QAS_Mailing_Street_Direction__c;
            contact.QAS_Mailing_Unit_Type__c = subscription.QAS_Mailing_Unit_Type__c;
            contact.QAS_Mailing_Street_Type__c = subscription.QAS_Mailing_Street_Type__c;
            contact.QAS_Mailing_POBox__c = subscription.QAS_Mailing_POBox__c;
            contact.QAS_Mailing_Record_Type__c = subscription.QAS_Mailing_Record_Type__c;
            contact.Email = subscription.Private_Email__c;
            contact.Public_Email__c = subscription.Public_Email__c;

            updatedContacts.add(contact);
      
        }       
    }
    
    if(executionFlowUtility.contactUpdate && updatedContacts.size() > 0){
        executionFlowUtility.subscriptionUpdate = false;
        executionFlowUtility.contactUpdate = false;
        upsert updatedContacts;
        executionFlowUtility.subscriptionUpdate = true;
        executionFlowUtility.contactUpdate = true;
    }
}