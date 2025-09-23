# Launching `teal.modules.general` and `teal.modules.clinical` Modules

**Learning Objectives:**
- Can implement a `teal` application using pre-built modules
- Can configure pre-built modules from `teal.modules.general` and `teal.modules.clinical`
- Understand how modules integrate with `teal.data` objects

Pre-built modules are the foundation of most `teal` applications. The `teal.modules.general` (TMG) package provides versatile modules for data exploration, visualization, and analysis that work with any data structure. The `teal.modules.clinical` (TMC) package offers specialized modules designed specifically for clinical trial data analysis.

---

## Example of Launching a `teal.modules.general` Module

**Learning Objective:** Understand how to integrate and configure a basic TMG module in a `teal` application.

Let's start with a simple but complete example using one of the most commonly used modules from `teal.modules.general`: the data table module (`tm_data_table`).

### Basic Data Table Module

The `tm_data_table` module provides an interactive data table with built-in filtering, sorting, and searching capabilities.

```r
library(teal)
library(teal.modules.general)
library(teal.data)
library(pharmaverseadam)

# Step 1: Load real ADaM data from pharmaverseadam
data("adsl", package = "pharmaverseadam")

# Step 2: Create teal_data object with the real dataset
clinical_data <- teal_data()
clinical_data <- within(clinical_data, {
  # Use the real ADSL dataset from pharmaverseadam
  ADSL <- adsl
  
  # The pharmaverseadam ADSL already contains proper CDISC variables:
  # - USUBJID (unique subject identifier)
  # - AGE, AGEGR1 (age and age groups)
  # - SEX, RACE (demographics)
  # - ARM, ACTARM (treatment arms)
  # - SAFFL, ITTFL (analysis flags)
  # - And many other standard ADaM variables
})

# Step 3: Create the teal application with tm_data_table
app <- teal::init(
  data = clinical_data,
  modules = teal::modules(
    teal.modules.tm_data_table(
      label = "Subject Data Explorer",
      dataname = "ADSL"
    )
  )
)

# Step 4: Launch the application
if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### What You'll See in the Application

When you launch this application with real pharmaverseadam data, you'll observe:

1. **Filter Panel (Left)**: Shows filtering options for all ADSL variables
   - **Categorical variables**: SEX, ARM, ACTARM, RACE, AGEGR1, COUNTRY, SAFFL, ITTFL show as checkboxes
   - **Numeric variables**: AGE, BMIBL, HEIGHTBL, WEIGHTBL show as range sliders
   - **Date variables**: RFSTDTC, RFENDTC show as date pickers
   - All filters are interconnected with the data table

2. **Main Content Area (Center)**: Displays the interactive data table with real clinical data
   - **Real subject data**: 254 subjects from the pharmaverseadam study
   - **Standard CDISC variables**: All properly labeled and formatted
   - **Sortable columns**: Click any column header to sort
   - **Search functionality**: Global search across all variables
   - **Professional appearance**: Industry-standard data presentation

3. **Module Controls**: Built-in table options
   - **Export functionality**: Download real clinical data (CSV, Excel)
   - **Column selection**: Show/hide specific CDISC variables
   - **Row selection**: Select subjects for further analysis

### Adding Multiple TMG Modules

Let's expand the example to include several popular TMG modules:

```r
library(teal)
library(teal.modules.general)
library(teal.data)
library(pharmaverseadam)

# Step 1: Load multiple ADaM datasets from pharmaverseadam
data("adsl", package = "pharmaverseadam")
data("adae", package = "pharmaverseadam")

# Step 2: Create comprehensive teal_data with real datasets
comprehensive_data <- teal_data()
comprehensive_data <- within(comprehensive_data, {
  # Use real ADSL dataset - contains all standard CDISC variables
  ADSL <- adsl
  
  # Use real ADAE dataset - contains adverse event data
  ADAE <- adae
  
  # The pharmaverseadam datasets include:
  # ADSL: USUBJID, AGE, AGEGR1, SEX, RACE, ARM, ACTARM, 
  #       BMIBL, HEIGHTBL, WEIGHTBL, SAFFL, ITTFL, and more
  # ADAE: USUBJID, AEDECOD, AEBODSYS, AESEV, AESER, 
  #       AEREL, AEACN, AESTDY, AEENDY, and more
})

