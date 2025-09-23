# Filter Panel

**Learning Objectives:**
- Understand the relationship between the filter panel and data passed to modules
- Can save and restore filtering states
- Can launch a `teal` application with a custom filtering state
- Understand the coupled nature of filtering and hierarchical relationships

The filter panel is one of the most powerful features of `teal` applications, providing users with dynamic, interactive data filtering capabilities. It appears on the left side of every `teal` application and automatically adapts to your data structure, enabling real-time data exploration and analysis.

---

## The Structure of the Filter Panel UI

**Learning Objective:** Understand the visual organization and components of the filter panel interface.

The filter panel follows a consistent, intuitive structure that adapts to your data:

### Basic Filter Panel Layout

```r
library(teal)
library(teal.modules.general)
library(teal.data)
library(pharmaverseadam)

# Load data to demonstrate filter panel structure
data("adsl", package = "pharmaverseadam")
data("adae", package = "pharmaverseadam")

# Create teal_data object
demo_data <- teal_data()
demo_data <- within(demo_data, {
  ADSL <- adsl
  ADAE <- adae
})

# Basic application to show filter panel structure
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

if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### Filter Panel Components

When you launch this application, the filter panel displays:

#### **1. Dataset Sections**
- **ADSL Section**: Contains filters for all ADSL variables
- **ADAE Section**: Contains filters for all ADAE variables
- Each section can be **expanded/collapsed** for better organization

#### **2. Variable Type Filters**
- **Categorical Variables** (SEX, ARM, RACE): Show as **checkboxes** with all unique values
- **Numeric Variables** (AGE, BMIBL): Show as **range sliders** with min/max values
- **Date Variables** (RFSTDTC, RFENDTC): Show as **date pickers** with calendar interface
- **Logical Variables**: Show as **checkbox selections** (TRUE/FALSE)

#### **3. Filter Controls**
- **"Add Filter" button**: Add new filters for any variable
- **"Remove" buttons**: Remove individual filters
- **"Clear all" option**: Reset all filters to default state
- **Filter counters**: Show how many subjects/records remain after filtering

#### **4. Search and Navigation**
- **Variable search**: Find specific variables quickly in large datasets
- **Collapsible sections**: Organize filters by dataset for better navigation
- **Filter summaries**: Show active filter states at a glance

---

## How Filters in the Filter Panel Work

**Learning Objective:** Understand the mechanics of filtering and how different filter types behave.

### Filter Mechanics by Variable Type

#### Categorical Variable Filtering

```r
# Demonstrate categorical filtering behavior
categorical_demo <- teal::init(
  data = demo_data,
  modules = teal::modules(
    tm_variable_browser(
      label = "Variable Browser",
      dataname = "ADSL"
    ),
    tm_g_distribution(
      label = "Treatment Distribution",
      dataname = "ADSL",
      dist_var = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", "ARM"),
          selected = "ARM"
        )
      )
    )
  )
)

# When you filter ARM (treatment):
# - Checkboxes show: "Placebo", "Xanomeline High Dose", "Xanomeline Low Dose"
# - Selecting "Placebo" only shows placebo subjects
# - Multiple selections are combined with OR logic
# - Unselected values are completely filtered out

if (interactive()) {
  shiny::shinyApp(categorical_demo$ui, categorical_demo$server)
}
```

#### Numeric Variable Filtering

```r
# Demonstrate numeric filtering behavior
numeric_demo <- teal::init(
  data = demo_data,
  modules = teal::modules(
    tm_g_scatterplot(
      label = "Age vs BMI",
      dataname = "ADSL",
      x = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", "AGE"),
          selected = "AGE"
        )
      ),
      y = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", "BMIBL"),
          selected = "BMIBL"
        )
      )
    )
  )
)

# When you filter AGE:
# - Range slider shows min-max values (e.g., 18-88 years)
# - Dragging handles sets lower and upper bounds
# - Only subjects within the range are included
# - Real-time updates as you drag the slider

if (interactive()) {
  shiny::shinyApp(numeric_demo$ui, numeric_demo$server)
}
```

### Filter Behavior Characteristics

1. **Real-time Updates**: Changes apply immediately to all modules
2. **Inclusive Logic**: Multiple selections within a variable use OR logic
3. **Exclusive Logic**: Multiple variables use AND logic
4. **Range Filtering**: Numeric variables filter by continuous ranges
5. **Missing Value Handling**: Special options for NA/missing values

---

## How to Save Filters and Restore Them

**Learning Objective:** Master the filter state management system for reproducible analysis workflows.

### Understanding Filter State

Filter states in `teal` can be saved, exported, and restored, enabling reproducible analysis workflows.

#### Saving Filter States

```r
# Application with save/restore capabilities
save_restore_demo <- teal::init(
  data = demo_data,
  modules = teal::modules(
    tm_data_table(
      label = "ADSL Data",
      dataname = "ADSL"
    ),
    tm_g_distribution(
      label = "Age Distribution",
      dataname = "ADSL",
      dist_var = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", "AGE"),
          selected = "AGE"
        )
      ),
      strata_var = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", "ARM"),
          selected = "ARM"
        )
      )
    )
  )
)

