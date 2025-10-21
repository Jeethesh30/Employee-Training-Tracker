import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import searchAvailableEmployees from '@salesforce/apex/TrainingEnrollmentController.searchAvailableEmployees';
import enrollEmployees from '@salesforce/apex/TrainingEnrollmentController.enrollEmployees';

// Columns for the datatable
const COLS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Employee ID', fieldName: 'Employee_ID__c' },
    { label: 'Department', fieldName: 'Department__c' }
];

export default class QuickEnrollmentManager extends LightningElement {
    @api recordId; // This will automatically get the Training__c ID

    columns = COLS;
    isLoading = false;
    searchTerm = '';
    selectedEmployeeIds = [];

    // Wire service to get search results from Apex
    @wire(searchAvailableEmployees, { trainingId: '$recordId', searchTerm: '$searchTerm' })
    searchResults;

    // Handlers
    handleSearch(event) {
        this.isLoading = true;
        this.searchTerm = event.target.value;
        this.isLoading = false;
    }

    handleRowSelection(event) {
        this.selectedEmployeeIds = event.detail.selectedRows.map(row => row.Id);
    }

    async handleEnroll() {
        this.isLoading = true;
        try {
            const resultMessage = await enrollEmployees({ trainingId: this.recordId, employeeIds: this.selectedEmployeeIds });

            // Show success toast
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: resultMessage,
                variant: 'success'
            }));

            // Clear selection and refresh the search results
            this.template.querySelector('lightning-datatable').selectedRows = [];
            this.selectedEmployeeIds = [];
            refreshApex(this.searchResults);

        } catch (error) {
            // Show error toast
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error Enrolling Employees',
                message: error.body.message,
                variant: 'error'
            }));
        } finally {
            this.isLoading = false;
        }
    }

    // Getter to disable the button if no rows are selected
    get isEnrollButtonDisabled() {
        return this.selectedEmployeeIds.length === 0;
    }
}