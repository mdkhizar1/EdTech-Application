trigger ContactAllEventsTrigger on Contact (before insert, after insert, after delete) {
    switch on Trigger.operationType {
        when BEFORE_INSERT, BEFORE_UPDATE {
            // Trigger-10: Remove Contact's Last Name from Account Name
			ContactTriggerHandler.beforeInsertUpdateAction(Trigger.new, Trigger.oldMap);
        }
        when AFTER_INSERT {
            // Trigger-4: Update Account Name with Contact's Last Name
            ContactTriggerHandler.afterInsertAction(Trigger.new);
        }
        when AFTER_DELETE {
            // Trigger-5: Remove Contact's Last Name from Account Name
            ContactTriggerHandler.afterDeleteAction(Trigger.old);
        }
        when else {
        }
    }
}