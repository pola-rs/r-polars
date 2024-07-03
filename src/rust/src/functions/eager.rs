use crate::{prelude::*, PlRDataFrame, RPolarsErr};
use polars::functions;
use savvy::{savvy, ListSexp, Result};

#[savvy]
pub fn concat_df(dfs: ListSexp) -> Result<PlRDataFrame> {
    use polars_core::error::PolarsResult;
    use polars_core::utils::rayon::prelude::*;

    let rdfs = <Wrap<Vec<DataFrame>>>::try_from(dfs)?.0;
    let identity_df = rdfs.iter().next().unwrap().clear();

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
