import { LightningElement, track } from 'lwc';
import fetchDuplicates from '@salesforce/apex/DeleteDuplicateAttachmentsController.fetchDuplicates';
import deleteDuplicates from '@salesforce/apex/DeleteDuplicateAttachmentsController.deleteDuplicates';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DeleteDuplicateAttachments extends LightningElement {
    @track duplicates = [];
    @track selectedRecords = [];
    @track isLoading = false;

    columns = [
        { label: 'File Name', fieldName: 'Title', type: 'text' },
        { label: 'File ID', fieldName: 'Id', type: 'text' }
    ];

    connectedCallback() {
        this.loadDuplicateFiles();
    }

    // Load duplicate files
    loadDuplicateFiles() {
        this.isLoading = true;
        fetchDuplicates()
            .then((result) => {
                this.duplicates = result;
            })
            .catch((error) => {
                this.showToast('Error', 'Error fetching duplicates', 'error');
                console.error(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // Handle row selection in datatable
    handleRowSelection(event) {
        this.selectedRecords = event.detail.selectedRows.map((row) => row.Id);
    }

    // Handle delete action
    handleDelete() {
        if (this.selectedRecords.length === 0) {
            this.showToast('Warning', 'Please select files to delete', 'warning');
            return;
        }

        this.isLoading = true;
        deleteDuplicates({ fileIds: this.selectedRecords })
            .then(() => {
                this.showToast('Success', 'Selected duplicates deleted successfully', 'success');
                this.loadDuplicateFiles(); // Reload duplicates after deletion
            })
            .catch((error) => {
                this.showToast('Error', 'Error deleting files', 'error');
                console.error(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // Utility method for showing toast messages
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}
