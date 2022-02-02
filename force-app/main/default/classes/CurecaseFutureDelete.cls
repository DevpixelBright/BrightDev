public class CurecaseFutureDelete {
    @Future
    public static void deleteCase(list<string> delCaseIds){
    
        if(delCaseIds != null && !delCaseIds.isEmpty()){
            list<case> delCases = [Select Id From Case Where Id IN :delCaseIds];
                delete delCases;
            
        }
        
    } 
}