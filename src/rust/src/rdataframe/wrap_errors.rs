//simple utility to wrap any Error that has Display into extendr_api::Error::Other(string)

use extendr_api;
use std::fmt::Display;

pub struct WrapError<T>
where
    T: Display,
{
    pub e: T,
}

pub fn wrap_error<T>(e: T) -> WrapError<T>
where
    T: Display,
{
    WrapError::<T> { e: e }
}

impl<T> From<WrapError<T>> for extendr_api::Error
where
    T: Display,
{
    fn from(e: WrapError<T>) -> Self {
        extendr_api::Error::Other(e.e.to_string())
    }
}
