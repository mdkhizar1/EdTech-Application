// Trigger Handler Class to encapsulate Campaign logic
public class CampaignTriggerHandler {
    public void handleAfterUpdate(List<Campaign> updatedCampaigns) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Map<Id, List<String>> closureDetails = new Map<Id, List<String>>();

        for (Campaign camp : updatedCampaigns) {
            if (camp.Status == 'Completed') {
                // Query all Opportunities related to the Campaign
                List<Opportunity> associatedOpportunities = [
                    SELECT Id, Name, StageName, 
                           (SELECT Id FROM OpportunityLineItems)
                    FROM Opportunity
                    WHERE CampaignId = :camp.Id
                ];

                for (Opportunity opp : associatedOpportunities) {
                    if (!opp.OpportunityLineItems.isEmpty()) {
                        opp.StageName = 'Closed Won';
                        if (!closureDetails.containsKey(camp.Id)) closureDetails.put(camp.Id, new List<String>());
                        closureDetails.get(camp.Id).add('Opportunity "' + opp.Name + '" closed as Won.');
                    } else {
                        opp.StageName = 'Closed Lost';
                        if (!closureDetails.containsKey(camp.Id)) closureDetails.put(camp.Id, new List<String>());
                        closureDetails.get(camp.Id).add('Opportunity "' + opp.Name + '" closed as Lost.');
                    }
                    opportunitiesToUpdate.add(opp);
                }
            }
        }

        // Update all Opportunities in bulk
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }

        // Log the summary of closure details (could send email instead)
        for (Id campId : closureDetails.keySet()) {
            System.debug('Campaign Id: ' + campId);
            for (String detail : closureDetails.get(campId)) {
                System.debug(detail);
            }
        }
    }
}