# Step 3: Create application with multiple TMG modules using real variables
app <- teal::init(
  data = comprehensive_data,
  modules = teal::modules(
    # Data exploration modules
    tm_data_table(
      label = "ADSL Data Table",
      dataname = "ADSL"
    ),
    
    tm_data_table(
      label = "ADAE Data Table",
      dataname = "ADAE"
    ),
    
    tm_variable_browser(
      label = "Variable Browser",
      dataname = "ADSL"
    ),
    
    # Visualization modules using real pharmaverseadam variables
    tm_g_scatterplot(
      label = "Demographics Scatter Plot",
      dataname = "ADSL",
      x = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("AGE", "BMIBL", "HEIGHTBL", "WEIGHTBL")),
          selected = "AGE"
        )
      ),
      y = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("AGE", "BMIBL", "HEIGHTBL", "WEIGHTBL")),
          selected = "BMIBL"
        )
      ),
      color_by = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("SEX", "ARM", "ACTARM", "RACE", "AGEGR1")),
          selected = "ARM"
        )
      )
    ),
    
    tm_g_distribution(
      label = "Age Distribution",
      dataname = "ADSL",
      dist_var = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("AGE", "BMIBL", "HEIGHTBL", "WEIGHTBL")),
          selected = "AGE"
        )
      ),
      strata_var = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("SEX", "ARM", "ACTARM", "RACE", "AGEGR1")),
          selected = "ARM"
        )
      )
    ),
    
    # Summary and analysis modules
    tm_t_summary(
      label = "Demographics Summary",
      dataname = "ADSL",
      summarize_vars = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("AGE", "BMIBL", "HEIGHTBL", "WEIGHTBL")),
          selected = c("AGE", "BMIBL"),
          multiple = TRUE
        )
      ),
      useNA = "ifany"
    )
  )
)

# Step 3: Launch the comprehensive application
if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### Understanding Module Integration

Each TMG module integrates seamlessly with the `teal` framework:

1. **Data Integration**: Modules automatically connect to datasets specified in `dataname`
2. **Filter Integration**: All modules respond to filters applied in the filter panel
3. **Consistent UI**: Modules follow the same design patterns and user experience
4. **Code Generation**: Modules generate reproducible R code for all operations

### Key TMG Modules and Their Uses

| Module | Purpose | Best For |
|--------|---------|----------|
| `tm_data_table` | Interactive data tables | Data exploration, verification |
| `tm_variable_browser` | Variable summaries and distributions | Understanding data structure |
| `tm_g_scatterplot` | Scatter plots with customization | Correlation analysis, relationships |
| `tm_g_distribution` | Distribution plots (histograms, boxplots) | Understanding variable distributions |
| `tm_t_summary` | Summary statistics tables | Descriptive statistics |
| `tm_g_association` | Association plots and tests | Categorical variable relationships |
| `tm_a_pca` | Principal Component Analysis | Dimensionality reduction |
| `tm_a_regression` | Regression analysis | Predictive modeling |

### Module Configuration Patterns

All TMG modules follow consistent configuration patterns:

```r
# Basic pattern for TMG modules
tm_module_name(
  label = "User-friendly name",           # Appears in navigation
  dataname = "DATASET_NAME",              # Must match dataset in teal_data
  # Module-specific parameters using data_extract_spec
  variable_param = data_extract_spec(
    dataname = "DATASET_NAME",
    select = select_spec(
      choices = variable_choices("DATASET_NAME", c("VAR1", "VAR2")),
      selected = "VAR1"
    )
  )
)
```

### Benefits of Using TMG Modules

1. **Rapid Development**: Pre-built modules eliminate need for custom Shiny development
2. **Consistency**: All modules follow the same interaction patterns
3. **Integration**: Seamless integration with filtering and data management
4. **Reproducibility**: Automatic code generation for all analyses
5. **Flexibility**: Extensive customization options through parameters
6. **Professional Quality**: Production-ready modules with error handling

### Next Steps

This basic example demonstrates how easy it is to create powerful data exploration applications using TMG modules. In the next section, we'll explore more complex scenarios with multiple nested modules and advanced configurations.

### Benefits of Using `pharmaverseadam` Data

Using real datasets from `pharmaverseadam` provides several advantages:

1. **Industry Standard Compliance**: All datasets follow CDISC ADaM implementation guidelines
2. **Realistic Data Structures**: Contains the complexity and nuances of real clinical trial data
3. **Proper Variable Labels**: All variables have appropriate CDISC labels and formats
4. **Comprehensive Coverage**: Includes all standard demographic, safety, and efficacy variables
5. **Reproducible Examples**: Everyone using the same standardized datasets gets identical results
6. **Professional Development**: Training with real data structures prepares for actual work scenarios

