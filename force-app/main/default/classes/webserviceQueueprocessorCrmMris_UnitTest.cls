public class webserviceQueueprocessorCrmMris_UnitTest {

        static testMethod void webserviceQueueprocessorTest1()
        {
            webserviceQueueprocessorCrmMrisCom queryProcObj = new webserviceQueueprocessorCrmMrisCom();
            webserviceQueueprocessorCrmMrisCom.salesForceRequestResponse_element  salesForceRequestResponseObj = new webserviceQueueprocessorCrmMrisCom.salesForceRequestResponse_element(); 
            webserviceQueueprocessorCrmMrisCom.QueueProcessorBaseFault_element  QueueProcessorBaseObj = new webserviceQueueprocessorCrmMrisCom.QueueProcessorBaseFault_element(); 
            webserviceQueueprocessorCrmMrisCom.salesForceRequest_element  ssalesForceRequestObj = new webserviceQueueprocessorCrmMrisCom.salesForceRequest_element();    

            webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint  QueueProcessorHttpObj = new webserviceQueueprocessorCrmMrisCom.QueueProcessorHttpsSoap11Endpoint(); 
            QueueProcessorHttpObj.salesForceRequest(null);
        }   
}