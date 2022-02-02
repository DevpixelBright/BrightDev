public virtual without sharing class Bootstrap_Controller 
{       
    public Bootstrap_Controller() {
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge, chrome=1');
        Apexpages.currentPage().getHeaders().put('viewport', 'width=device-width, initial-scale=1, maximum-scale=1');
    }
}