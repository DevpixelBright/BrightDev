public class SMS_ZuoraIntegrationWorkflowBypass {
    
    public static Boolean zuoraByPass { get; set; }
    public static Integer counter  { get; set; }
    
    
    public static Map<String,boolean> subIdZByPass { get; set; }
    
    /*
    
    public static Map<String,boolean> subIdZByPass{ get{
        if(subIdZByPass == null)
            return new Map<String,Boolean>();
        else
            return subIdZByPass;
    } set; }
    
    
    public static void setZuoraByPass(Boolean byPass) {
        zuoraByPass = byPass;    
    }
    
    public static Boolean getZuoraByPass() {
        return zuoraByPass;
    }
    
    public static void setCounter() {
        if(counter == null)
            counter = 0;
        counter++;
    }
    
    public static Integer getCounter() {
        return counter;
    } */  
}