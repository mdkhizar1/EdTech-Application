trigger SetDefaultPricebookEntry on Product2 (after insert) {
    // Get the Standard Pricebook ID
    Id standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;

    List<PricebookEntry> pricebookEntriesToInsert = new List<PricebookEntry>();

    for (Product2 product : Trigger.new) {
        // Create a new PricebookEntry for each Product
        pricebookEntriesToInsert.add(new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = 15,
            IsActive = true
        ));
    }

    // Insert the Pricebook Entries
    if (!pricebookEntriesToInsert.isEmpty()) {
        try {
            insert pricebookEntriesToInsert;
        } catch (DmlException e) {
            System.debug('Error while creating Pricebook Entries: ' + e.getMessage());
        }
    }
}