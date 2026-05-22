# Install/load packages
install.packages("hdm")
install.packages("xtable")

library(hdm)
library(xtable)

# Load the pension dataset from the hdm package
data("pension", package = "hdm")

# Check the data
dim(pension)
head(pension)
names(pension)

# Outcome, treatment, and controls
y <- pension$tw      # main outcome: total wealth
d <- pension$p401    # treatment variable
z <- pension$e401    # eligibility/instrument variable used for LATE/LATET later

# Covariates used in the paper's simple model
xvar <- c("i2", "i3", "i4", "i5", "i6", "i7",
          "a2", "a3", "a4", "a5",
          "fsize", "hs", "smcol", "col",
          "marr", "twoearn", "db", "pira", "hown")

X <- pension[, xvar]

# Required project summary numbers
N_observations <- nrow(pension)
N_covariates <- ncol(X)
mean_outcome <- mean(pension$tw, na.rm = TRUE)
sd_outcome <- sd(pension$tw, na.rm = TRUE)

summary_table <- data.frame(
  N_observations = N_observations,
  N_covariates = N_covariates,
  Mean_Main_Outcome_tw = mean_outcome,
  SD_Main_Outcome_tw = sd_outcome
)

print(summary_table)


# Formula used for ATE and ATET
form <- as.formula(
  paste("tw ~", paste(c("p401", xvar), collapse = "+"),
        "|", paste(xvar, collapse = "+"))
)

# Estimate ATE
pension.ate <- rlassoATE(form, data = pension)
summary(pension.ate)

# Estimate ATET
pension.atet <- rlassoATET(form, data = pension)
summary(pension.atet)

# Create replication table for ATE and ATET
ate_atet_table <- matrix(0, 2, 2)

ate_atet_table[1, ] <- summary(pension.ate)[, 1:2]
ate_atet_table[2, ] <- summary(pension.atet)[, 1:2]

colnames(ate_atet_table) <- c("Estimate", "Std. Error")
rownames(ate_atet_table) <- c("ATE", "ATET")

print(ate_atet_table)

# Optional LaTeX-style table
xtable(ate_atet_table, digits = c(2, 2, 2))