@isTest
public class AddressUtility_UnitTest {
    
    public static testMethod void  AddressUtility_New_Test() {
        
        CornerstoneMappings__c csmCityObj = new CornerstoneMappings__c();
        csmCityObj.CornerstoneID__c = '10395530992';
        csmCityObj.LongValue__c = '% CARMEN DELSIGNOR-GRANT-WV';
        csmCityObj.ParentLookupItem__c = '10000002985';
        csmCityObj.ParentLookupItemKey__c = '10000006018';
        csmCityObj.ParenetLookupKeyID__c = '10000006018';
        csmCityObj.TypeName__c = 'CARMEN DELSIGNOR';
        csmCityObj.Type__c = 'Office/city';
        insert csmCityObj;

        List<String> cities = new List<String>{'Alexandria', 'Herndon', 'UN'};
        AddressUtility_New.validateCSCity('ACCOUNT', cities);
        AddressUtility_New.validateCSCity('SUBSCRIPTION', cities); 
        AddressUtility_New.validateCSCityAll('ACCOUNT', cities); 
        AddressUtility_New.validateCSCityAll('SUBSCRIPTION', cities);
        AddressUtility_New.validateCSState('ACCOUNT', cities);
        AddressUtility_New.validateCSState('SUBSCRIPTION', cities); 
        List<String> streetDirections = new List<String>{'North, NY', 'SOUTH, S'};
        AddressUtility_New.validateCSStreetDirection('ACCOUNT', streetDirections); 
        AddressUtility_New.validateCSStreetDirection('SUBSCRIPTION', streetDirections); 
        AddressUtility_New.validateCSCounty('ACCOUNT', cities);
        AddressUtility_New.validateCSCounty('SUBSCRIPTION', cities);
        AddressUtility_New.validateCSCountry('ACCOUNT', cities); 
        AddressUtility_New.validateCSCountry('SUBSCRIPTION', cities);
        AddressUtility_New.validateCSStreetType('ACCOUNT', cities);
        AddressUtility_New.validateCSStreetType('SUBSCRIPTION', cities);
        AddressUtility_New.validateCSStreetUnitTypes('ACCOUNT', cities);
        AddressUtility_New.validateCSStreetUnitTypes('SUBSCRIPTION', cities);
        
        Map<String, String> getStates = new Map<String, String>{'VA'=>'USA', 'UN'=>'UNITED STATES'};
        AddressUtility_New.getCSState(getStates, 'ACCOUNT');
        getStates = new Map<String, String>{'VA'=>'USA', 'UN'=>'CANADA'};
        AddressUtility_New.getCSState(getStates, 'SUBSCRIPTION');
        getStates = new Map<String, String>{'VA'=>'USA', 'UN'=>'USA'};
        AddressUtility_New.getCSState(getStates, 'ACCOUNT');
        
        List<String> getStreetDirections = new List<String>{'NORTH, N', 'SOUTH, S'};
        AddressUtility_New.getCSStreetDirection(getStreetDirections, 'ACCOUNT');
        AddressUtility_New.getCSStreetDirection(getStreetDirections, 'SUBSCRIPTION'); 
        AddressUtility_New.getCSCounty(getStreetDirections, 'ACCOUNT');
        AddressUtility_New.getCSCounty(getStreetDirections, 'SUBSCRIPTION'); 
        AddressUtility_New.getCSCountry(getStreetDirections, 'ACCOUNT');
        AddressUtility_New.getCSCountry(getStreetDirections, 'SUBSCRIPTION');  
        AddressUtility_New.getCSStreetType(getStreetDirections, 'ACCOUNT');
        AddressUtility_New.getCSStreetType(getStreetDirections, 'SUBSCRIPTION');
        AddressUtility_New.getCSStreetUnitTypes(getStreetDirections, 'ACCOUNT');
        AddressUtility_New.getCSStreetUnitTypes(getStreetDirections, 'SUBSCRIPTION'); 
        AddressUtility_New.getCSCityAll(getStreetDirections, 'ACCOUNT');
        AddressUtility_New.getCSCityAll(getStreetDirections, 'SUBSCRIPTION');                                                   
    }

}