### Available pharmaverseadam Datasets

The package includes several key ADaM datasets:

- **`adsl`**: Subject-Level Analysis Dataset (254 subjects)
- **`adae`**: Adverse Events Analysis Dataset  
- **`adlb`**: Laboratory Data Analysis Dataset
- **`adtte`**: Time-to-Event Analysis Dataset
- **`advs`**: Vital Signs Analysis Dataset

Each dataset contains realistic data that follows 
CDISC standards, making your training examples more 
relevant and professional. See more at 
https://pharmaverse.github.io/pharmaverseadam/.

### Key Takeaway

TMG modules provide a robust foundation for building interactive data applications without requiring extensive Shiny development expertise. When combined with standardized `pharmaverseadam` data, they create professional-quality applications that mirror real-world pharmaceutical data analysis workflows. The modules handle complex UI and server logic while allowing you to focus on your data analysis objectives using industry-standard datasets.

---

## Example with Multiple Nested Modules

**Learning Objective:** Understand how to organize complex `teal` applications using nested module structures for better navigation and logical grouping of analyses.

As your `teal` applications grow in complexity, organizing modules into logical groups becomes essential. Module nesting allows you to create hierarchical structures that improve user experience and application maintainability.

### Understanding Module Nesting

Module nesting in `teal` allows you to:

1. **Group related analyses** under common themes
2. **Create hierarchical navigation** for complex applications
3. **Improve user experience** with logical organization
4. **Maintain cleaner code** with structured module definitions
5. **Scale applications** without overwhelming the user interface

### Comprehensive Clinical Data Analysis Application

Let's create a comprehensive clinical data analysis application that demonstrates advanced nested module structures:

