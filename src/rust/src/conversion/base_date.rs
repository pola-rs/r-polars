use savvy::{NumericSexp, NumericTypedSexp};

pub struct DateProxy(pub Vec<i32>);

// Double vector should be floored only for Date class
impl From<NumericSexp> for DateProxy {
    fn from(value: NumericSexp) -> Self {
        let vec = match value.into_typed() {
            NumericTypedSexp::Integer(i) => i.to_vec(),
            NumericTypedSexp::Real(r) => r.iter().map(|v| v.floor() as i32).collect::<Vec<_>>(),
        };
        DateProxy(vec)
    }
}
