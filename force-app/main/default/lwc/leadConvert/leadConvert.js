import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import revertBack from '@salesforce/apex/LeadConvertController.revertBack';
import convertLead from '@salesforce/apex/LeadConvertController.convertLead';

import CHECK_CONVERT_FIELD from '@salesforce/schema/New_Lead__c.Lead_Convert_Check__c';
import NAME_FIELD from '@salesforce/schema/New_Lead__c.Name';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/New_Lead__c.Account_Name__c';

import modal from "@salesforce/resourceUrl/customModal";
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { NavigationMixin } from "lightning/navigation";

export default class LeadConvert extends NavigationMixin(LightningElement) {
    @api recordId;
    @track newLead;
    @api prop1;

    @track isShowModal = false;

    @track newAccount = { Id : null, Name : "" };
    @track newContact = { Id : null, Name : "" };
    @track newOrder = { Id : null, Name : "" };

    @track newAccountSelected = true;
    @track existingAccountSelected = false;

    @track newContactSelected = true;
    @track existingContactSelected = false;

    @track newOrderSelected = true;
    @track existingOrderSelected = false;

    @track recordOwner = '';
    
    activeSections = ['A', 'B', 'C'];
    activeSectionsMessage = '';

    @track leadConverted = false;
    @track createOrder = false;

    connectedCallback() {
        // loadStyle(this, modal);
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ CHECK_CONVERT_FIELD, NAME_FIELD, ACCOUNT_NAME_FIELD ] })
    getNewLeadRecord({ data, error }) {
        console.log('NewLeadRecord => ', data, error);
        if (data) {
            console.log(data);
            this.newLead = data;
            if(this.newLead.fields.Lead_Convert_Check__c.value){                
                this.newAccount.Name = this.newLead.fields.Account_Name__c.value != null ? this.newLead.fields.Account_Name__c.value : '';
                this.newContact.Name = this.newLead.fields.Name.value != null ? this.newLead.fields.Name.value : '';
                this.newOrder.Name = this.newLead.fields.Account_Name__c.value != null ? this.newLead.fields.Account_Name__c.value : '' + '-';
                this.isShowModal = true;
                this.leadConverted = false;
                console.log(this.newAccount);
            }else if(this.newLead.fields.Lead_Convert_Check__c.value == false){
                this.isShowModal = false;
            }
            console.log("newLead", this.newLead.fields.Lead_Convert_Check__c.value);
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error));
        }
    }

    handleChange(event){
        console.log(event.target.checked);
        if(event.target.name == "accountName"){
            this.newAccount.Name = event.target.value;
        }else if(event.target.name == "contactName"){
            this.newContact.Name = event.target.value;
        }else if(event.target.name == "orderName"){
            this.newOrder.Name = event.target.value;
        }else if(event.target.name == "createOrder"){
            this.createOrder = event.target.checked;
        }
        console.log(this.createOrder);
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    showModalBox() {  
        this.isShowModal = true;
    }

    hideOnlyModalBox() {
        this.isShowModal = false;
    }

    hideModalBox() {
        this.isShowModal = false;
        revertBack({
            leadId: this.recordId
        }).then(response => {
            eval("$A.get('e.force:refreshView').fire();");
        }).catch((error) => {
            console.log('Something went wrong' + JSON.stringify(error));
        });
    }

    convertLead(){
        console.log("CONVERT LEAD");
        convertLead({
            leadId: this.recordId,
            accNew: JSON.stringify(this.newAccount),
            conNew: JSON.stringify(this.newContact),
            orderNew: JSON.stringify(this.newOrder),
            createOrder : this.createOrder,
            recordOwner : this.recordOwnerId
        }).then(response => {
            console.log(response);
            if(response.errorMessage == ''){
                this.newAccount = response.accountId;
                this.newContact = response.contactId;
                if(!this.createOrder)    this.newOrder = response.newOrderId;
                this.leadConverted = true;
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'error',
                        message: response.errorMessage,
                        variant: 'error'
                    })
                );
            }
        }).catch((error) => {
            console.log('Something went wrong' + JSON.stringify(error.message));            
        });
    }

    handleAccountSelection(event){
        console.log("the selected record id is"+event.detail);
        this.newAccount.Id = event.detail;
    }

    handleContactSelection(event){
        this.newContact.Id = event.detail;
    }

    handleOrderSelection(event){
        this.newOrder.Id = event.detail;
    }

    handleOwnerSelection(event){
        this.recordOwnerId = event.detail;
    }

    viewRecord(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value+'',
                objectApiName: event.target.name+'',
                actionName: 'view'
            },
        });
    }

    goToLeads(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'New_Lead__c',
                actionName: 'list'
            },
            state: {
                filterName: 'All'
            }
        });
    }
}