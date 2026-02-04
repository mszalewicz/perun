package main

import "../crypto"
import "core:encoding/hex"
import "core:fmt"
import "core:os"

main :: proc() {
	hash, err := crypto.hash_string("test", "asfsafasfasfasfsafas")

	if err != .None {
		fmt.println(err)
		os.exit(1)
	}

	fmt.printf("%s\n", hex.encode(hash[:]))
}
