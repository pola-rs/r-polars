use crate::prelude::*;
use polars::lazy::dsl;
use savvy::{ListSexp, NumericScalar, NumericSexp, Result, Sexp, StringSexp, savvy};
use std::{
    hash::{Hash, Hasher},
    sync::Arc,
};

#[savvy]
#[repr(transparent)]
#[derive(Clone)]
pub struct PlRSelector {
    pub inner: Selector,
}

impl From<Selector> for PlRSelector {
    fn from(inner: Selector) -> Self {
        Self { inner }
    }
}

fn parse_time_unit_set(time_units: Vec<TimeUnit>) -> TimeUnitSet {
    let mut tu = TimeUnitSet::empty();
    for v in time_units {
        match v {
            TimeUnit::Nanoseconds => tu |= TimeUnitSet::NANO_SECONDS,
            TimeUnit::Microseconds => tu |= TimeUnitSet::MICRO_SECONDS,
            TimeUnit::Milliseconds => tu |= TimeUnitSet::MILLI_SECONDS,
        }
    }
    tu
}

// Same as `parse_datatype_selector` of polars-python
impl TryFrom<&PlRSelector> for DataTypeSelector {
    type Error = savvy::Error;

    fn try_from(selector: &PlRSelector) -> Result<Self> {
        selector.inner.clone().to_dtype_selector().ok_or_else(|| {
            format!(
                "expected datatype based expression got '{}'",
                selector.inner
            )
            .into()
        })
    }
}

#[savvy]
impl PlRSelector {
    fn union(&self, other: &PlRSelector) -> Result<Self> {
        Ok(Self {
            inner: self.inner.clone() | other.inner.clone(),
        })
    }

    fn difference(&self, other: &PlRSelector) -> Result<Self> {
        Ok(Self {
            inner: self.inner.clone() - other.inner.clone(),
        })
    }

    fn exclusive_or(&self, other: &PlRSelector) -> Result<Self> {
        Ok(Self {
            inner: self.inner.clone() ^ other.inner.clone(),
        })
    }

    fn intersect(&self, other: &PlRSelector) -> Result<Self> {
        Ok(Self {
            inner: self.inner.clone() & other.inner.clone(),
        })
    }

    fn by_dtype(dtypes: ListSexp) -> Result<Self> {
        let dtypes = <Wrap<Vec<DataType>>>::try_from(dtypes)?.0;
        Ok(Self {
            inner: dsl::dtype_cols(dtypes).as_selector(),
        })
    }

    fn by_name(names: StringSexp, require_all: bool) -> Result<Self> {
        Ok(dsl::by_name(names.to_vec(), require_all, false).into())
    }

    fn by_index(indices: NumericSexp, require_all: bool) -> Result<Self> {
        let indices = <Wrap<Vec<i64>>>::try_from(indices)?.0.into();
        Ok(Selector::ByIndex {
            indices,
            strict: require_all,
        }
        .into())
    }

    fn first(strict: bool) -> Result<Self> {
        Ok(Selector::ByIndex {
            indices: [0].into(),
            strict,
        }
        .into())
    }

    fn last(strict: bool) -> Result<Self> {
        Ok(Selector::ByIndex {
            indices: [-1].into(),
            strict,
        }
        .into())
    }

    fn matches(pattern: &str) -> Result<Self> {
        Ok(Selector::Matches(pattern.into()).into())
    }

    fn r#enum() -> Result<Self> {
        Ok(DataTypeSelector::Enum.as_selector().into())
    }

    fn categorical() -> Result<Self> {
        Ok(DataTypeSelector::Categorical.as_selector().into())
    }

    fn nested() -> Result<Self> {
        Ok(DataTypeSelector::Nested.as_selector().into())
    }

    fn list(inner_dst: Option<&PlRSelector>) -> Result<Self> {
        let inner_dst = match inner_dst {
            None => None,
            Some(inner_dst) => Some(Arc::new(DataTypeSelector::try_from(inner_dst)?)),
        };
        Ok(DataTypeSelector::List(inner_dst).as_selector().into())
    }

    fn array(inner_dst: Option<&PlRSelector>, width: Option<NumericScalar>) -> Result<Self> {
        let inner_dst = match inner_dst {
            None => None,
            Some(inner_dst) => Some(Arc::new(DataTypeSelector::try_from(inner_dst)?)),
        };
        let width = width
            .map(|w| <Wrap<usize>>::try_from(w).map(|w| w.0))
            .transpose()?;
        Ok(DataTypeSelector::Array(inner_dst, width)
            .as_selector()
            .into())
    }

    fn r#struct() -> Result<Self> {
        Ok(DataTypeSelector::Struct.as_selector().into())
    }

    fn integer() -> Result<Self> {
        Ok(DataTypeSelector::Integer.as_selector().into())
    }

    fn signed_integer() -> Result<Self> {
        Ok(DataTypeSelector::SignedInteger.as_selector().into())
    }

    fn unsigned_integer() -> Result<Self> {
        Ok(DataTypeSelector::UnsignedInteger.as_selector().into())
    }

    fn float() -> Result<Self> {
        Ok(DataTypeSelector::Float.as_selector().into())
    }

    fn decimal() -> Result<Self> {
        Ok(DataTypeSelector::Decimal.as_selector().into())
    }

    fn numeric() -> Result<Self> {
        Ok(DataTypeSelector::Numeric.as_selector().into())
    }

    fn temporal() -> Result<Self> {
        Ok(DataTypeSelector::Temporal.as_selector().into())
    }

    fn datetime(time_unit: StringSexp, time_zone: Sexp) -> Result<Self> {
        use TimeZoneSet as TZS;

        let time_unit = <Wrap<Vec<TimeUnit>>>::try_from(time_unit)?.0;
        let tu = parse_time_unit_set(time_unit);
        let tz = <Wrap<Vec<Option<TimeZone>>>>::try_from(time_zone)?.0;

        let mut allow_unset = false;
        let mut allow_set = false;
        let mut any_of: Vec<TimeZone> = Vec::new();

        for t in tz {
            match t {
                None => allow_unset = true,
                Some(s) if s.as_str() == "*" => allow_set = true,
                Some(t) => any_of.push(t),
            }
        }

        let tzs = match (allow_unset, allow_set) {
            (true, true) => TZS::Any,
            (false, true) => TZS::AnySet,
            (true, false) if any_of.is_empty() => TZS::Unset,
            (true, false) => TZS::UnsetOrAnyOf(any_of.into()),
            (false, false) => TZS::AnyOf(any_of.into()),
        };
        Ok(DataTypeSelector::Datetime(tu, tzs).as_selector().into())
    }

    fn duration(time_unit: StringSexp) -> Result<Self> {
        let time_unit = <Wrap<Vec<TimeUnit>>>::try_from(time_unit)?.0;
        let tu = parse_time_unit_set(time_unit);
        Ok(DataTypeSelector::Duration(tu).as_selector().into())
    }

    fn empty() -> Result<Self> {
        Ok(dsl::empty().into())
    }

    fn all() -> Result<Self> {
        Ok(dsl::all().into())
    }

    fn hash(&self) -> Result<Sexp> {
        let mut hasher = std::hash::DefaultHasher::default();
        self.inner.hash(&mut hasher);
        (hasher.finish() as f64).try_into()
    }
}
