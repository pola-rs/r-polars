use crate::prelude::{sync_on_close::SyncOnCloseType, *};
use savvy::{EnvironmentSexp, ListSexp, NumericScalar, Result, Sexp, StringSexp, TypedSexp, savvy};
use std::{
    path::{Path, PathBuf},
    sync::Arc,
};

#[derive(Clone)]
pub enum RSinkTarget {
    File(SinkTarget),
    Partition(PlRPartitioning),
}

#[savvy]
#[derive(Clone)]
pub struct PlRPartitioning {
    pub base_path: PathBuf,
    pub variant: PartitionVariant,
    pub per_partition_sort_by: Option<Vec<SortColumn>>,
}

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
    pub fn base_path(&self) -> Option<&Path> {
        match self {
            Self::File(t) => match t {
                SinkTarget::Path(p) => Some(p.as_path()),
                SinkTarget::Dyn(_) => None,
            },
            Self::Partition(p) => Some(&p.base_path),
        }
    }
}

#[savvy]
impl PlRPartitioning {
    fn base_path(&self) -> Result<Sexp> {
        self.base_path.to_str().unwrap_or_default().try_into()
    }

    pub fn new_max_size(
        base_path: &str,
        max_size: NumericScalar,
        per_partition_sort_by: Option<ListSexp>,
    ) -> Result<Self> {
        let base_path = PathBuf::from(base_path);
        let max_size = <Wrap<IdxSize>>::try_from(max_size)?.0;
        let per_partition_sort_by = <Wrap<Option<Vec<SortColumn>>>>::from(per_partition_sort_by).0;

        Ok(PlRPartitioning {
            base_path,
            variant: PartitionVariant::MaxSize(max_size),
            per_partition_sort_by,
        })
    }

    pub fn new_by_key(
        base_path: &str,
        by: ListSexp,
        include_key: bool,
        per_partition_sort_by: Option<ListSexp>,
    ) -> Result<Self> {
        let base_path = PathBuf::from(base_path);
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        let per_partition_sort_by = <Wrap<Option<Vec<SortColumn>>>>::from(per_partition_sort_by).0;

        Ok(PlRPartitioning {
            base_path,
            variant: PartitionVariant::ByKey {
                key_exprs: by.into_iter().collect(),
                include_key,
            },
            per_partition_sort_by,
        })
    }

    pub fn new_parted(
        base_path: &str,
        by: ListSexp,
        include_key: bool,
        per_partition_sort_by: Option<ListSexp>,
    ) -> Result<Self> {
        let base_path = PathBuf::from(base_path);
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        let per_partition_sort_by = <Wrap<Option<Vec<SortColumn>>>>::from(per_partition_sort_by).0;

        Ok(PlRPartitioning {
            base_path,
            variant: PartitionVariant::Parted {
                key_exprs: by.into_iter().collect(),
                include_key,
            },
            per_partition_sort_by,
        })
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

impl TryFrom<StringSexp> for RSinkTarget {
    type Error = savvy::Error;

    fn try_from(value: StringSexp) -> Result<Self> {
        let string_value: &str = <Sexp>::from(value).try_into()?;
        Ok(RSinkTarget::File(SinkTarget::Path(Arc::new(
            PathBuf::from(string_value),
        ))))
    }
}

impl TryFrom<EnvironmentSexp> for RSinkTarget {
    type Error = savvy::Error;

    fn try_from(env: EnvironmentSexp) -> Result<Self> {
        let partitioning = <&PlRPartitioning>::try_from(env)?;
        Ok(Self::Partition(partitioning.clone()))
    }
}

impl TryFrom<EnvironmentSexp> for &PlRPartitioning {
    type Error = savvy::Error;

    fn try_from(env: EnvironmentSexp) -> Result<Self> {
        let ptr = env
            .get(".ptr")
            .expect("Failed to get `.ptr` from the object")
            .ok_or("The object is not a valid PlRPartitioning")?;
        <&PlRPartitioning>::try_from(ptr)
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
            opt_value.map(|value| <Wrap<Vec<Expr>>>::from(value).0),
        ))
    }
}
