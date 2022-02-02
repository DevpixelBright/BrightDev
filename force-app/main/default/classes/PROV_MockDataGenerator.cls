public class PROV_MockDataGenerator {
    public static String methodName;
    public static Boolean isSuccess;
    public static String errorType;
    public static String subscriptionName;
    private static System.HttpResponse response;
    
    public static System.HttpResponse generateMockData(System.HttpRequest request) {
        response = new System.HttpResponse();
        
        if(!isSuccess) {
            if(errorType == 'HTTPError') {
                response.setStatusCode(401);
                response.setStatus('Unauthorized');
                response.setBody('');
            }
            else if(errorType == 'EmptyResponse') {
                response.setStatusCode(200);
                response.setStatus('Ok');
                response.setBody('');
            } 
            else if(errorType == 'ServiceError' || errorType == 'SOAPError' || errorType == 'AuthError' || errorType == 'CookieError' || errorType == 'StatusError') {
                response.setStatusCode(200);
                identifyServiceType(request);    
            }                     
        }
        else {
            response.setStatusCode(200);
            identifyServiceType(request);
        }
        
        return response;
    }
    
    private static void identifyServiceType(System.HttpRequest request) {
        String requestMsg = request.getBody();
        String soapAction = request.getHeader('SOAPAction');
        String serviceUrl = request.getEndpoint();
        if(requestMsg.indexOf('SendStoreRequest') > 0) {
            if(requestMsg.indexOf('Terminate') > 0)
                requestForAuthentisign('UpgradeTerminatedSuccessfully');
            else
                requestForAuthentisign('UpgradeCreatedSuccessfully');
        }
        else if(requestMsg.indexOf('AgentWebsite') > 0 || requestMsg.indexOf('OfficeWebsite') > 0)
            requestForXactSite();  
        else if(serviceUrl.indexOf('license') > 0) 
            requestForRealping();  
        else if(serviceUrl.indexOf('services/rest') > 0) {
            if(serviceUrl.indexOf('Lock') > 0)
                requestForCornerStone('Lock');
            else
                requestForCornerStone('Update');
        }     
    }
    
    private static void requestForCornerStone(String operation) {
        System.debug('*** operation:' + operation);
        String responseMsg = '';
        
        if(operation == 'Lock') {
            if(errorType == 'ServiceError')
                responseMsg += '<?xml version="1.0" encoding="UTF-8"?><Response xsi:noNamespaceSchemaLocation="http://devdata.mris.com/services/rest/schema/mris_data_services.xsd;local=true;system=MRIS"><ResponseStatus><StatusCode>0</StatusCode><StatusMessage>Success</StatusMessage></ResponseStatus><MRISAgents/><ResponseDetail><KeysNotFound><Key>850335941385</Key></KeysNotFound></ResponseDetail></Response>';
            else if(errorType == 'StatusError')
                responseMsg += '<?xml version="1.0" encoding="UTF-8"?><Response xsi:noNamespaceSchemaLocation="http://devdata.mris.com/services/rest/schema/mris_data_services.xsd;local=true;system=MRIS"><ResponseStatus><StatusCode></StatusCode><StatusMessage></StatusMessage></ResponseStatus><MRISAgents/></Response>';                     
            else
                responseMsg += '<?xml version="1.0" encoding="UTF-8"?><Response xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://testdata.mris.com/services/rest/schema/mris_data_services.xsd;local=true;system=MRIS"><ResponseStatus><StatusCode>0</StatusCode><StatusMessage>Success</StatusMessage></ResponseStatus><MRISAgents><MRISAgent ResourceKey="90435444159"><Agent><AgentID><AgentListingServiceName>Metropolitan Regional Information Systems, Inc.</AgentListingServiceName><AgentKey>90435444159</AgentKey><AgentID>3162252</AgentID><AgentNationalID xsi:nil="true"></AgentNationalID><NRDSMemberID xsi:nil="true"></NRDSMemberID><AgentRealPingID>25202</AgentRealPingID><AgentModificationTimestamp>2015-08-14T05:56:15</AgentModificationTimestamp><AgentFirstName>PROV</AgentFirstName><AgentLastName>Aug - 14 - One</AgentLastName><AgentNameSuffix xsi:nil="true"></AgentNameSuffix><AgentMiddleName xsi:nil="true"></AgentMiddleName><AgentMiddleInitial xsi:nil="true"></AgentMiddleInitial><AgentNickName xsi:nil="true"></AgentNickName><AgentDesignations xsi:nil="true"></AgentDesignations><AgentSalutation xsi:nil="true"></AgentSalutation><AgentAlternateDisplayName xsi:nil="true"></AgentAlternateDisplayName><AgentBirthDate xsi:nil="true"></AgentBirthDate><AgentWarpFactor>236455</AgentWarpFactor><AgentPIN xsi:nil="true"></AgentPIN><AgentFullRoleList>Agent,Edit,Lister,Search,Status Active,Personal Assistant,System-MRIS</AgentFullRoleList><AgentRoleList>HCL1 Agent, HCL1 Edit, HCL1 Lister, HCL1 Personal Assistant, HCL1 Search, HCL1 Status Active, HCL1 System-MRIS</AgentRoleList><AgentAssociations xsi:nil="true"></AgentAssociations><AgentPrimaryAssociation xsi:nil="true"></AgentPrimaryAssociation><AgentUserName>3162252</AgentUserName><AgentVerificationQuestion xsi:nil="true"></AgentVerificationQuestion><AgentVerificationInfo xsi:nil="true"></AgentVerificationInfo><AgentVerificationAttempts>0</AgentVerificationAttempts><AgentActiveFlag>1</AgentActiveFlag><AgentLoginAsFlag xsi:nil="true"></AgentLoginAsFlag><AgentNumViolations>0</AgentNumViolations><AgentJoinDate>2015-08-14</AgentJoinDate><AgentReinstatementDate>2015-08-14</AgentReinstatementDate><AgentTerminationDate>2015-08-14</AgentTerminationDate><AgentSystemLocale>MRIS</AgentSystemLocale><AgentSubSystemLocale>MRIS_MAIN</AgentSubSystemLocale><AgentExternalSystemID>3162252</AgentExternalSystemID><AgentRatePlugFlag xsi:nil="true"></AgentRatePlugFlag></AgentID><ContactInformation><AgentOfficePhone xsi:nil="true"></AgentOfficePhone><AgentCellPhone>9999999999</AgentCellPhone><AgentVoiceMailNum xsi:nil="true"></AgentVoiceMailNum><AgentVoiceMailExt xsi:nil="true"></AgentVoiceMailExt><AgentHomePhone>7036159328</AgentHomePhone><AgentFax xsi:nil="true"></AgentFax><AgentFaxHome xsi:nil="true"></AgentFaxHome><AgentPager xsi:nil="true"></AgentPager><AgentEmail>sreehitha.ravi@bltglobalventures.com</AgentEmail><AgentPrivateEmail>#</AgentPrivateEmail><AgentWWW xsi:nil="true"></AgentWWW></ContactInformation><StreetAddress><AgentStreetNumber xsi:nil="true"></AgentStreetNumber><AgentStreetException xsi:nil="true"></AgentStreetException><AgentBoxNumber xsi:nil="true"></AgentBoxNumber><AgentStreetDirPrefix xsi:nil="true"></AgentStreetDirPrefix><AgentStreetName>NO STREET NAME</AgentStreetName><AgentStreetAdditionalInfo xsi:nil="true"></AgentStreetAdditionalInfo><AgentStreetDirSuffix xsi:nil="true"></AgentStreetDirSuffix><AgentStreetSuffix>UNDEFINED</AgentStreetSuffix><AgentUnitNumber xsi:nil="true"></AgentUnitNumber><AgentCity>ALEXANDRIA</AgentCity><AgentCityName>ALEXANDRIA</AgentCityName><AgentCounty>FAIRFAX</AgentCounty><AgentState>VA</AgentState><AgentCountry>UNITED STATES OF AMERICA</AgentCountry><AgentPostalCode>2222</AgentPostalCode><AgentZip4 xsi:nil="true"></AgentZip4><AgentCarrierRoute xsi:nil="true"></AgentCarrierRoute><AgentFullStreetAddress>NO STREET NAME UNDEF</AgentFullStreetAddress><AgentAddressAdditionalInfo xsi:nil="true"></AgentAddressAdditionalInfo><AgentUnitDesignation xsi:nil="true"></AgentUnitDesignation></StreetAddress></Agent><Office><OfficeID><OfficeListingServiceName>Metropolitan Regional Information Systems, Inc.</OfficeListingServiceName><OfficeName>Harry Lamberton Real Estate</OfficeName><OfficeKey>10000156587</OfficeKey><OfficeID>HCL1</OfficeID><BrokerID>HCL1</BrokerID><NRDSOfficeID xsi:nil="true"></NRDSOfficeID><OfficeModificationTimestamp>2004-06-10T18:48:17</OfficeModificationTimestamp></OfficeID><ContactInformation><OfficeOfficePhone>2024227200</OfficeOfficePhone><OfficeCellPhone xsi:nil="true"></OfficeCellPhone><OfficeHomePhone xsi:nil="true"></OfficeHomePhone><OfficeFax>2025885504</OfficeFax><OfficePager xsi:nil="true"></OfficePager><OfficeEmail xsi:nil="true"></OfficeEmail><OfficeWWW xsi:nil="true"></OfficeWWW></ContactInformation><StreetAddress><OfficeStreetNumber>3201</OfficeStreetNumber><OfficeBoxNumber xsi:nil="true"></OfficeBoxNumber><OfficeStreetDirPrefix xsi:nil="true"></OfficeStreetDirPrefix><OfficeStreetName>NEW MEXICO</OfficeStreetName><OfficeStreetAdditionalInfo xsi:nil="true"></OfficeStreetAdditionalInfo><OfficeStreetDirSuffix>NORTHWEST</OfficeStreetDirSuffix><OfficeStreetSuffix>AVENUE</OfficeStreetSuffix><OfficeUnitNumber xsi:nil="true"></OfficeUnitNumber><OfficeCity>WASHINGTON</OfficeCity><OfficeCityName>WASHINGTON</OfficeCityName><OfficeState>DC</OfficeState><OfficeCountry>UNITED STATES OF AMERICA</OfficeCountry><OfficePostalCode>20016</OfficePostalCode><OfficeCarrierRoute xsi:nil="true"></OfficeCarrierRoute></StreetAddress></Office></MRISAgent></MRISAgents></Response>';   
        }
        else {
            if(errorType == 'ServiceError')
                responseMsg += '<?xml version="1.0" encoding="UTF-8"?><Response xsi:noNamespaceSchemaLocation="http://devdata.mris.com/services/rest/schema/mris_data_services.xsd;local=true;system=MRIS"><ResponseStatus><StatusCode>23450</StatusCode><StatusMessage>failed</StatusMessage></ResponseStatus><MRISAgents/></Response>';
            else
                responseMsg += '<?xml version="1.0" encoding="UTF-8"?><Response xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://testdata.mris.com/services/rest/schema/mris_data_services.xsd;local=true;system=MRIS"><ResponseStatus><StatusCode>0</StatusCode><StatusMessage>Success</StatusMessage></ResponseStatus><MRISAgents><MRISAgent ResourceKey="90435444159"><Agent><AgentID><AgentListingServiceName>Metropolitan Regional Information Systems, Inc.</AgentListingServiceName><AgentKey>90435444159</AgentKey><AgentID>3162252</AgentID><AgentNationalID xsi:nil="true"></AgentNationalID><NRDSMemberID xsi:nil="true"></NRDSMemberID><AgentRealPingID>25203</AgentRealPingID><AgentModificationTimestamp>2015-08-14T07:18:44</AgentModificationTimestamp><AgentFirstName>PROV</AgentFirstName><AgentLastName>Aug - 14 - One</AgentLastName><AgentNameSuffix xsi:nil="true"></AgentNameSuffix><AgentMiddleName xsi:nil="true"></AgentMiddleName><AgentMiddleInitial xsi:nil="true"></AgentMiddleInitial><AgentNickName xsi:nil="true"></AgentNickName><AgentDesignations xsi:nil="true"></AgentDesignations><AgentSalutation xsi:nil="true"></AgentSalutation><AgentAlternateDisplayName xsi:nil="true"></AgentAlternateDisplayName><AgentBirthDate xsi:nil="true"></AgentBirthDate><AgentWarpFactor>236455</AgentWarpFactor><AgentPIN xsi:nil="true"></AgentPIN><AgentFullRoleList>Agent,Edit,Lister,Search,Status Active,Personal Assistant,System-MRIS</AgentFullRoleList><AgentRoleList>HCL1 Agent, HCL1 Edit, HCL1 Lister, HCL1 Personal Assistant, HCL1 Search, HCL1 Status Active, HCL1 System-MRIS</AgentRoleList><AgentAssociations xsi:nil="true"></AgentAssociations><AgentPrimaryAssociation xsi:nil="true"></AgentPrimaryAssociation><AgentUserName>3162252</AgentUserName><AgentVerificationQuestion xsi:nil="true"></AgentVerificationQuestion><AgentVerificationInfo xsi:nil="true"></AgentVerificationInfo><AgentVerificationAttempts>0</AgentVerificationAttempts><AgentActiveFlag>1</AgentActiveFlag><AgentLoginAsFlag xsi:nil="true"></AgentLoginAsFlag><AgentNumViolations>0</AgentNumViolations><AgentJoinDate>2015-08-14</AgentJoinDate><AgentReinstatementDate>2015-08-14</AgentReinstatementDate><AgentTerminationDate>2015-08-14</AgentTerminationDate><AgentSystemLocale>50000900598</AgentSystemLocale><AgentSubSystemLocale>10000065722</AgentSubSystemLocale><AgentExternalSystemID>3162252</AgentExternalSystemID><AgentRatePlugFlag xsi:nil="true"></AgentRatePlugFlag></AgentID><ContactInformation><AgentOfficePhone xsi:nil="true"></AgentOfficePhone><AgentCellPhone>9999999999</AgentCellPhone><AgentVoiceMailNum xsi:nil="true"></AgentVoiceMailNum><AgentVoiceMailExt xsi:nil="true"></AgentVoiceMailExt><AgentHomePhone>7036159328</AgentHomePhone><AgentFax xsi:nil="true"></AgentFax><AgentFaxHome xsi:nil="true"></AgentFaxHome><AgentPager xsi:nil="true"></AgentPager><AgentEmail>sreehitha.ravi@bltglobalventures.com</AgentEmail><AgentPrivateEmail>sreehitha.ravi@bltglobalventures.com</AgentPrivateEmail><AgentWWW xsi:nil="true"></AgentWWW></ContactInformation><StreetAddress><AgentStreetNumber xsi:nil="true"></AgentStreetNumber><AgentStreetException xsi:nil="true"></AgentStreetException><AgentBoxNumber xsi:nil="true"></AgentBoxNumber><AgentStreetDirPrefix xsi:nil="true"></AgentStreetDirPrefix><AgentStreetName>NO STREET NAME</AgentStreetName><AgentStreetAdditionalInfo xsi:nil="true"></AgentStreetAdditionalInfo><AgentStreetDirSuffix xsi:nil="true"></AgentStreetDirSuffix><AgentStreetSuffix>10000000581</AgentStreetSuffix><AgentUnitNumber xsi:nil="true"></AgentUnitNumber><AgentCity>10000050889</AgentCity><AgentCityName>ALEXANDRIA</AgentCityName><AgentCounty>10000005773</AgentCounty><AgentState>10000003034</AgentState><AgentCountry>10000002986</AgentCountry><AgentPostalCode>2222</AgentPostalCode><AgentZip4 xsi:nil="true"></AgentZip4><AgentCarrierRoute xsi:nil="true"></AgentCarrierRoute><AgentFullStreetAddress>NO STREET NAME UNDEF</AgentFullStreetAddress><AgentAddressAdditionalInfo xsi:nil="true"></AgentAddressAdditionalInfo><AgentUnitDesignation xsi:nil="true"></AgentUnitDesignation></StreetAddress></Agent><Office><OfficeID><OfficeListingServiceName>Metropolitan Regional Information Systems, Inc.</OfficeListingServiceName><OfficeName>Harry Lamberton Real Estate</OfficeName><OfficeKey>10000156587</OfficeKey><OfficeID>HCL1</OfficeID><BrokerID>HCL1</BrokerID><NRDSOfficeID xsi:nil="true"></NRDSOfficeID><OfficeModificationTimestamp>2004-06-10T18:48:17</OfficeModificationTimestamp></OfficeID><ContactInformation><OfficeOfficePhone>2024227200</OfficeOfficePhone><OfficeCellPhone xsi:nil="true"></OfficeCellPhone><OfficeHomePhone xsi:nil="true"></OfficeHomePhone><OfficeFax>2025885504</OfficeFax><OfficePager xsi:nil="true"></OfficePager><OfficeEmail xsi:nil="true"></OfficeEmail><OfficeWWW xsi:nil="true"></OfficeWWW></ContactInformation><StreetAddress><OfficeStreetNumber>3201</OfficeStreetNumber><OfficeBoxNumber xsi:nil="true"></OfficeBoxNumber><OfficeStreetDirPrefix xsi:nil="true"></OfficeStreetDirPrefix><OfficeStreetName>NEW MEXICO</OfficeStreetName><OfficeStreetAdditionalInfo xsi:nil="true"></OfficeStreetAdditionalInfo><OfficeStreetDirSuffix>10000000415</OfficeStreetDirSuffix><OfficeStreetSuffix>10000000421</OfficeStreetSuffix><OfficeUnitNumber xsi:nil="true"></OfficeUnitNumber><OfficeCity>10000008016</OfficeCity><OfficeCityName>WASHINGTON</OfficeCityName><OfficeState>10000002996</OfficeState><OfficeCountry>10000002986</OfficeCountry><OfficePostalCode>20016</OfficePostalCode><OfficeCarrierRoute xsi:nil="true"></OfficeCarrierRoute></StreetAddress></Office></MRISAgent></MRISAgents></Response>';           
        }
        System.debug('*** responseMsg :' + responseMsg);
        if(errorType == 'AuthError')
            response.setHeader('WWW-Authenticate', '');
        else
            response.setHeader('WWW-Authenticate', 'Digest realm="users@mris.com", nonce="3134333935333837303531333620cdef0349cd23d9acd8a13f372a95fc00", opaque="6e6f742075736564"');
        
        if(errorType == 'CookieError')
            response.setHeader('Set-Cookie', '');
        else
            response.setHeader('Set-Cookie', 'MDS-Session-ID=85081077681; Path=/');
        
        response.setBody(responseMsg);    
    }     
    
    private static void requestForRealping() {
        String responseMsg = '';
        
        if(errorType == 'ServiceError')
            responseMsg += '<?xml version="1.0" encoding="iso-8859-1"?><RealPING><copyright><message>RealPING - Copyright 2015 - Usage strictly restricted to licensees in accordance with the terms of the license agreement.</message></copyright><response>0</response></RealPING>';
        else
            responseMsg += '<?xml version="1.0" encoding="iso-8859-1"?><RealPING><copyright><message>RealPING - Copyright 2015 - Usage strictly restricted to licensees in accordance with the terms of the license agreement.</message></copyright><response>25203</response><subscriber><id>25203</id><password>sre0324</password><qlogin>29d67d90fdf3b954028792e4c8588680</qlogin><acct_type>Full Feature Account</acct_type></subscriber></RealPING>';   
        
        response.setBody(responseMsg);    
    }    
    
    private static void requestForXactSite() {
        String responseMsg = '';
        
        if(errorType == 'SOAPError')
            responseMsg += '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><soap:Fault><soap:faultcode>2000</soap:faultcode><soap:faultstring>Invalid parameters</soap:faultstring></soap:Fault></soap:Body></soap:Envelope>';
        else if(errorType == 'ServiceError')
            responseMsg += '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ActivateAgentWebsiteResponse xmlns="http://services.fnistools.com/"><ActivateAgentWebsiteResult><StatusCode>400</StatusCode>        <StatusMessage>failed</StatusMessage></ActivateAgentWebsiteResult>   </ActivateAgentWebsiteResponse></soap:Body></soap:Envelope>';
        else
            responseMsg += '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ActivateAgentWebsiteResponse xmlns="http://services.fnistools.com/"><ActivateAgentWebsiteResult><StatusCode>200</StatusCode>        <StatusMessage>success</StatusMessage></ActivateAgentWebsiteResult>   </ActivateAgentWebsiteResponse></soap:Body></soap:Envelope>';   
        
        response.setBody(responseMsg);    
    }
    
    private static void requestForAuthentisign(String statusMsg) {
        String responseMsg = '';
        
        if(errorType == 'ServiceError')
            responseMsg += '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><SendStoreRequestResponse xmlns="http://tempuri.org/"><SendStoreRequestResult><ShortResult>UserAlreadyUpgraded</ShortResult><LongResult>The upgrade is already applied to this user/email.</LongResult><UpgradeGUID /><UserGUID /></SendStoreRequestResult></SendStoreRequestResponse></soap:Body></soap:Envelope>';
        else
            responseMsg += '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><SendStoreRequestResponse xmlns="http://tempuri.org/"><SendStoreRequestResult><ShortResult>' + statusMsg + '</ShortResult><LongResult>The upgrade was created and the user has been e-mailed.</LongResult><UpgradeGUID>08FD3947-05C6-44D9-B5AF-E8356C707A1D</UpgradeGUID><UserGUID>057ACCF1-2B7A-4718-8932-F0B544D6F708</UserGUID></SendStoreRequestResult></SendStoreRequestResponse></soap:Body></soap:Envelope>';   
        
        response.setBody(responseMsg);
    }
}