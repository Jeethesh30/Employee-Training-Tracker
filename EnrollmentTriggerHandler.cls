public class EnrollmentTriggerHandler {

    public static void preventDuplicateEnrollments(List<Enrollment__c> newEnrollments) {
        
        Set<Id> employeeIds = new Set<Id>();
        Set<Id> trainingIds = new Set<Id>();
        
        for(Enrollment__c enr : newEnrollments) {
            employeeIds.add(enr.Employee__c);
            trainingIds.add(enr.Training__c);
        }

        Map<String, Enrollment__c> existingMap = new Map<String, Enrollment__c>();
        
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //  NEW FIX: Trying 'Status_c__c'
        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        for(Enrollment__c existing : [SELECT Id, Employee__c, Training__c 
                                      FROM Enrollment__c 
                                      WHERE Employee__c IN :employeeIds 
                                      AND Training__c IN :trainingIds
                                      AND Status_c__c != 'Completed']) { // <-- THIS LINE IS FIXED
            
            String key = existing.Employee__c + '-' + existing.Training__c;
            existingMap.put(key, existing);
        }

        for(Enrollment__c newEnr : newEnrollments) {
            String key = newEnr.Employee__c + '-' + newEnr.Training__c;
            if(existingMap.containsKey(key)) {
                newEnr.addError('This employee is already actively enrolled in this training.');
            }
        }
    }
}