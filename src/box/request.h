#ifndef TARANTOOL_BOX_REQUEST_H_INCLUDED
#define TARANTOOL_BOX_REQUEST_H_INCLUDED
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
#include "tarantool/util.h"
#include <stdbool.h>

struct txn;
struct port;

#define BOX_RETURN_TUPLE		0x01
#define BOX_ADD				0x02
#define BOX_REPLACE			0x04
#define BOX_ALLOWED_REQUEST_FLAGS	(BOX_RETURN_TUPLE | \
					 BOX_ADD | \
					 BOX_REPLACE)

/**
    deprecated request ids:
        _(INSERT, 1)
        _(DELETE, 2)
        _(SET_FIELD, 3)
        _(ARITH, 5)
        _(SET_FIELD, 6)
        _(ARITH, 7)
        _(SELECT, 4)
        _(DELETE, 8)
        _(UPDATE_FIELDS, 9)
        _(INSERT,10)
        _(JUBOX_ALIVE, 11)
        _(SELECT_LIMIT, 12)
        _(SELECT_OLD, 14)
        _(SELECT_LIMIT, 15)
        _(UPDATE_FIELDS_OLD, 16)

    DO NOT use these ids!
 */
#define REQUESTS(_)				\
        _(REPLACE, 13)				\
	_(SELECT, 17)				\
	_(UPDATE, 19)				\
	_(DELETE_1_3, 20)			\
	_(DELETE, 21)				\
	_(CALL, 22)

ENUM(requests, REQUESTS);
extern const char *requests_strs[];

static inline bool
request_is_select(uint32_t type)
{
	return type == SELECT || type == CALL;
}

const char *request_name(uint32_t type);

struct request
{
	uint32_t type;
	uint32_t flags;
	const char *data;
	uint32_t len;
};

struct request *request_create(uint32_t type, const char *data, uint32_t len);

void request_execute(struct request *request, struct txn *txn, struct port *port);

#endif /* TARANTOOL_BOX_REQUEST_H_INCLUDED */
