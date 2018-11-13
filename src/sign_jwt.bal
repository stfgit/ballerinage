import ballerina/internal;
import ballerina/io;


function createConfig(string keyAlias, string keyPassword, string keyStoreFilePath, string keyStorePassword) returns internal:JWTIssuerConfig {
    return {
        keyAlias: "stfballerinajwt",
        keyPassword: "ballerina",
        keyStoreFilePath: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
        keyStorePassword: "ballerina"
        };
}


function createPayload(string iss, string sub, int exp) returns internal:JwtPayload {
    return {
        iss: iss,
        sub: sub,
        exp: exp,
        aud: ["ballerina"]
    };
}

public function signJwt(string iss = "ballerina.stfweb.com", string sub = "ballerina.stfweb.com", int exp = 1573554720, 
                        string keyAlias = "stfballerinajwt", string keyPassword = "ballerina", string keyStoreFilePath = "${ballerina.home}/bre/security/ballerinaKeystore.p12", string keyStorePassword = "ballerina") returns string|error {
    internal:JwtPayload jwtPayload = createPayload(iss, sub, exp);
    internal:JWTIssuerConfig jwtConfig = createConfig(keyAlias, keyPassword, keyStoreFilePath, keyStorePassword);
    internal:JwtHeader jwtHeader= {
        alg: "RS256",
        typ: "JWT"
    };
    return internal:issue(jwtHeader, jwtPayload, jwtConfig);
}

public function main(string iss = "ballerina.stfweb.com", string sub = "ballerina.stfweb.com", int exp = 1573554720, 
                     string keyAlias = "stfballerinajwt", string keyPassword = "ballerina", string keyStoreFilePath = "${ballerina.home}/bre/security/ballerinaKeystore.p12", string keyStorePassword = "ballerina") {
    var chkToken = signJwt(iss = iss, sub = sub, exp = exp, keyAlias = keyAlias, keyPassword = keyPassword, keyStoreFilePath = keyStoreFilePath, keyStorePassword = keyStorePassword);

    match chkToken {
        string token => {
            io:println(token);
        }
        error err => {
            io:println("Error occurred: " + err.message);
        }
    }
}

