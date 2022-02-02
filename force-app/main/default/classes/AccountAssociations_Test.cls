@isTest
public class AccountAssociations_Test
{
    static testMethod void testDoTest() 
    {
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();    
        
        Account mainAccount = new Account();
        mainAccount.name = 'ADA1231';
        mainAccount.type = 'Residential';
        mainAccount.Account_Name__c = 'Main Account';
        mainAccount.City__c = 'Herndon';
        mainAccount.Zip__c = '20171';
        mainAccount.QAS_Mailing_County__c = 'Fairfax';
        mainAccount.County__c = 'Fairfax';
        mainAccount.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert mainAccount;
        mainAccount.State__c = 'MD';
        mainAccount.OfficeKey__c = '12345';
        update mainAccount;
        
        Account relatedAccountOne = new Account();
        relatedAccountOne.name = 'ADA1232';
        relatedAccountOne.type = 'Association';
        relatedAccountOne.Account_Name__c = 'Related Account Association';
        relatedAccountOne.City__c = 'Herndon';
        relatedAccountOne.Zip__c = '20171';
        relatedAccountOne.QAS_Mailing_County__c = 'Fairfax';
        relatedAccountOne.County__c = 'Fairfax';
        relatedAccountOne.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert relatedAccountOne;
        
        Account relatedAccountTwo = new Account();
        relatedAccountTwo.name = 'ADA1233';
        relatedAccountTwo.type = 'Association';
        relatedAccountTwo.Account_Name__c = 'Related Account Association';
        relatedAccountTwo.City__c = 'Herndon';
        relatedAccountTwo.Zip__c = '20171';
        relatedAccountTwo.QAS_Mailing_County__c = 'Fairfax';
        relatedAccountTwo.County__c = 'Fairfax';
        relatedAccountTwo.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        insert relatedAccountTwo;
        
        Related_Association__c associationOne = new Related_Association__c ();
        associationOne.Association__c = relatedAccountOne.id;
        associationOne.Broker_Code__c = mainAccount.id;
        insert associationOne;
        
        Related_Association__c associationTwo = new Related_Association__c ();
        associationTwo.Association__c = relatedAccountTwo.id;
        associationTwo.Broker_Code__c = mainAccount.id;
        insert associationTwo;
        
        PageReference accountDetail= Page.AccountDetailPage; 
        Test.setCurrentPage(accountDetail);
        ApexPages.currentPage().getParameters().put('id',mainAccount.id);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(mainAccount); 
        AccountAssociations accAssociation = new AccountAssociations(controller);
        accAssociation.associationId = associationOne.id;
        accAssociation.addAssociation();        
        accAssociation.editAssociation();
        accAssociation.saveEdit();
        accAssociation.cancelEdit();
        accAssociation.deleteAssociation();
        
        
    }
}