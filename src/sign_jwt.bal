import ballerina/internal;
import ballerina/io;

internal:JwtHeader jwtHeader= {
    alg: "RS256",
    typ: "JWT"
};

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

public function main(string iss = "ballerina.stfweb.com", string sub = "ballerina.stfweb.com", int exp = 1573554720, 
                     string keyAlias = "stfballerinajwt", string keyPassword = "ballerina", string keyStoreFilePath = "${ballerina.home}/bre/security/ballerinaKeystore.p12", string keyStorePassword = "ballerina") {
    internal:JwtPayload jwtPayload = createPayload(iss, sub, exp);
    internal:JWTIssuerConfig jwtConfig = createConfig(keyAlias, keyPassword, keyStoreFilePath, keyStorePassword);

    var chkToken = internal:issue(jwtHeader, jwtPayload, jwtConfig);
    match chkToken {
        string token => {
            io:println(token);
        }
        error err => {
            io:println("Error occurred: " + err.message);
        }
    }
}

