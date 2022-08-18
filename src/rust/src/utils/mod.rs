pub mod wrappers;

#[macro_export]
macro_rules! apply {
    ($self:expr, $apply_method:ident, $ca_method:ident, $inp_type:ty, $out_type:ty, $rfun:expr,  $dc_method:ident) => {
        Rseries(
            $self
                .$ca_method()
                .unwrap()
                .$apply_method(|x: $inp_type| -> $out_type {
                    $rfun
                        .call(pairlist!(x = x))
                        .expect("rfun failed evaluation")
                        .$dc_method()
                        .expect("rfun failed to yield correct output type")
                })
                .into_series(),
        )
    };
}

#[macro_export]
macro_rules! apply_cn {
    ($self:expr, $ca_method_and_inp_type:ident, $series_type:ty, $out_type:ty, $rfun:expr,  $dc_method:ident) => {
        Rseries(
            $self
                .$ca_method_and_inp_type()
                .unwrap()
                .apply_cast_numeric::<_, $series_type>(|x: $ca_method_and_inp_type| -> $out_type {
                    $rfun
                        .call(pairlist!(x = x))
                        .expect("rfun failed evaluation")
                        .$dc_method()
                        .expect("rfun failed to yield correct output type")
                })
                .into_series(),
        )
    };
}
//const RFUN_FAILED_EVALUATION: &'static str = "rfun_FAILED_EVALUATION";
//const RFUN_FAILED_OUTPUT: &'static str = "rfun failed to yield correct output type";
use extendr_api::prelude::*;

#[macro_export]
macro_rules! make_r_na_fun {

    (f64 $rfun:expr) => {
        R!("function(f) {function() f(NA_real_)}")
            .unwrap()
            .as_function()
            .expect("failed to make function");
    };
    (f32 $rfun:expr) => {make_r_na_fun!(f64 $rfun)};

    (i32 $rfun:expr) => {
        R!("function(f) {function() f(NA_integer_)}")
            .unwrap()
            .as_function()
            .expect("failed to make function");
    };
    (i64 $rfun:expr) => {make_r_na_fun!(i32 $rfun)};
    (i16 $rfun:expr) => {make_r_na_fun!(i32 $rfun)};
    (i8 $rfun:expr) => {make_r_na_fun!(i32 $rfun)};
    (f32 $rfun:expr) => {make_r_na_fun!(f64 $rfun)};

    (utf8 $rfun:expr) => {
        R!("function(f) {function() f(NA_character_)}")
            .unwrap()
            .as_function()
            .expect("failed to make function");
    };
}

