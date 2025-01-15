import { LightningElement } from 'lwc';
import createPaymentLink from '@salesforce/apex/IntegrationWithStripe.createPaymentLink';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
export default class StripePaymentLink extends LightningElement {
    quantity;
 
    stripPaymentHandler(event) {
        this.quantity = event.target.value;
    }
   
    createPaymentHandler() {
        createPaymentLink({quantity: this.quantity})
        .then((response) => {
            this.showToastMessage('Success', response, 'success');
            this.handleClose();
        })
        .catch((error) => {
            this.showToastMessage(error.statusText, error.body.message, 'error');
        } )
    }
 

    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissible'
        })
        this.dispatchEvent(evt);
    }
 

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}