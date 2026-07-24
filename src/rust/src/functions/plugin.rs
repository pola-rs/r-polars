use crate::{PlRExpr, prelude::*};
use polars_plan::prelude::{CastingRules, FunctionExpr, FunctionFlags, FunctionOptions};
use savvy::{ListSexp, RawSexp, Result, savvy};

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
