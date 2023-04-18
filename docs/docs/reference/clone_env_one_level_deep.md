# Clone env on level deep.

```r
clone_env_one_level_deep(env)
```

## Arguments

- `env`: an R environment.

## Returns

shallow clone of R environment

Clone env on level deep.

## Details

Sometimes used in polars to produce different hashmaps(environments) containing some of the same, but not all elements.

environments are used for collections of methods and types. This function can be used to make a parallel collection pointing to some of the same types. Simply copying an environment, does apparently not spawn a new hashmap, and therefore the collections stay identical.

## Examples

```r
fruit_env = new.env(parent = emptyenv())
fruit_env$banana = TRUE
fruit_env$apple = FALSE

env_1 = new.env(parent = emptyenv())
env_1$fruit_env = fruit_env

env_naive_copy = env_1
env_shallow_clone = polars:::clone_env_one_level_deep(env_1)

#modifying env_!
env_1$minerals = new.env(parent = emptyenv())
env_1$fruit_env$apple = 42L

#naive copy is fully identical to env_1, so copying it not much useful
ls(env_naive_copy)
#shallow copy env does not have minerals
ls(env_shallow_clone)

#however shallow clone does subscribe to changes to fruits as they were there
# at time of cloning
env_shallow_clone$fruit_env$apple
```