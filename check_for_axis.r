df <- read.csv('value_along_axis.csv')
plot(df$Z,df$BZ_VALUE, type='l')

MU_ZERO <- 1.25663706212e-6
I = 1
A = 0.4

z <- seq(-5*A, 5*A , length.out = 1000)

r <- sqrt(A**2+z**2)


# Calculate corresponding y values using sin(x)
y <- (MU_ZERO*I*(A**2))/(2*(r**3))

# Plot sin(x)
points(z, y, col = "blue", lwd = 2, main = "Plot of field", xlab = "r", ylab = "Field value")

