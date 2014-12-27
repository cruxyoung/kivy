from cpython.ref cimport PyObject

cdef class ObjectWithUid(object):
    cdef readonly int uid


cdef class Observable(ObjectWithUid):
    cdef object __fast_bind_mapping


cdef class EventDispatcher(ObjectWithUid):
    cdef dict __event_stack
    cdef dict __properties
    cdef dict __storage
    cdef object __weakref__
    cpdef dict properties(self)


cdef enum BoundLock:
    unlocked  # whether the BoundCallback is unlocked and can be deleted
    locked  # whether the BoundCallback is locked and cannot be deleted
    deleted  # whether the locked BoundCallback was marked for deletion

cdef class BoundCallback:
    cdef object func
    cdef tuple largs
    cdef dict kwargs
    cdef int is_ref
    cdef BoundLock lock  # see BoundLock
    cdef BoundCallback next
    cdef BoundCallback prev


cdef class EventObservers:
    # If dispatching should occur in normal or reverse order of binding.
    cdef int dispatch_reverse
    # If in dispatch, the value parameter is dispatched or ignored.
    cdef int dispatch_value
    cdef BoundCallback first_callback
    cdef BoundCallback last_callback

    cdef inline void bind(self, object observer) except *
    cdef inline void fast_bind(self, object observer, tuple largs, dict kwargs, int is_ref) except *
    cdef inline void unbind(self, object observer, int is_ref, int stop_on_first) except *
    cdef inline void fast_unbind(self, object observer, tuple largs, dict kwargs) except *
    cdef inline void remove_callback(self, BoundCallback callback, int force=*) except *
    cdef inline object _dispatch(
        self, object f, tuple slargs, dict skwargs, object obj, object value, tuple largs, dict kwargs)
    cdef inline int dispatch(self, object obj, object value, tuple largs, dict kwargs, int stop_on_true) except 2
