#ifndef TARANTOOL_BOX_TXN_H_INCLUDED
#define TARANTOOL_BOX_TXN_H_INCLUDED
/*
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the following
 * conditions are met:
 *
 * 1. Redistributions of source code must retain the above
 *    copyright notice, this list of conditions and the
 *    following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * <COPYRIGHT HOLDER> OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
#include "index.h"

struct tuple;
struct space;

struct txn {
	/* Undo info. */
	struct space *space;
	struct tuple *old_tuple;
	struct tuple *new_tuple;

	/* Redo info: binary packet */
	const char *data;
	uint32_t len;
	uint16_t op;
};

struct txn *txn_begin();
void txn_commit(struct txn *txn);
void txn_finish(struct txn *txn);
void txn_rollback(struct txn *txn);
void txn_add_redo(struct txn *txn, uint16_t op, const char *data, uint32_t len);
void txn_replace(struct txn *txn, struct space *space,
		 struct tuple *old_tuple, struct tuple *new_tuple,
		 enum dup_replace_mode mode);
#endif /* TARANTOOL_BOX_TXN_H_INCLUDED */
