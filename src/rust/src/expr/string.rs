use crate::{prelude::*, PlRExpr, RPolarsErr};
use savvy::{savvy, NumericScalar, Result};

#[savvy]
impl PlRExpr {
    fn str_len_bytes(&self) -> Result<Self> {
        Ok(self.inner.clone().str().len_bytes().into())
    }

    fn str_len_chars(&self) -> Result<Self> {
        Ok(self.inner.clone().str().len_chars().into())
    }

    fn str_join(&self, delimiter: &str, ignore_nulls: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .join(delimiter, ignore_nulls)
            .into())
    }

    fn str_to_uppercase(&self) -> Result<Self> {
        Ok(self.inner.clone().str().to_uppercase().into())
    }

    fn str_to_lowercase(&self) -> Result<Self> {
        Ok(self.inner.clone().str().to_lowercase().into())
    }

    // fn str_to_titlecase(&self) -> Result<Self> {
    //     f_str_to_titlecase(self)
    // }

    fn str_strip_chars(&self, characters: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .strip_chars(characters.inner.clone())
            .into())
    }

    fn str_strip_chars_end(&self, characters: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .strip_chars_end(characters.inner.clone())
            .into())
    }

    fn str_strip_chars_start(&self, characters: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .strip_chars_start(characters.inner.clone())
            .into())
    }

    fn str_strip_prefix(&self, prefix: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .strip_prefix(prefix.inner.clone())
            .into())
    }

    fn str_strip_suffix(&self, suffix: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .strip_suffix(suffix.inner.clone())
            .into())
    }

    fn str_zfill(&self, length: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().str().zfill(length.inner.clone()).into())
    }

    fn str_pad_end(&self, length: NumericScalar, fill_char: &str) -> Result<Self> {
        let length = <Wrap<usize>>::try_from(length)?.0;
        let fill_char = <Wrap<char>>::try_from(fill_char)?.0;
        Ok(self.inner.clone().str().pad_end(length, fill_char).into())
    }

    fn str_pad_start(&self, length: NumericScalar, fill_char: &str) -> Result<Self> {
        let length = <Wrap<usize>>::try_from(length)?.0;
        let fill_char = <Wrap<char>>::try_from(fill_char)?.0;
        Ok(self.inner.clone().str().pad_start(length, fill_char).into())
    }

    fn str_to_decimal(&self, infer_len: NumericScalar) -> Result<Self> {
        let infer_len = <Wrap<usize>>::try_from(infer_len)?.0;
        Ok(self.inner.clone().str().to_decimal(infer_len).into())
    }

    fn str_contains(&self, pat: &PlRExpr, literal: bool, strict: bool) -> Result<Self> {
        if literal {
            Ok(self
                .inner
                .clone()
                .str()
                .contains_literal(pat.inner.clone())
                .into())
        } else {
            Ok(self
                .inner
                .clone()
                .str()
                .contains(pat.inner.clone(), strict)
                .into())
        }
    }

    fn str_ends_with(&self, suffix: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .ends_with(suffix.inner.clone())
            .into())
    }

    fn str_starts_with(&self, prefix: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .starts_with(prefix.inner.clone())
            .into())
    }

    #[allow(unused_variables)]
    fn str_json_path_match(&self, pat: &PlRExpr) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            Ok(self
                .inner
                .clone()
                .str()
                .json_path_match(pat.inner.clone())
                .into())
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }

    // fn str_json_decode(&self, dtype: &PlRExpr, infer_schema_len: &PlRExpr) -> Result<Self> {
    //     let dtype = robj_to!(Option, RPolarsDataType, dtype)?.map(|dty| dty.0);
    //     let infer_schema_len = robj_to!(Option, usize, infer_schema_len)?;
    //     Ok(self
    //         .inner
    //         .clone()
    //         .str()
    //         .json_decode(dtype, infer_schema_len)
    //         .into())
    // }

    fn str_hex_encode(&self) -> Result<Self> {
        Ok(self.inner.clone().str().hex_encode().into())
    }

    fn str_hex_decode(&self, strict: bool) -> Result<Self> {
        Ok(self.inner.clone().str().hex_decode(strict).into())
    }

    fn str_base64_encode(&self) -> Result<Self> {
        Ok(self.inner.clone().str().base64_encode().into())
    }

    fn str_base64_decode(&self, strict: bool) -> Result<Self> {
        Ok(self.inner.clone().str().base64_decode(strict).into())
    }

    fn str_extract(&self, pattern: &PlRExpr, group_index: NumericScalar) -> Result<Self> {
        let group_index = <Wrap<usize>>::try_from(group_index)?.0;
        Ok(self
            .inner
            .clone()
            .str()
            .extract(pattern.inner.clone(), group_index)
            .into())
    }

    fn str_extract_all(&self, pattern: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .extract_all(pattern.inner.clone())
            .into())
    }

    fn str_extract_groups(&self, pattern: &str) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .extract_groups(pattern)
            .map_err(RPolarsErr::from)?
            .into())
    }

    fn str_count_matches(&self, pat: &PlRExpr, literal: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .count_matches(pat.inner.clone(), literal)
            .into())
    }

    fn str_to_date(
        &self,
        strict: bool,
        exact: bool,
        cache: bool,
        format: Option<&str>,
    ) -> Result<Self> {
        let format = format.map(|x| x.into());
        Ok(self
            .inner
            .clone()
            .str()
            .to_date(StrptimeOptions {
                format,
                strict,
                exact,
                cache,
            })
            .into())
    }

    #[allow(clippy::too_many_arguments)]
    fn str_to_datetime(
        &self,
        strict: bool,
        exact: bool,
        cache: bool,
        ambiguous: &PlRExpr,
        format: Option<&str>,
        time_unit: Option<&str>,
        time_zone: Option<&str>,
    ) -> Result<Self> {
        let format: Option<PlSmallStr> = format.map(|x| x.into());
        let time_unit: Option<TimeUnit> = match time_unit {
            Some(x) => Some(<Wrap<TimeUnit>>::try_from(x)?.0),
            None => None,
        };
        let time_zone: Option<PlSmallStr> = time_zone.map(|x| x.into());

        Ok(self
            .inner
            .clone()
            .str()
            .to_datetime(
                time_unit,
                time_zone,
                StrptimeOptions {
                    format,
                    strict,
                    exact,
                    cache,
                },
                ambiguous.inner.clone(),
            )
            .into())
    }

    fn str_to_time(&self, strict: bool, cache: bool, format: Option<&str>) -> Result<Self> {
        let format = format.map(|x| x.into());

        Ok(self
            .inner
            .clone()
            .str()
            .to_time(StrptimeOptions {
                format,
                strict,
                cache,
                exact: true,
            })
            .into())
    }

    fn str_split(&self, by: &PlRExpr, inclusive: bool) -> Result<Self> {
        if inclusive {
            Ok(self
                .inner
                .clone()
                .str()
                .split_inclusive(by.inner.clone())
                .into())
        } else {
            Ok(self.inner.clone().str().split(by.inner.clone()).into())
        }
    }

    fn str_split_exact(&self, by: &PlRExpr, n: NumericScalar, inclusive: bool) -> Result<Self> {
        let n = <Wrap<usize>>::try_from(n)?.0;
        Ok(if inclusive {
            self.inner
                .clone()
                .str()
                .split_exact_inclusive(by.inner.clone(), n)
        } else {
            self.inner.clone().str().split_exact(by.inner.clone(), n)
        }
        .into())
    }

    fn str_splitn(&self, by: &PlRExpr, n: NumericScalar) -> Result<Self> {
        let n = <Wrap<usize>>::try_from(n)?.0;
        Ok(self.inner.clone().str().splitn(by.inner.clone(), n).into())
    }

    fn str_replace(
        &self,
        pat: &PlRExpr,
        value: &PlRExpr,
        literal: bool,
        n: NumericScalar,
    ) -> Result<Self> {
        let n = <Wrap<i64>>::try_from(n)?.0;
        Ok(self
            .inner
            .clone()
            .str()
            .replace_n(pat.inner.clone(), value.inner.clone(), literal, n)
            .into())
    }

    fn str_replace_all(&self, pat: &PlRExpr, value: &PlRExpr, literal: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .replace_all(pat.inner.clone(), value.inner.clone(), literal)
            .into())
    }

    fn str_slice(&self, offset: &PlRExpr, length: &PlRExpr) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .slice(offset.inner.clone(), length.inner.clone())
            .into())
    }

    fn str_to_integer(&self, base: &PlRExpr, strict: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .to_integer(base.inner.clone(), strict)
            .into())
    }

    fn str_reverse(&self) -> Result<Self> {
        Ok(self.inner.clone().str().reverse().into())
    }

    fn str_contains_any(&self, patterns: &PlRExpr, ascii_case_insensitive: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .contains_any(patterns.inner.clone(), ascii_case_insensitive)
            .into())
    }

    fn str_replace_many(
        &self,
        patterns: &PlRExpr,
        replace_with: &PlRExpr,
        ascii_case_insensitive: bool,
    ) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .replace_many(
                patterns.inner.clone(),
                replace_with.inner.clone(),
                ascii_case_insensitive,
            )
            .into())
    }

    fn str_extract_many(
        &self,
        patterns: &PlRExpr,
        ascii_case_insensitive: bool,
        overlapping: bool,
    ) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .str()
            .extract_many(patterns.inner.clone(), ascii_case_insensitive, overlapping)
            .into())
    }

    fn str_find(&self, pat: &PlRExpr, literal: bool, strict: bool) -> Result<Self> {
        if literal {
            Ok(self
                .inner
                .clone()
                .str()
                .find_literal(pat.inner.clone())
                .into())
        } else {
            Ok(self
                .inner
                .clone()
                .str()
                .find(pat.inner.clone(), strict)
                .into())
        }
    }

    fn str_head(&self, n: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().str().head(n.inner.clone()).into())
    }

    fn str_tail(&self, n: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().str().tail(n.inner.clone()).into())
    }
}
