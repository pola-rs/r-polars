//simple utility to wrap any Error that has Display into extendr_api::Error::Other(string)

use extendr_api;

//minimal struct for error conversions
pub struct WrapError<T>
where
    T: std::error::Error,
{
    pub e: T,
}

pub fn wrap_error<T>(e: T) -> WrapError<T>
where
    T: std::error::Error,
{
    WrapError::<T> { e: e }
}

impl<T> From<WrapError<T>> for extendr_api::Error
where
    T: std::error::Error,
{
    fn from(e: WrapError<T>) -> Self {
        extendr_api::Error::Other(e.e.to_string())
    }
}
