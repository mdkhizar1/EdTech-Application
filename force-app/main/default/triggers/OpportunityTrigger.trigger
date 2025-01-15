trigger OpportunityTrigger on Opportunity (before update, after insert, after update) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

    // Trigger - 8 Logic (Add Account Contacts to Opportunity Contact Roles)
    if (Trigger.isAfter && Trigger.isInsert) {
        handler.handleAfterInsert(Trigger.new); // Corrected method name
    }
    // Trigger - 6 Logic (Prevent closing Opportunity without Line Items)
    if (Trigger.isBefore && Trigger.isUpdate) {
        handler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    // Trigger - 7 Logic (Increment "No of Products Sold" field)
    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}