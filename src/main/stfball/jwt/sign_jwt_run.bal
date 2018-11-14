import ballerina/internal;
import ballerina/io;


public function main(string iss = "ballerina.stfweb.com", string sub = "ballerina.stfweb.com", int exp = 1573554720, 
                     string keyAlias = "stfballerinajwt", string keyPassword = "ballerina", 
                     string keyStoreFilePath = "${ballerina.home}/bre/security/ballerinaKeystore.p12", string keyStorePassword = "ballerina",
                     string... aud) {
    if (lengthof aud == 0) {
        aud = ["ballerina"];
    }
    var chkToken = signJwt(iss, sub, exp, keyAlias, keyPassword, keyStoreFilePath = keyStoreFilePath, keyStorePassword = keyStorePassword, ...aud);

    match chkToken {
        string token => {
            io:println(token);
        }
        error err => {
            io:println("Error occurred: " + err.message);
        }
    }
}

