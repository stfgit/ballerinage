import ballerina/test;
import ballerina/http;
import ballerina/runtime;

any[] outputs = [];
int outputCount = 0;

string expectedHostName;

// This is the mock function which will replace the real function
@test:Mock {
    packageName: "ballerina/io",
    functionName: "println"
}
public function mockPrint(any... s) {
    expectedHostName = <string>s[1];
    outputs[outputCount] = <string>s[0] + expectedHostName;
    outputCount++;
}

endpoint http:Client clientEP {
    url:"https://ballerina.stfweb.com:9090/ordermgt",
    auth: {
        scheme: http:JWT_AUTH
    }
};

@test:Config
// Function to test POST resource 'addOrder'.
function testOrderAlerts() {
    // Set the JWT token into runtime invocation context mentioning scheme as `jwt`
    string token = "eyJhbGciOiJSUzI1NiIsICJ0eXAiOiJKV1QifQ==.eyJzdWIiOiJiYWxsZXJpbmE" +
                    "uc3Rmd2ViLmNvbSIsICJpc3MiOiJiYWxsZXJpbmEuc3Rmd2ViLmNvbSIsICJleH" +
                    "AiOjE1NzM1NTQ3MjAsICJpYXQiOjAsICJhdWQiOlsiYmFsbGVyaW5hIl19" +
                    ".OHQI1-nCwbgqTUo7fqyAP7eRdCvJzamlx8ac4Bcxgi5x1u4W1qrrodLytJuzj82" +
                    "Gi1oaxTkVzsNaIFN-Y_DYogC1OC0IBR9K4jHHvnM-yoyq11PA7CuG1uKxyfUkNrK" +
                    "4fZEAT5Q7dhgH1fyF-UQYXNwCgqTKTlxWBUxygd5vKnt8jDnQv6vafdn33BIaLsM-" +
                    "Vh6XvuOtzgtos5m_eaUi4RuV9FvuqZXUNskTB7hjKC569yIKT7TuuNNRnzJmoD_CJr" +
                    "GbV8z03dVOe4bw8qzEsqvDfwVONWKoOQ9n7z6ZSefSlmYDc91pr-YXT798uvO4BPnYphoy7G31kRywxUyr2Q==";
    runtime:getInvocationContext().authContext.scheme = "jwt";
    runtime:getInvocationContext().authContext.authToken = token;

    int reqIndex = 0;
    // Initialize the empty http request.
    http:Request request = new;
    // Construct the request payload.
    json payload = {"Order":{"ID":"100500", "Name":"XYZ", "Description":"Sample order."}};
    request.setJsonPayload(payload);
    while (reqIndex <= 20) {
        // Send 'POST' request and obtain the response.
        http:Response response = check clientEP -> post("/order", request);
        // Expected response code is 201.
        test:assertEquals(response.statusCode, 201,
            msg = "addOrder resource did not respond with expected response code!");
        // Check whether the response is as expected.
        json resPayload = check response.getJsonPayload();
        json expectedPayload = {"status": "Order Created.", "orderId": "100500"};
        test:assertEquals(resPayload.toString(), expectedPayload.toString(), msg = "Response mismatch!");
        reqIndex = reqIndex + 1;
    }
    // Wait till we get the alert in stdout. Note that outputs array mocks the stdout
    while (!(lengthof outputs > 0)) {
        runtime:sleep(500);
    }

    test:assertEquals(outputs[0], "ALERT!! : Received more than 10 requests within 10 seconds from the host: "
            + expectedHostName);
}