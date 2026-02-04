#include <stdio.h>
#include <string.h>
#include <openssl/core_names.h>
#include <openssl/crypto.h>
#include <openssl/kdf.h>
#include <openssl/params.h>
#include <openssl/thread.h>
#include <openssl/err.h>

/*
    Wrapper function for Odin.

    password:         Raw bytes of the password
    password_length:  Length of password
    salt:             Raw bytes of the salt
    salt_length:      Length of salt
    out_buffer:       Buffer to write the hash into
    out_length:       Size of the output buffer (desired hash length)
    outcome:          Return value: 1 on success, 0 on failure
*/

int argon2_hash_password(
    const unsigned char *password,
    size_t password_length,
    const unsigned char *salt,
    size_t salt_length,
    unsigned char *out_buffer,
    size_t out_length
) {
    int outcome = 0; // Default to failure
    EVP_KDF *kdf = NULL;
    EVP_KDF_CTX *kctx = NULL;
    OSSL_LIB_CTX *lib_ctx = NULL;
    OSSL_PARAM params[6], *p = params;

    // Hardcoded Argon2 params for this example (Adjust as needed)
    uint32_t memory_cost = 1048576; // 1GiB
    uint32_t iteration_cost = 3;
    uint32_t parallel_cost = 8;

    // 1. Create Library Context
    lib_ctx = OSSL_LIB_CTX_new();
    if (lib_ctx == NULL) goto end;

    // 2. Fetch Argon2id implementation
    kdf = EVP_KDF_fetch(lib_ctx, "argon2id", NULL);
    if (kdf == NULL) goto end;

    // 3. Create Context
    kctx = EVP_KDF_CTX_new(kdf);
    if (kctx == NULL) goto end;

    // 4. Construct Parameters
    *p++ = OSSL_PARAM_construct_octet_string(OSSL_KDF_PARAM_PASSWORD, (void*)password, password_length);
    *p++ = OSSL_PARAM_construct_octet_string(OSSL_KDF_PARAM_SALT, (void*)salt, salt_length);
    *p++ = OSSL_PARAM_construct_uint32(OSSL_KDF_PARAM_ITER, &iteration_cost);
    *p++ = OSSL_PARAM_construct_uint32(OSSL_KDF_PARAM_ARGON2_LANES, &parallel_cost);
    *p++ = OSSL_PARAM_construct_uint32(OSSL_KDF_PARAM_ARGON2_MEMCOST, &memory_cost);
    *p = OSSL_PARAM_construct_end();

    // 5. Derive
    if (EVP_KDF_derive(kctx, out_buffer, out_length, params) == 1) {
        outcome = 1; // Success
    }

end:
    EVP_KDF_CTX_free(kctx);
    EVP_KDF_free(kdf);
    OSSL_LIB_CTX_free(lib_ctx);
    return outcome;
}