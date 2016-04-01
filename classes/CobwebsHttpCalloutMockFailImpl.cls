@isTest 
global class CobwebsHttpCalloutMockFailImpl implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        System.debug('Entered cobwebs mock');
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(400);
        return res;
    }
}