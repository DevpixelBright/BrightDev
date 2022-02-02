public class ArticlesPrint {
    public Knowledge__kav currentArticle {get;set;}
    
    public ArticlesPrint(){
        List <Knowledge__kav> artilceList = [SELECT Id, ArticleNumber, KB_Article_Content_RTF__c, KB_Article_Content__c, UrlName, Title, Summary from Knowledge__kav 
                                             WHERE Id =: ApexPages.currentPage().getParameters().get('kvid')];
        if(artilceList != null && artilceList.size() > 0){
            currentArticle = artilceList[0];
        }
    }
}