public class MARCOM_Util {
    
    public static Map<String,String> getLabelValue(List<String> lName){
        Map<String,String> mLabels = new Map<String,String>();
        try{
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID()); //Get user Session ID
            req.setHeader('Content-Type', 'application/json');
            String SFdomainUrl=URL.getSalesforceBaseUrl().toExternalForm();
            string query='Select+id,Name,value+from+externalstring+where+name+in+(';
            for(Integer i = 0; i < lName.size(); i++){
                if(i != 0)
                    query += ',';
                query += '\''+lName[i]+'\'';
            }
            query += ')';
            req.setEndpoint(SFdomainUrl+'/services/data/v49.0/tooling/query/?q='+query);
            req.setMethod('GET');
            Http h = new Http();
            HttpResponse response = h.send(req);
            system.debug(response.getBody());
            ToolingResponse tr = ToolingResponse.parse(response.getBody());
            system.debug(tr.records);
            for(ToolingResponse.Records rec : tr.records){
                mLabels.put(rec.Name, rec.value);
            }
            system.debug(mLabels);
            return mLabels;
        }catch(Exception ex){
            return mLabels;
        }
    }
    
    public static String processEmailBody(String hBody){
        system.debug(hBody);
        Boolean hasLabel = true;
        Integer maxIteration = 0;
        List<String> lLbl = new List<String>();
        Map<String,String> mLabels = new Map<String,String>();
        while(hasLabel && maxIteration < 20){
            maxIteration++;
            if(hBody.contains('{!$Label')){
                String tag = hBody.substringBetween('{!$Label.', '}');
                System.debug('before trim = '+tag);
                System.debug('after trim = '+tag.trim());
                lLbl.add(tag.trim());
                hBody = hBody.replace('{!$Label.'+tag+'}', '<tag>'+tag+'</tag>');
            }else{
                hasLabel = false;
            }
        }
        mLabels = getLabelValue(lLbl);
        system.debug(mLabels);
        for(String key : mLabels.keySet()){
            hBody = hBody.replaceAll('<tag>'+ key +'</tag>', mLabels.get(key));
        }
        return hbody;
    }
}