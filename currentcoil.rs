use std::f64;

// Using the SI units, so Amperes for I
const MU_ZERO: f64 = 1.25663706212e-6;
const PI: f64 = std::f64::consts::PI;
const I: f64 = 10000.0; 
const A: f64 = 0.4; // Radius of the loop of current

const X: f64 = 0.0;
const Y: f64 = 0.0;
const Z: f64 = 0.0;
const BREAK_NUMBER: u32 = 500;
const AXIS: char = 'z';
// The following is just the number of points we calculate the field at
// If N dims, it's N times. 
// NUMBER_OF_POINTS_PER_DIMENSION should be a multiple of 4 for shifting
const NUMBER_OF_POINTS_PER_DIMENSION: u32 = 2000;
const STEP: f64 = 0.01;


fn main() {
    let zstart = -2.0*A;
    let xstart = -2.0*A;
    let xend = 2.0*A;
    let zend = 2.0*A;
    
    let xsize = (xend - xstart)/NUMBER_OF_POINTS_PER_DIMENSION as f64;
    let zsize = (zend - zstart)/NUMBER_OF_POINTS_PER_DIMENSION as f64 ;

    println!("X, Z, BZ_VALUE");

    for px in 0..NUMBER_OF_POINTS_PER_DIMENSION {
        for pz in 0..NUMBER_OF_POINTS_PER_DIMENSION {
            
            let xcoord = xstart + px as f64 *xsize;
            let zcoord = zstart + pz as f64 *zsize;

            let field = integrate(xcoord,Y,zcoord,BREAK_NUMBER,AXIS);

            println!("{},{},{}",xcoord,zcoord, field);
        }         
    }
}


    // let step = (zend-zstart)/f64::from(BREAK_NUMBER);

    /*
    let mut z = zstart;

    while z < zend {
        let mut x = xstart;
        while x < xend {
            let field = integrate(x,Y,z,BREAK_NUMBER,AXIS);
            println!("{},{},{}",x,z, field);
            x+=STEP;
        }
        z+=STEP;
        println!("{}",z);
    }
}
    */


fn get_value_at_point() { 
    let field = integrate(X,Y,Z,BREAK_NUMBER,AXIS);
    println!("Value : {field}");
}


fn show_integral_getting_refined() {
    println!("Break_number, integral_value");
    for break_number in 100..100000 {
        let field = integrate(X,Y,Z,break_number, AXIS);
        println!("{break_number},{field}");
    }
}

fn dbx(x:f64,y:f64,z:f64, theta:f64) -> f64 {
    let num = MU_ZERO*I;
    let denom = (x - A*theta.cos()).powi(2)+(y - A*theta.sin()).powi(2)+z.powi(2);
    
    return num/(4.0*PI*((denom).powf(1.5)))

}

fn dby(x:f64,y:f64,z:f64, theta:f64) -> f64 {
    return dbx(x,y,z,theta) // it is the same
}

fn dbz(x:f64,y:f64,z:f64, theta:f64) -> f64 {
    let num = MU_ZERO*I*(A.powi(2)-A*(y*theta.sin()+x*theta.cos()));
    let denom = ((x - A*theta.cos()).powi(2)+(y - A*theta.sin()).powi(2)+z.powi(2)).powf(1.5);

    return num/(4.0*PI*denom)
}


fn integrate(x: f64, y: f64, z: f64, break_number: u32, axis: char) -> f64 {
    let result = match axis {
        'x' => integrate_axis(dbx, x, y, z, break_number),
        'y' => integrate_axis(dby, x, y, z, break_number),
        'z' => integrate_axis(dbz, x, y, z, break_number),
        _ => panic!("Invalid axis"),
    };

    result
}

fn integrate_axis<F>(axis_func: F, x: f64, y: f64, z: f64, break_number: u32) -> f64
where
    F: Fn(f64, f64, f64, f64) -> f64,
{
    let interval_size = 2.0*PI;
    let break_size = interval_size / f64::from(break_number);

    let sum = (0..break_number)
        .map(|k| {
            let point_of_eval = break_size * (f64::from(k)*0.5);
             axis_func(x, y, z, point_of_eval) * break_size
        })
        .sum();

    sum
}


fn main2<F>() {
    let result = integrate(1.0, 2.0, 3.0, 100, 'x');
    println!("Result: {}", result);
}


