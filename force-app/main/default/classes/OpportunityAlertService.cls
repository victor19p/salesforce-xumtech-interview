public with sharing class OpportunityAlertService {

    public static void sendStageChangeAlert(Opportunity opp, String oldStage, String newStage) {
        if (newStage == 'Recopilación de documentos' && oldStage != newStage) {
            sendDocumentRequestAlert(opp);
        } else if (newStage == 'Evaluación crediticia' && oldStage != newStage) {
            sendCreditEvaluationAlert(opp);
        } else if (newStage == 'Aprobación' && oldStage != newStage) {
            sendApprovalAlert(opp);
        }
    }

    private static void sendDocumentRequestAlert(Opportunity opp) {
        System.debug('Alerta: Solicitar documentos para oportunidad ' + opp.Id);
        
        String oppUrl = 'https://freelance-4e-dev-ed.develop.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
        
        // Enviar email al agente de ventas
        sendEmail(
            'victor19cod@gmail.com',
            'Solicitud de documentos - ' + opp.Account.Name,
            '<h2>Solicitud de Documentos</h2>' +
            '<p>Estimado agente,</p>' +
            '<p>Se requiere solicitar documentos al cliente <strong>' + opp.Account.Name + '</strong> para la oportunidad de préstamo personal.</p>' +
            '<h3>Detalles de la oportunidad:</h3>' +
            '<ul>' +
            '<li><strong>Cliente:</strong> ' + opp.Account.Name + '</li>' +
            '<li><strong>Oportunidad:</strong> <a href="' + oppUrl + '" target="_blank">Ver en Salesforce</a></li>' +
            '<li><strong>Etapa actual:</strong> Recopilación de documentos</li>' +
            '</ul>' +
            '<p><strong>Acción requerida:</strong> Por favor, contactar al cliente para recopilar la documentación necesaria.</p>' +
            '<br>' +
            '<p>Saludos,<br><strong>Equipo Salesforce</strong></p>'
        );
    }

    private static void sendCreditEvaluationAlert(Opportunity opp) {
        System.debug('Alerta: Iniciar evaluación crediticia para oportunidad ' + opp.Id);
        
        String oppUrl = 'https://freelance-4e-dev-ed.develop.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
        
        // Enviar email al agente de ventas (owner de la oportunidad)
        sendEmail(
            'victor19cod@gmail.com',
            'Evaluación crediticia - ' + opp.Account.Name,
            '<h2>Evaluación Crediticia</h2>' +
            '<p>Estimado agente,</p>' +
            '<p>La oportunidad de préstamo personal para el cliente <strong>' + opp.Account.Name + '</strong> ha pasado a la etapa de evaluación crediticia.</p>' +
            '<h3>Detalles de la oportunidad:</h3>' +
            '<ul>' +
            '<li><strong>Cliente:</strong> ' + opp.Account.Name + '</li>' +
            '<li><strong>Oportunidad:</strong> <a href="' + oppUrl + '" target="_blank">Ver en Salesforce</a></li>' +
            '<li><strong>Etapa actual:</strong> Evaluación crediticia</li>' +
            '</ul>' +
            '<p><strong>Acción requerida:</strong> Por favor, proceder con la evaluación crediticia correspondiente.</p>' +
            '<br>' +
            '<p>Saludos,<br><strong>Equipo Salesforce</strong></p>'
        );
    }

    private static void sendApprovalAlert(Opportunity opp) {
        System.debug('Alerta: Oportunidad aprobada ' + opp.Id);
        
        String oppUrl = 'https://freelance-4e-dev-ed.develop.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
        
        // Enviar email al agente de ventas
        sendEmail(
            'victor19cod@gmail.com',
            'Préstamo aprobado - ' + opp.Account.Name,
            '<h2>✅ Préstamo Aprobado</h2>' +
            '<p>Estimado agente,</p>' +
            '<p>¡Excelente noticia! El préstamo personal para el cliente <strong>' + opp.Account.Name + '</strong> ha sido <strong style="color: green;">APROBADO</strong>.</p>' +
            '<h3>Detalles de la oportunidad:</h3>' +
            '<ul>' +
            '<li><strong>Cliente:</strong> ' + opp.Account.Name + '</li>' +
            '<li><strong>Oportunidad:</strong> <a href="' + oppUrl + '" target="_blank">Ver en Salesforce</a></li>' +
            '<li><strong>Etapa actual:</strong> Aprobación</li>' +
            '</ul>' +
            '<p><strong>Siguiente paso:</strong> Por favor, proceder con la formalización y desembolso.</p>' +
            '<br>' +
            '<p>Saludos,<br><strong>Equipo Salesforce</strong></p>'
        );
        
        // Enviar email al cliente (hardcodeado por ahora)
        sendEmail(
            'vpinedaa@unah.hn',
            '🎉 Su préstamo ha sido aprobado',
            '<h2>🎉 ¡Felicitaciones!</h2>' +
            '<p>Estimado/a <strong>' + opp.Account.Name + '</strong>,</p>' +
            '<p>Nos complace informarle que su solicitud de préstamo personal ha sido <strong style="color: green;">APROBADA</strong>.</p>' +
            '<h3>Próximos pasos:</h3>' +
            '<ul>' +
            '<li>Su agente de ventas se pondrá en contacto con usted en las próximas 24 horas</li>' +
            '<li>Procederemos con la formalización del préstamo</li>' +
            '<li>Una vez completada la documentación, procederemos con el desembolso</li>' +
            '</ul>' +
            '<p>Gracias por confiar en nosotros para sus necesidades financieras.</p>' +
            '<br>' +
            '<p>Saludos cordiales,<br><strong>Equipo de Ventas</strong></p>'
        );
    }
    
    private static void sendEmail(String toEmail, String subject, String body) {
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{toEmail});
            email.setSubject(subject);
            email.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            System.debug('Email enviado a: ' + toEmail);
        } catch (Exception e) {
            System.debug('Error al enviar email: ' + e.getMessage());
        }
    }
}