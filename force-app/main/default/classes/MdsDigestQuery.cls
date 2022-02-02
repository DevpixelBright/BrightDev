public class MdsDigestQuery {
   static String uri = '/services/rest/UserSessionInfo';
   static String httpMethod = 'GET';
   static String e1 = '';
   static String cookie = '';
   static String auth = '';

   public static String mdsDigestQuery (String qry) {
      System.Debug('mdsDigestQuery String:'+qry);

      //construct initial HTTP request
      HttpRequest req = new HttpRequest();

      req.setMethod(httpMethod);
      req.setHeader('Content-Type', 'application/xml');
      req.setHeader('X-User-Agent', 
                    MDS_Settings__c.getInstance().product__c + '/' + 
                    MDS_Settings__c.getInstance().ver__c );
                    
      req.setEndpoint(MDS_Settings__c.getInstance().mds_url__c + uri);
      e1 = MDS_Settings__c.getInstance().e1__c;
      
      System.Debug('request header content type: '+req.getHeader('Content-Type'));
      System.Debug('request header: user agent: '+req.getHeader('X-User-Agent'));
      System.Debug('request EndPoint: '+req.getEndpoint());
      System.Debug('e1:'+e1);
      System.Debug('SendRequest:'+req); 
      //send initial request
      HttpResponse res = sendRequest(req);
      System.Debug('After sending first request:'); 
      // respond to digest challenges
      HttpResponse res2 = digestResponse(res);
      System.Debug('After sending second request:'); 
      HttpResponse res3 = digestResponse(res2);
      System.Debug('After sending third request:'); 

      //send mds query
      req = new HttpRequest();

      req.setMethod(httpMethod);
      req.setHeader('Content-Type', 'application/xml');
      req.setHeader('X-User-Agent',
                    MDS_Settings__c.getInstance().product__c + '/' + 
                    MDS_Settings__c.getInstance().ver__c );
      req.setHeader('Cookie',cookie);
      req.setHeader('Authorization', auth);

      req.setEndpoint(MDS_Settings__c.getInstance().mds_url__c + qry);
    
      HttpResponse res4 = sendRequest(req);
      return res4.getBody();
   }
  
   public static HttpResponse digestResponse(HttpResponse rs1) {
      System.Debug(rs1);
      String WWWAuthenticate = rs1.getHeader('WWW-Authenticate');
      String realm = waParse('realm',WWWAuthenticate);
      String nonce = waParse('nonce',WWWAuthenticate);
      String opaque = waParse('opaque',WWWAuthenticate);
      String e2 = EncodingUtil.base64Decode(e1).toString();
      
      String a1 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', 
                  Blob.valueOf(MDS_Settings__c.getInstance().userid__c + ':' + realm + ':' + e2)));
      String a2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(httpMethod + ':' + uri)));
      String digest = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(a1 + ':' + nonce + ':' + a2)));

      auth='Digest username="' + MDS_Settings__c.getInstance().userid__c + 
           ((!String.isEmpty(realm)) ? '", realm="' + realm : '') +
           ((!String.isEmpty(nonce)) ? '", nonce="' + nonce : '') +
           ((!String.isEmpty(uri)) ? '", uri="' + uri : '') +
           ((!String.isEmpty(digest)) ? '", response="' + digest : '') +
           ((!String.isEmpty(opaque)) ? '", opaque="' + opaque : '') + '"';
    
      //update HTTP request authorization for challenge response
      HttpRequest req = new HttpRequest();
      req.setMethod(httpMethod);
      req.setHeader('Content-Type', 'application/xml');
      req.setHeader('X-User-Agent', 
                    MDS_Settings__c.getInstance().product__c + '/' + 
                    MDS_Settings__c.getInstance().ver__c );
      req.setHeader('Authorization', auth);

      //get cookie if present
      if (!String.isEmpty(rs1.getHeader('Set-Cookie'))) {
         cookie = rs1.getHeader('Set-Cookie').replaceAll(';.*','');
         req.setHeader('Cookie',cookie);
      }

      req.setEndpoint(MDS_Settings__c.getInstance().mds_url__c + uri);

      //send challenge response
      HttpResponse rs2 = sendRequest(req);
      return rs2;
   }

   public static HttpResponse sendRequest(HttpRequest req) {
      Http http = new Http();
      //em debugging
      System.Debug('in sendRequest before it sends req'); 
      System.debug('Request Body: '+req.getBody());
      
      
      HttpResponse res = http.send(req);
      System.Debug('in send request after it sends req'); 
      System.debug('##########XML DATA from the response##########'+res.getXmlStreamReader());
      //Xmlstreamreader reader = new Xmlstreamreader(res.getBody());
      //while(reader.hasNext())
      //{
       //System.Debug('next text in res:'+reader.getText()); 
       //reader.next();
      //} 
      //check the response
      if (res.getStatusCode() == 200) {
         System.Debug('Success!!!!!!!! response: '+res.getBody());
      } else {
         System.debug('Callout failed: ' + res);
         System.debug('Callout failed: ' + res.getStatus());
         System.debug('Callout failed: ' + res.getBody());
      }
      return res;
   }

   public static void prtHdr(HttpResponse res) {
      string[] headerkeys = res.getHeaderKeys();
      Map<string, string> headers = new map<string, string>();
      for(string s : headerkeys) {
         if(s!=null) {
            headers.put(s,res.getHeader(s));
            system.debug('header: ' + s + ' value: ' + res.getHeader(s));
         }
      }
   }

   // parse given item, ie., WWW-Authenticate
   public static String waParse(String f1, String f2) {
      return (!f2.contains(f1)) ? '' : 
         f2.replaceAll('.*' + f1 + '="','').replaceAll('".*','');
   }

   public static void tmpMethod() {
      String rsp = MdsDigestQuery.mdsDigestQuery('/services/rest/Agent/10000261281?View=AGENT_PARTY_ROLES');
      System.debug('MDS!!!!!!!!!!: '+rsp);
   }   
}