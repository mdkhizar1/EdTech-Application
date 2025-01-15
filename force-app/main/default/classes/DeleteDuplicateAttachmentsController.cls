public with sharing class DeleteDuplicateAttachmentsController {
    
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> fetchDuplicates() {
        // Map to group files by their title
        Map<String, List<ContentDocument>> fileMap = new Map<String, List<ContentDocument>>();
        List<ContentDocument> duplicateFiles = new List<ContentDocument>();

        // Query for all attachments grouped by Title to find duplicates
        for (ContentDocument doc : [SELECT Id, Title FROM ContentDocument]) {
            if (!fileMap.containsKey(doc.Title)) {
                fileMap.put(doc.Title, new List<ContentDocument>());
            }
            fileMap.get(doc.Title).add(doc);
        }

        // Add duplicates (more than 1 file with the same title) to the result list
        for (String title : fileMap.keySet()) {
            if (fileMap.get(title).size() > 1) {
                duplicateFiles.addAll(fileMap.get(title));
            }
        }

        return duplicateFiles;
    }

    @AuraEnabled
    public static void deleteDuplicates(List<Id> fileIds) {
        try {
            System.debug('File IDs to delete: ' + fileIds);
            List<ContentDocument> filesToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :fileIds];
            System.debug('Files to delete: ' + filesToDelete);
            delete filesToDelete;
        } catch (Exception e) {
            System.debug('Error deleting files: ' + e.getMessage());
            throw new AuraHandledException('Error deleting files: ' + e.getMessage());
        }
    }
    
}