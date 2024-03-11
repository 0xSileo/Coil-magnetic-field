library(dplyr)
library(ggplot2)
library(matrixcalc)
library(viridis)


radius <- 0.4
interval_length <- 2*2*radius #since spanning from -2A to 2A

points <- 500

roundmultiple <- interval_length/points

#radius should be a multiple of roundmultiple
# here, points should be a mult of 4

data <- read.csv('value_on_plane.csv')

shift_by <- radius*length(unique(data$Z))/interval_length



# Shift the values to the right
df_shifted <- data %>%
  mutate(Z = Z + 0.4) 


# Merge data frames and create a new column 'Z' with the sum
merged_df <- merge(data, df_shifted, by = c("X", "Z"), all = TRUE)
merged_df$BZ_VALUE <- rowSums(merged_df[, c("BZ_VALUE.x", "BZ_VALUE.y")], na.rm = FALSE)

# Select only the necessary columns
result_df <- merged_df[, c("X", "Z", "BZ_VALUE")]

# Display the result
print(result_df)



two_coils_df <- result_df


lower_bound <- -0.05
upper_bound <- -lower_bound

data_filtered <- two_coils_df[two_coils_df$BZ_VALUE >= lower_bound & two_coils_df$BZ_VALUE <= upper_bound, ]


# Create the scatter plot with gradient colors
ggplot(data_filtered, aes(x=Z, y=X, color = BZ_VALUE)) +
  geom_point(size = 1) +
  scale_color_viridis(name = "Value", option="viridis", direction=-1) +
  theme_minimal() +
  labs(title = "Scatter Plot with Gradient Colors",
       x = "Z-axis",
       y = "X-axis") + 
  geom_point(data=data.frame(Z = c(0,0), X = c(-0.4,0.4)), aes(x=Z, y=X), color = "black", size = 5) +
  geom_point(data=data.frame(Z = c(1,1)*radius, X = c(-0.4,0.4)), aes(x=Z, y=X), color = "black", size = 5)





###
# Sample data frames
#df1 <- data.frame(x = c(1, 2, 3), y = c(1, 2, 3), Z = c(10, 20, 30))
#df2 <- data.frame(x = c(1, 2, 4), y = c(1, 2, 4), Z = c(5, 15, 25))

# Merge data frames and create a new column 'Z' with the sum
#merged_df <- merge(df1, df2, by = c("x", "y"), all = TRUE)
#merged_df$Z <- rowSums(merged_df[, c("Z.x", "Z.y")], na.rm = FALSE)

# Select only the necessary columns
#result_df <- merged_df[, c("x", "y", "Z")]

# Display the result
#print(result_df)
###



