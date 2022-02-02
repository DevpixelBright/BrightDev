trigger QAScopyAddrToBillingContact on Contact (before insert, before update) {

    //Exit trigger if records are inserted and/or updated by dataloader profile.
    if (Utils.BypassValidationrules())return;
    
    /* Smart Street Address Validation*/
    //SSV_AddressValidation validation = new SSV_AddressValidation();
    SSV_AddressValidation.setAddressValidationStatus(trigger.oldMap, trigger.New, trigger.isInsert);
    
    
    /*if(Trigger.isUpdate ){
        for(Contact contact : Trigger.new){
            Contact oldContact = Trigger.OLDMAP.get(contact.ID);
            system.debug('Before: ' + contact.AddressValidationStatus__c );
            
            if(contact.AddressValidationStatus__c != 'Verified' && contact.AddressValidationStatus__c != 'Not Required'){
                if(contact.Street_Number__c != oldContact.Street_Number__c || 
                   contact.Street_Name__c != oldContact.Street_Name__c || 
                   contact.City__c != oldContact.City__c || 
                   contact.State__c != oldContact.State__c || 
                   contact.Street_Type__c != oldContact.Street_Type__c  || 
                   contact.Street_Direction__c != oldContact.Street_Direction__c || 
                   contact.Unit_Type__c != oldContact.Unit_Type__c || 
                   contact.Unit__c != oldContact.Unit__c ){
                       contact.AddressValidationStatus__c = 'To be verify';
                }
            }
            
            system.debug('After: ' + contact.AddressValidationStatus__c );

            
            if(contact.AddressValidationStatus__c != 'To be verify')
                contact.AddressValidationStatus__c = null;
                
            system.debug('Final: ' + contact.AddressValidationStatus__c );

        }            
    }
    else{
        for(Contact contact : Trigger.new)
             contact.AddressValidationStatus__c = 'To be verify';    
    }*/

    
    // QAS required code
      //QAS_NA.RecordStatusSetter.InvokeRecordStatusSetterConstrained(trigger.new,trigger.old,trigger.IsInsert,2);
    
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
    'UPAS'=>'UNDERPASS , UPAS','UNS'=>'UNIONS , UNS','VLYS'=>'VALLEYS , VLYS','VLGS'=>'VILLAGES , VLGS','WAYS'=>'WAYS , WAYS','WL'=>'WELL , WL',
    'ROUTE'=>'ROUTE , RTE'
    };                                            
    
    Map<String,String> streetDirectionsMap = new Map<String,String>{
        'N'=>'N, NORTH','E'=>'E, EAST','S'=>'S, SOUTH','W'=>'W, WEST',
        'NE'=>'NE, NORTHEAST','SE'=>'SE, SOUTHEAST','NW'=>'NW, NORTHWEST','SW'=>'SW, SOUTHWEST'};

    Map<String,String> unitTypesMap = new Map<String,String>{
        'APT'=>'APT, APARTMENT','BSMT'=>'BSMT, BASEMENT','BLDG'=>'BLDG, BUILDING','DEPT'=>'DEPT, DEPARTMENT','FL'=>'FL, FLOOR',
        'FRNT'=>'FRNT, FRONT','HNGR'=>'HNGR, HANGAR','KEY'=>'KEY, KEY','LBBY'=>'LBBY, LOBBY','LOT'=>'LOT, LOT','LOWR'=>'LOWR, LOWER',
        'OFC'=>'OFC, OFFICE','PH'=>'PH, PENTHOUSE','PIER'=>'PIER, PIER','REAR'=>'REAR, REAR','RM'=>'RM, ROOM','SIDE'=>'SIDE, SIDE',
        'SLIP'=>'SLIP, SLIP','SPC'=>'SPC, SPACE','STOP'=>'STOP, STOP','STE'=>'STE, SUITE','TRLR'=>'TRLR, TRAILER','UNIT'=>'UNIT, UNIT',
        'UPPR'=>'UPPR, UPPER'};               

    List<String> accountIds = new List<String>();//Territory Owner
    
    for(Contact contact : Trigger.new) {
        if(String.isBlank(contact.Service_Jurisdiction__c))
            contact.Service_Jurisdiction__c = 'MRIS';
            
        accountIds.add(contact.AccountId);//Territory Owner
            
        if(contact.Copy_Address_to_Billing__c == true) {
            contact.Billing_Addl_Display_Name__c = contact.Addl_Display_Name__c;
            contact.Billing_Box__c = contact.Box__c;
            contact.Billing_City__c = contact.City__c;
            contact.QAS_Billing_Country__c = contact.QAS_Mailing_Country__c;
            contact.QAS_Billing_County__c = contact.QAS_Mailing_County__c;
            contact.Billing_State__c = contact.State__c;
            contact.QAS_Billing_Street_Direction__c = contact.QAS_Mailing_Street_Direction__c;
            contact.Billing_Street_Name__c = contact.Street_Name__c;
            contact.Billing_Street_Number__c = contact.Street_Number__c;
            contact.Billing_Street_Number_Suffix__c = contact.Street_Number_Suffix__c;
            contact.QAS_Billing_Street_Type__c = contact.QAS_Mailing_Street_Type__c;
            contact.Billing_Unit_Number__c = contact.Unit__c;
            contact.QAS_Billing_Unit_Type__c = contact.QAS_Mailing_Unit_Type__c;
            contact.Billing_Zip__c = contact.Zip__c;
            contact.Billing_Zip_4__c = contact.Zip_4__c;
            contact.QAS_Billing_POBox__c = contact.QAS_Mailing_POBox__c;
            contact.QAS_Billing_Record_Type__c = contact.QAS_Mailing_Record_Type__c;
        }
    
        if(contact.Nickname__c == '' || contact.Nickname__c ==null) 
            contact.Nickname__c = contact.FirstName;
        /* update Preferred first name */
        if(String.isBlank(contact.PreferredFirstName__c)){
            if(String.isBlank(contact.Nickname__c))
                contact.PreferredFirstName__c = contact.FirstName;
            else
                contact.PreferredFirstName__c = contact.Nickname__c;
        }
        if(String.isBlank(contact.PreferredLastName__c) )  
            contact.PreferredLastName__c = contact.LastName;
       
        
            
        /* Street Type */
        if(contact.QAS_Mailing_Street_Type__c != null && streetTypesMap.get(contact.QAS_Mailing_Street_Type__c.toUpperCase()) != null) 
            contact.Street_Type__c = streetTypesMap.get(contact.QAS_Mailing_Street_Type__c.toUpperCase());
        else
           contact.Street_Type__c = 'UNDEFINED, UNDEF';
     
            
        if(contact.QAS_Billing_Street_Type__c != null && streetTypesMap.get(contact.QAS_Billing_Street_Type__c.toUpperCase()) != null) 
            contact.Billing_Street_Type__c = streetTypesMap.get(contact.QAS_Billing_Street_Type__c.toUpperCase());
        else
            contact.Billing_Street_Type__c = 'UNDEFINED, UNDEF';
            
        /* Street Direction */    
        if(contact.QAS_Mailing_Street_Direction__c != null && streetDirectionsMap.get(contact.QAS_Mailing_Street_Direction__c.toUpperCase()) != null) 
            contact.Street_Direction__c = streetDirectionsMap.get(contact.QAS_Mailing_Street_Direction__c.toUpperCase());
        else
            contact.Street_Direction__c = '';  
            
        if(contact.QAS_Billing_Street_Direction__c != null && streetDirectionsMap.get(contact.QAS_Billing_Street_Direction__c.toUpperCase()) != null) 
            contact.Billing_Street_Direction__c = streetDirectionsMap.get(contact.QAS_Billing_Street_Direction__c.toUpperCase());
        else
            contact.Billing_Street_Direction__c = ''; 
            
        /* Unit Type */   
        if(contact.QAS_Mailing_Unit_Type__c != null && unitTypesMap.get(contact.QAS_Mailing_Unit_Type__c.toUpperCase()) != null) 
            contact.Unit_Type__c = unitTypesMap.get(contact.QAS_Mailing_Unit_Type__c.toUpperCase());
        else
            contact.Unit_Type__c = ''; 
            
        if(contact.QAS_Billing_Unit_Type__c != null && unitTypesMap.get(contact.QAS_Billing_Unit_Type__c.toUpperCase()) != null) 
            contact.Billing_Unit_Type__c = unitTypesMap.get(contact.QAS_Billing_Unit_Type__c.toUpperCase());
        else
            contact.Billing_Unit_Type__c = '';                    
        
        /* County update */
        if(contact.QAS_Mailing_County__c == 'DISTRICT OF COLUMBIA')
            contact.County__c = 'WASHINGTON';
        else if(contact.QAS_Mailing_County__c != null)
            contact.County__c = contact.QAS_Mailing_County__c;
        else if(contact.QAS_Mailing_County__c == NULL && contact.County__c == NULL)
            contact.addError('County is a mandatory field');
            
        if(contact.QAS_Billing_County__c == 'DISTRICT OF COLUMBIA')
            contact.Billing_County__c = 'WASHINGTON';
        else if(contact.QAS_Billing_County__c != null)
            contact.Billing_County__c = contact.QAS_Billing_County__c; 
            
        /* Country update */
        if(contact.QAS_Mailing_Country__c == 'USA')
            contact.Country__c = 'UNITED STATES OF AMERICA';
        if(contact.QAS_Mailing_Country__C == 'CAN')
            contact.Country__c = 'CANADA';
                
        if(contact.QAS_Billing_Country__c == 'USA')
            contact.Billing_Country__c ='UNITED STATES OF AMERICA';
        if(contact.QAS_Billing_Country__C == 'CAN')
            contact.Billing_Country__c = 'CANADA'; 
            
        /* Fill in POBOX */ 
        if(contact.QAS_Mailing_Record_Type__c == 'P'){
            String mailingPOBox = '';
            if(contact.QAS_Mailing_POBox__c != null)
                mailingPOBox = contact.QAS_Mailing_POBox__c;
            
            if((mailingPOBox).contains('PO BOX'))
                mailingPOBox = mailingPOBox.remove('PO BOX');
            
            contact.QAS_Mailing_POBox__c = mailingPOBox;
            contact.Addl_Display_Name__c = contact.QAS_Mailing_POBox__c;
            contact.Street_Type__c = '';
            contact.Street_Direction__c = '';
            contact.Unit_Type__c = '';
        }
        else
            contact.Addl_Display_Name__c = ' ';        
        
        if(contact.QAS_Billing_Record_Type__c == 'P'){
            String billingPOBox = '';
            if(contact.QAS_Billing_POBox__c != null)
                billingPOBox = contact.QAS_Billing_POBox__c;
            if((billingPOBox).contains('PO BOX'))
                billingPOBox = billingPOBox.remove('PO BOX ');
              
            contact.QAS_Billing_POBox__c = billingPOBox;
            contact.Billing_Addl_Display_Name__c = contact.QAS_Billing_POBox__c;
            contact.Billing_Street_Type__c = '';
            contact.Billing_Street_Direction__c = '';
            contact.Billing_Unit_Type__c = '';
        }
        else
            contact.Billing_Addl_Display_Name__c = '';
        
        //listing notification filed update
        if(Trigger.isUpdate ){
            if(contact.Status__c == 'Active' && Trigger.oldMap.get(contact.Id).Status__c== 'Inactive') 
                contact.BRIGHT_email_preferences_Listings__c = true;
            }
    }
    
    /****** Please dont uncomment the below code as it is throwing and error while assignment****/
    //Territory Owner
    //Map<Id,Account> accounts = new Map<Id,Account>([SELECT Id,OwnerId FROM Account WHERE Id IN :accountIds]);
    
    //for(Contact contact : Trigger.new) {           
    //    contact.OwnerId = accounts.get(contact.accountId).OwnerId;
    //}
    
}