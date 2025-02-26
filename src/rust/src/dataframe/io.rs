use crate::{prelude::*, PlRDataFrame, RPolarsErr};
use polars::io::RowIndex;
use savvy::{savvy, NumericScalar, NumericSexp, Result, StringSexp};
use std::path::PathBuf;

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
        let row_index_offset = <Wrap<u32>>::try_from(row_index_offset)?.0;
        let columns: Option<Vec<String>> = columns.map(|x| x.iter().map(|x| x.into()).collect());
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

    #[cfg(not(target_arch = "wasm32"))]
    pub fn write_parquet(
        &mut self,
        path: &str,
        compression: &str,
        retries: NumericScalar,
        partition_chunk_size_bytes: NumericScalar,
        stat_min: bool,
        stat_max: bool,
        stat_distinct_count: bool,
        stat_null_count: bool,
        compression_level: Option<NumericScalar>,
        row_group_size: Option<NumericScalar>,
        data_page_size: Option<NumericScalar>,
        partition_by: Option<StringSexp>,
        storage_options: Option<StringSexp>,
    ) -> Result<()> {
        let path: PathBuf = path.into();
        let statistics = StatisticsOptions {
            min_value: stat_min,
            max_value: stat_max,
            null_count: stat_null_count,
            distinct_count: stat_distinct_count,
        };
        let compression_level: Option<i32> = match compression_level {
            Some(x) => Some(x.as_i32()?),
            None => None,
        };
        let compression = parse_parquet_compression(compression, compression_level)?;
        let row_group_size: Option<usize> = match row_group_size {
            Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
            None => None,
        };
        let data_page_size: Option<usize> = match data_page_size {
            Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
            None => None,
        };
        let retries = <Wrap<usize>>::try_from(retries)?.0;
        let partition_chunk_size_bytes = <Wrap<usize>>::try_from(partition_chunk_size_bytes)?.0;
        let cloud_options = match storage_options {
            Some(x) => {
                let out = <Wrap<Vec<(String, String)>>>::try_from(x).map_err(|_| {
                    RPolarsErr::Other(
                        "`storage_options` must be a named character vector".to_string(),
                    )
                })?;
                Some(out.0)
            }
            None => None,
        };
        let cloud_options = {
            let cloud_options =
                parse_cloud_options(path.to_str().unwrap(), cloud_options.unwrap_or_default())?;
            Some(cloud_options.with_max_retries(retries))
        };

        let partition_by = partition_by.map(|x| x.to_vec());

        if let Some(partition_by) = partition_by {
            let write_options = ParquetWriteOptions {
                compression,
                statistics,
                row_group_size,
                data_page_size,
                maintain_order: true,
            };
            let out = write_partitioned_dataset(
                &mut self.df,
                std::path::Path::new(&path),
                partition_by.into_iter().map(|x| x.into()).collect(),
                &write_options,
                cloud_options.as_ref(),
                partition_chunk_size_bytes,
            )
            .map_err(RPolarsErr::from)?;
            return Ok(out.into());
        };
        let f = std::fs::File::create(path).map_err(RPolarsErr::from)?;

        let out = ParquetWriter::new(f)
            .with_compression(compression)
            .with_statistics(statistics)
            .with_row_group_size(row_group_size)
            .with_data_page_size(data_page_size)
            .finish(&mut self.df)
            .map(|_| ())
            .map_err(RPolarsErr::from)?;

        Ok(out.into())
    }
}
