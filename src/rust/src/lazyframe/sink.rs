use crate::prelude::{sync_on_close::SyncOnCloseType, *};
use savvy::Result;

impl TryFrom<&str> for Wrap<SyncOnCloseType> {
    type Error = savvy::Error;

    fn try_from(value: &str) -> Result<Self> {
        let parsed = match value {
            "none" => SyncOnCloseType::None,
            "data" => SyncOnCloseType::Data,
            "all" => SyncOnCloseType::All,
            _ => return Err("unreachable".to_string().into()),
        };
        Ok(Wrap(parsed))
    }
}
