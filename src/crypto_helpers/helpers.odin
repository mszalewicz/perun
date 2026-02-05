package crypto_helpers

import "core:c"
import "core:crypto"
import "core:encoding/hex"

foreign import lib {
	"../../external/crypto/crypto_wrapper.o",
	"../../external/crypto/openssl/libcrypto.a",
}

foreign lib {
	argon2_hash_password :: proc (
		password:          [^]u8,
		password_length:   c.size_t,
		salt:              [^]u8,
		salt_length:       c.size_t,
		out_buffer:        [^]u8,
		out_length:        c.size_t,
		) -> c.int ---
}

CryptoError :: enum {
	None,
	NotHashed
}

generate_salt :: proc() -> string {
	salt: [32]byte
	crypto.rand_bytes(salt[:])
	salt_string := hex.encode(salt[:])
	// defer delete(salt_string)

	return string(salt_string)
}

hash_string :: proc(input: string, salt: string) -> ([32]u8, CryptoError) {
	output_length : uint : 32
	output_buffer : [output_length]u8

	outcome_of_hashing := argon2_hash_password(
		raw_data(input),
		len(input),
		raw_data(salt),
		len(salt),
		&output_buffer[0],
		output_length
	)

	if outcome_of_hashing == 1 {
		return output_buffer, .None
	}

	return output_buffer, .NotHashed
}