```r
library(teal)
library(teal.modules.general)
library(teal.data)
library(pharmaverseadam)

# Step 1: Load multiple ADaM datasets
data("adsl", package = "pharmaverseadam")
data("adae", package = "pharmaverseadam")
data("adlb", package = "pharmaverseadam")

# Step 2: Create comprehensive clinical data object
clinical_study_data <- teal_data()
clinical_study_data <- within(clinical_study_data, {
  # Subject-level data
  ADSL <- adsl
  
  # Adverse events data  
  ADAE <- adae
  
  # Laboratory data
  ADLB <- adlb
})

# Step 3: Create nested module structure
app <- teal::init(
  data = clinical_study_data,
  modules = teal::modules(
    
    # Top-level module group: Data Overview
    teal::modules(
      label = "📊 Data Overview",
      
      tm_data_table(
        label = "Subject Data (ADSL)",
        dataname = "ADSL"
      ),
      
      tm_data_table(
        label = "Adverse Events (ADAE)", 
        dataname = "ADAE"
      ),
      
      tm_data_table(
        label = "Laboratory Data (ADLB)",
        dataname = "ADLB"
      ),
      
      tm_variable_browser(
        label = "Variable Explorer",
        dataname = "ADSL"
      )
    ),
    
    # Top-level module group: Demographics Analysis
    teal::modules(
      label = "👥 Demographics & Baseline",
      
      # Nested subgroup: Demographic Distributions
      teal::modules(
        label = "Demographic Distributions",
        
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
              choices = variable_choices("ADSL", c("ARM", "ACTARM", "SEX", "RACE")),
              selected = "ARM"
            )
          )
        ),
        
        tm_g_distribution(
          label = "BMI Distribution",
          dataname = "ADSL",
          dist_var = data_extract_spec(
            dataname = "ADSL",
            select = select_spec(
              choices = variable_choices("ADSL", "BMIBL"),
              selected = "BMIBL"
            )
          ),
          strata_var = data_extract_spec(
            dataname = "ADSL",
            select = select_spec(
              choices = variable_choices("ADSL", c("ARM", "ACTARM", "SEX")),
              selected = "ARM"
            )
          )
        )
      ),
      
      # Nested subgroup: Demographic Relationships
      teal::modules(
        label = "Demographic Relationships",
        
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
          ),
          color_by = data_extract_spec(
            dataname = "ADSL",
            select = select_spec(
              choices = variable_choices("ADSL", c("ARM", "SEX", "RACE")),
              selected = "ARM"
            )
          )
        ),
        
        tm_g_association(
          label = "Categorical Associations",
          dataname = "ADSL",
          ref = data_extract_spec(
            dataname = "ADSL",
            select = select_spec(
              choices = variable_choices("ADSL", c("ARM", "SEX", "RACE", "AGEGR1")),
              selected = "ARM"
            )
          ),
          vars = data_extract_spec(
            dataname = "ADSL",
            select = select_spec(
              choices = variable_choices("ADSL", c("SEX", "RACE", "AGEGR1", "COUNTRY")),
              selected = c("SEX", "RACE"),
              multiple = TRUE
            )
          )
        )
      ),
      
      # Nested subgroup: Summary Tables
      teal::modules(
        label = "Demographic Summary Tables",
        
        tm_t_summary(
          label = "Demographics by Treatment",
          dataname = "ADSL",
          arm_var = data_extract_spec(
            dataname = "ADSL",
            select = select_spec(
              choices = variable_choices("ADSL", c("ARM", "ACTARM")),
              selected = "ARM"
            )
          ),
          summarize_vars = data_extract_spec(
            dataname = "ADSL",
            select = select_spec(
              choices = variable_choices("ADSL", c("AGE", "BMIBL", "SEX", "RACE")),
              selected = c("AGE", "SEX"),
              multiple = TRUE
            )
          )
        )
      )
    ),
    
    # Top-level module group: Safety Analysis
    teal::modules(
      label = "⚠️ Safety Analysis",
      
      # Nested subgroup: AE Overview
      teal::modules(
        label = "Adverse Events Overview",
        
        tm_t_summary(
          label = "AE Summary by Treatment",
          dataname = "ADAE",
          arm_var = data_extract_spec(
            dataname = "ADAE",
            select = select_spec(
              choices = variable_choices("ADAE", c("ARM", "ACTARM")),
              selected = "ARM"
            )
          ),
          summarize_vars = data_extract_spec(
            dataname = "ADAE",
            select = select_spec(
              choices = variable_choices("ADAE", c("AEDECOD", "AESEV", "AESER")),
              selected = c("AEDECOD", "AESEV"),
              multiple = TRUE
            )
          )
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
              choices = variable_choices("ADAE", c("ARM", "ACTARM", "SEX")),
              selected = "ARM"
            )
          )
        )
      ),
      
      # Nested subgroup: Specific AE Analysis
      teal::modules(
        label = "Detailed AE Analysis",
        
        tm_g_association(
          label = "AE-Treatment Association",
          dataname = "ADAE",
          ref = data_extract_spec(
            dataname = "ADAE",
            select = select_spec(
              choices = variable_choices("ADAE", c("ARM", "ACTARM")),
              selected = "ARM"
            )
          ),
          vars = data_extract_spec(
            dataname = "ADAE",
            select = select_spec(
              choices = variable_choices("ADAE", c("AESEV", "AESER", "AEREL")),
              selected = c("AESEV", "AESER"),
              multiple = TRUE
            )
          )
        )
      )
    ),
    
    # Top-level module group: Laboratory Analysis  
    teal::modules(
      label = "🧪 Laboratory Analysis",
      
      teal::modules(
        label = "Lab Values Overview",
        
        tm_g_distribution(
          label = "Lab Parameter Distribution",
          dataname = "ADLB",
          dist_var = data_extract_spec(
            dataname = "ADLB",
            select = select_spec(
              choices = variable_choices("ADLB", "AVAL"),
              selected = "AVAL"
            )
          ),
          strata_var = data_extract_spec(
            dataname = "ADLB",
            select = select_spec(
              choices = variable_choices("ADLB", c("ARM", "PARAMCD", "VISIT")),
              selected = "PARAMCD"
            )
          )
        ),
        
        tm_g_scatterplot(
          label = "Baseline vs Post-baseline",
          dataname = "ADLB",
          x = data_extract_spec(
            dataname = "ADLB",
            select = select_spec(
              choices = variable_choices("ADLB", "BASE"),
              selected = "BASE"
            )
          ),
          y = data_extract_spec(
            dataname = "ADLB",
            select = select_spec(
              choices = variable_choices("ADLB", "AVAL"),
              selected = "AVAL"
            )
          ),
          color_by = data_extract_spec(
            dataname = "ADLB",
            select = select_spec(
              choices = variable_choices("ADLB", c("ARM", "PARAMCD")),
              selected = "ARM"
            )
          )
        )
      )
    )
  )
)

# Step 4: Launch the comprehensive nested application
if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### Understanding the Nested Structure

This comprehensive example demonstrates several levels of nesting:

#### **Level 1: Main Categories (Top Navigation)**
- 📊 **Data Overview**: Basic data exploration and variable browsing
- 👥 **Demographics & Baseline**: All demographic and baseline analyses  
- ⚠️ **Safety Analysis**: Adverse event analyses
- 🧪 **Laboratory Analysis**: Laboratory data analyses

#### **Level 2: Analysis Groups (Sub-navigation)**
Within Demographics & Baseline:
- **Demographic Distributions**: Distribution plots for key variables
- **Demographic Relationships**: Correlation and association analyses
- **Demographic Summary Tables**: Tabular summaries by treatment

#### **Level 3: Specific Analyses (Individual Modules)**
Each analysis group contains specific modules focused on particular aspects.

### Benefits of This Nested Structure

1. **Logical Organization**: Related analyses are grouped together
2. **Scalable Navigation**: Easy to add new analyses without cluttering
3. **User-Friendly**: Clear hierarchy helps users find relevant analyses
4. **Maintainable Code**: Organized structure makes code easier to maintain
5. **Professional Appearance**: Emojis and clear labels enhance user experience

### Navigation Experience

When users launch this application, they'll see:

1. **Top-level tabs**: Main analysis categories with intuitive icons
2. **Sub-level tabs**: Specific analysis groups within each category
3. **Module content**: Individual analysis modules with their specific controls
4. **Consistent filtering**: All modules respond to the same filter panel
5. **Cross-dataset integration**: Modules can access multiple datasets as configured

### Best Practices for Module Nesting

1. **Logical Grouping**: Group modules by analysis type or data domain
2. **Clear Labels**: Use descriptive names and consider emojis for visual appeal
3. **Balanced Hierarchy**: Avoid too many nesting levels (2-3 levels maximum)
4. **Consistent Structure**: Follow similar patterns across all groups
5. **User-Centric Design**: Organize from the user's analytical workflow perspective

### Advanced Nesting Patterns

```r
# Pattern 1: Domain-based nesting
modules(
  label = "Safety Domain",
  modules(label = "Overview", ...),
  modules(label = "Detailed Analysis", ...),
  modules(label = "Regulatory Tables", ...)
)

