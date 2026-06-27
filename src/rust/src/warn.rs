use parking_lot::Mutex;
use polars_error::PolarsWarning;
use savvy::{NullSexp, OwnedListSexp, OwnedStringSexp, Result, Sexp, savvy, savvy_init};

struct QueuedWarning {
    message: String,
    // Stable string representation of the PolarsWarning variant,
    // used as an R condition class (e.g. "PolarsDeprecationWarning").
    category: &'static str,
}

static POLARS_WARNING_QUEUE: Mutex<Vec<QueuedWarning>> = Mutex::new(Vec::new());

fn polars_warning_function(msg: &str, variant: PolarsWarning) {
    let category = match variant {
        PolarsWarning::Deprecation => "PolarsDeprecationWarning",
        PolarsWarning::UserWarning => "PolarsUserWarning",
        PolarsWarning::CategoricalRemappingWarning => "PolarsCategoricalRemappingWarning",
        PolarsWarning::MapWithoutReturnDtypeWarning => "PolarsMapWithoutReturnDtypeWarning",
    };
    // Safe to call from any thread: only pushes to the queue, never calls R APIs.
    POLARS_WARNING_QUEUE.lock().push(QueuedWarning {
        message: msg.to_string(),
        category,
    });
}

#[savvy_init]
fn init_polars_warning_handler(_dll_info: *mut savvy::ffi::DllInfo) -> savvy::Result<()> {
    polars_error::set_warning_function(polars_warning_function);
    Ok(())
}

// Drain all pending Polars warnings.
// Returns NULL if no warnings are pending (fast path).
// Otherwise returns a named list with `message` and `category` character vectors.
// Must be called from the main R thread.
#[savvy]
fn polars_drain_warnings() -> Result<Sexp> {
    let mut queue = POLARS_WARNING_QUEUE.lock();
    if queue.is_empty() {
        return Ok(NullSexp.into());
    }
    let warnings: Vec<QueuedWarning> = std::mem::take(&mut *queue);
    drop(queue);

    let n = warnings.len();
    let mut messages = OwnedStringSexp::new(n)?;
    let mut categories = OwnedStringSexp::new(n)?;

    for (i, w) in warnings.into_iter().enumerate() {
        messages.set_elt(i, &w.message)?;
        categories.set_elt(i, w.category)?;
    }

    let mut result = OwnedListSexp::new(2, true)?;
    result.set_name_and_value(0, "message", messages)?;
    result.set_name_and_value(1, "category", categories)?;

    Ok(result.into())
}