#[macro_export]
macro_rules! apply_opt_cast {
    ($self:expr, $ca_method_and_inp_type:ident, $out_chunk_type:ty , $out_type:ty, $rfun:expr,  $dc_method:ident) => {
        Rseries(
            $self
                .$ca_method_and_inp_type()
                .unwrap()
                .into_iter()
                .map(|opt| {
                    let x: $ca_method_and_inp_type =
                        opt.or_else(|| Some(0 as $ca_method_and_inp_type)).unwrap();
                    let out: $out_type = $rfun
                        .call(pairlist!(x = x))
                        .expect("rfun_FAILED_EVALUATION")
                        .$dc_method()
                        .expect("rfun failed to yield correct output type");
                    Some(out)
                })
                .collect::<$out_chunk_type>()
                .into_series(),
        )
    };

    //assumes const R_INT_NA_ENC in scope
    (integer_in_out, $self:expr, $rfun:expr) => {
        Rseries(
            $self
                .i32()
                .unwrap()
                .into_iter()
                .map(|opt| {
                    let y: i32 = opt.or_else(|| Some(R_INT_NA_ENC)).unwrap();
                    let robj = $rfun
                        .call(pairlist!(x = y))
                        .expect("R function failed evaluation");

                    let x = robj.as_integers().expect("only returning int allowed");
                    let val = x.iter().next().expect("zero length int not allowed").0;

                    if val == R_INT_NA_ENC {
                        None
                    } else {
                        Some(val)
                    }
                })
                .collect::<Int32Chunked>()
                .into_series(),
        )
    };

    (integer_in, $self:expr, $out_chunk_type:ty , $out_type:ty, $rfun:expr,  $dc_method:ident) => {
        Rseries(
            $self
                .i32()
                .unwrap()
                .into_iter()
                .map(|opt| {
                    let y: i32 = opt.or_else(|| Some(R_INT_NA_ENC)).unwrap();
                    let robj = $rfun
                        .call(pairlist!(x = y))
                        .expect("R function failed evaluation");

                    let x = robj
                        .$dc_method()
                        .expect("rfun failed to yield correct output type");

                    Some(x)
                })
                .collect::<$out_chunk_type>()
                .into_series(),
        )
    };

    (integer_out, $self:expr, $ca_method_and_inp_type:ident, $rfun:expr) => {{
        let rnafun = make_r_na_fun!($ca_method_and_inp_type rfun).call(pairlist!(f = $rfun.clone())).expect("failed eval wrap").as_function().expect("failed ret wrap");
        Rseries(
            $self
                .$ca_method_and_inp_type()
                .unwrap()
                .into_iter()
                .map(|opt| {
                    let val: i32 = opt.
                        map_or_else(
                            || {
                                //if NONE(missing) run lambda with corrosponding R NA type as input
                                rnafun
                                .call(pairlist!())
                                },
                            |x| {
                                //run lambda with value
                                $rfun
                                .call(pairlist!(x = x))

                            }
                        )
                        .map(|x| {rprintln!("{:?}",x.rtype());x})
                        .expect("R function failed evaluation")
                        .as_integer()
                        .expect("yep rfun failed to yield correct output type");

                        if val == R_INT_NA_ENC {
                            None
                        } else {
                            Some(val)
                        }
                })
                .collect::<Int32Chunked>()
                .into_series(),
        )
    }};
}

#[macro_export]
macro_rules! apply_input {
    ($self:expr, $ca_method_and_inp_type:ident, $rfun:expr, $na_fun:expr) => {
        {
            //wrap lambda in a function passing the corrosponding R NAtype if polars null
            //assumes mut na_fun: Function (extendr_api struct) is present invoked scope
            //needs to live there as match_arm life-time is too short for iterator
                $na_fun =
                    make_r_na_fun!($ca_method_and_inp_type rfun)
                    .call(pairlist!(f = $rfun.clone()))
                    .expect("failed eval wrap")
                    .as_function()
                    .expect("failed ret wrap");

            // produce iterator which yield returns from the lambda
                $self
                    .$ca_method_and_inp_type() //to chunkedarray(ca)
                    .unwrap()
                    .into_iter()
                    .map(|opt| {
                        let rval: Robj = opt.
                        map_or_else(
                            ||  $na_fun.call(pairlist!()),
                            |x| $rfun.call(pairlist!(x = x))
                        ).expect("fail r eval");
                        rval
                    })
        }
    };
}

#[macro_export]
macro_rules! apply_output {
    ($out_chunk_type:ident) => {
        {
            //wrap lambda in a function passing the corrosponding R NAtype if polars null
            //assumes mut na_fun: Function (extendr_api struct) is present invoked scope
            //needs to live there as match_arm life-time is too short for iterator
                $na_fun =
                    make_r_na_fun!($ca_method_and_inp_type rfun)
                    .call(pairlist!(f = $rfun.clone()))
                    .expect("failed eval wrap")
                    .as_function()
                    .expect("failed ret wrap");

            // produce iterator which yield returns from the lambda
                $self
                    .$ca_method_and_inp_type() //to chunkedarray(ca)
                    .unwrap()
                    .into_iter()
                    .map(|opt| {
                        let rval: Robj = opt.
                        map_or_else(
                            ||  $na_fun.call(pairlist!()),
                            |x| $rfun.call(pairlist!(x = x))
                        ).expect("fail r eval");
                        rval
                    })
        }
    };
}

#[macro_export]
macro_rules! Rseries_chain_methods {
    ($self:ident, ) => {};
    ($self:ident, $name:ident $($tail:tt)*) => {
        pub fn $name(&$self) -> Rseries {
            Rseries($self.0.clone().$name())
        }
        Rseries_chain_methods![$self, $($tail)*];
    };
}