# In the application, you can:
# 1. Apply filters (e.g., ARM = "Placebo", AGE = 30-70)
# 2. Click "Show R Code" to see filter state
# 3. Use the bookmark feature to save the current state
# 4. Export filter state as R code for reproducibility

if (interactive()) {
  shiny::shinyApp(save_restore_demo$ui, save_restore_demo$server)
}
```

#### Programmatic Filter State Management

```r
# Create and save filter states programmatically
library(teal.slice)

# Define a specific filter state
saved_filters <- teal_slices(
  teal_slice(
    dataname = "ADSL",
    varname = "ARM",
    selected = c("Placebo", "Xanomeline High Dose"),
    title = "Treatment Groups"
  ),
  teal_slice(
    dataname = "ADSL",
    varname = "AGE",
    selected = c(30, 70),
    title = "Age Range 30-70"
  ),
  teal_slice(
    dataname = "ADSL",
    varname = "SEX",
    selected = "F",
    title = "Female Subjects"
  ),
  teal_slice(
    dataname = "ADSL",
    varname = "SAFFL",
    selected = "Y",
    title = "Safety Population"
  )
)

# Save filter state to file
# saveRDS(saved_filters, "clinical_analysis_filters.rds")

# The saved filter state can be shared with colleagues
# or used to reproduce exact analysis conditions
```

#### Restoring Filter States

```r
# Load and apply saved filter state
# saved_filters <- readRDS("clinical_analysis_filters.rds")

# Apply saved filters to a new application
restored_app <- teal::init(
  data = demo_data,
  modules = teal::modules(
    tm_data_table(
      label = "Filtered ADSL Data",
      dataname = "ADSL"
    ),
    tm_t_summary(
      label = "Demographics Summary",
      dataname = "ADSL",
      summarize_vars = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("AGE", "BMIBL", "RACE")),
          selected = c("AGE", "RACE"),
          multiple = TRUE
        )
      )
    )
  ),
  filter = saved_filters  # Apply the saved filter state
)

# This application will launch with all the saved filters already applied:
# - Only Placebo and Xanomeline High Dose treatments
# - Only subjects aged 30-70
# - Only female subjects  
# - Only safety population subjects

if (interactive()) {
  shiny::shinyApp(restored_app$ui, restored_app$server)
}
```

### Filter State Export Formats

Filter states can be exported in multiple formats:

1. **R Code**: Complete reproducible code
2. **JSON**: Structured data format for integration
3. **Bookmark URLs**: Shareable application links
4. **RDS Files**: Binary R objects for efficient storage

---

## Providing Filter State on Initial Application Launch

**Learning Objective:** Learn how to launch `teal` applications with predefined filters for specific analysis scenarios.

### Launching with Predefined Filters

```r
# Create application with initial filter state
initial_filters <- teal_slices(
  # Population definition filters
  teal_slice(
    dataname = "ADSL",
    varname = "ITTFL",
    selected = "Y",
    title = "Intent-to-Treat Population"
  ),
  teal_slice(
    dataname = "ADSL", 
    varname = "ARM",
    selected = c("Placebo", "Xanomeline High Dose"),
    title = "Primary Analysis Arms"
  ),
  
  # Demographic filters
  teal_slice(
    dataname = "ADSL",
    varname = "AGE",
    selected = c(18, 80),
    title = "Adult Population"
  ),
  
  # Safety filters for ADAE
  teal_slice(
    dataname = "ADAE",
    varname = "AESEV",
    selected = c("MODERATE", "SEVERE"),
    title = "Moderate to Severe AEs"
  ),
  teal_slice(
    dataname = "ADAE",
    varname = "AEREL", 
    selected = c("RELATED", "POSSIBLY RELATED"),
    title = "Treatment-Related AEs"
  )
)

