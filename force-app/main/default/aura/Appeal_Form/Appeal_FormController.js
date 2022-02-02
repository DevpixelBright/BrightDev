({
	handleFilesChange : function (cmp, event) {
        var files = event.getSource().get("v.files");
        alert(files.length + ' files !!');
    },
    
    handleFilesChange1: function(component, event, helper) {

        var fileName = 'No File Selected..';
        if (component.find('fuploader1').get("v.files").length > 0) {
            
            var fileInput = component.find("fuploader1").get("v.files");
            var file = fileInput[0];
            if(file.size > 2000000) {
                alert("File size must be less than 2 MB");
                component.find("fuploader1").set("v.files", null)
            }
            else {
                fileName = file.name;
            }
        }
        component.set("v.fileName1", fileName);
    },  
    
     handleFilesChange: function (component, event, helper) {
      // This will contain the List of File uploaded data and status
      var uploadFile = event.getSource().get("v.files");
      var self = this;
      var file = uploadFile[0]; // getting the first file, loop for multiple files
      if(file.size > 2097152) {
            alert("File size must be less than 2 MB");            
      } else {
          var reader = new FileReader();
          reader.onload =  $A.getCallback(function() {
          var dataURL = reader.result;
          var base64 = 'base64,';
          var dataStart = dataURL.indexOf(base64) + base64.length;
          dataURL= dataURL.substring(dataStart);
          console.log("dataURL***", dataURL);
          //helper.upload(component, file, dataURL)
                     });
          reader.readAsDataURL(file);
      }
      
    },
})