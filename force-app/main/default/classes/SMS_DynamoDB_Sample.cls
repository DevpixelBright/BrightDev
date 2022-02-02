public with sharing class SMS_DynamoDB_Sample {

    private final String SERVICE = 'dynamodb'; 
    private String AWSAccessKeyId; 
    private String AWSAccessKeySecret;
    private String AWSRegion;
    
    public SMS_DynamoDB_Sample(){
        SMS_DynamoDB__c settings = SMS_DynamoDB__c.getValues('Default');
        AWSAccessKeyId = settings.Access_Key__c;
        AWSAccessKeySecret = settings.Secret_Access_Key__c;
        AWSRegion = settings.Region__c;
    }
    
    public String scan() {
        Map<String, String> params = new Map<String, String>();
 
        List<String> signedHeaders = new List<String>{
            'host', 
            'x-amz-date',
            'content-length',
            'content-type',
            'x-amz-target'
        };
 
        DateTime dt = DateTime.now();
        String credentialScope = dt.formatGmt('YYYYMMdd') + '/' + 
                                 AWSRegion + '/' + SERVICE + '/aws4_request';
        
        String indexName;
        String hashKey;
        String dataType;
        String query;
        
        //query = '{"TableName":"CasesBuilddemoArchive","ProjectionExpression": "ID, PRODUCT__C, MRIS_SUBSCRIPTION_ID__C","FilterExpression": "PRODUCT__C = :val", "ExpressionAttributeValues": {":val": {"S": "Compliance"}},"ReturnConsumedCapacity": "TOTAL"}';

        query = '{"TableName":"CasesProdArchive","ExclusiveStartKey":{"ID": {"S": "500U000000589FAIAY"}},"ProjectionExpression": "ID","FilterExpression": "PRODUCT__C = :val", "ExpressionAttributeValues": {":val": {"S": "Keystone"}},"ReturnConsumedCapacity": "TOTAL"}';

        //query = '{"TableName":"CasesBuilddemoArchive","ScanFilter":{"PRODUCT__C" :{"ComparisonOperator":"EQ","AttributeValueList":[{"S":"Compliance"}]}},"ReturnConsumedCapacity": "TOTAL"}';
        
        //query = '{"TableName":"CasesBuilddemoArchive","ScanFilter":{"PRODUCT__C" :{"ComparisonOperator":"EQ","AttributeValueList":[{"S":"Compliance"}]},"MRIS_SUBSCRIPTION_ID__C":{"ComparisonOperator":"EQ","AttributeValueList":[{"S":"3161885"}]}},"ReturnConsumedCapacity": "TOTAL"}';

        //query = '{"TableName":"CasesBuilddemoArchive","ProjectionExpression": "ID, PRODUCT__C, MRIS_SUBSCRIPTION_ID__C","FilterExpression": "PRODUCT__C = :val AND MRIS_SUBSCRIPTION_ID__C = :val1","ExpressionAttributeValues": {":val": {"S": "Compliance"},":val1": {"S": "3161885"}},"ReturnConsumedCapacity": "TOTAL"}';

        
        String stringToSign = this.createStringToSign(
            'AWS4-HMAC-SHA256',
            dt, 
            credentialScope, 
            this.createHashedCanonicalRequest(
                'SHA256',
                'POST',
                '/',
                params,
                new Map<String, String>{
                    'Host' => 'dynamodb.' + AWSRegion + '.amazonaws.com',
                    'x-amz-date' => dt.formatGmt('YYYYMMdd') + 'T' + 
                                    dt.formatGmt('HHmmss') + 'Z',
                    'content-length' => String.valueOf(query.length()),
                    'content-type' => 'application/x-amz-json-1.0',
                    'x-amz-target' => 'DynamoDB_20120810.Scan'
                },
                signedHeaders,
                query
            )
        );
 
        String signature = this.createSignature(
            'hmacSHA256',
            dt,
            AWSRegion,
            SERVICE,
            Blob.valueOf(stringToSign)
        );
 
        return this.callCommonDDBCall(
            dt,
            'dynamodb.' + AWSRegion + '.amazonaws.com',
            credentialScope,
            signedHeaders,
            signature,
            'DynamoDB_20120810.Scan',
            query
        );
    }
 
    public String query(String subId,String caseId) {
        Map<String, String> params = new Map<String, String>();
 
        List<String> signedHeaders = new List<String>{
            'host', 
            'x-amz-date',
            'content-length',
            'content-type',
            'x-amz-target'
        };
 
        DateTime dt = DateTime.now();
        String credentialScope = dt.formatGmt('YYYYMMdd') + '/' + 
                                 AWSRegion + '/' + SERVICE + '/aws4_request';
        
        String indexName;
        String hashKey;
        String dataType;
        String query;
        
        //query = '{"TableName":"CasesBuilddemoArchive","IndexName":"MRIS_SUBSCRIPTION_ID__C-CREATEDDATE-index","KeyConditions":{"MRIS_SUBSCRIPTION_ID__C":{"ComparisonOperator":"EQ","AttributeValueList":[{"S":"3161885"}]}},"QueryFilter":{"PRODUCT__C" :{"ComparisonOperator":"EQ","AttributeValueList":[{"S":"Compliance"}]}}}';
         
        //query = '{"TableName":"CasesBuilddemoArchive","IndexName":"MRIS_SUBSCRIPTION_ID__C-CREATEDDATE-index","QueryFilter":{"PRODUCT__C" :{"ComparisonOperator":"EQ","AttributeValueList":[{"S":"Compliance"}]}}}';

        //query = '{"TableName":"CasesBuilddemoArchive","IndexName":"MRIS_SUBSCRIPTION_ID__C-CREATEDDATE-index","ProjectionExpression": "ID, PRODUCT__C, RECORDTYPEID, MRIS_SUBSCRIPTION_ID__C","KeyConditionExpression": "MRIS_SUBSCRIPTION_ID__C = :v1 AND PRODUCT__C = :v2","ExpressionAttributeValues": {":v1": {"S": "3161885"},":v2": {"S": "Compliance"}}}';

        
        query = '{"TableName":"CasesProdArchive","IndexName":"MRIS_SUBSCRIPTION_ID__C-CREATEDDATE-index","KeyConditions":{"MRIS_SUBSCRIPTION_ID__C":{"ComparisonOperator":"EQ","AttributeValueList":[{"S":"'+subId+'"}]}},"QueryFilter":{"ID" :{"ComparisonOperator":"EQ","AttributeValueList":[{"S":"'+caseId+'"}]}}}';
         
        
        String stringToSign = this.createStringToSign(
            'AWS4-HMAC-SHA256',
            dt, 
            credentialScope, 
            this.createHashedCanonicalRequest(
                'SHA256',
                'POST',
                '/',
                params,
                new Map<String, String>{
                    'Host' => 'dynamodb.' + AWSRegion + '.amazonaws.com',
                    'x-amz-date' => dt.formatGmt('YYYYMMdd') + 'T' + 
                                    dt.formatGmt('HHmmss') + 'Z',
                    'content-length' => String.valueOf(query.length()),
                    'content-type' => 'application/x-amz-json-1.0',
                    'x-amz-target' => 'DynamoDB_20120810.Query'
                },
                signedHeaders,
                query
            )
        );
 
        String signature = this.createSignature(
            'hmacSHA256',
            dt,
            AWSRegion,
            SERVICE,
            Blob.valueOf(stringToSign)
        );
 
        return this.callCommonDDBCall(
            dt,
            'dynamodb.' + AWSRegion + '.amazonaws.com',
            credentialScope,
            signedHeaders,
            signature,
            'DynamoDB_20120810.Query',
            query
        );
    }
    
    /*
    public String describeTable(String tableName) {
        Map<String, String> params = new Map<String, String>();
 
        List<String> signedHeaders = new List<String>{
            'host', 
            'x-amz-date',
            'content-length',
            'content-type',
            'x-amz-target'
        };
 
        DateTime dt = DateTime.now();
        String credentialScope = dt.formatGmt('YYYYMMdd') + '/' + 
                                 AWSRegion + '/' + SERVICE + '/aws4_request';
        
        
        String query;
        
        query = '{"TableName":"' + tableName + '"}';
            
         
        String stringToSign = this.createStringToSign(
            'AWS4-HMAC-SHA256',
            dt, 
            credentialScope, 
            this.createHashedCanonicalRequest(
                'SHA256',
                'POST',
                '/',
                params,
                new Map<String, String>{
                    'Host' => 'dynamodb.' + AWSRegion + '.amazonaws.com',
                    'x-amz-date' => dt.formatGmt('YYYYMMdd') + 'T' + 
                                    dt.formatGmt('HHmmss') + 'Z',
                    'content-length' => String.valueOf(query.length()),
                    'content-type' => 'application/x-amz-json-1.0',
                    'x-amz-target' => 'DynamoDB_20120810.DescribeTable'
                },
                signedHeaders,
                query
            )
        );
 
        String signature = this.createSignature(
            'hmacSHA256',
            dt,
            AWSRegion,
            SERVICE,
            Blob.valueOf(stringToSign)
        );
 
        return this.callCommonDDBCall(
            dt,
            'dynamodb.' + AWSRegion + '.amazonaws.com',
            credentialScope,
            signedHeaders,
            signature,
            'DynamoDB_20120810.DescribeTable',
            query
        );
    }*/

    private String callCommonDDBCall(DateTime dt,String hostname,String credentialScope,List<String> signedHeaders,String signature,String target,String query) {
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Host', hostname);
        req.setHeader(
            'x-amz-date', 
            dt.formatGmt('YYYYMMdd') + 'T' + dt.formatGmt('HHmmss') + 'Z'
        );
 
        req.setHeader('Content-Type', 'application/x-amz-json-1.0');
        req.setHeader('x-amz-target', target);
        req.setHeader('Content-Length', String.valueOf(query.length()));
 
        req.setHeader(
            'Authorization',
            'AWS4-HMAC-SHA256 Credential=' + this.AWSAccessKeyId + '/' + credentialScope + ',' +
            'SignedHeaders=' + String.join(getLowerCaseSortedList(signedHeaders), ';') + ',' + 
            'Signature=' + signature
        );
        req.setEndpoint('https://' + hostname + '/');
        req.setMethod('POST');
 
        req.setBody(query);
 
        Http http = new Http();
        HttpResponse res;
        if (Test.isRunningTest()) {
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            /*
      Map<String,String> fieldValues = new Map<String,String>{'S' => 'NULL'};
            Map<String,Map<String,String>> fieldNames = new Map<String,Map<String,String>>{'TYPE' => fieldValues,'ACCOUNTID' = fieldValues};
      Map<String,String> resBody = new Map<String,String>{'Count' => '1','Items' => 'Test'};            
//String resbody = '{"Count":1,"Items":[{"TYPE":{"S":"NULL"},"ID":{"S":"500U000000580GWIAY"},"ACCOUNTID":{"S":"001U000000Nx8ciIAB"},"PRODUCT__C":{"S":"MIGRATE-INITIAL"}}]}';
            
            Map<String, Object> jsonMap = new Map<String, Object> {
    'TableName' => 'CasesJsonTest',
    'Items' => new Map<String, Object> {
        'ID' => new Map<String, Object> {
         'S'=>'500U000000580GfIAI'  
        },'ACC' => new Map<String, Object> {
         'S'=>'500U000000580GfIAI'  
        }
    }
};*/
    Map<String, Object> fieldValue = new Map<String, Object>
{
  'S' => 'StringValue'
};
 Map<String, Object> fieldNames = new Map<String, Object>{
  'FIELDNAME1' => fieldValue,
  'FIELDNAME2' => fieldValue,
  'FIELDNAME3' => fieldValue,
  'FIELDNAME4' => fieldValue
};
List<object> records = new List<Object>{fieldNames , fieldNames ,fieldNames  };
Map<String, Object> responseBody = new Map<String, Object>{
  'Items' => records
};
//String resbody = Json.serialize(jsonMap);
            res.setBody(JSON.serialize(responseBody));
            res.setStatusCode(200);
        }
        else
            res = http.send(req);
            
        return res.getBody();
    }
 
    private String createHashedCanonicalRequest(String algorithm,String method,String url,Map<String, String> params,Map<String, String> headers,List<String> signedHeaders,String payload) {     
        String signature = '';
        signature += method + '\n';
        signature += url + '\n';
        signature += getSortedParam(params) + '\n';
        signature += createCanonicalHeaders(headers) + '\n';
        signature += String.join(getLowerCaseSortedList(signedHeaders), ';') + '\n';
        signature += EncodingUtil.convertToHex(Crypto.generateDigest(algorithm,Blob.valueOf(payload)));
        
        //system.debug(signature);
        return EncodingUtil.convertToHex(Crypto.generateDigest(algorithm,Blob.valueOf(signature))).toLowerCase();
    }
 
    
    private String createStringToSign(String algorithm,DateTime requestDateTime,String credentialScope,String hashedCanonicalRequest) {
        String stringToSign = algorithm + '\n';
        stringToSign += requestDateTime.formatGmt('YYYYMMdd') + 'T' + requestDateTime.formatGmt('HHmmss') + 'Z' + '\n';
        stringToSign += credentialScope + '\n';
        stringToSign += hashedCanonicalRequest;
        return stringToSign;        
    }
 
    private String createSignature(String algorithm,DateTime requestDateTime,String AWSRegion,String service,Blob stringToSign) {
        
        //system.debug(stringToSign.toString());
        
        Blob kDate = Crypto.generateMac(algorithm,Blob.valueOf(requestDateTime.formatGmt('YYYYMMdd')),Blob.valueOf('AWS4' + this.AWSAccessKeySecret));
        
        Blob kRegion = Crypto.generateMac(algorithm,Blob.valueOf(AWSRegion),kDate);
        
        Blob kService = Crypto.generateMac(algorithm,Blob.valueOf(service),kRegion);
 
        Blob kSigning = Crypto.generateMac(algorithm,Blob.valueOf('aws4_request'),kService);
 
        return EncodingUtil.convertToHex(Crypto.generateMac(algorithm,stringToSign,kSigning));
    }
    
    private String getSortedParam(Map<String,String> mapParam){
        if (mapParam == null || mapParam.keySet().isEmpty()) {
            return '';
        }
        String param = '';
        List<String> keys = new List<String>();
        keys.addAll(mapParam.keySet());
        List<String> sortedKey = getLowerCaseSortedList(keys);
        for(String key: sortedKey){
            param += percentEncodeRfc3986(key) + '=' + percentEncodeRfc3986(mapParam.get(key)) + '&';
        }
        return param.substring(0,param.length() - 1);
    }
 
    private String percentEncodeRfc3986(String s) {
        return EncodingUtil.urlEncode(s, 'UTF-8').replace('+', '%20').replace('*', '%2A').replace('%7E', '~');
    }
 
    private String createCanonicalHeaders(Map<String, String> headers) {
        if (headers == null || headers.keySet().isEmpty()) {
            return '';
        }
 
        Map<String, String> lowerCaseHeaders = new Map<String, String>();
        for (String key : headers.keySet()) {
            lowerCaseHeaders.put(key.toLowerCase(), headers.get(key));
        }
        String param = '';
        List<String> keys = new List<String>();
        keys.addAll(lowerCaseHeaders.keySet());
        List<String> sortedKey = getLowerCaseSortedList(keys);
        for(String key: sortedKey){
            param += key + ':' + lowerCaseHeaders.get(key).trim() + '\n';
        }
        return param;
    }
 
    private List<String> getLowerCaseSortedList(List<String> keys) {
        List<String> sortedKeys = new List<String>();
        for (String key : keys) {
            sortedKeys.add(key.toLowerCase());
        }
        sortedKeys.sort();
        return sortedKeys;
    }
}