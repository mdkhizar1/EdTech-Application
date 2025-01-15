trigger UpdateAccountName on Contact (after insert) {
    // Map to store Account Ids and their corresponding concatenated names
    Map<Id, String> accountUpdates = new Map<Id, String>();

    for (Contact con : Trigger.new) {
        if (con.AccountId != null && con.LastName != null) {
            // Add the Last Name to the Account Name in the map
            accountUpdates.put(con.AccountId, con.LastName);
        }
    }

    // Query the Accounts that need updates
    List<Account> accountsToUpdate = [
        SELECT Id, Name FROM Account WHERE Id IN :accountUpdates.keySet()
    ];

    // Update the Account names by appending the Last Names
    for (Account acc : accountsToUpdate) {
        if (accountUpdates.containsKey(acc.Id)) {
            acc.Name += ' ' + accountUpdates.get(acc.Id);
        }
    }

    // Perform the update
    if (!accountsToUpdate.isEmpty()) {
        try {
            update accountsToUpdate;
        } catch (DmlException e) {
            System.debug('Error updating Account names: ' + e.getMessage());
        }
    }
}