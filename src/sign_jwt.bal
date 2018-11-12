import ballerina/internal;
import ballerina/io;

// TODO Params
internal:JWTIssuerConfig jwtConfig = {
    keyAlias: "stfballerinajwt",
    keyPassword: "ballerina",
    keyStoreFilePath: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
    keyStorePassword: "ballerina"
};
internal:JwtHeader jwtHeader= {
    alg: "RS256",
    typ: "JWT"
};

internal:JwtPayload jwtPayload = {
    iss: "ballerina.stfweb.com",
    sub: "ballerina.stfweb.com",
    exp: 1573554720,
    aud: ["ballerina"]
};

public function main() {
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

