#ifndef INCLUDE_RE_H__
#define INCLUDE_RE_H__

#include <stdint.h>
#include <stddef.h>

typedef struct {
    size_t start;
    size_t end;
} match_t;

typedef struct {
    const match_t *ptr;
    size_t len;
} matches_t;

typedef struct re_t re_t;

re_t *re_compile(const uint8_t *regex, size_t regex_len);
matches_t re_search(const re_t *re, const uint8_t *buf, size_t buf_len);
void re_free(re_t *re);
void re_free_matches(matches_t matches);

#endif
