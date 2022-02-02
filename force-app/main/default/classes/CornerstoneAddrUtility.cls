public class CornerstoneAddrUtility{
    public CornerstoneAddrUtility()
    {
    }
    public void addAddrs()
    {
        //office info
        
        CornerstoneMappings__c mc = new CornerstoneMappings__c();
        mc.CornerstoneID__c = '98765432123456789098765432123456';
        mc.Type__c = 'Office/city';
        mc.TypeName__c = 'Herndon';
        insert(mc);
        
        CornerstoneMappings__c mc2 = new CornerstoneMappings__c();
        mc2.CornerstoneID__c = '98765432123456789098765432123455';
        mc2.Type__c = 'Office/county';
        mc2.TypeName__c = 'Fairfax';
        insert(mc2);
        
        CornerstoneMappings__c mc5 = new CornerstoneMappings__c();
        mc5.CornerstoneID__c = '98765432123456789098765432123457';
        mc5.Type__c = 'Office/state';
        mc5.TypeName__c = 'VA';
        insert(mc5);
        
        CornerstoneMappings__c mc7 = new CornerstoneMappings__c();
        mc7.CornerstoneID__c = '98765432123456789098765432123459';
        mc7.Type__c = 'Office/streetTypes';
        mc7.TypeName__c = 'ACRES, ACRES';
        insert(mc7);
        
        CornerstoneMappings__c mc9 = new CornerstoneMappings__c();
        mc9.CornerstoneID__c = '98765432123456789098765432123469';
        mc9.Type__c = 'Office/unitDesignation';
        mc9.TypeName__c = 'KEY, KEY';
        insert(mc9);
                
        //agent info
        
        CornerstoneMappings__c mc3 = new CornerstoneMappings__c();
        mc3.CornerstoneID__c = '98765432123456789098765432123454';
        mc3.Type__c = 'Agent/city';
        mc3.TypeName__c = 'Herndon';
        insert(mc3);
        
        CornerstoneMappings__c mc4 = new CornerstoneMappings__c();
        mc4.CornerstoneID__c = '98765432123456789098765432123453';
        mc4.Type__c = 'Agent/county';
        mc4.TypeName__c = 'Fairfax';
        insert(mc4);
        
        CornerstoneMappings__c mc6 = new CornerstoneMappings__c();
        mc6.CornerstoneID__c = '98765432123456789098765432123458';
        mc6.Type__c = 'Agent/state';
        mc6.TypeName__c = 'VA';
        insert(mc6);
        
        CornerstoneMappings__c mc8 = new CornerstoneMappings__c();
        mc8.CornerstoneID__c = '98765432123456789098765432123460';
        mc8.Type__c = 'Agent/streetTypes';
        mc8.TypeName__c = 'ACRES, ACRES';
        insert(mc8);
    
        CornerstoneMappings__c mc10 = new CornerstoneMappings__c();
        mc10.CornerstoneID__c = '98765432123456789098765432123468';
        mc10.Type__c = 'Agent/unitDesignation';
        mc10.TypeName__c = 'KEY, KEY';
        insert(mc10);        
    
        CornerstoneMappings__c cm_a = new CornerstoneMappings__c();
        cm_a.Type__c = 'Agent/city';
        cm_a.CornerStoneID__c = '10000045331';
        cm_a.LongValue__c = 'HERNDON-FAIRFAX-VA';
        insert cm_a;

        CornerstoneMappings__c cm_b = new CornerstoneMappings__c();
        cm_b.Type__c = 'Office/city';
        cm_b.CornerStoneID__c = '10000045331';
        cm_b.LongValue__c = 'HERNDON-FAIRFAX-VA';
        insert cm_b;
    }
}