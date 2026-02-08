use crate::{
    error::RPolarsErr,
    prelude::{CloudScheme, cloud::CloudOptions},
};

pub fn parse_cloud_options(
    cloud_scheme: Option<CloudScheme>,
    storage_options: Option<Vec<(String, String)>>,
) -> Result<Option<CloudOptions>, RPolarsErr> {
    use crate::prelude::parse_cloud_options;

    let cloud_options = parse_cloud_options(cloud_scheme, storage_options.unwrap_or_default())?;
    Ok(Some(cloud_options))
}