# Launch application with predefined analysis focus
predefined_app <- teal::init(
  data = demo_data,
  modules = teal::modules(
    # Demographics analysis with predefined population
    teal::modules(
      label = "📊 Demographics Analysis",
      tm_t_summary(
        label = "Baseline Demographics",
        dataname = "ADSL",
        summarize_vars = data_extract_spec(
          dataname = "ADSL",
          select = select_spec(
            choices = variable_choices("ADSL", c("AGE", "SEX", "RACE", "BMIBL")),
            selected = c("AGE", "SEX", "RACE"),
            multiple = TRUE
          )
        )
      ),
      tm_g_distribution(
        label = "Age Distribution by Treatment",
        dataname = "ADSL",
        dist_var = data_extract_spec(
          dataname = "ADSL",
          select = select_spec(
            choices = variable_choices("ADSL", "AGE"),
            selected = "AGE"
          )
        ),
        strata_var = data_extract_spec(
          dataname = "ADSL",
          select = select_spec(
            choices = variable_choices("ADSL", "ARM"),
            selected = "ARM"
          )
        )
      )
    ),
    
    # Safety analysis with predefined AE filters
    teal::modules(
      label = "⚠️ Safety Analysis",
      tm_data_table(
        label = "Treatment-Related AEs",
        dataname = "ADAE"
      ),
      tm_g_distribution(
        label = "AE Severity Distribution",
        dataname = "ADAE",
        dist_var = data_extract_spec(
          dataname = "ADAE",
          select = select_spec(
            choices = variable_choices("ADAE", "AESEV"),
            selected = "AESEV"
          )
        ),
        strata_var = data_extract_spec(
          dataname = "ADAE",
          select = select_spec(
            choices = variable_choices("ADAE", "ARM"),
            selected = "ARM"
          )
        )
      )
    )
  ),
  filter = initial_filters,  # Apply predefined filters
  title = "Clinical Study Analysis - Predefined Population"
)

# This application launches with:
# - Only ITT population subjects
# - Only primary analysis treatment arms
# - Only adult subjects (18-80 years)
# - Only moderate to severe, treatment-related AEs
# - All analyses automatically focus on this defined population

if (interactive()) {
  shiny::shinyApp(predefined_app$ui, predefined_app$server)
}
```

### Advanced Initial Filter Configurations

```r
# Complex filter expressions for sophisticated population definitions
advanced_filters <- teal_slices(
  # Complex expression filter
  teal_slice(
    dataname = "ADSL",
    expr = "AGE >= 65 & BMIBL < 30",
    title = "Elderly Non-Obese",
    id = "elderly_normal_bmi"
  ),
  
  # Multiple variable combination
  teal_slice(
    dataname = "ADSL",
    expr = "ARM %in% c('Placebo', 'Xanomeline High Dose') & SEX == 'F'",
    title = "Female Primary Arms",
    id = "female_primary"
  ),
  
  # Date-based filtering
  teal_slice(
    dataname = "ADSL",
    varname = "RFSTDTC",
    selected = c(as.Date("2013-01-01"), as.Date("2014-12-31")),
    title = "Study Period 2013-2014"
  )
)
```

---

## Understanding the Coupled Nature of Filtering

**Learning Objective:** Master how filtering propagates through related datasets and hierarchical data structures.

### Coupled Filtering Mechanism

In `teal`, filtering is "coupled" - when you filter one dataset, related datasets are automatically filtered based on their relationships (join keys).

#### Demonstration of Coupled Filtering

```r
# Create data with clear relationships to demonstrate coupling
coupled_demo_data <- teal_data()
coupled_demo_data <- within(coupled_demo_data, {
  # ADSL - 20 subjects for clear demonstration
  ADSL <- adsl[1:20, ]
  
  # ADAE - Only adverse events for first 15 subjects
  ADAE <- adae[adae$USUBJID %in% ADSL$USUBJID[1:15], ]
  
  # ADCM - Only concomitant meds for first 10 subjects  
  ADCM <- data.frame(
    STUDYID = "01-701-1015",
    USUBJID = rep(ADSL$USUBJID[1:10], each = 2),
    CMSEQ = rep(1:2, 10),
    CMDECOD = sample(c("ASPIRIN", "IBUPROFEN", "ACETAMINOPHEN"), 20, replace = TRUE),
    CMSTDTC = sample(seq.Date(as.Date("2013-01-01"), as.Date("2013-12-31"), by = "day"), 20)
  )
})

# Application demonstrating coupled filtering
coupled_app <- teal::init(
  data = coupled_demo_data,
  modules = teal::modules(
    tm_data_table(
      label = "ADSL (Subject Level)",
      dataname = "ADSL"
    ),
    tm_data_table(
      label = "ADAE (Adverse Events)",
      dataname = "ADAE"
    ),
    tm_data_table(
      label = "ADCM (Concomitant Meds)",
      dataname = "ADCM"
    ),
    tm_variable_browser(
      label = "Data Summary",
      dataname = "ADSL"
    )
  )
)

