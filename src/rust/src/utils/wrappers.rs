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
