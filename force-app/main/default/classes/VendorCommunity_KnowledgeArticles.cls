public class VendorCommunity_KnowledgeArticles {
    
    //Page Size
    private Static Final Integer PAGE_NUMBER = 25;
    
    //Search String used in ArticleList tag
    public String searchstring { get; set; }
    public set<string> departments{get; set;}
    public String filterType { get; set; }
    
    public VendorCommunity_KnowledgeArticles() {
        String qryString = 'SELECT Id, title, UrlName, ArticleType, LastPublishedDate, LastModifiedById FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'en_US\')';
        List<KnowledgeArticleVersion> articleList = Database.query(qryString);
        maxSize = articleList.size() ;
        departments = new set<string>();
        for(KnowledgeArticleVersion art : articleList){
        	system.debug('---art.ArticleType---'+art.ArticleType);
        	departments.add(art.ArticleType);
        }
    }
    
    //Keeps track of current page & max size of article list
    Integer currentPage = 1;
    Integer maxSize = 1;
    
    // Returns whether we need to see previous button or not
    public boolean getPrevRequired() {
        return currentPage > 1;
    }
    
    // Returns whether we need to see next button or not
    public boolean getNextRequired() {
        return currentPage * PAGE_NUMBER < maxSize;
    }
    
    //Returns current page number 
    public Decimal getCurrentPageNumber() {
        return this.currentPage;
    }
    
    //action for next click
    public PageReference next() {
        if(maxSize > this.currentPage * PAGE_NUMBER) {
            this.currentPage = this.currentPage + 1;
        }
        return null;
    }    
    
    //action for previous click
    public PageReference previous() {        
        if(this.currentPage > 1)
            this.currentPage = this.currentPage - 1;
        return null;
    }
    
}