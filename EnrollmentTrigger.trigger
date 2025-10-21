trigger EnrollmentTrigger on Enrollment__c (before insert) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        EnrollmentTriggerHandler.preventDuplicateEnrollments(Trigger.new);
    }
}