# Pattern 2: Analysis-type nesting  
modules(
  label = "Exploratory Analysis",
  modules(label = "Distributions", ...),
  modules(label = "Correlations", ...),
  modules(label = "Associations", ...)
)

# Pattern 3: Data-source nesting
modules(
  label = "ADSL Analysis",
  modules(label = "Demographics", ...),
  modules(label = "Disposition", ...),
  modules(label = "Medical History", ...)
)
```

This nested structure creates a professional, scalable application that can handle complex clinical data analysis workflows while maintaining excellent user experience and code organization.

---

## Understanding `data_extract_spec` Objects

**Learning Objective:** Master how `data_extract_spec` objects control data selection and filtering in `teal.modules.general`, and understand the impact of `select_spec` and `filter_spec` on module behavior.

The `data_extract_spec` is the key mechanism that controls how TMG modules interact with your data. It acts as the bridge between your datasets and the module's analytical functionality, determining both which columns are available for analysis and which rows are included.

### Purpose of `data_extract_spec`

`data_extract_spec` objects serve several critical functions:

1. **Column Selection**: Define which variables from a dataset are available in module dropdowns
2. **Row Filtering**: Apply pre-filters to limit which observations are included
3. **User Interface Control**: Determine what options users see in module controls
4. **Data Processing**: Dictate how modules process and display data
5. **Analysis Scope**: Control the scope and focus of analytical outputs

### How `data_extract_spec` Interacts with Data

```
Dataset → data_extract_spec → Module Processing → User Interface → Analysis Output
   ↓            ↓                    ↓               ↓              ↓
Raw Data → Column Selection → Row Filtering → UI Controls → Final Analysis
         → Variable Choices → Data Subset → User Options → Processed Results
```

### Components of `data_extract_spec`

- **`dataname`**: Specifies which dataset to use
- **`select`**: Controls column selection via `select_spec`
- **`filter`**: Controls row filtering via `filter_spec`
- **`reshape`**: Controls data reshaping (advanced usage)

### Comparative Examples: Understanding the Impact

Let's use the same module (`tm_g_scatterplot`) with three different `data_extract_spec` configurations to demonstrate the impact of `select_spec` and `filter_spec`.

#### Example 1: Using Only `select_spec`

This example shows basic column selection without any row filtering:

```r
library(teal)
library(teal.modules.general)
library(teal.data)
library(pharmaverseadam)

