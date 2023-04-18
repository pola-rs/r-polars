data

# internal keeping of state at runtime

## Format

An object of class `environment` of length 0.

```r
runtime_state
```

This environment is used internally for the package to remember what has been going on. Currently only used to throw one-time warnings()