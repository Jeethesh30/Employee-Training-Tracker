public with sharing class TrainingEnrollmentController {

    // Method to get employees who are NOT already enrolled
    @AuraEnabled(cacheable=true)
    public static List<Employee__c> searchAvailableEmployees(Id trainingId, String searchTerm) {
        String likeKey = '%' + searchTerm + '%';

        // Find Employees who are already enrolled in this training
        Set<Id> enrolledEmployeeIds = new Set<Id>();
        for (Enrollment__c enr : [SELECT Employee__c FROM Enrollment__c WHERE Training__c = :trainingId]) {
            enrolledEmployeeIds.add(enr.Employee__c);
        }

        // Return employees who match the search term AND are not in the enrolled list
        return [SELECT Id, Name, Employee_ID__c, Department__c 
                FROM Employee__c 
                WHERE Name LIKE :likeKey
                AND Id NOT IN :enrolledEmployeeIds
                LIMIT 10];
    }

    // Method to create the new Enrollment records
    @AuraEnabled
    public static String enrollEmployees(Id trainingId, List<Id> employeeIds) {
        List<Enrollment__c> enrollmentsToCreate = new List<Enrollment__c>();

        for (Id empId : employeeIds) {
            enrollmentsToCreate.add(new Enrollment__c(
                Employee__c = empId,
                Training__c = trainingId,
                Status__c = 'Enrolled'
            ));
        }

        try {
            insert enrollmentsToCreate;
            return 'Success! Enrolled ' + enrollmentsToCreate.size() + ' new employees.';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}