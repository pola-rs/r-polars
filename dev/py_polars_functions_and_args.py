import polars as pl
import inspect
import polars.selectors as cs

families = ["LazyFrame", "DataFrame"]

dicts = {}


# family = "DataFrame"
# function = "select"
# fam = getattr(pl, family)
# args = getattr(fam, function)
# vkw = inspect.getfullargspec(args).varkw
# if vkw is not None and isinstance(vkw, str):
#     vkw = "..."
# args2 = (
#     inspect.getfullargspec(args).args
#     + [inspect.getfullargspec(args).varargs]
#     + [vkw]
#     + inspect.getfullargspec(args).kwonlyargs
# )
# out = [x for x in args2 if x is not None]
# out = [x for x in out if not x.startswith("_") and x != "self"]


def get_args(family, function):
    fam = getattr(pl, family)
    args = getattr(fam, function)
    vkw = inspect.getfullargspec(args).varkw
    if vkw is not None and isinstance(vkw, str):
        vkw = "..."
    args2 = (
        inspect.getfullargspec(args).args
        + [inspect.getfullargspec(args).varargs]
        + [vkw]
        + inspect.getfullargspec(args).kwonlyargs
    )
    out = [x for x in args2 if x is not None]
    out = [x for x in out if not x.startswith("_") and x != "self"]
    return [out]


for family in families:
    fns = dir(getattr(pl, family))
    fns = [x for x in fns if not x.startswith("_")]
    for function in fns:
        try:
            dicts[family + "_" + function] = get_args(family=family, function=function)
        except:
            print(f"function {function} has no args")


pl.from_dict(dicts).unpivot(cs.all()).explode("value").filter(
    pl.col("value") != "args"
).rename({"variable": "fun", "value": "args"}).write_csv(
    "dev/py_polars_functions_and_args.csv"
)