# Coupled filtering behavior:
# 1. Filter ADSL by ARM = "Placebo" (affects ~7 subjects)
# 2. ADAE automatically filters to show only AEs for those 7 subjects
# 3. ADCM automatically filters to show only meds for those subjects
# 4. All modules update simultaneously with consistent data

if (interactive()) {
  shiny::shinyApp(coupled_app$ui, coupled_app$server)
}
```

### Hierarchical Filtering Behavior

```r
# Demonstrate hierarchical filtering with parent-child relationships
hierarchical_demo <- teal::init(
  data = coupled_demo_data,
  modules = teal::modules(
    # Parent dataset view
    teal::modules(
      label = "👤 Subject Level (Parent)",
      tm_t_summary(
        label = "Subject Summary",
        dataname = "ADSL",
        summarize_vars = data_extract_spec(
          dataname = "ADSL",
          select = select_spec(
            choices = variable_choices("ADSL", c("AGE", "SEX", "ARM")),
            selected = c("AGE", "ARM"),
            multiple = TRUE
          )
        )
      )
    ),
    
    # Child dataset views
    teal::modules(
      label = "📋 Event Level (Children)",
      tm_g_distribution(
        label = "AE Distribution",
        dataname = "ADAE",
        dist_var = data_extract_spec(
          dataname = "ADAE",
          select = select_spec(
            choices = variable_choices("ADAE", "AEDECOD"),
            selected = "AEDECOD"
          )
        )
      ),
      tm_data_table(
        label = "Concomitant Medications",
        dataname = "ADCM"
      )
    )
  )
)

# Hierarchical behavior:
# - ADSL is the "parent" dataset (subject-level)
# - ADAE and ADCM are "child" datasets (event-level)
# - Filtering ADSL (parent) automatically filters ADAE and ADCM (children)
# - Filtering ADAE doesn't affect ADSL (child can't filter parent)
# - This maintains data integrity and logical relationships

if (interactive()) {
  shiny::shinyApp(hierarchical_demo$ui, hierarchical_demo$server)
}
```

### Understanding Filter Propagation Rules

#### **Rule 1: Parent → Child Filtering**
```
ADSL (Parent) Filter: ARM = "Placebo"
    ↓
ADAE (Child) Result: Only AEs for placebo subjects
ADCM (Child) Result: Only medications for placebo subjects
```

#### **Rule 2: Child Filtering Independence**
```
ADAE (Child) Filter: AESEV = "SEVERE"
    ↓
ADSL (Parent) Result: No change - still shows all subjects
ADCM (Sibling) Result: No change - still shows all medications
```

#### **Rule 3: Multiple Filter Combination**
```
ADSL Filter: ARM = "Placebo" AND AGE >= 65
    ↓
Child Datasets: Only events/medications for elderly placebo subjects
```

### Practical Implications of Coupled Filtering

1. **Data Consistency**: Related datasets always remain synchronized
2. **Analysis Integrity**: Prevents analysis of mismatched populations
3. **User Experience**: Intuitive behavior matching analytical expectations
4. **Performance**: Automatic data reduction improves application speed
5. **Reproducibility**: Filter states capture complete analysis context

### Advanced Coupling Scenarios

```r
# Complex coupling with multiple relationships
complex_coupling_demo <- teal::init(
  data = coupled_demo_data,
  modules = teal::modules(
    tm_g_scatterplot(
      label = "Cross-Dataset Analysis",
      dataname = "ADSL",
      x = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", "AGE"),
          selected = "AGE"
        )
      ),
      y = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", "BMIBL"),
          selected = "BMIBL"
        )
      ),
      color_by = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", "ARM"),
          selected = "ARM"
        )
      )
    )
  ),
  # Initial filters demonstrating coupling
  filter = teal_slices(
    teal_slice(
      dataname = "ADSL",
      varname = "SEX",
      selected = "F",
      title = "Female Subjects"
    ),
    teal_slice(
      dataname = "ADAE",
      varname = "AESEV",
      selected = "SEVERE",
      title = "Severe AEs Only"
    )
  )
)

# This demonstrates:
# - ADSL filtered to females affects all child datasets
# - ADAE filtered to severe AEs doesn't affect ADSL
# - Combined effect: Analysis focuses on severe AEs in female subjects
# - All visualizations remain consistent with these population definitions

if (interactive()) {
  shiny::shinyApp(complex_coupling_demo$ui, complex_coupling_demo$server)
}
```

