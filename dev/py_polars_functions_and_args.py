import polars as pl
import inspect
import polars.selectors as cs

families = ["LazyFrame", "DataFrame"]

dicts = {}


# family = "struct"
# function = "field"
# fam = getattr(pl.col("x"), family)
# args = getattr(fam, function)
# # vkw = inspect.getfullargspec(args).varkw
# # if vkw is not None and isinstance(vkw, str):
# #     vkw = "..."
# args2 = (
#     inspect.getfullargspec(args).args
#     + [inspect.getfullargspec(args).varargs]
#     + [inspect.getfullargspec(args).varkw]
#     + inspect.getfullargspec(args).kwonlyargs
# )
# out = [x for x in args2 if x is not None]
# out = [x for x in out if not x.startswith("_") and not x.startswith("more_") and x != "self"]



def get_args(family, function):
    if family in ["arr", "cat", "dt", "list", "meta", "name", "str", "struct"]:
        fam = getattr(pl.col("x"), family)
        args = getattr(fam, function)
    elif family is not None:
        fam = getattr(pl, family)
        args = getattr(fam, function)
    else:
        args = getattr(pl.col("x"), function)

    
    args2 = (
        inspect.getfullargspec(args).args
        + [inspect.getfullargspec(args).varargs]
        + [inspect.getfullargspec(args).varkw]
        + inspect.getfullargspec(args).kwonlyargs
    )
    out = [x for x in args2 if x is not None]
    out = [x for x in out if not x.startswith("_") and x != "self"]
    out = ["..." if x.startswith("more_") or x in ["constraints", "kwargs"] or x.startswith("named_") else x for x in out]
    return [out]

# LazyFrame, DataFrame
for family in families:
    fns = dir(getattr(pl, family))
    fns = [x for x in fns if not x.startswith("_")]
    for function in fns:
        try:
            dicts[family + "_" + function] = get_args(family=family, function=function)
        except:
            print(f"function {function} has no args")

# Expr
fns = dir(pl.col("x"))
fns = [x for x in fns if not x.startswith("_") and not x in ["arr", "cat", "dt", "list", "meta", "name", "str", "struct"]]
for function in fns:
    try:
        dicts["Expr_" + function] = get_args(family=None, function=function)
    except:
        print(f"function {function} has no args")

# Expr subns
for subns in ["arr", "cat", "dt", "list", "meta", "name", "str", "struct"]:
    fns = dir(getattr(pl.col("x"), subns))
    fns = [x for x in fns if not x.startswith("_")]
    for function in fns:
        try:
            dicts["Expr_" + subns + "_" + function] = get_args(family=subns, function=function)
        except:
            print(f"function {function} has no args")



pl.from_dict(dicts).unpivot(cs.all()).explode("value").filter(
    pl.col("value") != "args"
).rename({"variable": "fun", "value": "args"}).write_csv(
    "py_polars_functions_and_args.csv"
)
