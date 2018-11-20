import ballerina/internal;
import ballerina/io;


function createConfig(string keyAlias, string keyPassword, string keyStoreFilePath, string keyStorePassword) returns internal:JWTIssuerConfig {
    return {
        keyAlias: keyAlias,
        keyPassword: keyPassword,
        keyStoreFilePath: keyStoreFilePath,
        keyStorePassword: keyStorePassword
        };
}


function createPayload(string iss, string sub, int exp, string... aud) returns internal:JwtPayload {
    return {
        iss: iss,
        sub: sub,
        exp: exp,
        aud: aud
    };
}

public function signJwt(string iss, string sub, int exp,
                        string keyAlias, string keyPassword, 
                        string keyStoreFilePath = "${ballerina.home}/bre/security/ballerinaKeystore.p12", string keyStorePassword = "ballerina",
                        string... aud)  returns string|error {
    internal:JwtHeader jwtHeader= {
        alg: "RS256",
        typ: "JWT"
    };
    internal:JWTIssuerConfig jwtConfig = createConfig(keyAlias, keyPassword, keyStoreFilePath, keyStorePassword);
    internal:JwtPayload jwtPayload = createPayload(iss, sub, exp, ...aud);
    
    return internal:issue(jwtHeader, jwtPayload, jwtConfig);
}



