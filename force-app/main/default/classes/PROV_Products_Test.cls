@istest(seealldata = true)
private class PROV_Products_Test {
    
    private Static Account account;
    private Static Contact contact;
    private Static Subscriptions__c subscription;
    private static Relationship__c relaion;  
    private static SMS_Provisioned_Product__c provisionProduct;  
    
    
    private static testMethod void doTestAuthentisignOne(){       
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'Authentisign', 'Authentisign', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'HTTPError';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    } 
    
    private static testMethod void doTestAuthentisignTwo(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'Authentisign', 'Authentisign', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'EmptyResponse';       
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct);
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                             
    }
    
    private static testMethod void doTestAuthentisignThree(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'Authentisign', 'Authentisign', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'ServiceError';       
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                            
    } 
    
    private static testMethod void doTestAuthentisignFour(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'Authentisign', 'Authentisign', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = true;      
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct);
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                             
    } 
    
    private static testMethod void doTestAuthentisignFive(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'Authentisign', 'Authentisign', 'Terminate', 'Pending Deprovisioned');        

        PROV_MockDataGenerator.isSuccess = true;      
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct);
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                             
    }  
    
    private static testMethod void doTestAuthentisignSix(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'Authentisign', 'Authentisign', 'Update', 'Pending Deprovisioned');        

        PROV_MockDataGenerator.isSuccess = true;      
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct);
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                             
    } 
    
    private static testMethod void doTestXactsiteOne(){       
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Select', 'New', 'Pending Provisioned');               
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'HTTPError';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);  
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList); 
        
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Office', 'New', 'Pending Provisioned');       
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'HTTPError';        
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct); 
        List<SMS_Provisioned_Product__c> provProductList1 = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList1);                                             
    } 
    
    private static testMethod void doTestXactsiteTwo(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Select', 'New', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'SOAPError';       
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList); 
        
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Office', 'New', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'SOAPError';       
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct);
        List<SMS_Provisioned_Product__c> provProductList1 = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList1);                                                     
    }
    
    private static testMethod void doTestXactsiteThree(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Select', 'New', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'ServiceError';       
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);  
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);
        
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Office', 'New', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'ServiceError';       
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct);  
        List<SMS_Provisioned_Product__c> provProductList1 = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList1);                                                      
    } 
    
    private static testMethod void doTestXactsiteFour(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Select', 'New', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = true;    
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList); 
        
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Office', 'New', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = true;    
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct); 
        List<SMS_Provisioned_Product__c> provProductList1 = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList1);                                                    
    } 
    
    private static testMethod void doTestXactsiteFive(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Select', 'Terminate', 'Pending Deprovisioned');        
        PROV_MockDataGenerator.isSuccess = true;    
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);
        
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Office', 'Terminate', 'Pending Deprovisioned');        
        PROV_MockDataGenerator.isSuccess = true;    
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct); 
        List<SMS_Provisioned_Product__c> provProductList1 = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList1);                                                     
    }  
    
    private static testMethod void doTestXactsiteSix(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Select', 'Reinstate', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = true;    
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);  
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);  
        
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Office', 'Reinstate', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = true;    
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct);  
        List<SMS_Provisioned_Product__c> provProductList1 = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList1);                                                    
    }
    
    private static testMethod void doTestXactsiteSeven(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Select', 'Update', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = true;    
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);  
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);  
        
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Office', 'Update', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = true;    
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct);  
        List<SMS_Provisioned_Product__c> provProductList1 = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList1);                                                    
    }
    
    private static testMethod void doTestXactsiteEight(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Select', 'Terminate', 'Pending Deprovisioned');        
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'ServiceError';       
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);    
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);
        
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Office', 'Terminate', 'Pending Deprovisioned');        
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'ServiceError';       
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct);    
        List<SMS_Provisioned_Product__c> provProductList1 = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList1);                                                    
    } 
    
    private static testMethod void doTestXactsiteNine(){         
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Select', 'Reinstate', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'ServiceError';       
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct);        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);  
        
        createProvisionProduct(subscription.Id, subscription.Name, 'XactSite', 'XactSite Office', 'Reinstate', 'Pending Provisioned');        
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'ServiceError';       
        PROV_ProvisionProduct obj1 = new PROV_ProvisionProduct(provisionProduct);        
        List<SMS_Provisioned_Product__c> provProductList1 = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList1);                                                   
    }                                                    
    
    private static testMethod void doTestRealpingOne(){       
        generateTestData();
        subscriptionRelationship(subscription.Id);
        createProvisionProduct(subscription.Id, subscription.Name, 'realPING', 'realPING', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'HTTPError';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    }
    
    private static testMethod void doTestRealpingTwo(){       
        generateTestData();
        subscriptionRelationship(subscription.Id);
        createProvisionProduct(subscription.Id, subscription.Name, 'realPING', 'realPING', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'EmptyResponse';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    }
    
    private static testMethod void doTestRealpingThree(){       
        generateTestData();
        subscriptionRelationship(subscription.Id);
        createProvisionProduct(subscription.Id, subscription.Name, 'realPING', 'realPING', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'ServiceError';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    } 
    
    private static testMethod void doTestRealpingFour(){       
        generateTestData();
        subscriptionRelationship(subscription.Id);
        createProvisionProduct(subscription.Id, subscription.Name, 'realPING', 'realPING', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = true;      
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    }
    
    private static testMethod void doTestRealpingFive(){       
        generateTestData();
        subscriptionRelationship(subscription.Id);
        createProvisionProduct(subscription.Id, subscription.Name, 'realPING', 'realPING', 'Terminate', 'Pending Deprovisioned');        

        PROV_MockDataGenerator.isSuccess = true;      
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    } 
    
    private static testMethod void doTestRealpingSix(){       
        generateTestData();
        subscriptionRelationship(subscription.Id);
        createProvisionProduct(subscription.Id, subscription.Name, 'realPING', 'realPING', 'Reinstate', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = true;      
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    }   
    
    private static testMethod void doTestRealpingSeven(){       
        generateTestData();
        subscriptionRelationship(subscription.Id);
        createProvisionProduct(subscription.Id, subscription.Name, 'realPING', 'realPING', 'Update', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = true;      
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    } 
    
    private static testMethod void doTestRealpingEight(){       
        generateTestData();
        subscriptionRelationship(subscription.Id);
        createProvisionProduct(subscription.Id, subscription.Name, 'realPING', 'realPING', 'Reinstate', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'HTTPError';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    } 
    
    private static testMethod void doTestRealpingNine(){       
        generateTestData();
        subscriptionRelationship(subscription.Id);
        createProvisionProduct(subscription.Id, subscription.Name, 'realPING', 'realPING', 'Terminate', 'Pending Deprovisioned');        

        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'HTTPError';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    } 
    
    
    private static testMethod void doTestSpherebyBrightMLSAgentIDX(){       
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'Sphere by Bright MLS Agent IDX', 'Sphere by Bright MLS Agent IDX', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = true;
        //PROV_MockDataGenerator.errorType = 'HTTPError';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    } 
    
    private static testMethod void doTestSpherebyBrightMLSOfficeIDX(){       
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'Sphere by Bright MLS Office IDX', 'Sphere by Bright MLS Office IDX', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = true;
        //PROV_MockDataGenerator.errorType = 'HTTPError';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    } 
    
    
    private static testMethod void doTestCloudCMA(){       
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'CloudCMA', 'CloudCMA', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = true;
        //PROV_MockDataGenerator.errorType = 'HTTPError';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    } 
    
    private static testMethod void doTestSpherebyBrightMLS(){       
        generateTestData();
        createProvisionProduct(subscription.Id, subscription.Name, 'Sphere by Bright MLS', 'Sphere by Bright MLS', 'New', 'Pending Provisioned');        

        PROV_MockDataGenerator.isSuccess = true;
        //PROV_MockDataGenerator.errorType = 'HTTPError';        
        PROV_ProvisionProduct obj = new PROV_ProvisionProduct(provisionProduct); 
        
        List<SMS_Provisioned_Product__c> provProductList = new List<SMS_Provisioned_Product__c>{provisionProduct};
        PROV_ProvisionProductDirect.PROV_ProvisionProduct(provProductList);                                    
    } 
    
    
    private static testMethod void doTestCornerStoneOne(){             
        PROV_MockDataGenerator.isSuccess = true;       
        PROV_CornerStoneUpdate.updateCornerStone('35434545', '23456');                            
    }
    
    private static testMethod void doTestCornerStoneTwo(){             
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'HTTPError';      
        PROV_CornerStoneUpdate.updateCornerStone('35434545', '23456');                            
    } 
    
    private static testMethod void doTestCornerStoneThree(){             
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'ServiceError';      
        PROV_CornerStoneUpdate.updateCornerStone('35434545', '23456');                            
    } 
    
    private static testMethod void doTestCornerStoneFour(){                  
        PROV_CornerStoneUpdate.updateCornerStone('', '');                            
    }
    
    private static testMethod void doTestCornerStoneFive(){             
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'AuthError';      
        PROV_CornerStoneUpdate.updateCornerStone('35434545', '23456');                            
    } 
    
    private static testMethod void doTestCornerStoneSix(){             
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'CookieError';      
        PROV_CornerStoneUpdate.updateCornerStone('35434545', '23456');                            
    } 
    
    private static testMethod void doTestCornerStoneSeven(){             
        PROV_MockDataGenerator.isSuccess = false;
        PROV_MockDataGenerator.errorType = 'StatusError';      
        PROV_CornerStoneUpdate.updateCornerStone('35434545', '23456');                            
    }                                                              
    
    private static void generateTestData() {
        generateData();
        createAccount('Residential','XYZ124');
        createContact(account.Id); 
        createSubscription(account.Id, contact.Id);
        
        subscription.Status__c = 'Active';
        update subscription;    
    }                    
    
    private static void createAccount(String type,String name){
        account = new Account();
        account.Name = name;
        account.Type = type;
        account.Account_Name__c = 'Test Account';
        account.QAS_Mailing_County__c = 'Fairfax';
        account.County__c = 'Fairfax';
        account.City__c = 'Herndon';
        account.Zip__c = '20171';
        account.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        account.State__c = 'VA';
        account.Street_Type__c = 'ACRES, ACRES';
        account.Street_Number__c = '453';
        account.Street_Name__c = 'avenue';
        account.Street_Direction__c = 'W, WEST'; 
        insert account; 
    }
    
    private static void createContact(String accountId){
        contact = new Contact();
        contact.Email = 'email@something.com';
        contact.FirstName = 'Test Class';
        contact.LastName = 'Contact';
        contact.Public_Email__c = 'email@something.com';
        contact.AccountId = accountId; 
        contact.Salutation = 'Mr.';
        contact.City__c = 'Herndon';
        contact.QAS_Mailing_County__c = 'Arlington';
        contact.Zip__c = '20171';
        contact.State__c = 'VA';
        insert contact;  
    }
    
    private Static void createSubscription(String accountId, String contactId){
        subscription = new  Subscriptions__c();
        subscription.Name = '12345';
        subscription.Contact__c = contact.id;
        subscription.Subscription_Type__c = 'Realtor/Shareholder';
        subscription.Status__c = 'In Progress';
        subscription.City__c = 'Alexandria';
        subscription.State__c = 'VA';
        subscription.Zip__c = '20171';
        subscription.County__c = 'Fairfax';
        subscription.QAS_Mailing_Street_Type__c = 'ACRES, ACRES';
        subscription.AgentKey__c = '123111';
        subscription.name = '123111';
        subscription.County__c = 'Fairfax';
        subscription.Related_Location_Broker_Office__c = account.id;
        subscription.Contact_Type__c = 'Agent';
        subscription.Private_Email__c = 'test@test.com';
        subscription.Primary_Phone__c = '9999999999';

        insert subscription; 
    }
    
    private Static void createProvisionProduct(String subId, String subName, String product, String subType, String productStatus, String provStatus) {
        provisionProduct = new SMS_Provisioned_Product__c();
        provisionProduct.MRIS_Subscription_Id__c = subName;
        provisionProduct.Product_Type__c = product;
        provisionProduct.Product_Sub_Type__c = subType;
        provisionProduct.Product_Status__c = productStatus;
        provisionProduct.Provisioned_Status__c = provStatus;
        provisionProduct.RealPing_Id__c = '20586';
        insert provisionProduct;
    }
    
    private static void generateData(){         
        CornerstoneAddrUtility cau = new CornerstoneAddrUtility();
        cau.addAddrs();  
    }
    
    private Static void subscriptionRelationship(String subName) {
        relaion = new Relationship__c();
        relaion.Relationship_Type__c = 'Broker Of Record';
        relaion.Subscription__c= subName;
        insert relaion;
    }          
       
}