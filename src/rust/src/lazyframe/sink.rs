use crate::prelude::{sync_on_close::SyncOnCloseType, *};
use savvy::{EnvironmentSexp, ListSexp, NumericScalar, Result, Sexp, StringSexp, TypedSexp, savvy};

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

impl RSinkTarget {
    pub fn base_path(&self) -> Option<PlPathRef<'_>> {
        match self {
            Self::File(t) => match t {
                SinkTarget::Path(p) => Some(p.as_ref()),
                SinkTarget::Dyn(_) => None,
            },
            Self::Partition(p) => Some(p.base_path.as_ref()),
        }
    }
}

impl TryFrom<Sexp> for RSinkTarget {
    type Error = savvy::Error;

    fn try_from(value: Sexp) -> Result<Self> {
        match value.into_typed() {
            TypedSexp::String(s) => s.try_into(),
            TypedSexp::Environment(e) => e.try_into(),
            _ => Err("Invalid sink target".to_string().into()),
        }
    }
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
