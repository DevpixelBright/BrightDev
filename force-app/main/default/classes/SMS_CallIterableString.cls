global class SMS_CallIterableString  implements Iterable<String> {
    List<String> iterableStrings ;
    
    public SMS_CallIterableString (List<String> iterableStrings) {
        this.iterableStrings = iterableStrings;
    }
    
    global Iterator<String> Iterator() {
        return new SMS_IterableString(iterableStrings);
    }
}