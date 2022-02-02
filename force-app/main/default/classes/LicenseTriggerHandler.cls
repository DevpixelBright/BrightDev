public class LicenseTriggerHandler {
   /* public static void validateLicense(List<License__c> lNewLicense) {
        Profile userProfile = [SELECT id,Name FROM Profile WHERE id = :UserInfo.getProfileId()];
        if(userProfile.Name != 'eProcess Profile'){
            
            try {
                
                //Set<String> licenses = new Set<String>();
                Set<String> states = new Set<String>();
                Set<String> contacts = new Set<String>();
                Set<String> ids = new Set<String>();
                for(License__c lic : lNewLicense){
                    if(lic.SoftDeleted__c != 'Yes'){
                    states.add(lic.License_State__c);
                    contacts.add(lic.Contact__c);
                    ids.add(lic.Id);
                    }
                }
                
                Set<String> uniqueValues = new Set<String>();
                for(License__c license : [SELECT Id, License_State__c, Contact__c 
                                          FROM   License__c 
                                          WHERE License_State__c IN :states 
                                          AND Contact__c = :contacts 
                                          AND SoftDeleted__c != 'Yes'
                                          AND Id NOT IN : ids]){
                                              uniqueValues.add(license.License_State__c.toLowerCase()+''+license.Contact__c);                                      
                                          }
                for(License__c license : lNewLicense ){
                    if(uniqueValues.contains(license.License_State__c.toLowerCase()+''+license.Contact__c)){
                        if(userProfile.Name == 'MRIS Customer Community Login'){
                            license.addError('A license for this state already exists. Use the pencil next to the license to change the expiration date. If you have another license in the same state, it must be associated with another subscription ID in Bright.');
                        }
                        else{
                            license.addError('A license for this state already exists.  Please validate the correct license by verifying it with Real Estate Commission for that state.');                
                        }
                    }
                    
                }
            }
            catch(Exception e) {
                system.debug(e);
            }
        }    
    }*/
}