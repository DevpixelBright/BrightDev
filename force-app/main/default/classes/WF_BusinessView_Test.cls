/**

 */
@isTest
private class WF_BusinessView_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        list<string> lstIds = new list<string>();
        lstIds = WF_BusinessView.queryWFIds();
        lstIds.add('01QJ00000002S1wMAE');
        WF_BusinessView.getWorkflowMetaDate(lstIds);
    }
}