use extendr_api::prelude::*;
use polars::prelude as pl;

//TODO throw a warning if i32 contains a lowerbound value which is the NA in R.
pub fn pl_series_to_list(series: &pl::Series, tag_structs: bool) -> pl::PolarsResult<Robj> {
    use pl::DataType::*;
    fn to_list_recursive(s: &pl::Series, tag_structs: bool) -> pl::PolarsResult<Robj> {
        match s.dtype() {
            Float64 => s.f64().map(|ca| ca.into_iter().collect_robj()),
            Float32 => s.f32().map(|ca| ca.into_iter().collect_robj()),

            Int8 => s.i8().map(|ca| ca.into_iter().collect_robj()),
            Int16 => s.i16().map(|ca| ca.into_iter().collect_robj()),
            Int32 => s.i32().map(|ca| ca.into_iter().collect_robj()),
            Int64 => s.i64().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as f64))
                    .collect_robj()
            }),
            UInt8 => s.u8().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as i32))
                    .collect_robj()
            }),
            UInt16 => s.u16().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as i32))
                    .collect_robj()
            }),
            UInt32 => s.u32().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as f64))
                    .collect_robj()
            }),
            UInt64 => s.u64().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as f64))
                    .collect_robj()
            }),
            Utf8 => s.utf8().map(|ca| ca.into_iter().collect_robj()),

            Boolean => s.bool().map(|ca| ca.into_iter().collect_robj()),
            Categorical(_) => s
                .categorical()
                .map(|ca| extendr_api::call!("factor", ca.iter_str().collect_robj()).unwrap()),
            List(_) => {
                let mut v: Vec<extendr_api::Robj> = Vec::with_capacity(s.len());
                let ca = s.list().unwrap();

                for opt_s in ca.amortized_iter() {
                    match opt_s {
                        Some(s) => {
                            let s_ref = s.as_ref();
                            let inner_val = to_list_recursive(s_ref, tag_structs)?;
                            v.push(inner_val);
                        }

                        None => {
                            v.push(r!(extendr_api::NULL));
                        }
                    }
                }
                //TODO let l = extendr_api::List::from_values(v); or see if possible to skip vec allocation
                //or take ownership of vector
                let l = extendr_api::List::from_iter(v.iter());
                Ok(l.into_robj())
            }
            Struct(_) => {
                let df = s.clone().into_frame().unnest(&[s.name()]).unwrap();
                let l = super::DataFrame(df).to_list_result()?;

                //TODO contribute extendr_api set_attrib mutates &self, change signature to surprise anyone
                if tag_structs {
                    l.set_attrib("is_struct", true).unwrap();
                } else {
                };

                Ok(l.into_robj())
            }
            _ => Err(pl::PolarsError::NotFound(polars::error::ErrString::Owned(
                format!(
                    "sorry rpolars has not yet implemented R conversion for Series.dtype: {}",
                    s.dtype()
                ),
            ))),
        }
    }

    to_list_recursive(series, tag_structs)
}
