# Understanding Data in `teal`

**Learning Objectives:** 
- Understand `teal` data management and relationships
- Can create their own `teal.data` objects with custom `join_keys` for CDISC data relationships
- Understand data flow from `teal.data` through filters to modules

Data management is at the heart of every `teal` application. The `teal.data` package provides a unified framework for handling datasets, defining relationships between them, and ensuring reproducibility. This section will guide you through the core concepts and practical applications of data management in `teal`.

---

## `teal.data` as a Vehicle for User Data

**Learning objective**: Understand `teal` data management and relationships.

The `teal.data` package serves as the foundation for all data operations in `teal`. It provides a structured way to:
- Store multiple datasets in a single object
- Track the code used to create or modify data
- Define relationships between datasets
- Ensure reproducible analysis workflows

### Creating Basic `teal_data` Objects

The simplest way to create a `teal_data` object is using the `teal_data()` function:

```r
library(teal.data)

# Create a basic teal_data object
my_data <- teal_data(
  IRIS = iris,
  MTCARS = mtcars
)

# View the structure
print(my_data)
```

### Understanding the `teal_data` Structure

When you create a `teal_data` object, several important things happen:

1. **Data storage** - Your datasets are stored within the object
2. **Code tracking** - The creation process is recorded for reproducibility
3. **Metadata creation** - Information about datasets and their relationships is stored

### Adding Code for Reproducibility

One of the key features of `teal.data` is its ability to track the code used to generate data:

```r
# Create teal_data with explicit code tracking
my_data <- teal_data()

# Add datasets with code
my_data <- within(my_data, {
  # Load and prepare iris data
  IRIS <- iris
  IRIS$Species <- as.factor(IRIS$Species)
  
  # Load and prepare mtcars data  
  MTCARS <- mtcars
  MTCARS$cyl <- as.factor(MTCARS$cyl)
  MTCARS$gear <- as.factor(MTCARS$gear)
})

# View the tracked code
get_code(my_data)
```

---

## Understanding `join_keys`

**Learning Objective:** Master the creation and management of dataset relationships using `join_keys`.

`join_keys` define how datasets relate to each other, which is crucial for:
- Proper filtering across related datasets
- Correct data merging in modules
- Maintaining data integrity in analysis

### What is the Purpose of `join_keys`?

`join_keys` serve several critical functions:

1. **Data Relationships** - Define how datasets connect (parent-child relationships)
2. **Filter Propagation** - Ensure filters apply correctly across related datasets  
3. **Module Integration** - Help modules understand how to merge data correctly
4. **Data Integrity** - Prevent incorrect joins that could lead to wrong results

### How to Create `join_keys` Manually

Sometimes you need to create or modify join keys manually:

```r
# Create a teal_data object without automatic join detection
my_data <- teal_data(
  PATIENTS = data.frame(
    patient_id = 1:100,
    age = sample(18:80, 100, replace = TRUE),
    treatment = sample(c("A", "B"), 100, replace = TRUE)
  ),
  VISITS = data.frame(
    patient_id = rep(1:100, each = 4),
    visit_num = rep(1:4, 100),
    visit_date = seq.Date(as.Date("2024-01-01"), by = "week", length.out = 400),
    measurement = rnorm(400, 100, 15)
  ),
  EVENTS = data.frame(
    patient_id = sample(1:100, 200, replace = TRUE),
    event_type = sample(c("AE", "CM", "EX"), 200, replace = TRUE),
    event_date = sample(seq.Date(as.Date("2024-01-01"), as.Date("2024-12-31"), by = "day"), 200)
  )
)

# Manually define join keys
join_keys(my_data) <- join_keys(
  join_key("PATIENTS", "VISITS", "patient_id"),
  join_key("PATIENTS", "EVENTS", "patient_id")
)

# View the join keys
print("Manual join keys:")
print(join_keys(my_data))
```

### Printing `join_keys` and Understanding the Output

