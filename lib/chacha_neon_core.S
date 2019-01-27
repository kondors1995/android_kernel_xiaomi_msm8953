/*
 * ChaCha/XChaCha NEON helper functions
 *
 * Copyright (C) 2016-2018 Linaro, Ltd. <ard.biesheuvel@linaro.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * Originally based on:
 * ChaCha20 256-bit cipher algorithm, RFC7539, x64 SSSE3 functions
 *
 * Copyright (C) 2015 Martin Willi
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#include <linux/linkage.h>
#include <asm/assembler.h>
#include <asm/cache.h>

	.text
	.align		6

ENTRY(chacha_block_xor_neon)
	// x0: Input state matrix, s
	// x1: 1 data block output, o
	// x2: 1 data block input, i
	// w3: nrounds

	stp		x29, x30, [sp, #-16]!
	mov		x29, sp

	// x0..3 = s0..3
	ld1		{v0.4s-v3.4s}, [x0]
	ld1		{v8.4s-v11.4s}, [x0]

	// start chacha permute
	adr_l		x10, ROT8
	ld1		{v12.4s}, [x10]

.Ldoubleround:
	// x0 += x1, x3 = rotl32(x3 ^ x0, 16)
	add		v0.4s, v0.4s, v1.4s
	eor		v3.16b, v3.16b, v0.16b
	rev32		v3.8h, v3.8h

	// x2 += x3, x1 = rotl32(x1 ^ x2, 12)
	add		v2.4s, v2.4s, v3.4s
	eor		v4.16b, v1.16b, v2.16b
	shl		v1.4s, v4.4s, #12
	sri		v1.4s, v4.4s, #20

	// x0 += x1, x3 = rotl32(x3 ^ x0, 8)
	add		v0.4s, v0.4s, v1.4s
	eor		v3.16b, v3.16b, v0.16b
	tbl		v3.16b, {v3.16b}, v12.16b

	// x2 += x3, x1 = rotl32(x1 ^ x2, 7)
	add		v2.4s, v2.4s, v3.4s
	eor		v4.16b, v1.16b, v2.16b
	shl		v1.4s, v4.4s, #7
	sri		v1.4s, v4.4s, #25

	// x1 = shuffle32(x1, MASK(0, 3, 2, 1))
	ext		v1.16b, v1.16b, v1.16b, #4
	// x2 = shuffle32(x2, MASK(1, 0, 3, 2))
	ext		v2.16b, v2.16b, v2.16b, #8
	// x3 = shuffle32(x3, MASK(2, 1, 0, 3))
	ext		v3.16b, v3.16b, v3.16b, #12

	// x0 += x1, x3 = rotl32(x3 ^ x0, 16)
	add		v0.4s, v0.4s, v1.4s
	eor		v3.16b, v3.16b, v0.16b
	rev32		v3.8h, v3.8h

	// x2 += x3, x1 = rotl32(x1 ^ x2, 12)
	add		v2.4s, v2.4s, v3.4s
	eor		v4.16b, v1.16b, v2.16b
	shl		v1.4s, v4.4s, #12
	sri		v1.4s, v4.4s, #20

	// x0 += x1, x3 = rotl32(x3 ^ x0, 8)
	add		v0.4s, v0.4s, v1.4s
	eor		v3.16b, v3.16b, v0.16b
	tbl		v3.16b, {v3.16b}, v12.16b

	// x2 += x3, x1 = rotl32(x1 ^ x2, 7)
	add		v2.4s, v2.4s, v3.4s
	eor		v4.16b, v1.16b, v2.16b
	shl		v1.4s, v4.4s, #7
	sri		v1.4s, v4.4s, #25

	// x1 = shuffle32(x1, MASK(2, 1, 0, 3))
	ext		v1.16b, v1.16b, v1.16b, #12
	// x2 = shuffle32(x2, MASK(1, 0, 3, 2))
	ext		v2.16b, v2.16b, v2.16b, #8
	// x3 = shuffle32(x3, MASK(0, 3, 2, 1))
	ext		v3.16b, v3.16b, v3.16b, #4

	subs		w3, w3, #2
	b.ne		.Ldoubleround
	// end chacha permute

	ld1		{v4.16b-v7.16b}, [x2]

	// o0 = i0 ^ (x0 + s0)
	add		v0.4s, v0.4s, v8.4s
	eor		v0.16b, v0.16b, v4.16b

	// o1 = i1 ^ (x1 + s1)
	add		v1.4s, v1.4s, v9.4s
	eor		v1.16b, v1.16b, v5.16b

	// o2 = i2 ^ (x2 + s2)
	add		v2.4s, v2.4s, v10.4s
	eor		v2.16b, v2.16b, v6.16b

	// o3 = i3 ^ (x3 + s3)
	add		v3.4s, v3.4s, v11.4s
	eor		v3.16b, v3.16b, v7.16b

	st1		{v0.16b-v3.16b}, [x1]

	ldp		x29, x30, [sp], #16
	ret
ENDPROC(chacha_block_xor_neon)

ROT8:	.word	0x02010003, 0x06050407, 0x0a09080b, 0x0e0d0c0f
