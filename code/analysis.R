script_file <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
script_dir <- if (length(script_file) == 1) dirname(normalizePath(script_file)) else getwd()
repo_root <- normalizePath(file.path(script_dir, ".."), mustWork = TRUE)

analysis_file <- file.path(repo_root, "temp", "analysis_data.rds")
tables_dir <- file.path(repo_root, "output", "tables")

dir.create(tables_dir, recursive = TRUE, showWarnings = FALSE)

if (!requireNamespace("hdm", quietly = TRUE)) {
  stop("Package 'hdm' is required. Install it with install.packages('hdm').")
}

if (!requireNamespace("xtable", quietly = TRUE)) {
  stop("Package 'xtable' is required. Install it with install.packages('xtable').")
}

library(hdm)
library(xtable)

analysis_data <- readRDS(analysis_file)
pension <- analysis_data$pension
xvar <- analysis_data$xvar

controls <- paste(xvar, collapse = " + ")
form <- as.formula(paste("tw ~ p401 +", controls, "|", controls))

pension_ate <- rlassoATE(form, data = pension)
pension_atet <- rlassoATET(form, data = pension)

ate_summary <- summary(pension_ate)
atet_summary <- summary(pension_atet)

results <- data.frame(
  Estimand = c("ATE", "ATET"),
  Estimate = c(ate_summary[1, 1], atet_summary[1, 1]),
  `Std. Error` = c(ate_summary[1, 2], atet_summary[1, 2]),
  check.names = FALSE
)

result_table <- xtable(
  results,
  caption = "Replication of ATE and ATET Estimates",
  label = "tab:main-results",
  digits = c(0, 0, 2, 3)
)

print(
  result_table,
  file = file.path(tables_dir, "main_result.tex"),
  include.rownames = FALSE,
  floating = TRUE,
  table.placement = "!htbp"
)

paper_ate <- 10180.09
paper_atet <- 12628.46

cat("Paper ATE =", paper_ate, ", replicated ATE =", results$Estimate[1], "\n")
cat("ATE difference =", results$Estimate[1] - paper_ate, "\n")
cat("Paper ATET =", paper_atet, ", replicated ATET =", results$Estimate[2], "\n")
cat("ATET difference =", results$Estimate[2] - paper_atet, "\n")
