public class subscriptionsobjects {
        public string selectedobject {get; set;}   
        public string Selectedfield {get; set;}   

public String getObjectFields (string selectedobject, string Selectedfield) 
 {
        Map<String, Schema.SObjectType> obj = Schema.getGlobalDescribe();

        Schema.SObjectType Objt = obj.get(selectedObject);
		//return Objt.getDescribe().getLabel();
     
       // objt = schema.getDescribe(Selectedfield);
					                    //Schema.DescribeSObjectResult objDesc = Objt.getDescribe();
					                    //string objLabel = objDesc.getLabel();
	                                    
										Map<String, Schema.SObjectField> fieldMap = Objt.getDescribe().fields.getMap();
										schema.SObjectField fnme =fieldMap.get(Selectedfield);
										return fnme.getDescribe().getLabel();
										
										//return fieldLabel;
 }
}