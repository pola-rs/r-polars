use crate::{PlRDataFrame, RPolarsErr, prelude::*};
use polars::io::RowIndex;
use savvy::{NumericScalar, NumericSexp, Result, StringSexp, savvy};

#[savvy]
impl PlRDataFrame {
    pub fn read_ipc_stream(
        source: &str,
        row_index_offset: NumericScalar,
        rechunk: bool,
        columns: Option<StringSexp>,
        projection: Option<NumericSexp>,
        n_rows: Option<NumericScalar>,
        row_index_name: Option<&str>,
    ) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let row_index_offset = <Wrap<u32>>::try_from(row_index_offset)?.0;
            let columns: Option<Vec<String>> =
                columns.map(|x| x.iter().map(|x| x.into()).collect());
            let projection = projection
                .map(|x| <Wrap<Vec<usize>>>::try_from(x).map(|x| x.0))
                .transpose()?;
            let n_rows = n_rows
                .map(|x| <Wrap<usize>>::try_from(x).map(|x| x.0))
                .transpose()?;

            let row_index = row_index_name.map(|x| RowIndex {
                name: x.into(),
                offset: row_index_offset,
            });
            let file = std::fs::File::open(source).map_err(RPolarsErr::from)?;

            let df = IpcStreamReader::new(file)
                .with_projection(projection)
                .with_columns(columns)
                .with_n_rows(n_rows)
                .with_row_index(row_index)
                .set_rechunk(rechunk)
                .finish()
                .map_err(RPolarsErr::from)?;
            Ok(df.into())
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }

    pub fn write_json(&mut self, path: &str) -> Result<()> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let f = std::fs::File::create(path).map_err(RPolarsErr::from)?;

            JsonWriter::new(f)
                .with_json_format(JsonFormat::Json)
                .finish(&mut self.df)
                .map_err(RPolarsErr::from)?;
            Ok(())
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }
}
