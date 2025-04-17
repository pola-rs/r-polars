use crate::{PlRDataFrame, PlRSeries, RPolarsErr, prelude::*};
use savvy::{ListSexp, Result, savvy};

#[savvy]
pub fn concat_df(dfs: ListSexp) -> Result<PlRDataFrame> {
    use polars_core::error::PolarsResult;
    use polars_core::utils::rayon::prelude::*;

    let rdfs = <Wrap<Vec<DataFrame>>>::try_from(dfs)?.0;
    let identity_df = rdfs.first().unwrap().clear();

    let identity = || Ok(identity_df.clone());

    let df = polars_core::POOL
        .install(|| {
            rdfs.into_par_iter()
                .fold(identity, |acc: PolarsResult<DataFrame>, df| {
                    let mut acc = acc?;
                    acc.vstack_mut(&df)?;
                    Ok(acc)
                })
                .reduce(identity, |acc, df| {
                    let mut acc = acc?;
                    acc.vstack_mut(&df?)?;
                    Ok(acc)
                })
        })
        .map_err(RPolarsErr::from)?;

    Ok(df.into())
}

#[savvy]
pub fn concat_series(series: ListSexp) -> Result<PlRSeries> {
    let vec = <Wrap<Vec<Series>>>::try_from(series)?.0;
    let mut s = vec.first().unwrap().clone();

    for series in vec.iter().skip(1) {
        s.append(series).map_err(RPolarsErr::from)?;
    }
    Ok(s.into())
}
