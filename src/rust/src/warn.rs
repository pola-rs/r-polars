use parking_lot::Mutex;
use polars_error::PolarsWarning;
use savvy::{NullSexp, OwnedListSexp, OwnedStringSexp, Result, Sexp, savvy};

struct QueuedWarning {
    message: String,
    // Stable string representation of the PolarsWarning variant, used as an R condition class.
    category: &'static str,
}

static WARNING_QUEUE: Mutex<Vec<QueuedWarning>> = Mutex::new(Vec::new());

pub(crate) fn warning_function(msg: &str, variant: PolarsWarning) {
    let category = match variant {
        PolarsWarning::Deprecation => "polars_deprecation_warning",
        PolarsWarning::UserWarning => "polars_user_warning",
        PolarsWarning::CategoricalRemappingWarning => "polars_categorical_remapping_warning",
        PolarsWarning::MapWithoutReturnDtypeWarning => "polars_map_without_return_dtype_warning",
    };
    // Safe to call from any thread: only pushes to the queue, never calls R APIs.
    WARNING_QUEUE.lock().push(QueuedWarning {
        message: msg.to_string(),
        category,
    });
}

// Drain all pending Polars warnings.
// Returns NULL if no warnings are pending (fast path).
// Otherwise returns a named list with `message` and `category` character vectors.
// Must be called from the main R thread.
#[savvy]
fn drain_warnings() -> Result<Sexp> {
    let mut queue = WARNING_QUEUE.lock();
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