```r
# Create example with multiple relationships
complex_data <- cdisc_data()

complex_data <- within(complex_data, {
  ADSL <- data.frame(
    STUDYID = rep("STUDY001", 30),
    USUBJID = paste0("SUBJ", sprintf("%03d", 1:30)),
    SITEID = sample(paste0("SITE", 1:5), 30, replace = TRUE),
    AGE = sample(18:80, 30, replace = TRUE)
  )
  
  ADAE <- data.frame(
    STUDYID = "STUDY001",
    USUBJID = sample(ADSL$USUBJID, 90, replace = TRUE),
    AESEQ = sequence(table(sample(ADSL$USUBJID, 90, replace = TRUE))),
    AEDECOD = sample(c("Headache", "Nausea"), 90, replace = TRUE)
  )
  
  ADLB <- data.frame(
    STUDYID = "STUDY001", 
    USUBJID = sample(ADSL$USUBJID, 120, replace = TRUE),
    PARAMCD = sample(c("ALT", "AST", "BILI"), 120, replace = TRUE),
    AVAL = rnorm(120, 50, 10)
  )
})

# Print and interpret join keys
cat("Join Keys Structure:\n")
print(join_keys(complex_data))

# Understanding the output:
# - Each line shows a relationship between two datasets
# - The arrow (->) indicates the direction (parent -> child)
# - Variables in brackets show the joining columns
# - ADSL is typically the parent (subject-level data)
```

---

## `cdisc_data` as a Vehicle for Structured ADaM Data

**Learning Objective:** Understand when and how to use `cdisc_data()` for clinical trial data with automatic relationship detection.

For clinical trial data following CDISC standards, `teal.data` provides the specialized `cdisc_data()` function that automatically handles common clinical data relationships.

### When to Use `cdisc_data()`

Use `cdisc_data()` when you have:
- ADaM datasets (ADSL, ADAE, ADCM, etc.)
- Standard CDISC variable names (STUDYID, USUBJID, etc.)
- Need for automatic join key detection
- Clinical trial data with known relationships

### Creating `cdisc_data` Objects

```r
library(teal.data)

# Create sample ADSL data
adsl <- data.frame(
  STUDYID = rep("STUDY001", 50),
  USUBJID = paste0("SUBJ", sprintf("%03d", 1:50)),
  AGE = sample(18:80, 50, replace = TRUE),
  SEX = sample(c("M", "F"), 50, replace = TRUE),
  ARM = sample(c("Placebo", "Treatment"), 50, replace = TRUE),
  SAFFL = "Y",
  stringsAsFactors = FALSE
)

# Create sample ADAE data (adverse events)
adae <- data.frame(
  STUDYID = rep("STUDY001", 150),
  USUBJID = rep(paste0("SUBJ", sprintf("%03d", 1:50)), each = 3),
  AESEQ = rep(1:3, 50),
  AEDECOD = sample(c("Headache", "Nausea", "Fatigue", "Dizziness"), 150, replace = TRUE),
  AESEV = sample(c("MILD", "MODERATE", "SEVERE"), 150, replace = TRUE),
  AESER = sample(c("Y", "N"), 150, replace = TRUE, prob = c(0.1, 0.9)),
  stringsAsFactors = FALSE
)

# Create cdisc_data object
clinical_data <- cdisc_data(
  ADSL = adsl,
  ADAE = adae,
  code = c(
    "ADSL <- adsl_data_creation_code()",
    "ADAE <- adae_data_creation_code()"
  )
)

print(clinical_data)
```

### Automatic Join Key Detection

One of the key advantages of `cdisc_data()` is automatic join key detection:

```r
# View the automatically detected join keys
join_keys(clinical_data)

# The output will show:
# ADSL <-> ADAE: [STUDYID, USUBJID]
```

### Manual `cdisc_data` Creation with Explicit Code

