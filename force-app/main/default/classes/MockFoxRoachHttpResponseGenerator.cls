@isTest
global class MockFoxRoachHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        Reliance_API_Configuration__mdt relianceConfig = [SELECT URL__c, Authorization__c FROM Reliance_API_Configuration__mdt WHERE MasterLabel = 'Fox & Roach'];
        	
        
        System.assert(req.getEndpoint().contains(relianceConfig.URL__c));
        System.assert(String.isNotBlank(req.getMethod()));
        System.assertEquals(relianceConfig.Authorization__c, req.getHeader('Authorization'));
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint().contains('offices'))
        {
            list<FoxRoach_Modal.Office> offices = new list<FoxRoach_Modal.Office>();
            //Office Active
            FoxRoach_Modal.Office office = new FoxRoach_Modal.Office();
            office.name = 'Test Office Name';
            office.id = 12345;
            office.franchiseCode= 'Franchise';
            FoxRoach_Modal.Address address = new FoxRoach_Modal.Address();
            address.address1='Street -1';
            address.address2='Lane-5';
            address.city = 'Newyork';
            address.country = 'India';
            address.postalCode = '88874';
            address.stateOrProvince = 'NY';
            
            office.address = address;
            offices.add(office);
            
            
            system.debug('mock response Body---'+JSON.serialize(offices));
            res.setBody(JSON.serialize(offices));
            
        }else if(req.getEndpoint().contains('account')){
            
            list<FoxRoach_Modal.Account> accs = new list<FoxRoach_Modal.Account>();
            FoxRoach_Modal.Account acc = new FoxRoach_Modal.Account();
            acc.id = 1122;
            
            FoxRoach_Modal.Address address = new FoxRoach_Modal.Address();
            address.address1='Street -1';
            address.address2='Lane-5';
            address.city = 'Newyork';
            address.country = 'India';
            address.postalCode = '88874';
            address.stateOrProvince = 'NY';
            acc.address = address;
            acc.officeName = 'Test Office Name';
            acc.email = 'test@test.com';
            acc.firstName = 'My First ANme';
            acc.lastName = 'My Last Name';
            acc.officeID = 12345;
            list<FoxRoach_Modal.PhoneNumber> phones = new list<FoxRoach_Modal.PhoneNumber>();
            FoxRoach_Modal.PhoneNumber phone = new FoxRoach_Modal.PhoneNumber();
            phone.label = 'mobile';
            phone.phoneNumber = '1234512345';
            phones.add(phone);
            acc.phoneNumbers = phones;
            
            accs.add(acc);
            res.setBody(JSON.serialize(accs));
        }else{
            res.setBody('{"message": "successfully triggered"}');
        }
        res.setStatusCode(200);
        return res;
    }
}