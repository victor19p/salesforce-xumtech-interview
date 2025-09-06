trigger OpportunityTrigger on Opportunity (before update, after update) {
    new OpportunityPrestamoTriggerHandler('OpportunityPrestamoTriggerHandler').run();
}