```r
# More explicit approach with within()
clinical_data <- cdisc_data()

clinical_data <- within(clinical_data, {
  # Create ADSL
  ADSL <- data.frame(
    STUDYID = rep("STUDY001", 100),
    USUBJID = paste0("SUBJ", sprintf("%03d", 1:100)),
    AGE = sample(18:80, 100, replace = TRUE),
    SEX = as.factor(sample(c("M", "F"), 100, replace = TRUE)),
    ARM = as.factor(sample(c("Placebo", "Treatment"), 100, replace = TRUE)),
    SAFFL = "Y"
  )
  
  # Create ADAE based on ADSL
  n_events <- 300
  ADAE <- data.frame(
    STUDYID = "STUDY001",
    USUBJID = sample(ADSL$USUBJID, n_events, replace = TRUE),
    AESEQ = sequence(table(sample(ADSL$USUBJID, n_events, replace = TRUE))),
    AEDECOD = sample(c("Headache", "Nausea", "Fatigue"), n_events, replace = TRUE),
    AESEV = as.factor(sample(c("MILD", "MODERATE", "SEVERE"), n_events, replace = TRUE))
  )
})

# View the structure and join keys
print(clinical_data)
join_keys(clinical_data)
```

---

### Recreating `join_keys` for a CDISC Example (ADSL-ADAE)

Let's walk through a complete example of creating proper join keys for a typical CDISC study:

```r
# Step 1: Create the datasets
cdisc_example <- teal_data()

cdisc_example <- within(cdisc_example, {
  # ADSL: Subject-Level Analysis Dataset
  ADSL <- data.frame(
    STUDYID = rep("STUDY001", 100),
    USUBJID = paste0("SUBJ", sprintf("%03d", 1:100)),
    SUBJID = sprintf("%03d", 1:100),
    SITEID = sample(paste0("SITE", sprintf("%02d", 1:10)), 100, replace = TRUE),
    AGE = sample(18:80, 100, replace = TRUE),
    AGEGR1 = cut(sample(18:80, 100, replace = TRUE), 
                 breaks = c(0, 30, 50, 65, 100), 
                 labels = c("<30", "30-50", "50-65", ">65")),
    SEX = as.factor(sample(c("M", "F"), 100, replace = TRUE)),
    RACE = as.factor(sample(c("WHITE", "BLACK", "ASIAN", "OTHER"), 100, replace = TRUE)),
    ARM = as.factor(sample(c("Placebo", "Treatment A", "Treatment B"), 100, replace = TRUE)),
    ACTARM = as.factor(sample(c("Placebo", "Treatment A", "Treatment B"), 100, replace = TRUE)),
    SAFFL = "Y",
    ITTFL = "Y"
  )
  
  # ADAE: Adverse Event Analysis Dataset
  # Generate realistic number of AEs per subject
  ae_counts <- rpois(100, 2.5)  # Average 2.5 AEs per subject
  total_aes <- sum(ae_counts)
  
  ADAE <- data.frame(
    STUDYID = rep("STUDY001", total_aes),
    USUBJID = rep(ADSL$USUBJID, ae_counts),
    SUBJID = rep(ADSL$SUBJID, ae_counts),
    SITEID = rep(ADSL$SITEID, ae_counts),
    AESEQ = sequence(ae_counts),
    AEDECOD = sample(c("Headache", "Nausea", "Fatigue", "Dizziness", "Insomnia", 
                       "Diarrhea", "Constipation", "Rash", "Cough", "Fever"), 
                     total_aes, replace = TRUE),
    AEBODSYS = sample(c("Nervous system disorders", "Gastrointestinal disorders",
                        "General disorders", "Skin and subcutaneous tissue disorders",
                        "Respiratory disorders"), total_aes, replace = TRUE),
    AESEV = as.factor(sample(c("MILD", "MODERATE", "SEVERE"), total_aes, 
                            replace = TRUE, prob = c(0.6, 0.3, 0.1))),
    AESER = as.factor(sample(c("Y", "N"), total_aes, replace = TRUE, prob = c(0.05, 0.95))),
    AEREL = as.factor(sample(c("RELATED", "NOT RELATED", "POSSIBLY RELATED"), 
                            total_aes, replace = TRUE, prob = c(0.2, 0.6, 0.2))),
    AEACN = as.factor(sample(c("NONE", "DOSE REDUCED", "DRUG WITHDRAWN"), 
                            total_aes, replace = TRUE, prob = c(0.8, 0.15, 0.05))),
    AESTDY = sample(1:365, total_aes, replace = TRUE),
    SAFFL = "Y"
  )
})

# Step 2: Understand the automatic join keys
cat("Automatic CDISC join keys:\n")
print(join_keys(cdisc_example))

# Step 3: Verify the relationships work
cat("\nTesting the relationship:\n")
cat("ADSL subjects:", length(unique(cdisc_example[["ADSL"]]$USUBJID)), "\n")
cat("ADAE subjects:", length(unique(cdisc_example[["ADAE"]]$USUBJID)), "\n")
cat("ADAE events:", nrow(cdisc_example[["ADAE"]]), "\n")

# Step 4: Manual verification of join key validity
adsl_keys <- unique(cdisc_example[["ADSL"]][c("STUDYID", "USUBJID")])
adae_keys <- unique(cdisc_example[["ADAE"]][c("STUDYID", "USUBJID")])
cat("All ADAE subjects exist in ADSL:", all(adae_keys$USUBJID %in% adsl_keys$USUBJID), "\n")
```

