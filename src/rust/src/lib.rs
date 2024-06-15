// Example functions

use savvy::savvy;

use savvy::{IntegerSexp, OwnedIntegerSexp, OwnedStringSexp, StringSexp};

use savvy::NotAvailableValue;

/// Convert Input To Upper-Case
///
/// @param x A character vector.
/// @returns A character vector with upper case version of the input.
/// @export
#[savvy]
fn to_upper(x: StringSexp) -> savvy::Result<savvy::Sexp> {
    let mut out = OwnedStringSexp::new(x.len())?;

    for (i, e) in x.iter().enumerate() {
        if e.is_na() {
            out.set_na(i)?;
            continue;
        }

        let e_upper = e.to_uppercase();
        out.set_elt(i, &e_upper)?;
    }

    Ok(out.into())
}

/// Multiply Input By Another Input
///
/// @param x An integer vector.
/// @param y An integer to multiply.
/// @returns An integer vector with values multiplied by `y`.
/// @export
#[savvy]
fn int_times_int(x: IntegerSexp, y: i32) -> savvy::Result<savvy::Sexp> {
    let mut out = OwnedIntegerSexp::new(x.len())?;

    for (i, e) in x.iter().enumerate() {
        if e.is_na() {
            out.set_na(i)?;
        } else {
            out[i] = e * y;
        }
    }

    Ok(out.into())
}

#[savvy]
struct Person {
    pub name: String,
}

/// A person with a name
///
/// @export
#[savvy]
impl Person {
    fn new() -> Self {
        Self {
            name: "".to_string(),
        }
    }

    fn set_name(&mut self, name: &str) -> savvy::Result<()> {
        self.name = name.to_string();
        Ok(())
    }

    fn name(&self) -> savvy::Result<savvy::Sexp> {
        let mut out = OwnedStringSexp::new(1)?;
        out.set_elt(0, &self.name)?;
        Ok(out.into())
    }

    fn associated_function() -> savvy::Result<savvy::Sexp> {
        let mut out = OwnedStringSexp::new(1)?;
        out.set_elt(0, "associated_function")?;
        Ok(out.into())
    }
}

// This test is run by `cargo test`. You can put tests that don't need a real
// R session here.
#[cfg(test)]
mod test1 {
    #[test]
    fn test_person() {
        let mut p = super::Person::new();
        p.set_name("foo").expect("set_name() must succeed");
        assert_eq!(&p.name, "foo");
    }
}

// Tests marked under `#[cfg(feature = "savvy-test")]` are run by `savvy-cli test`, which
// executes the Rust code on a real R session so that you can use R things for
// testing.
#[cfg(feature = "savvy-test")]
mod test1 {
    // The return type must be `savvy::Result<()>`
    #[test]
    fn test_to_upper() -> savvy::Result<()> {
        // You can create a non-owned version of input by `.as_read_only()`
        let x = savvy::OwnedStringSexp::try_from_slice(["foo", "bar"])?.as_read_only();

        let result = super::to_upper(x)?;

        // This function compares an SEXP with the result of R code specified in
        // the second argument.
        savvy::assert_eq_r_code(result, r#"c("FOO", "BAR")"#);

        Ok(())
    }
}
