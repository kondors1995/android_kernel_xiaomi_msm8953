/*
 * ChaCha20 256-bit cipher algorithm, RFC7539
 *
 * Copyright (C) 2015 Martin Willi
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#include <linux/kernel.h>
#include <linux/export.h>

#include <asm/neon.h>

asmlinkage void chacha_block_xor_neon(u32 *state, u8 *dst, const u8 *src, int nrounds);

extern void chacha20_block(u32 *state, void *stream)
{
	u32 x[16];

	memcpy(x, state, 64);

	kernel_neon_begin();
	chacha_block_xor_neon(x, stream, stream, 20);
	kernel_neon_end();

	state[12]++;
}
EXPORT_SYMBOL(chacha20_block);
