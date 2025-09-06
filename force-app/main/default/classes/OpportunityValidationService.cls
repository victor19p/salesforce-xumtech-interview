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

            if(isTarjetaCredito(opp)){
                System.debug('Validating Tarjeta de Credito Opportunity: ' + opp.Id);
                validateLastDigits(opp, oldOpp);
            }
        }
    }
    
    private static Boolean isPrestamoPersonal(Opportunity opp) {
        System.debug(LoggingLevel.INFO, 'Checking if Opportunity is Prestamo Personal: ' + opp.Id + '/'+ opp.RecordType?.DeveloperName );
        
        String rtOpportunity = [SELECT DeveloperName FROM RecordType WHERE Id = :opp.RecordTypeId LIMIT 1].DeveloperName;
        System.debug(LoggingLevel.INFO, 'RecordType DeveloperName: ' + rtOpportunity);

        return rtOpportunity == 'Prestamo_Personal';
    }

    private static Boolean isTarjetaCredito(Opportunity opp) {
        String rtOpportunity = [SELECT DeveloperName FROM RecordType WHERE Id = :opp.RecordTypeId LIMIT 1].DeveloperName;
        System.debug(LoggingLevel.INFO, 'RecordType DeveloperName: ' + rtOpportunity);

        return rtOpportunity == 'Solicitud_de_Tarjeta_de_Credito';
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
    
    // Validación específica para tarjetas de crédito - Últimos 4 dígitos
    private static void validateLastDigits(Opportunity newOpp, Opportunity oldOpp) {
        if (oldOpp == null) {
            return; // Nueva oportunidad, no validar transición
        }

        String oldStage = oldOpp.StageName;
        String newStage = newOpp.StageName;

        // Validar que los últimos 4 dígitos estén ingresados antes de marcar como "Aprobada"
        if (newStage == 'Aprobada' && oldStage != 'Aprobada') {
            if (String.isBlank(newOpp.Ultimos_4_Digitos__c)) {
                newOpp.Ultimos_4_Digitos__c.addError('Los últimos 4 dígitos de la tarjeta son obligatorios antes de aprobar.');
            } else if (newOpp.Ultimos_4_Digitos__c.length() != 4) {
                newOpp.Ultimos_4_Digitos__c.addError('Los últimos 4 dígitos deben tener exactamente 4 caracteres.');
            } else if (!newOpp.Ultimos_4_Digitos__c.isNumeric()) {
                newOpp.Ultimos_4_Digitos__c.addError('Los últimos 4 dígitos deben ser solo números.');
            }
        }
    }
}