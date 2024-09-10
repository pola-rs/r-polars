patrick::with_parameters_test_that(
  "data types print",
  .cases = {
    tibble::tribble(
      ~.test_name, ~object,
      "Int8", pl$Int8,
      "Int16", pl$Int16,
      "Int32", pl$Int32,
      "Int64", pl$Int64,
      "UInt8", pl$UInt8,
      "UInt16", pl$UInt16,
      "UInt32", pl$UInt32,
      "UInt64", pl$UInt64,
      "Float32", pl$Float32,
      "Float64", pl$Float64,
      "Boolean", pl$Boolean,
      "String", pl$String,
      "Binary", pl$Binary,
      "Date", pl$Date,
      "Time", pl$Time,
      "Null", pl$Null,
      "Decimal(NULL, 1)", pl$Decimal(NULL, 1),
      "Decimal(2, 1)", pl$Decimal(2, 3),
      "Datetime('ms', NULL)", pl$Datetime("ms", NULL),
      "Datetime('ns', 'UTC')", pl$Datetime("ns", "UTC"),
      "Duration('ms')", pl$Duration("ms"),
      "List(String)", pl$List(pl$String),
      "List(List(Datetime('ms', 'UTC')))", pl$List(pl$List(pl$Datetime("ms", "UTC"))),
      "Struct(a = Int32, b = String)", pl$Struct(a = pl$Int32, b = pl$String),
      "Struct(a = Struct(b = Int32), c = String)", pl$Struct(a = pl$Struct(b = pl$Int32), c = pl$String),
      "Categorical()", pl$Categorical(),
      "Enum(c('a', 'b', 'c'))", pl$Enum(c("a", "b", "c")),
    )
  },
  code = {
    expect_snapshot(print(object))
  }
)
