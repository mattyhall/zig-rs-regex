use regex::bytes::Regex;

#[repr(C)]
pub struct Match {
    start: usize, end: usize
}

#[repr(C)]
pub struct Matches {
    ptr: *const Match,
    len: usize,
}


#[no_mangle]
pub extern "C" fn re_search(regex: *const u8, regex_len: usize, buf: *const u8, buf_len: usize) -> Matches {
    let regex = unsafe { std::str::from_utf8_unchecked(std::slice::from_raw_parts(regex, regex_len) ) };
    let buf = unsafe { std::slice::from_raw_parts(buf, buf_len) };
    let r = Regex::new(regex).unwrap();
    let mut matches = Vec::new();
    for mat in r.find_iter(buf) {
        matches.push(Match { start: mat.start(), end: mat.end() });
    }
    matches.shrink_to_fit();
    let (ptr, len) = (matches.as_ptr(), matches.len());
    std::mem::forget(matches);
    Matches { ptr, len }
}

#[no_mangle]
pub extern "C" fn re_free_matches(matches: Matches) {
    let _ = unsafe { Vec::from_raw_parts(matches.ptr as *mut Match, matches.len, matches.len) };
}

