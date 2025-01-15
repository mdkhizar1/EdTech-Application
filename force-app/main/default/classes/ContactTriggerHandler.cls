public class ContactTriggerHandler {

    public static void beforeInsertUpdateAction(List<Contact> newContacts, Map<Id, Contact> oldContactsMap) {
        // Set of Account IDs to query
        Set<Id> accountIds = new Set<Id>();

        // Gather Account IDs where the checkbox is true
        for (Contact con : newContacts) {
            if (con.Copy_Billing_Address__c == true && con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }

        // Fetch Account Billing Addresses
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry 
                                                             FROM Account 
                                                             WHERE Id IN :accountIds]);

        // Update the Contact's Mailing Address with the Account's Billing Address
        for (Contact con : newContacts) {
            if (con.Copy_Billing_Address__c == true && con.AccountId != null) {
                Account acc = accountMap.get(con.AccountId);
                if (acc != null) {
                    con.MailingStreet = acc.BillingStreet;
                    con.MailingCity = acc.BillingCity;
                    con.MailingState = acc.BillingState;
                    con.MailingPostalCode = acc.BillingPostalCode;
                    con.MailingCountry = acc.BillingCountry;
                }
            }
        }
    }


    // Trigger-4 Logic
    public static void afterInsertAction(List<Contact> newContacts) {
        // Collect Account Ids to update
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : newContacts) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }
    
        // If no accounts to update, exit
        if (accountIds.isEmpty()) return;
    
        // Get the accounts that need to be updated
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>(
            [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
        );
    
        // Update account names
        for (Contact con : newContacts) {
            if (con.AccountId != null && accountsToUpdate.containsKey(con.AccountId)) {
                Account acc = accountsToUpdate.get(con.AccountId);
                // last name was appending twice, 
	    //  So use if else to ensure the last name is appended only once
                if (!acc.Name.contains(' ' + con.LastName)) {
                    acc.Name = acc.Name + ' ' + con.LastName;
                }
                accountsToUpdate.put(acc.Id, acc);
            }
        }
    
        // Update the accounts
        if (!accountsToUpdate.isEmpty()) {
            try {
                update accountsToUpdate.values();
            } catch (Exception e) {
                System.debug('Error updating accounts: ' + e.getMessage());
            }
        }
    }

    
    // Trigger-5 Logic
    public static void afterDeleteAction(List<Contact> oldContacts) {
        // Collect Account Ids to update
        Set<Id> accountIds = new Set<Id>();
        for(Contact con : oldContacts) {
            if(con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }
        
        // If no accounts to update, exit
        if(accountIds.isEmpty()) return;
        
        // Get the accounts and their related contacts
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>(
            [SELECT Id, Name, (SELECT LastName FROM Contacts) 
             FROM Account WHERE Id IN :accountIds]
        );
        
        // Process each deleted contact
        for(Contact deletedContact : oldContacts) {
            if(deletedContact.AccountId != null && accountsToUpdate.containsKey(deletedContact.AccountId)) {
                Account acc = accountsToUpdate.get(deletedContact.AccountId);
                // Remove the deleted contact's last name from account name
                String updatedName = acc.Name.replace(' ' + deletedContact.LastName, '');
                acc.Name = updatedName;
                accountsToUpdate.put(acc.Id, acc);
            }
        }
        
        // Update the accounts
        if(!accountsToUpdate.isEmpty()) {
            try {
                update accountsToUpdate.values();
            } catch(Exception e) {
                System.debug('Error updating accounts: ' + e.getMessage());
            }
        }
    }
}