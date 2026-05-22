script_file <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
script_dir <- if (length(script_file) == 1) dirname(normalizePath(script_file)) else getwd()
repo_root <- normalizePath(file.path(script_dir, ".."), mustWork = TRUE)

input_file <- file.path(repo_root, "input", "pension.rda")
temp_dir <- file.path(repo_root, "temp")
tables_dir <- file.path(repo_root, "output", "tables")

dir.create(temp_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(tables_dir, recursive = TRUE, showWarnings = FALSE)

loaded_objects <- load(input_file)

if ("pension" %in% loaded_objects) {
  pension <- get("pension")
} else if (length(loaded_objects) == 1) {
  pension <- get(loaded_objects)
} else {
  stop("Could not identify the pension data object in input/pension.rda.")
}

if (!is.data.frame(pension)) {
  pension <- as.data.frame(pension)
}

xvar <- c(
  "i2", "i3", "i4", "i5", "i6", "i7",
  "a2", "a3", "a4", "a5",
  "fsize", "hs", "smcol", "col",
  "marr", "twoearn", "db", "pira", "hown"
)

required_vars <- c("tw", "p401", "e401", xvar)
missing_vars <- setdiff(required_vars, names(pension))

if (length(missing_vars) > 0) {
  stop("Missing required variables: ", paste(missing_vars, collapse = ", "))
}

y <- pension$tw
d <- pension$p401
z <- pension$e401
X <- pension[, xvar]

analysis_data <- list(
  pension = pension,
  y = y,
  d = d,
  z = z,
  X = X,
  xvar = xvar
)

saveRDS(analysis_data, file.path(temp_dir, "analysis_data.rds"))

summary_stats <- data.frame(
  Statistic = c("Observations", "Covariates", "Mean total wealth", "SD total wealth"),
  Value = c(
    format(nrow(pension), big.mark = ",", scientific = FALSE),
    format(length(xvar), scientific = FALSE),
    format(round(mean(y, na.rm = TRUE), 2), nsmall = 2, big.mark = ",", scientific = FALSE),
    format(round(sd(y, na.rm = TRUE), 2), nsmall = 2, big.mark = ",", scientific = FALSE)
  ),
  stringsAsFactors = FALSE
)

summary_table <- c(
  "\\begin{table}[!htbp]",
  "\\centering",
  "\\caption{Summary Statistics for the 401(k) Analysis Sample}",
  "\\label{tab:data-summary}",
  "\\begin{tabular}{lr}",
  "\\hline",
  "Statistic & Value \\\\",
  "\\hline",
  paste0(summary_stats$Statistic, " & ", summary_stats$Value, " \\\\"),
  "\\hline",
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(summary_table, file.path(tables_dir, "data_summary.tex"))

cat("N observations:", nrow(pension), "\n")
cat("N covariates:", length(xvar), "\n")
cat("Mean tw:", mean(y, na.rm = TRUE), "\n")
cat("SD tw:", sd(y, na.rm = TRUE), "\n")
