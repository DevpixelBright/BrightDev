public with sharing class CommunityUser {

    @future
    public static void AssignCommunityPermission(Map<Id,Id> userPermissionMap) {
        
        List<PermissionSetAssignment> permissions = new List<PermissionSetAssignment>();
        
        for(Id user : userPermissionMap.keySet()) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = user;
            psa.PermissionSetId = userPermissionMap.get(user);
            permissions.add(psa);
        }
        insert permissions;
    }
    
}