# library(rpolars)
# DATASET_BASE_DIR = "../tpch/tables_scale_1/"
#
#
# get_line_item_ds = function(base_dir = DATASET_BASE_DIR) {
#   polars:::scan_parquet(paste0(base_dir,"lineitem.parquet"))
# }
# get_customer_ds = function(base_dir = DATASET_BASE_DIR) {
#   polars:::scan_parquet(paste0(base_dir,"customer.parquet"))
# }
# get_orders_ds = function(base_dir = DATASET_BASE_DIR) {
#   polars:::scan_parquet(paste0(base_dir,"orders.parquet"))
# }
#
#
#
#
# #todo imlpement datetime, join, limit, with_column, keep_name
#
# #VAR1 = datetime(1998, 9, 2)
#
#
# #var1 = var2 = datetime(1995, 3, 15)
# var3 = "BUILDING"
#
# orders_ds = get_orders_ds()
# customer_ds = get_customer_ds()
# line_item_ds = get_line_item_ds()
#
#
# q_final = (
#   customer_ds$filter(pl$col("c_mktsegment") == var3)$filter(pl$col("c_custkey")==127588L)
#   $join(orders_ds, left_on="c_custkey", right_on="o_custkey")
#   $join(line_item_ds, left_on="o_orderkey", right_on="l_orderkey")
#   #$filter(pl.col("o_orderdate") < var2)
# )
# q_final
#
# q_final$describe_optimized_plan()
# system.time({df = q_final$collect()})
#
#
#
#
# df
# df$as_data_frame()
#
#
#   .filter(pl.col("l_shipdate") > var1)
#   .with_column(
#     (pl.col("l_extendedprice") * (1 - pl.col("l_discount"))).alias("revenue")
#   )
#   .groupby(["o_orderkey", "o_orderdate", "o_shippriority"])
#   .agg([pl.sum("revenue")])
#   .select(
#     [
#       pl.col("o_orderkey").alias("l_orderkey"),
#       "revenue",
#       "o_orderdate",
#       "o_shippriority",
#     ]
#   )
#   .sort(by=["revenue", "o_orderdate"], reverse=[True, False])
#   .limit(10)
# )
#
#
# pl$DataFrame(iris)$select(
#   pl$col("Sepal.Length")$map(\(x) {print(1);Sys.sleep(1);x})$alias("a"),
#   pl$col("Sepal.Length")$map(\(x) {print(2);Sys.sleep(1);x})$alias("b"),
#   pl$col("Sepal.Length")$map(\(x) {print(3);Sys.sleep(1);x})$alias("x")
# )