---

## Data Preprocessing

**Learning Objective:** Understand best practices for data preprocessing in `teal` applications and how to encapsulate preprocessing within `teal.data` objects.

### Best Practices for Data Preprocessing

1. **Separate preprocessing from application logic**
2. **Document all transformations with code**
3. **Validate data after preprocessing**
4. **Use consistent variable naming and types**
5. **Handle missing values appropriately**

### Where Should Preprocessing Happen?

```r
# Option 1: Separate preprocessing functions
preprocess_adsl <- function(raw_adsl) {
  processed <- raw_adsl
  
  # Convert character variables to factors where appropriate
  factor_vars <- c("SEX", "RACE", "ARM", "ACTARM", "SAFFL", "ITTFL")
  processed[factor_vars] <- lapply(processed[factor_vars], as.factor)
  
  # Create age groups
  processed$AGEGR1 <- cut(processed$AGE, 
                         breaks = c(0, 30, 50, 65, 100),
                         labels = c("<30", "30-50", "50-65", ">65"),
                         right = FALSE)
  
  # Create derived variables
  processed$AGECAT <- ifelse(processed$AGE >= 65, "Elderly", "Non-elderly")
  processed$AGECAT <- as.factor(processed$AGECAT)
  
  return(processed)
}

preprocess_adae <- function(raw_adae) {
  processed <- raw_adae
  
  # Convert to factors
  factor_vars <- c("AESEV", "AESER", "AEREL", "AEACN", "SAFFL")
  processed[factor_vars] <- lapply(processed[factor_vars], as.factor)
  
  # Create severity categories
  processed$AESEVN <- as.numeric(factor(processed$AESEV, 
                                       levels = c("MILD", "MODERATE", "SEVERE")))
  
  return(processed)
}
```

### Encapsulating Data Preprocessing in `teal.data`

```r
# Option 2: Encapsulate preprocessing in teal.data
create_clinical_data <- function(raw_adsl, raw_adae) {
  clinical_data <- teal_data()
  
  clinical_data <- within(clinical_data, {
    # ADSL preprocessing
    ADSL <- raw_adsl
    
    # Convert to factors
    factor_vars <- c("SEX", "RACE", "ARM", "ACTARM", "SAFFL", "ITTFL")
    ADSL[factor_vars] <- lapply(ADSL[factor_vars], as.factor)
    
    # Create age groups
    ADSL$AGEGR1 <- cut(ADSL$AGE, 
                       breaks = c(0, 30, 50, 65, 100),
                       labels = c("<30", "30-50", "50-65", ">65"),
                       right = FALSE)
    
    # ADAE preprocessing  
    ADAE <- raw_adae
    
    # Convert to factors
    ae_factor_vars <- c("AESEV", "AESER", "AEREL", "AEACN", "SAFFL")
    ADAE[ae_factor_vars] <- lapply(ADAE[ae_factor_vars], as.factor)
    
    # Data validation
    stopifnot("All ADAE subjects must exist in ADSL" = 
              all(ADAE$USUBJID %in% ADSL$USUBJID))
  })
  
  return(clinical_data)
}

# Usage example
# clinical_data <- create_clinical_data(raw_adsl_data, raw_adae_data)
```

---

## Data Flow in `teal` Applications