# Load data
data("adsl", package = "pharmaverseadam")

# Create teal_data object
demo_data <- teal_data()
demo_data <- within(demo_data, {
  ADSL <- adsl
})

# Example 1: Only select_spec - Column selection only
app_select_only <- teal::init(
  data = demo_data,
  modules = teal::modules(
    tm_g_scatterplot(
      label = "Example 1: Select Spec Only",
      dataname = "ADSL",
      x = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("AGE", "BMIBL", "HEIGHTBL", "WEIGHTBL")),
          selected = "AGE",
          multiple = FALSE,
          fixed = FALSE
        )
        # No filter specified - all rows included
      ),
      y = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("BMIBL", "HEIGHTBL", "WEIGHTBL")),
          selected = "BMIBL",
          multiple = FALSE,
          fixed = FALSE
        )
        # No filter specified - all rows included
      ),
      color_by = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("ARM", "SEX", "RACE", "AGEGR1")),
          selected = "ARM",
          multiple = FALSE,
          fixed = FALSE
        )
      )
    )
  )
)

# What you'll see:
# - All 254 subjects included in the plot
# - X-axis dropdown: AGE, BMIBL, HEIGHTBL, WEIGHTBL options
# - Y-axis dropdown: BMIBL, HEIGHTBL, WEIGHTBL options  
# - Color dropdown: ARM, SEX, RACE, AGEGR1 options
# - No pre-filtering applied - full dataset used

if (interactive()) {
  shiny::shinyApp(app_select_only$ui, app_select_only$server)
}
```

#### Example 2: Using Only `filter_spec`

This example shows row filtering without restricting column choices:

```r
# Example 2: Only filter_spec - Row filtering only
app_filter_only <- teal::init(
  data = demo_data,
  modules = teal::modules(
    tm_g_scatterplot(
      label = "Example 2: Filter Spec Only",
      dataname = "ADSL",
      x = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL"),  # All numeric variables available
          selected = "AGE",
          multiple = FALSE,
          fixed = FALSE
        ),
        filter = filter_spec(
          vars = "ARM",
          choices = value_choices("ADSL", "ARM"),
          selected = "Placebo",
          multiple = FALSE,
          label = "Treatment Arm"
        )
      ),
      y = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL"),  # All numeric variables available
          selected = "BMIBL",
          multiple = FALSE,
          fixed = FALSE
        ),
        filter = filter_spec(
          vars = "SEX",
          choices = value_choices("ADSL", "SEX"),
          selected = "F",
          multiple = FALSE,
          label = "Gender"
        )
      ),
      color_by = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL"),  # All categorical variables available
          selected = "RACE",
          multiple = FALSE,
          fixed = FALSE
        ),
        filter = filter_spec(
          vars = "AGEGR1",
          choices = value_choices("ADSL", "AGEGR1"),
          selected = c("18-64", ">=65"),
          multiple = TRUE,
          label = "Age Group"
        )
      )
    )
  )
)

# What you'll see:
# - Only female subjects on placebo in specified age groups included
# - X-axis dropdown: All available numeric variables (many options)
# - Y-axis dropdown: All available numeric variables (many options)
# - Color dropdown: All available categorical variables (many options)
# - Pre-filtering applied: ARM="Placebo" AND SEX="F" AND AGEGR1 in ("18-64", ">=65")
# - Smaller subset of data used for analysis

