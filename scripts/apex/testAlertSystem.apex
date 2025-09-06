// Script para testear OpportunityAlertService en consola anónima

// Crear o buscar una cuenta
Account testAccount = new Account(Name = 'Cliente Prueba Préstamo');
insert testAccount;

// Crear una oportunidad de tipo Préstamo Personal
Opportunity testOpp = new Opportunity(
    Name = 'Préstamo Personal - ' + testAccount.Name,
    AccountId = testAccount.Id,
    StageName = 'Solicitud recibida',
    CloseDate = Date.today().addDays(30),
    RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Prestamo_Personal' AND SobjectType = 'Opportunity' LIMIT 1].Id
);
insert testOpp;

// Recargar la oportunidad con los datos relacionados necesarios
testOpp = [SELECT Id, Name, StageName, Account.Name FROM Opportunity WHERE Id = :testOpp.Id];

System.debug('=== TESTING ALERTAS DE PRÉSTAMO ===');

// Test 1: Alerta de solicitud de documentos
System.debug('--- Test 1: Recopilación de documentos ---');
OpportunityAlertService.sendStageChangeAlert(testOpp, 'Solicitud recibida', 'Recopilación de documentos');

// Test 2: Alerta de evaluación crediticia
System.debug('--- Test 2: Evaluación crediticia ---');
OpportunityAlertService.sendStageChangeAlert(testOpp, 'Recopilación de documentos', 'Evaluación crediticia');

// Test 3: Alerta de aprobación
System.debug('--- Test 3: Aprobación ---');
OpportunityAlertService.sendStageChangeAlert(testOpp, 'Evaluación crediticia', 'Aprobación');

System.debug('=== TESTS COMPLETADOS ===');

// Limpiar datos de prueba
delete testOpp;
delete testAccount;