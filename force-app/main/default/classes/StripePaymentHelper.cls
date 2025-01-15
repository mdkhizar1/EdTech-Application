public class StripePaymentHelper {
    private static final String baseURL = 'https://api.stripe.com';
    private static String getStripeKey() {
        Stripe_Credentials__mdt credentials = Stripe_Credentials__mdt.getInstance('Stripe_Keys');
        return credentials.Secret_Key__c;
    }
    
    public static String createPrice(OpportunityLineItem product) {
        String apiURL = baseURL + '/v1/prices';
        String requestBody = 'unit_amount_decimal=' + EncodingUtil.urlEncode(String.valueOf(product.TotalPrice), 'UTF-8') +
                           '&currency=' + EncodingUtil.urlEncode(String.valueOf(product.CurrencyIsoCode), 'UTF-8') +
                           '&product_data[name]=' + EncodingUtil.urlEncode(product.Product2.Name, 'UTF-8');
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiURL);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + getStripeKey());
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(requestBody);
        
        HttpResponse response = new Http().send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            return (String)result.get('id');
        }
        throw new StripeException('Failed to create price: ' + response.getBody());
    }
    
    public static String createPaymentLink(List<String> priceIds, Opportunity opportunity) {
        String apiURL = baseURL + '/v1/payment_links';
        
        List<Map<String, Object>> lineItems = new List<Map<String, Object>>();
        for(String priceId : priceIds) {
            lineItems.add(new Map<String, Object>{
                'price' => priceId,
                'quantity' => 1
            });
        }
        
        Map<String, Object> requestMap = new Map<String, Object>{
            'line_items' => lineItems,
            'after_completion' => new Map<String, Object>{
                'type' => 'redirect',
                'redirect' => new Map<String, Object>{
                    'url' => URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id
                }
            }
        };
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiURL);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + getStripeKey());
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(requestMap));
        
        HttpResponse response = new Http().send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            return (String)result.get('url');
        }
        throw new StripeException('Failed to create payment link: ' + response.getBody());
    }
    
    public static void sendPaymentEmail(String paymentURL, Opportunity opportunity) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(opportunity.OwnerId);
        email.setSubject('Payment Request for: ' + opportunity.Name);
        email.setPlainTextBody('Dear ' + opportunity.Account.Name + ',\n\nClick on this link ' + 
                              paymentURL + ' to make a payment.');
        email.setSaveAsActivity(true);
        
        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        } catch(Exception e) {
            throw new StripeException('Failed to send email: ' + e.getMessage());
        }
    }
    
    public class StripeException extends Exception {}
}