if (interactive()) {
  shiny::shinyApp(app_filter_only$ui, app_filter_only$server)
}
```

#### Example 3: Combining `select_spec` and `filter_spec`

This example shows both column selection and row filtering working together:

```r
# Example 3: Both select_spec and filter_spec - Full control
app_select_and_filter <- teal::init(
  data = demo_data,
  modules = teal::modules(
    tm_g_scatterplot(
      label = "Example 3: Select + Filter Specs",
      dataname = "ADSL",
      x = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("AGE", "BMIBL", "HEIGHTBL")),  # Limited choices
          selected = "AGE",
          multiple = FALSE,
          fixed = FALSE
        ),
        filter = filter_spec(
          vars = "ARM",
          choices = value_choices("ADSL", "ARM"),
          selected = c("Placebo", "Xanomeline High Dose"),
          multiple = TRUE,
          label = "Treatment Arms"
        )
      ),
      y = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("BMIBL", "HEIGHTBL", "WEIGHTBL")),  # Limited choices
          selected = "BMIBL",
          multiple = FALSE,
          fixed = FALSE
        ),
        filter = filter_spec(
          vars = "SAFFL",
          choices = value_choices("ADSL", "SAFFL"),
          selected = "Y",
          multiple = FALSE,
          label = "Safety Population"
        )
      ),
      color_by = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("SEX", "RACE", "AGEGR1")),  # Limited choices
          selected = "SEX",
          multiple = FALSE,
          fixed = FALSE
        ),
        filter = filter_spec(
          vars = "AGE",
          choices = c(18, 85),  # Age range filter
          selected = c(30, 70),
          multiple = TRUE,
          label = "Age Range"
        )
      )
    )
  )
)

# What you'll see:
# - Only subjects aged 30-70 in safety population on specific treatments
# - X-axis dropdown: Only AGE, BMIBL, HEIGHTBL (focused choices)
# - Y-axis dropdown: Only BMIBL, HEIGHTBL, WEIGHTBL (focused choices)
# - Color dropdown: Only SEX, RACE, AGEGR1 (focused choices)
# - Pre-filtering applied: ARM in ("Placebo", "Xanomeline High Dose") AND SAFFL="Y" AND AGE between 30-70
# - Precisely controlled dataset and user options

if (interactive()) {
  shiny::shinyApp(app_select_and_filter$ui, app_select_and_filter$server)
}
```

### Comparing the Three Examples

| Aspect | Example 1 (Select Only) | Example 2 (Filter Only) | Example 3 (Select + Filter) |
|--------|-------------------------|--------------------------|------------------------------|
| **Data Rows** | All 254 subjects | Filtered subset | Filtered subset |
| **Variable Choices** | Limited, focused options | All available variables | Limited, focused options |
| **User Experience** | Clean, focused interface | Many options, can be overwhelming | Optimal: focused + relevant |
| **Analysis Scope** | Broad population analysis | Specific population, broad variables | Specific population, focused variables |
| **Use Case** | General exploration | Population-specific analysis | Targeted, controlled analysis |

### Key Insights About `data_extract_spec`

1. **`select_spec` Impact**:
   - Controls dropdown options in module UI
   - Reduces cognitive load with focused choices
   - Improves user experience with relevant variables only

2. **`filter_spec` Impact**:
   - Pre-filters data before analysis
   - Reduces dataset size for performance
   - Focuses analysis on specific populations

3. **Combined Usage**:
   - Provides optimal control over both data scope and user interface
   - Creates targeted, efficient analyses
   - Balances flexibility with focus

### Advanced `data_extract_spec` Features

```r
# Advanced select_spec options
select_spec(
  choices = variable_choices("ADSL", c("AGE", "BMIBL")),
  selected = "AGE",
  multiple = TRUE,          # Allow multiple variable selection
  fixed = TRUE,            # Prevent user from changing selection
  always_selected = "AGE"  # Keep AGE always selected
)

# Advanced filter_spec options
filter_spec(
  vars = c("ARM", "SEX"),           # Multiple filter variables
  choices = list(
    ARM = c("Placebo", "Treatment"),
    SEX = c("M", "F")
  ),
  selected = list(
    ARM = "Placebo",
    SEX = c("M", "F")
  ),
  multiple = TRUE,
  label = "Population Filters"
)
```

### Best Practices for `data_extract_spec`

1. **Start Simple**: Use `select_spec` only for initial development
2. **Add Filters Gradually**: Introduce `filter_spec` for specific use cases
3. **Focus User Choices**: Limit variable choices to relevant options
4. **Consider Performance**: Use filters to reduce data size
5. **Think User Experience**: Balance flexibility with simplicity
6. **Document Filters**: Use clear labels for filter specifications

### Impact on Module Behavior

The `data_extract_spec` configuration directly affects:
- **Performance**: Filtered data processes faster
- **User Interface**: Focused choices improve usability  
- **Analysis Quality**: Relevant variables lead to better insights
- **Code Reproducibility**: Controlled specs ensure consistent results
- **Application Maintenance**: Well-defined specs are easier to maintain

Understanding `data_extract_spec` is crucial for creating effective TMG modules that provide users with the right balance of flexibility and focus for their analytical needs.