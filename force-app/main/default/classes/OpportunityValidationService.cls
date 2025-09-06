public with sharing class OpportunityValidationService {
    
    public static void validatePrestamoOpportunities(List<Opportunity> newRecords, Map<Id, Opportunity> oldRecordsMap) {
        for (Opportunity opp : newRecords) {
            Opportunity oldOpp = oldRecordsMap?.get(opp.Id);
            
            if (isPrestamoPersonal(opp)) {
                System.debug('Validating Prestamo Personal Opportunity: ' + opp.Id);
                validateStageTransition(opp, oldOpp);
                validateRequiredFields(opp);
                validateBusinessRules(opp);
            }
        }
    }
    
    private static Boolean isPrestamoPersonal(Opportunity opp) {
        System.debug(LoggingLevel.INFO, 'Checking if Opportunity is Prestamo Personal: ' + opp.Id + '/'+ opp.RecordType?.DeveloperName );
        
        String rtOpportunity = [SELECT DeveloperName FROM RecordType WHERE Id = :opp.RecordTypeId LIMIT 1].DeveloperName;
        System.debug(LoggingLevel.INFO, 'RecordType DeveloperName: ' + rtOpportunity);

        return rtOpportunity == 'Prestamo_Personal';
    }
    
    private static void validateStageTransition(Opportunity newOpp, Opportunity oldOpp) {
        if (oldOpp == null) {
            return;
        }

        String oldStage = oldOpp.StageName;
        String newStage = newOpp.StageName;

        if (oldStage == newStage) {
            return;
        }

        if (oldStage == 'Recopilación de documentos' && newStage == 'Evaluación crediticia') {
            if (newOpp.Documentacion_Recibida__c != true) {
                newOpp.addError('No se puede avanzar a Evaluación crediticia sin marcar "Documentación Recibida".');
            }
        }
        
        if (newStage == 'Aprobación') {
            if (newOpp.Amount == null || newOpp.Amount <= 0) {
                newOpp.addError('El monto del préstamo es requerido para aprobar.');
            }
        }
    }
    
    private static void validateRequiredFields(Opportunity opp) {
        if (opp.Amount != null && opp.Amount <= 0) {
            opp.Amount.addError('El monto debe ser mayor a 0.');
        }
        
        if (opp.CloseDate < Date.today()) {
            opp.CloseDate.addError('La fecha de cierre no puede ser en el pasado.');
        }
        
        if (opp.StageName == 'Evaluación crediticia') {
            if (String.isBlank(opp.Name)) {
                opp.Name.addError('El nombre de la oportunidad es requerido en esta etapa.');
            }
        }
    }
    
    private static void validateBusinessRules(Opportunity opp) {
        if (opp.Amount != null && opp.Amount > 100000) {
            opp.Amount.addError('El monto del préstamo no puede exceder $100,000.');
        }
    }
}