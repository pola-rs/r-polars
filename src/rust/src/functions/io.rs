use crate::{
    error::RPolarsErr,
    prelude::{CloudScheme, cloud::CloudOptions},
};
use polars::prelude::cloud::CloudRetryConfig;

pub fn parse_cloud_options(
    cloud_scheme: Option<CloudScheme>,
    storage_options: Option<Vec<(String, String)>>,
    retries: usize,
) -> Result<Option<CloudOptions>, RPolarsErr> {
    let result: Option<CloudOptions> = {
        use crate::prelude::parse_cloud_options;

        let cloud_options = parse_cloud_options(cloud_scheme, storage_options.unwrap_or_default())?;

        let retry_config = CloudRetryConfig {
            max_retries: Some(retries),
            ..Default::default()
        };
        Some(cloud_options.with_retry_config(retry_config))
    };
    Ok(result)
}
