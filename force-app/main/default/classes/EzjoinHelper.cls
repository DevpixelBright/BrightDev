public without Sharing class EzjoinHelper {
//test class: EZJoin_NewapplicationController_Test
    public static List<Sobject> getApplicationDetails(string query){
        if(query != null)
        return Database.query(query);
        else
            return null;
    }
}