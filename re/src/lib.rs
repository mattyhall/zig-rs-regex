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

#[repr(C)]
pub struct Re;

#[no_mangle]
pub extern "C" fn re_compile(regex: *const u8, regex_len: usize) -> *mut Re {
    let regex = unsafe { std::str::from_utf8_unchecked(std::slice::from_raw_parts(regex, regex_len) ) };
    let r = match Regex::new(regex) {
        Ok(r) => r,
        Err(_) => return std::ptr::null_mut() as *mut Re,
    };

    let r = Box::leak(Box::new(r)) as *mut Regex;
    r as *mut Re
}

#[no_mangle]
pub extern "C" fn re_search(re: *const Re, buf: *const u8, buf_len: usize) -> Matches {
    let regex = unsafe { Box::from_raw(re as *mut Regex) };
    let buf = unsafe { std::slice::from_raw_parts(buf, buf_len) };
    let mut matches = Vec::new();
    for mat in regex.find_iter(buf) {
        matches.push(Match { start: mat.start(), end: mat.end() });
    }
    matches.shrink_to_fit();
    let (ptr, len) = (matches.as_ptr(), matches.len());
    std::mem::forget(matches);
    std::mem::forget(regex);
    Matches { ptr, len }
}

#[no_mangle]
pub extern "C" fn re_free(re: *mut Re) {
    let _ = unsafe { Box::from_raw(re as *mut Regex) };
}

#[no_mangle]
pub extern "C" fn re_free_matches(matches: Matches) {
    let _ = unsafe { Vec::from_raw_parts(matches.ptr as *mut Match, matches.len, matches.len) };
}

