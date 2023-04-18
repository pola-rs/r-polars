# replace private class-methods with public

```r
replace_private_with_pub_methods(
  env,
  class_pattern,
  keep = c(),
  remove_f = FALSE
)
```

## Arguments

- `env`: class envrionment to modify. Envs are mutable so no return needed
- `class_pattern`: a regex string matching declared public functions of that class
- `keep`: list of unmentioned methods to keep in public api
- `remove_f`: bool if true, will move methods, not copy

## Returns

side effects only

extendr places the naked internal calls to rust in env-classes. This function can be used to delete them and replaces them with the public methods. Which are any function matching pattern typically '^CLASSNAME' e.g. '^DataFrame_' or '^Series_'. Likely only used in zzz.R