use bytes::Bytes;
use heavykeeper::TopK;
use libc::{c_int, c_void, size_t};

use super::TOPK_ITER_CONTINUE;

type TopkListForeachCallback = extern "C" fn(*const u8, size_t, *mut c_void) -> c_int;

pub struct TopkContext(TopK<Bytes>);

ffi_fn! {
    /// Create a new context.
    ///
    /// To avoid a memory leak, the context must eventually be free by `topk_free`.
    ///
    /// This returns `NULL` if allocating a new context fails.
    fn topk_new(
        k: size_t,
        width: size_t,
        depth: size_t,
        decay: f64
    ) -> *mut TopkContext {
        Box::into_raw(Box::new(TopkContext(TopK::new(k, width, depth, decay))))
    } ?= std::ptr::null_mut()
}

ffi_fn! {
    /// Adds an item to this context.
    unsafe fn topk_add(topk: *mut TopkContext, item: *const u8, item_len: size_t) {
        let topk = non_null! {&mut *topk ?= ()};
        let item = unsafe { std::slice::from_raw_parts(item, item_len) };
        topk.0.add(Bytes::copy_from_slice(item));
    }
}

ffi_fn! {
    /// Checks whether an item is one of Top-K items.
    unsafe fn topk_query(
        topk: *mut TopkContext,
        item: *const u8,
        item_len: size_t
    ) -> bool {
        let topk = non_null! {&*topk ?= false};
        let item = unsafe { std::slice::from_raw_parts(item, item_len) };
        topk.0.query(&Bytes::from_static(item))
    } ?= false
}

ffi_fn! {
    /// Iterates the Top-K items passing each item to the callback.
    ///
    /// The `userdata` pointer is also passed to the callback.
    ///
    /// The callback should return `TOPK_ITER_CONTINUE` to keep iterating, or
    /// `TOPK_ITER_BREAK` to stop.
    unsafe fn topk_list_foreach(topk: *mut TopkContext, cb: TopkListForeachCallback, userdata: *mut c_void) {
        let topk = non_null!(&*topk ?= ());

        let list = topk.0.list();
        if list.is_empty(){
            return;
        }

        for node in list.iter() {
            if TOPK_ITER_CONTINUE != cb(node.item.as_ptr(), node.item.len(), userdata){
                return;
            }
        }
    }
}

ffi_fn! {
    /// Free this context.
    unsafe fn topk_free(topk: *mut TopkContext) {
        drop(non_null! {Box::from_raw(topk) ?= ()})
    }
}
