/**
 * @description Opportunity Trigger handler
 * @author Victor Pineda
 * @since 2025
 * @group OpportunityTriggerHandler
 * https://github.com/dschach/salesforce-trigger-framework
 * 
 * System.debug('Emails restantes hoy: ' + Limits.getEmailInvocations() + '/' + Limits.getLimitEmailInvocations());
 */
public with sharing class OpportunityPrestamoTriggerHandler extends TriggerHandler{
    private List<Opportunity> newRecords;
	private List<Opportunity> oldRecords;
	private Map<Id, Opportunity> newRecordsMap;
	private Map<Id, Opportunity> oldRecordsMap;

    public OpportunityPrestamoTriggerHandler(String className) {
        super('OpportunityPrestamoTriggerHandler');
		this.newRecords = (List<Opportunity>) Trigger.new;
		this.oldRecords = (List<Opportunity>) Trigger.old;
		this.newRecordsMap = (Map<Id, Opportunity>) Trigger.newMap;
		this.oldRecordsMap = (Map<Id, Opportunity>) Trigger.oldMap;
	}

    public override void beforeUpdate() {
        System.debug('Before Update Trigger Handler');
        OpportunityValidationService.validatePrestamoOpportunities(newRecords, oldRecordsMap);
    }

    public override void afterUpdate() {
        TriggerHandler.bypass('OpportunityPrestamoTriggerHandler');
        System.debug('After Update Trigger Handler');
        for (Opportunity opp : newRecords) {
            Opportunity oldOpp = oldRecordsMap.get(opp.Id);
            if (oldOpp != null && opp.StageName != oldOpp.StageName) {
                OpportunityAlertService.sendStageChangeAlert(opp, oldOpp.StageName, opp.StageName);
            }
        }
        TriggerHandler.clearBypass('OpportunityPrestamoTriggerHandler');

    }

    public override void andFinally() {
        System.debug('And Finally Trigger Handler');
    }


}