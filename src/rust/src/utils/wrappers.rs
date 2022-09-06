use extendr_api::wrapper::nullable::Nullable;

#[repr(transparent)]
pub struct Wrap<T>(pub T);

impl<T> Clone for Wrap<T>
where
    T: Clone,
{
    fn clone(&self) -> Self {
        Wrap(self.0.clone())
    }
}
impl<T> From<T> for Wrap<T> {
    fn from(t: T) -> Self {
        Wrap(t)
    }
}

//convert R Nullable to rust option
impl<T> From<Wrap<Nullable<T>>> for Option<T> {
    fn from(x: Wrap<Nullable<T>>) -> Option<T> {
        if let Nullable::NotNull(y) = x.0 {
            Some(y)
        } else {
            None
        }
    }
}

pub fn null_to_opt<T>(x: Nullable<T>) -> Option<T> {
    if let Nullable::NotNull(y) = x {
        Some(y)
    } else {
        None
    }
}

//yikes, currently needed as I don't know how to transform Robj external_pointer back into any non native Extendr-type
pub unsafe fn strpointer_to_<T>(raw: &str) -> extendr_api::Result<&mut T> {
    let without_prefix = raw.trim_start_matches("0x");
    let z = usize::from_str_radix(without_prefix, 16)
        .map_err(|e| extendr_api::Error::Other(e.to_string()))?;

    //unsafe {
    let y = &mut *(z as *mut T);
    return Ok(y);
    //};
}
