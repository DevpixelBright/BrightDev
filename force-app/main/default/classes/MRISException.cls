/**
* @author: klanka@rainamker-llc.com
* @date:  2012-06-01
* Exception class to handle error messages
**/
global class MRISException extends Exception{
    
    global boolean isCriticalException {get; private set;}
    
    global MRISException(String message, boolean isCriticalException){
        this.setMessage(message);
        this.isCriticalException = isCriticalException;
    }
    
    global MRISException(String message, boolean isCriticalException, Exception ex){
        this.setMessage(message);
        this.isCriticalException = isCriticalException;
        
    }
    
    static testMethod void testDoGet() {
    
        MRISException me = new MRISException('this is an exception', true);
        
        Exception e;
        MRISException me2 = new MRISException('this is another exception', false, e);
        
        
        
    
    }
}