#[macro_use]
mod macros;

pub mod topk;

/// Return in iter functions to continue iterating.
pub const TOPK_ITER_CONTINUE: libc::c_int = 0;
/// Return in iter functions to stop iterating.
#[allow(unused)]
pub const TOPK_ITER_BREAK: libc::c_int = 1;
