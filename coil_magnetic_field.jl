using CUDA
using Plots
using LinearAlgebra # For UpperTriangular

CUDA.allowscalar(false)

# Constants
const MU_ZERO = 1.25663706212e-6;
const CURRENT_I = 10000.0; 
const RADIUS = 0.4; #Radius of the loop of current
const BREAK_NUMBER = 125;
const AXIS = 'z';
const NUMBER_OF_POINTS_PER_DIMENSION = 2000;
const XSTART = -2*RADIUS;
const XEND = 2*RADIUS;
const YSTART = -2*RADIUS;
const YEND = 2*RADIUS;
const ZSTART = -2*RADIUS;
const ZEND = 2*RADIUS;

# https://en.wikipedia.org/Shift_matrix
function generate_shift_matrix(n)
    A = zeros(n, n)
    for i in 1:n-1
        A[i, i+1] = 1
    end
    A = UpperTriangular(A)
    return A
end


# ==== Integrands ====
# Different integrand function based on axes,
# result of calculating the expression of the magnetic field of a coil of current
# where the coil is in the XY plane and perpendicular to the Z axis.
# These functions are written with element-wise operations in mind,
# for better parallelisation (ex: .+ instead of +)

function dbx(X, Y, Z, theta::Float64)
    num = MU_ZERO * CURRENT_I
    denom = (X .- RADIUS * cos(theta)).^2 .+ (Y .- RADIUS * sin(theta)).^2 + Z.^2
    return num ./ (4 * pi * (denom.^(1.5)))
end

# The expression for dby is the same than for dbx
function dby(X, Y, Z, theta::Float64)
    return dbx(X, Y, Z, theta)
end

function dbz(X, Y, Z, theta::Float64)
    num = (MU_ZERO * CURRENT_I) .* (RADIUS^2 .- RADIUS .* (Y .* sin(theta) .+ X .* cos(theta)))
    denom = ((X .- RADIUS * cos(theta)).^2 .+ (Y .- RADIUS * sin(theta)).^2 .+ Z.^2).^(1.5)
    return num ./ (4 * pi * denom)
end

# ==== Integration ====
# This is the best I could come up with for case matching in Julia.
# Selects the integrand based on which axis we want to look at
# and integrates

function integrate(X,Y,Z,break_number,axis)
    break_size = 2*pi/break_number

    # Selecting integrand based on axis
    if (axis=='x')
        axis_func = dbx
    elseif (axis=='y')
        axis_func = dby
    elseif (axis=='z')
        axis_func = dbz
    else 
        println("Invalid axis. Choose either 'x','y' or 'z'")
    end

    #Not starting k at 0 otherwise it's counted twice
    totvec = [(axis_func(X, Y, Z, break_size * k) * break_size) for k in 1:break_number]

    total_axis_integral = sum(totvec)

    return total_axis_integral
end


# ==== Preparing to plot ====

# Computing values for plotting and integrating
xsize = (XEND - XSTART)/NUMBER_OF_POINTS_PER_DIMENSION
ysize = (YEND - YSTART)/NUMBER_OF_POINTS_PER_DIMENSION
zsize = (ZEND - ZSTART)/NUMBER_OF_POINTS_PER_DIMENSION

xcoords = [XSTART + px*xsize for px in 0:NUMBER_OF_POINTS_PER_DIMENSION]
ycoords = [YSTART + py*ysize for py in 0:NUMBER_OF_POINTS_PER_DIMENSION]
zcoords = [ZSTART + pz*zsize for pz in 0:NUMBER_OF_POINTS_PER_DIMENSION]

# Creating the coordinates matrices
# this should be adapted if changing the POV
xMatrix = repeat(xcoords',length(zcoords),1)
yMatrix = repeat(reverse(ycoords),1,length(zcoords))
zMatrix = repeat(zcoords',length(xcoords),1)

# Preparing for CUDA execution
dX = CuArray(xMatrix)
dY = CuArray(yMatrix)
dZ = CuArray(zMatrix)

# ==== Plotting for multiple values of Z ====

# Define the parameters for drawing coil
center = (1000, 1000)
radius = RADIUS/xsize
theta_range = (0, 2*π) 
num_points = 1000
theta_values = LinRange(theta_range[1], theta_range[2], num_points)

# Convert coil polar coordinates to cartesian coordinates
x = center[1] .+ radius * cos.(theta_values)
y = center[2] .+ radius * sin.(theta_values)

# Compute the field matrix for several values of z
for z in 0.001:0.1:3.001
    gpuFieldMatrix = integrate(dX,dY,z,BREAK_NUMBER,AXIS)
    # Sending back to CPU
    cpuFieldMatrix = Array(gpuFieldMatrix)
    heatmap(cpuFieldMatrix,  size=(2160,1440), color = :turbo, aspect_ratio=:equal)
    # Drawing the coil
    plot!(x, y, aspect_ratio=:equal, legend=false, color=:black)
    # Opening in GUI
    gui()
end