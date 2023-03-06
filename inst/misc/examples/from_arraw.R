library(nanoarrow)

library(arrow)
library(xptr)
at =  arrow::arrow_table(data.frame(a=c(1,2,3,4,5)))
a0 = at$column(0)
c0 = a0$chunk(0)

rpolars:::field_to_rust2(c0)

x = at$pointer()
.Internal(inspect(x))

arrow::write_ipc_stream(at, "mtcars.ipc_stream")


nanoarrow::nanoarrow_pointer_addr_chr(at$schema$field(0)$pointer())
nanoarrow::nanoarrow_pointer_addr_chr(at$schema$pointer())
ca = at$column(0)

nanoarrow::nanoarrow_pointer_addr_chr(ca$pointer())
rpolars:::field_to_rust2("140265116619072")

f = at$field(0)
f$export_to_c()


df = rpolars:::scan_ipc("mtcars.ipc_stream")
df
df$collect()
