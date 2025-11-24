use crate::prelude::{sync_on_close::SyncOnCloseType, *};
use savvy::{ListSexp, Result};

fn parse_per_partition_sort_by(sort_by: Option<Vec<Expr>>) -> Option<Vec<SortColumn>> {
    sort_by.map(|exprs| {
        exprs
            .into_iter()
            .map(|e| SortColumn {
                expr: e,
                descending: false,
                nulls_last: false,
            })
            .collect()
    })
}

impl TryFrom<&str> for Wrap<SyncOnCloseType> {
    type Error = savvy::Error;

    fn try_from(value: &str) -> Result<Self> {
        let parsed = match value {
            "none" => SyncOnCloseType::None,
            "data" => SyncOnCloseType::Data,
            "all" => SyncOnCloseType::All,
            _ => return Err("unreachable".to_string().into()),
        };
        Ok(Wrap(parsed))
    }
}

impl From<Option<ListSexp>> for Wrap<Option<Vec<SortColumn>>> {
    fn from(opt_value: Option<ListSexp>) -> Self {
        Wrap(parse_per_partition_sort_by(
            opt_value.map(|value| <Wrap<Vec<Expr>>>::try_from(value).unwrap().0),
        ))
    }
}
