trigger EnforceFutureClosedDate on Opportunity (before insert, before update) {
    for (Opportunity opp : Trigger.new) {
        // Check if ClosedDate is in the past
        if (opp.CloseDate != null && opp.CloseDate < Date.today()) {
            opp.addError('Please enter a future Closed Date.');
        }
    }
}