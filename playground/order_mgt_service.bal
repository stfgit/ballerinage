import ballerina/http;
import ballerinax/kubernetes;

http:AuthProvider jwtAuthProvider = {
   scheme:"jwt",
   issuer:"ballerina.stfweb.com",
   audience: "ballerina",
   clockSkew:10,
   certificateAlias: "stfballerinajwt",
   trustStore: {
       path: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
       password: "ballerina"
   }
};

@kubernetes:Ingress {
    hostname : "ballerina.kubs",
    name:"playground",
    path:"/"
}
@kubernetes:Service {
    serviceType:"NodePort",
    name:"playground"
}
endpoint http:SecureListener endpointListener {
    port: 9090,
    authProviders:[jwtAuthProvider],
    secureSocket: {
       keyStore: {
           path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
           password: "ballerina"
       },
       trustStore: {
            path: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        }

   }
};



function sendRequestEventToStream (string hostName) {
    ClientRequest clientRequest = {host : hostName};
    requestStream.publish(clientRequest);
}


// Order management is done using an in memory map.
// Add some sample orders to 'ordersMap' at startup.
map<json> ordersMap;

@kubernetes:Deployment {
    image:"stf/playground:v1.0",
    name:"playground"
}
// RESTful service.
@http:ServiceConfig { basePath: "/ordermgt" }
service<http:Service> orderMgt bind endpointListener {

    future ftr = start initRealtimeRequestCounter();

    // Resource that handles the HTTP POST requests that are directed to the path
    // '/orders' to create a new Order.
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/order"
    }
    addOrder(endpoint client, http:Request req) {

        string hostName = untaint client.remote.host;
        sendRequestEventToStream(hostName);

        json orderReq = check req.getJsonPayload();
        string orderId = orderReq.Order.ID.toString();
        ordersMap[orderId] = orderReq;

        // Create response message.
        json payload = { status: "Order Created.", orderId: untaint orderId };
        http:Response response;
        response.setJsonPayload(payload);

        // Set 201 Created status code in the response message.
        response.statusCode = 201;
        // Set 'Location' header in the response message.
        // This can be used by the client to locate the newly added order.
        response.setHeader("Location", "https://localhost:9090/ordermgt/order/" +
                orderId);

        // Send response to the client.
        _ = client->respond(response);
    }
}