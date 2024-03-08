use std::f64;

// Using the SI units, so Amperes for I
const MU_ZERO: f64 = 1.25663706212e-6;
const PI: f64 = std::f64::consts::PI;
const I: f64 = 1.0; 
const A: f64 = 1.0; // Radius of the loop of current

fn main() {
    let small_field = dBx(4.0,7.0,12.0, PI/4.0 );
    println!("field = {small_field}");
}


fn dBx(x:f64,y:f64,z:f64, theta:f64) -> f64 {
    let num = MU_ZERO*I;
    let denom = 4.0*PI*(x - A*theta.cos()).powi(2)+(y - A*theta.sin())+z.powi(2);

    return num/(denom).powf(1.5)
}

fn dBy(x:f64,y:f64,z:f64, theta:f64) -> f64 {
    return dBx(x,y,z,theta) // it is the same
}

fn dBz(x:f64,y:f64,z:f64, theta:f64) -> f64 {
    let num = MU_ZERO*I*(a.powi(2)-a*(y*theta.sin()+x*theta.cos()));
    let denom = 4.0*PI*(x - A*theta.cos()).powi(2)+(y - A*theta.sin())+z.powi(2);

    return num/(denom).powf(1.5)
}

fn int_dB(x:f64,y:f64,z:f64, breaks=u32) -> f64 {
    //TODO: loop and 
}
