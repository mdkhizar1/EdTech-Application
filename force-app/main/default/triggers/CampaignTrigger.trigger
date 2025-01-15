// Trigger to handle Campaign logic and close associated Opportunities
trigger CampaignTrigger on Campaign (after update) {
    CampaignTriggerHandler handler = new CampaignTriggerHandler();

    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.handleAfterUpdate(Trigger.new);
    }
}