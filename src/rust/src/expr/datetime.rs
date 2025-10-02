use crate::{PlRExpr, prelude::*};
use savvy::{LogicalSexp, NumericSexp, Result, savvy};

#[savvy]
impl PlRExpr {
    fn dt_convert_time_zone(&self, time_zone: &str) -> Result<Self> {
        let time_zone = <Wrap<Option<TimeZone>>>::try_from(time_zone)?
            .0
            .unwrap_or(TimeZone::UTC);
        Ok(self.inner.clone().dt().convert_time_zone(time_zone).into())
    }

    fn dt_replace_time_zone(
        &self,
        ambiguous: &PlRExpr,
        non_existent: &str,
        time_zone: Option<&str>,
    ) -> Result<Self> {
        let time_zone = <Wrap<Option<TimeZone>>>::try_from(time_zone)?.0;
        Ok(self
            .inner
            .clone()
            .dt()
            .replace_time_zone(
                time_zone,
                ambiguous.inner.clone(),
                <Wrap<NonExistent>>::try_from(non_existent)?.0,
            )
            .into())
    }

    fn dt_truncate(&self, every: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().dt().truncate(every.inner.clone()).into())
    }

    fn dt_round(&self, every: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().dt().round(every.inner.clone()).into())
    }

    fn dt_time(&self) -> Result<Self> {
        Ok(self.inner.clone().dt().time().into())
    }

    fn dt_date(&self) -> Result<Self> {
        Ok(self.inner.clone().dt().date().into())
    }

    fn dt_combine(&self, time: &PlRExpr, time_unit: &str) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .dt()
            .combine(time.inner.clone(), <Wrap<TimeUnit>>::try_from(time_unit)?.0)
            .into())
    }

    fn dt_to_string(&self, format: &str) -> Result<Self> {
        Ok(self.inner.clone().dt().to_string(format).into())
    }
    fn dt_millennium(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().millennium().into())
    }
    fn dt_year(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().year().into())
    }
    fn dt_iso_year(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().iso_year().into())
    }
    fn dt_quarter(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().quarter().into())
    }
    fn dt_month(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().month().into())
    }
    fn dt_week(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().week().into())
    }
    fn dt_weekday(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().weekday().into())
    }
    fn dt_day(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().day().into())
    }
    fn dt_ordinal_day(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().ordinal_day().into())
    }
    fn dt_hour(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().hour().into())
    }
    fn dt_minute(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().minute().into())
    }
    fn dt_second(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().second().into())
    }
    fn dt_millisecond(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().millisecond().into())
    }
    fn dt_microsecond(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().microsecond().into())
    }
    fn dt_nanosecond(&self) -> Result<Self> {
        Ok(self.clone().inner.dt().nanosecond().into())
    }

    fn dt_timestamp(&self, time_unit: &str) -> Result<Self> {
        Ok(self
            .clone()
            .inner
            .dt()
            .timestamp(<Wrap<TimeUnit>>::try_from(time_unit)?.0)
            .into())
    }

    fn dt_epoch_seconds(&self) -> Result<Self> {
        Ok(self
            .clone()
            .inner
            .map(
                |s| {
                    s.take_materialized_series()
                        .timestamp(TimeUnit::Milliseconds)
                        .map(|ca| (ca / 1000).into_column())
                },
                |_, f| Ok(Field::new(f.name().clone(), DataType::Int64)),
            )
            .into())
    }

    fn dt_with_time_unit(&self, time_unit: &str) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .dt()
            .with_time_unit(<Wrap<TimeUnit>>::try_from(time_unit)?.0)
            .into())
    }

    fn dt_cast_time_unit(&self, time_unit: &str) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .dt()
            .cast_time_unit(<Wrap<TimeUnit>>::try_from(time_unit)?.0)
            .into())
    }

    fn dt_total_days(&self, fractional: bool) -> Result<Self> {
        Ok(self.inner.clone().dt().total_days(fractional).into())
    }
    fn dt_total_hours(&self, fractional: bool) -> Result<Self> {
        Ok(self.inner.clone().dt().total_hours(fractional).into())
    }
    fn dt_total_minutes(&self, fractional: bool) -> Result<Self> {
        Ok(self.inner.clone().dt().total_minutes(fractional).into())
    }
    fn dt_total_seconds(&self, fractional: bool) -> Result<Self> {
        Ok(self.inner.clone().dt().total_seconds(fractional).into())
    }
    fn dt_total_milliseconds(&self, fractional: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .dt()
            .total_milliseconds(fractional)
            .into())
    }
    fn dt_total_microseconds(&self, fractional: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .dt()
            .total_microseconds(fractional)
            .into())
    }
    fn dt_total_nanoseconds(&self, fractional: bool) -> Result<Self> {
        Ok(self.inner.clone().dt().total_nanoseconds(fractional).into())
    }

    fn dt_offset_by(&self, by: &PlRExpr) -> Result<Self> {
        Ok(self.inner.clone().dt().offset_by(by.inner.clone()).into())
    }

    fn dt_is_leap_year(&self) -> Result<Self> {
        Ok(self.inner.clone().dt().is_leap_year().into())
    }

    fn dt_dst_offset(&self) -> Result<Self> {
        Ok(self.inner.clone().dt().dst_offset().into())
    }

    fn dt_base_utc_offset(&self) -> Result<Self> {
        Ok(self.inner.clone().dt().base_utc_offset().into())
    }

    fn dt_month_start(&self) -> Result<Self> {
        Ok(self.inner.clone().dt().month_start().into())
    }

    fn dt_month_end(&self) -> Result<Self> {
        Ok(self.inner.clone().dt().month_end().into())
    }

    fn dt_century(&self) -> Result<Self> {
        Ok(self.inner.clone().dt().century().into())
    }

    fn dt_add_business_days(
        &self,
        n: &PlRExpr,
        week_mask: LogicalSexp,
        holidays: NumericSexp,
        roll: &str,
    ) -> Result<Self> {
        let week_mask: [bool; 7] = week_mask
            .to_vec()
            .try_into()
            .map_err(|_| savvy::Error::new("invalid week_mask"))?;
        let holidays = base_date::DateProxy::from(holidays).0;
        let roll = <Wrap<Roll>>::try_from(roll)?.0;
        Ok(self
            .inner
            .clone()
            .dt()
            .add_business_days(n.inner.clone(), week_mask, holidays, roll)
            .into())
    }

    fn dt_replace(
        &self,
        year: &PlRExpr,
        month: &PlRExpr,
        day: &PlRExpr,
        hour: &PlRExpr,
        minute: &PlRExpr,
        second: &PlRExpr,
        microsecond: &PlRExpr,
        ambiguous: &PlRExpr,
    ) -> Result<PlRExpr> {
        Ok(self
            .inner
            .clone()
            .dt()
            .replace(
                year.inner.clone(),
                month.inner.clone(),
                day.inner.clone(),
                hour.inner.clone(),
                minute.inner.clone(),
                second.inner.clone(),
                microsecond.inner.clone(),
                ambiguous.inner.clone(),
            )
            .into())
    }
}
