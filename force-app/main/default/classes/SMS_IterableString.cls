global class SMS_IterableString implements Iterator<String> {
    List<String> iterableStrings ;
    Integer i; 
    
    public SMS_IterableString(List<String> iterableStrings) {
        this.iterableStrings = iterableStrings;
        i = 0;
    }
    
    global boolean hasNext(){
        if(i >= iterableStrings.size())
            return false;
        else 
            return true;
    }
    
    global String next() {
        if(i > iterableStrings.size()) return null;
        
        i++;
        return iterableStrings[i-1];
    }
}