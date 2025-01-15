public class OpportunityTriggerHandler {
    public void handleAfterInsert(List<Opportunity> newOpps) {
        List<OpportunityContactRole> contactRolesToCreate = new List<OpportunityContactRole>();

        for (Opportunity opp : newOpps) {
            if (opp.AccountId != null) {
                // Query all Contacts related to the Account
                List<Contact> accountContacts = [
                    SELECT Id FROM Contact WHERE AccountId = :opp.AccountId
                ];

                // Create OpportunityContactRole records for each Contact
                for (Contact contact : accountContacts) {
                    OpportunityContactRole ocr = new OpportunityContactRole(
                        OpportunityId = opp.Id,
                        ContactId = contact.Id,
                        Role = 'Business User' // Default Role
                    );
                    contactRolesToCreate.add(ocr);
                }
            }
        }

        // Insert the OpportunityContactRole records in bulk
        if (!contactRolesToCreate.isEmpty()) {
            insert contactRolesToCreate;
        }
    }


    public void handleBeforeUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        for (Opportunity opp : newOpps) {
            // Prevent closing without Opportunity Line Items
            if ((opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost') &&
                (oldOppMap.get(opp.Id).StageName != 'Closed Won' && oldOppMap.get(opp.Id).StageName != 'Closed Lost')) {

                // Query for Opportunity Line Items associated with the Opportunity
                List<OpportunityLineItem> lineItems = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id LIMIT 1];

                // Add error if no Opportunity Line Items exist
                if (lineItems.isEmpty()) {
                    opp.addError('You cannot close an Opportunity without adding Opportunity Line Items.');
                }
            }
        }
    }

    public void handleAfterUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        List<Product2> productsToUpdate = new List<Product2>();

        for (Opportunity opp : newOpps) {
            // Check if Opportunity is closed as "Closed Won"
            if (opp.StageName == 'Closed Won' && oldOppMap.get(opp.Id).StageName != 'Closed Won') {
                // Query Opportunity Line Items and associated Products
                List<OpportunityLineItem> lineItems = [
                    SELECT Id, Quantity, PricebookEntry.Product2Id 
                    FROM OpportunityLineItem 
                    WHERE OpportunityId = :opp.Id
                ];

                for (OpportunityLineItem oli : lineItems) {
                    if (oli.PricebookEntry.Product2Id != null) {
                        // Update "No of Products Sold" field
                        Product2 product = [SELECT Id, No_of_Products_Sold__c FROM Product2 WHERE Id = :oli.PricebookEntry.Product2Id LIMIT 1];
                        product.No_of_Products_Sold__c = (product.No_of_Products_Sold__c == null ? 0 : product.No_of_Products_Sold__c) + Integer.valueOf(oli.Quantity);
                        productsToUpdate.add(product);
                    }
                }
            }
        }

        // Update Product records in bulk
        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate;
        }
    }
}