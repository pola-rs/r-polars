use crate::{PlRExpr, prelude::*};
use polars_plan::prelude::{CastingRules, FunctionExpr, FunctionFlags, FunctionOptions};
use savvy::{ListSexp, RawSexp, Result, Sexp, TypedSexp, savvy, savvy_err};
use serde_pickle::{HashableValue, SerOptions, Value, value_to_vec};
use std::collections::BTreeMap;

// Build an FFI plugin expression. Exposed to R as `pl$register_plugin_function()`.
#[savvy]
pub fn register_plugin_function(
    plugin_path: &str,
    function_name: &str,
    args: ListSexp,
    kwargs_raw: RawSexp,
    is_elementwise: bool,
    input_wildcard_expansion: bool,
    returns_scalar: bool,
    cast_to_supertype: bool,
    pass_name_to_apply: bool,
    changes_length: bool,
) -> Result<PlRExpr> {
    let args = <Wrap<Vec<Expr>>>::try_from(args)?.0;
    let kwargs = kwargs_raw.as_slice().to_vec();

    let cast_to_supertypes = if cast_to_supertype {
        Some(CastingRules::cast_to_supertypes())
    } else {
        None
    };

    let mut flags = FunctionFlags::default();
    if is_elementwise {
        flags.set_elementwise();
    }
    flags.set(FunctionFlags::LENGTH_PRESERVING, !changes_length);
    flags.set(FunctionFlags::PASS_NAME_TO_APPLY, pass_name_to_apply);
    flags.set(FunctionFlags::RETURNS_SCALAR, returns_scalar);
    flags.set(
        FunctionFlags::INPUT_WILDCARD_EXPANSION,
        input_wildcard_expansion,
    );

    let options = FunctionOptions {
        cast_options: cast_to_supertypes,
        flags,
        ..Default::default()
    };

    Ok(Expr::Function {
        input: args,
        function: FunctionExpr::FfiPlugin {
            flags: options,
            lib: plugin_path.into(),
            symbol: function_name.into(),
            kwargs: kwargs.into(),
        },
    }
    .into())
}

// Encode a named R list as pickle bytes, the payload format that the standard
// Polars plugin toolchain (serde-pickle in pyo3-polars) expects. The R wrapper
// validates the input (named scalars/raw/nested lists, no NA), so this is a
// near-total Sexp -> Value conversion. Exposed to R via `pl$register_plugin_function()`.
#[savvy]
pub fn pickle_kwargs(kwargs: ListSexp) -> Result<Sexp> {
    let value = list_to_value(kwargs)?;
    let bytes = value_to_vec(&value, SerOptions::new())
        .map_err(|err| savvy_err!("failed to encode kwargs as pickle: {}", err))?;
    bytes.try_into()
}

fn sexp_to_value(x: Sexp) -> Result<Value> {
    Ok(match x.into_typed() {
        TypedSexp::Null(_) => Value::None,
        TypedSexp::Logical(l) => Value::Bool(l.as_slice_raw()[0] == 1),
        TypedSexp::Integer(i) => Value::I64(i.as_slice()[0] as i64),
        TypedSexp::Real(r) => Value::F64(r.as_slice()[0]),
        TypedSexp::String(s) => Value::String(
            s.iter()
                .next()
                .ok_or(savvy_err!("empty string in kwargs"))?
                .to_string(),
        ),
        TypedSexp::Raw(b) => Value::Bytes(b.as_slice().to_vec()),
        TypedSexp::List(list) => list_to_value(list)?,
        _ => return Err(savvy_err!("unsupported value type in kwargs")),
    })
}

// A fully named list becomes a dict; a fully unnamed list becomes a list. The R
// wrapper rejects partially named lists before this is reached.
fn list_to_value(list: ListSexp) -> Result<Value> {
    let items: Vec<(&str, Sexp)> = list.iter().collect();
    let any_named = items.iter().any(|(name, _)| !name.is_empty());
    if any_named {
        let mut dict = BTreeMap::new();
        for (name, value) in items {
            dict.insert(HashableValue::String(name.to_string()), sexp_to_value(value)?);
        }
        Ok(Value::Dict(dict))
    } else {
        let mut values = Vec::with_capacity(items.len());
        for (_, value) in items {
            values.push(sexp_to_value(value)?);
        }
        Ok(Value::List(values))
    }
}