**Learning Objective:** Understand how data flows from `teal.data` objects through the filter panel to modules.

Understanding data flow is crucial for building effective `teal` applications. Let's trace how data moves through the system:

### The Complete Data Flow

```
Raw Data → teal.data → Filter Panel → Filtered Data → Modules → Output
```

### Demonstrating Data Flow with Code

```r
# Create a complete example showing data flow
library(teal)
library(teal.modules.general)

# Step 1: Create data with clear relationships
demo_data <- cdisc_data()
demo_data <- within(demo_data, {
  ADSL <- data.frame(
    USUBJID = paste0("SUBJ", sprintf("%03d", 1:20)),
    AGE = c(25, 35, 45, 55, 65, 75, 30, 40, 50, 60, 
            28, 38, 48, 58, 68, 32, 42, 52, 62, 72),
    SEX = as.factor(rep(c("M", "F"), 10)),
    ARM = as.factor(rep(c("Placebo", "Treatment"), each = 10)),
    SAFFL = "Y"
  )
  
  ADAE <- data.frame(
    USUBJID = rep(ADSL$USUBJID[1:15], each = 2),  # Only first 15 subjects have AEs
    AESEQ = rep(1:2, 15),
    AEDECOD = sample(c("Headache", "Nausea", "Fatigue"), 30, replace = TRUE),
    AESEV = as.factor(sample(c("MILD", "MODERATE"), 30, replace = TRUE))
  )
})

# Step 2: Create teal app to demonstrate data flow
app <- teal::init(
  data = demo_data,
  modules = teal::modules(
    tm_data_table(
      label = "ADSL Data",
      dataname = "ADSL"
    ),
    tm_data_table(
      label = "ADAE Data", 
      dataname = "ADAE"
    )
  )
)

# Understanding what happens when filters are applied:
# When you filter ADSL for:
# - AGE >= 50 (reduces ADSL from 20 to 10 subjects)
# - SEX == "M" (further reduces to 5 subjects)
# 
# The ADAE dataset automatically gets filtered to only show
# adverse events for those 5 remaining subjects
# This happens because of the join keys: USUBJID

# Launch the app to see data flow in action
if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

---

## Handling Large Datasets - Performance Considerations

**Learning Objective:** Understand strategies for optimizing `teal` applications with large clinical datasets.

Working with large clinical datasets requires careful consideration of performance and memory usage.

### Performance Optimization Strategies

```r
# Strategy 1: Data type optimization
optimize_data_types <- function(df) {
  # Convert character columns to factors (saves memory)
  char_cols <- sapply(df, is.character)
  df[char_cols] <- lapply(df[char_cols], as.factor)
  
  return(df)
}

# Strategy 2: Sampling for development
create_development_sample <- function(data_obj, sample_size = 1000) {
  adsl <- data_obj[["ADSL"]]
  
  # Sample subjects
  if (nrow(adsl) > sample_size) {
    sampled_subjects <- sample(adsl$USUBJID, sample_size)
    
    # Create new data object with sampled data
    sample_data <- teal_data()
    sample_data <- within(sample_data, {
      ADSL <- adsl[adsl$USUBJID %in% sampled_subjects, ]
      
      # Filter related datasets to sampled subjects
      if ("ADAE" %in% names(data_obj@data)) {
        ADAE <- data_obj[["ADAE"]][data_obj[["ADAE"]]$USUBJID %in% sampled_subjects, ]
      }
    })
    
    return(sample_data)
  }
  
  return(data_obj)
}

# Strategy 3: Memory monitoring
check_data_size <- function(data_obj) {
  total_size <- 0
  
  for (name in names(data_obj@data)) {
    dataset <- data_obj[[name]]
    size_mb <- as.numeric(object.size(dataset)) / 1024^2
    cat(sprintf("Dataset %s: %.2f MB (%d rows, %d cols)\n", 
                name, size_mb, nrow(dataset), ncol(dataset)))
    total_size <- total_size + size_mb
  }
  
  cat(sprintf("Total data size: %.2f MB\n", total_size))
  return(total_size)
}

# Usage
# check_data_size(clinical_data)
```
