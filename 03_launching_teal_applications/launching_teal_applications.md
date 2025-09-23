# Launching `teal` applications.

## The Simplest `teal` Application

**Learning Objective:** Understand the minimal structure required to launch
a `teal` application and recognize the basic UI components.

The absolute simplest `teal` application requires just the `teal::init()` function
with just one module. This creates a `teal` application that demonstrates
the core UI structure without any additional functionality.

### The `teal` UI

When you launch this minimal application, you'll observe:

1. The `teal` header - displaying the application title
2. A main panel that shows our one empty module.
3. The filter panel on the left - ready to filter data (though no data is loaded yet)
4. The navigation structure - showing how `teal` organizes content

### Basic Structure

Every `teal` application follows this fundamental pattern:

- Initialization using `teal::init()`
- Data specification (must be specified)
- Modules definition (empty module in this case)
- Application launch using the usual Shiny API

### Code Example

```r
# Load the teal library
library(teal)

# Create the simplest possible teal application
app <- teal::init(
  data = teal.data::teal_data(iris = iris),
  modules = teal::module()
)

# Launch the application
if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### What This Demonstrates

This minimal example shows you:

- The `teal` framework structure - even without modules, you can see how `teal` organizes the interface
- The filter panel - appears on the left side, ready to work with data when available
- The modular architecture - the list in the top left shows the module list (with just one module for now)
- The initialization pattern - `teal::init()` is the entry point for all `teal` applications

### Key Observations

1. The UI is responsive - the framework is fully functional even without much content.
2. This same pattern scales to complex applications - this training will use the same
   pattern throughout - passing data and modules to `teal::init`.

### Next Steps

While this minimal application doesn't do much, it establishes the foundation.
In the next section, we'll add a simple module to see how `teal` displays
content and how the different UI panels work together.

---

## `teal` Application with a Module

**Learning Objective:** Understand how modules are displayed in the `teal` UI and identify the key interface components (module area, filter panel, navigation).

Now let's add some actual functionality by including a simple module. 
This will help you understand how `teal` organizes content and where different UI elements appear.
The module we will be using is already built for us - it's from `teal.modules.general`(https://github.com/insightsengineering/teal.modules.general)

### What You'll See

When you launch this application with a module, you'll observe:

1. **Module navigation** - A dropdown or tab structure showing available modules
2. **The main content area** - Where the selected module's output is displayed  
3. **The filter panel** - Now more prominent since we have data to filter
4. **Module-specific controls** - Input elements that control the module's behavior

### Understanding the UI Layout

`teal` applications follow a consistent layout pattern:

- **Top**: Application header with title and navigation
- **Left**: Filter panel for dynamic data filtering
- **Center**: Main content area where modules display their output
- **Module controls**: Usually integrated within the main content area

### Code Example

```r
# Load required libraries
library(teal)
library(teal.modules.general)

# Create some sample data
data <- teal_data(
  IRIS = iris,
  MTCARS = mtcars
)

# Create a teal application with a data table module
app <- init(
  data = data,
  modules = teal::modules(
    teal.modules.general::tm_data_table(
      label = "Data Table",
      dataname = "IRIS"
    )
  )
)

# Launch the application
if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### What This Demonstrates

This example shows you:

- **Module integration** - How `tm_data_table` appears in the interface
- **Data connection** - How the module connects to the `IRIS` dataset
- **Filter panel activation** - The filter panel now shows filtering options for the iris data
- **Navigation structure** - If you had multiple modules, you'd see navigation between them

### Key UI Components Explained

1. **Module Area (Center)**:
   - Displays the active module's output
   - In this case, shows the iris dataset in a table format
   - Includes module-specific controls and options

2. **Filter Panel (Left)**:
   - Shows all available datasets (IRIS, MTCARS in this example)
   - Provides filtering controls for each variable in each dataset
   - Filters apply across all modules that use the same data

3. **Module Navigation**:
   - When you have multiple modules, navigation appears at the top
   - Shows module labels and allows switching between different analyses
   - In this single-module example, navigation is minimal

### Interactive Features

Try these interactions in the application:

1. **Filtering**: Use the filter panel to subset the iris data (e.g., filter by Species)
2. **Table exploration**: Sort and search within the data table
3. **Responsive design**: Resize the browser to see how the layout adapts

### Observations About `teal`'s Design

- **Consistent layout** - Every `teal` app follows the same visual pattern
- **Integrated filtering** - Filters work seamlessly with all modules
- **Modular content** - Each module occupies the same content area
- **Data awareness** - The filter panel automatically adapts to your datasets

---

## Understanding `teal::init` and Its Components

**Learning Objective:** Master the `teal::init()` function by understanding its key arguments and how they work together to create a complete `teal` application.

The `teal::init()` function is the heart of every `teal` application. It brings together your data, modules, and configuration options to create a functional interactive application. 

### The `teal::init()` Function Signature

```r
init(
  data,
  modules,
  filter = teal_slices(),
  title = "teal app",
  header = tags$p(),
  footer = tags$p(),
  ...
)
```

### The `data` Argument - Your Application's Foundation

The `data` argument is where you specify all the datasets your application will use. There are several ways to provide data to `teal`:

#### Option 1: Using `teal_data()`

```r
# Create data using teal_data()
my_data <- teal_data(
  ADSL = adsl_data,
  ADAE = adae_data,
  IRIS = iris
)

app <- init(
  data = my_data,
  modules = modules(...)
)
```

#### Option 2: Using `cdisc_data()` for Clinical Data

```r
# For CDISC/ADaM data with relationships
my_data <- cdisc_data(
  ADSL = adsl_data,
  ADAE = adae_data,
  code = c(
    "ADSL <- adsl_data",
    "ADAE <- adae_data"
  )
)

app <- init(
  data = my_data,
  modules = modules(...)
)
```

#### What the `data` Argument Controls:

- **Available datasets** - Which datasets appear in the filter panel
- **Data relationships** - How datasets connect to each other (via `join_keys`)
- **Reproducibility** - Code tracking for generating the data

### The `modules` Argument - Your Application's Functionality

The `modules` argument defines what your application can do. It accepts a `modules()` object containing one or more `teal` modules.

#### Single Module Example

```r
app <- init(
  data = teal_data(IRIS = iris),
  modules = modules(
    tm_data_table(
      label = "Data Explorer",
      dataname = "IRIS"
    )
  )
)
```

#### Multiple Modules Example

```r
app <- teal::init(
  data = teal_data(IRIS = iris, MTCARS = mtcars),
  modules = teal::modules(
    tm_data_table(
      label = "Data Tables",
      dataname = "IRIS"
    ),
    tm_variable_browser(
      label = "Variable Browser",
      dataname = "IRIS"
    ),
    tm_g_scatterplot(
      label = "Scatter Plot",
      dataname = "IRIS",
      x = data_extract_spec(
        dataname = "IRIS",
        select = select_spec(
          choices = variable_choices("IRIS", c("Sepal.Length", "Sepal.Width")),
          selected = "Sepal.Length"
        )
      ),
      y = data_extract_spec(
        dataname = "IRIS",
        select = select_spec(
          choices = variable_choices("IRIS", c("Petal.Length", "Petal.Width")),
          selected = "Petal.Length"
        )
      )
    )
  )
)
```

#### Nested Modules Example

```r
app <- init(
  data = teal_data(IRIS = iris, MTCARS = mtcars),
  modules = modules(
    label = "Data Exploration",
    modules(
      label = "Tables",
      tm_data_table("IRIS Table", dataname = "IRIS"),
      tm_data_table("MTCARS Table", dataname = "MTCARS")
    ),
    modules(
      label = "Visualizations", 
      tm_g_scatterplot("Scatter", dataname = "IRIS", ...),
      tm_g_distribution("Distribution", dataname = "IRIS", ...)
    )
  )
)
```

### How `data` and `modules` Work Together

The relationship between `data` and `modules` is crucial:

1. **Data availability** - Modules can only use datasets specified in the `data` argument
2. **Filter integration** - The filter panel shows all datasets from `data`, and filters apply to all modules using those datasets
3. **Code reproducibility** - `teal` tracks how data flows from the `data` argument through filters to modules

### Complete Example with Both Arguments

```r
library(teal)
library(teal.modules.general)

# Step 1: Prepare the data
app_data <- teal_data(
  IRIS = iris,
  MTCARS = mtcars
)

# Step 2: Define the modules
app_modules <- modules(
  tm_data_table(
    label = "Data Table",
    dataname = "IRIS"
  ),
  tm_variable_browser(
    label = "Variable Browser", 
    dataname = "IRIS"
  ),
  tm_g_scatterplot(
    label = "Scatter Plot",
    dataname = "IRIS",
    x = data_extract_spec(
      dataname = "IRIS",
      select = select_spec(
        choices = variable_choices("IRIS", c("Sepal.Length", "Sepal.Width")),
        selected = "Sepal.Length"
      )
    ),
    y = data_extract_spec(
      dataname = "IRIS", 
      select = select_spec(
        choices = variable_choices("IRIS", c("Petal.Length", "Petal.Width")),
        selected = "Petal.Length"
      )
    )
  )
)

# Step 3: Initialize the application
app <- init(
  data = app_data,
  modules = app_modules
)

# Step 4: Launch the application
if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### Key Insights About `teal::init()`

1. **Data-first approach** - Always define your data structure before configuring modules
2. **Module flexibility** - You can mix different types of modules in the same application
3. **Automatic integration** - `teal` handles the connections between data, filters, and modules
4. **Scalable structure** - The same pattern works for simple and complex applications

### Common Patterns

- **Start simple** - Begin with one dataset and one module, then add complexity
- **Group related modules** - Use nested `modules()` to organize functionality
- **Match data to modules** - Ensure each module's `dataname` exists in your `data` argument
- **Plan your data structure** - Consider what datasets and relationships you need before building modules
---

## Additional Modifiers for `teal` Applications

**Learning Objective:** Learn how to customize `teal` application appearance and user experience using modifier functions and landing modals.

Beyond the core `data` and `modules` arguments, `teal` provides several functions to enhance your application's appearance and user experience. These modifiers allow you to customize the title, header, footer, and add welcome messages to create a more professional and user-friendly application.

### Understanding `teal` Modifiers

`teal` uses a pipe-friendly approach for application customization. After creating your base application with `teal::init()`, you can chain modifier functions to customize various aspects of the interface.

### Customizing the Application Title

The `modify_title()` function changes the title that appears in the browser tab and can affect the main header display.

```r
library(teal)
library(teal.modules.general)

# Basic application with custom title
app <- teal::init(
  data = teal_data(IRIS = iris),
  modules = teal::modules(
    tm_data_table(
      label = "Data Explorer",
      dataname = "IRIS"
    )
  )
) |>
  modify_title(title = "My Clinical Data Explorer")

if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### Customizing the Header

The `modify_header()` function allows you to replace or enhance the default header with custom HTML content.

```r
# Application with custom header
custom_header <- tags$div(
  style = "background-color: #f8f9fa; padding: 10px; text-align: center;",
  tags$h2("Clinical Data Analysis Platform", style = "color: #2c3e50; margin: 0;"),
  tags$p("Powered by teal framework", style = "color: #7f8c8d; margin: 5px 0 0 0;")
)

app <- teal::init(
  data = teal_data(IRIS = iris, MTCARS = mtcars),
  modules = teal::modules(
    tm_data_table("Data Table", dataname = "IRIS"),
    tm_variable_browser("Variable Browser", dataname = "IRIS")
  )
) |>
  modify_header(element = custom_header)

if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### Customizing the Footer

The `modify_footer()` function adds or replaces footer content, useful for disclaimers, contact information, or version details.

```r
# Application with custom footer
custom_footer <- tags$div(
  style = "text-align: center; padding: 10px; background-color: #ecf0f1; color: #34495e;",
  tags$p("© 2024 Clinical Research Organization"),
  tags$p("For questions contact: data-team@example.com"),
  tags$small("Version 1.0 | Last updated: 2024")
)

app <- teal::init(
  data = teal_data(IRIS = iris),
  modules = teal::modules(
    tm_data_table("Data Explorer", dataname = "IRIS")
  )
) |>
  modify_footer(element = custom_footer)

if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### Combining Multiple Modifiers

You can chain multiple modifiers together to create a fully customized application:

```r
# Fully customized application
app <- teal::init(
  data = teal_data(IRIS = iris, MTCARS = mtcars),
  modules = teal::modules(
    tm_data_table("Data Table", dataname = "IRIS"),
    tm_g_scatterplot(
      label = "Scatter Plot",
      dataname = "IRIS",
      x = data_extract_spec(
        dataname = "IRIS",
        select = select_spec(
          choices = variable_choices("IRIS", c("Sepal.Length", "Sepal.Width")),
          selected = "Sepal.Length"
        )
      ),
      y = data_extract_spec(
        dataname = "IRIS",
        select = select_spec(
          choices = variable_choices("IRIS", c("Petal.Length", "Petal.Width")),
          selected = "Petal.Length"
        )
      )
    )
  )
) |>
  modify_title(title = "Clinical Data Analysis Suite") |>
  modify_header(
    element = tags$div(
      style = "background: linear-gradient(90deg, #3498db, #2ecc71); color: white; padding: 15px; text-align: center;",
      tags$h1("Data Explorer", style = "margin: 0;"),
      tags$p("Interactive Analysis Platform", style = "margin: 5px 0 0 0;")
    )
  ) |>
  modify_footer(
    element = tags$div(
      style = "text-align: center; padding: 10px; background-color: #34495e; color: white;",
      "Confidential - For Internal Use Only"
    )
  )

if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### Adding a Landing Modal

The `add_landing_modal()` function creates a welcome dialog that appears when users first access your application. This is perfect for providing instructions, disclaimers, or important announcements.

#### Basic Landing Modal

```r
app <- teal::init(
  data = teal_data(IRIS = iris),
  modules = teal::modules(
    tm_data_table("Data Explorer", dataname = "IRIS")
  )
) |>
  add_landing_modal(
    title = "Welcome to the Data Explorer",
    content = "This application allows you to explore and analyze the iris dataset interactively.",
    footer = modalButton("Get Started")
  )

if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

#### Advanced Landing Modal with Rich Content

```r
# Create rich content for the modal
modal_content <- tags$div(
  tags$h4("Welcome to Clinical Data Analysis Platform"),
  tags$p("This application provides interactive tools for exploring clinical trial data."),
  tags$hr(),
  tags$h5("Features:"),
  tags$ul(
    tags$li("Interactive data tables with filtering and sorting"),
    tags$li("Dynamic visualizations and plots"),
    tags$li("Integrated filter panel for data subsetting"),
    tags$li("Reproducible analysis with code generation")
  ),
  tags$hr(),
  tags$p(
    tags$strong("Important:"), 
    " This application contains confidential clinical data. ",
    "Please ensure compliance with data governance policies."
  )
)

app <- teal::init(
  data = teal_data(IRIS = iris, MTCARS = mtcars),
  modules = teal::modules(
    tm_data_table("Data Table", dataname = "IRIS"),
    tm_variable_browser("Variable Browser", dataname = "IRIS")
  )
) |>
  add_landing_modal(
    title = "Clinical Data Explorer v2.0",
    content = modal_content,
    footer = tagList(
      modalButton("Cancel"),
      actionButton("accept", "I Understand", class = "btn-primary")
    )
  )

if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
```

### Best Practices for Application Modifiers

1. **Keep headers concise** - Headers should be informative but not overwhelming
2. **Use consistent styling** - Match your organization's branding guidelines
3. **Include important disclaimers** - Use footers for legal or contact information
4. **Make landing modals informative** - Provide clear instructions and expectations
5. **Consider mobile users** - Ensure custom elements work on different screen sizes

### Common Use Cases

- **Corporate branding** - Add company logos and colors to headers
- **Regulatory compliance** - Include required disclaimers in footers or landing modals
- **User guidance** - Use landing modals to explain application purpose and usage
- **Version information** - Display version numbers and update dates in footers
- **Contact information** - Provide support contacts in footers

### Key Points to Remember

- **Modifier functions are chainable** - Use the pipe operator `|>` to combine multiple modifications
- **HTML content is supported** - Use `tags$` functions to create rich, styled content
- **Modals appear on load** - Landing modals automatically display when the application starts
- **Styling is customizable** - Use CSS styles to match your organization's design requirements

---

## Troubleshooting Common Launch Issues

**Learning Objective:** Identify and resolve common problems that occur when launching `teal` applications, enabling you to debug and fix issues independently.

Even well-constructed `teal` applications can encounter launch issues. Understanding common problems and their solutions will help you develop more robust applications and troubleshoot issues quickly.

### Common Error Categories

`teal` launch issues typically fall into these categories:
1. **Data-related errors** - Problems with data structure or content
2. **Module configuration errors** - Incorrect module setup or parameters
3. **Dependency issues** - Missing packages or version conflicts
4. **Memory and performance issues** - Large datasets or complex operations

### Data-Related Launch Issues

#### Problem: "object not found" errors

```r
# This will cause an error
app <- teal::init(
  data = teal_data(IRIS = iris),
  modules = teal::modules(
    tm_data_table("Data Table", dataname = "MTCARS")  # MTCARS not in data!
  )
)
```

**Error message:** `Error: object 'MTCARS' not found`

**Solution:** Ensure all `dataname` arguments in modules match datasets in your `data` argument.

```r
# Corrected version
app <- teal::init(
  data = teal_data(IRIS = iris, MTCARS = mtcars),  # Include MTCARS
  modules = teal::modules(
    tm_data_table("Data Table", dataname = "MTCARS")
  )
)
```

#### Problem: Empty or NULL data

```r
# This may cause issues
empty_data <- data.frame()
app <- teal::init(
  data = teal_data(EMPTY = empty_data),
  modules = teal::modules(
    tm_data_table("Data Table", dataname = "EMPTY")
  )
)
```

**Symptoms:** Application launches but modules show no content or errors

**Solution:** Always validate your data before passing to `teal_data()`:

```r
# Data validation approach
validate_data <- function(df, name) {
  if (is.null(df) || nrow(df) == 0) {
    stop(paste("Dataset", name, "is empty or NULL"))
  }
  if (ncol(df) == 0) {
    stop(paste("Dataset", name, "has no columns"))
  }
  return(df)
}

# Use validation
safe_data <- validate_data(your_data, "YOUR_DATA")
app <- teal::init(
  data = teal_data(YOUR_DATA = safe_data),
  modules = teal::modules(...)
)
```

### Module Configuration Issues

#### Problem: Incorrect `data_extract_spec` configuration

```r
# This will cause an error
app <- teal::init(
  data = teal_data(IRIS = iris),
  modules = teal::modules(
    tm_g_scatterplot(
      label = "Scatter Plot",
      dataname = "IRIS",
      x = data_extract_spec(
        dataname = "IRIS",
        select = select_spec(
          choices = variable_choices("IRIS", "NonExistentColumn"),  # Column doesn't exist!
          selected = "NonExistentColumn"
        )
      )
    )
  )
)
```

**Error message:** Variable selection errors or empty dropdowns

**Solution:** Use `variable_choices()` with existing column names or let it auto-detect:

```r
# Safe approach - let variable_choices auto-detect
app <- teal::init(
  data = teal_data(IRIS = iris),
  modules = teal::modules(
    tm_g_scatterplot(
      label = "Scatter Plot",
      dataname = "IRIS",
      x = data_extract_spec(
        dataname = "IRIS",
        select = select_spec(
          choices = variable_choices("IRIS"),  # Auto-detect all columns
          selected = NULL  # Let user choose
        )
      ),
      y = data_extract_spec(
        dataname = "IRIS",
        select = select_spec(
          choices = variable_choices("IRIS", c("Petal.Length", "Petal.Width")),
          selected = "Petal.Length"
        )
      )
    )
  )
)
```

#### Problem: Missing required module arguments

```r
# This may cause issues
app <- teal::init(
  data = teal_data(IRIS = iris),
  modules = teal::modules(
    tm_data_table()  # Missing required 'dataname' argument
  )
)
```

**Solution:** Always check module documentation for required arguments:

```r
# Correct usage
app <- teal::init(
  data = teal_data(IRIS = iris),
  modules = teal::modules(
    tm_data_table(
      label = "Data Table",    # Good practice to include label
      dataname = "IRIS"        # Required argument
    )
  )
)
```

### Dependency and Package Issues

#### Problem: Package not installed or wrong version

**Error messages:**
- `Error: there is no package called 'teal.modules.general'`
- `Error: namespace 'teal' X.Y.Z is already loaded, but >= A.B.C is required`

**Solution:** Check and install required packages:

```r
# Check if packages are installed and their versions
check_teal_packages <- function() {
  required_packages <- c("teal", "teal.modules.general", "teal.data")
  
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      message(paste("Installing", pkg))
      install.packages(pkg)
    } else {
      message(paste(pkg, "version:", packageVersion(pkg)))
    }
  }
}

check_teal_packages()
```

#### Problem: Conflicting package versions

**Solution:** Use a consistent package environment:

```r
# Check for conflicts
library(teal)
library(teal.modules.general)
library(teal.data)

# If you encounter version conflicts, restart R session and load in order
```

### Memory and Performance Issues

#### Problem: Application takes too long to load or crashes

**Symptoms:**
- Long loading times
- Browser timeout
- R session crashes

**Solutions:**

1. **Reduce data size for testing:**

```r
# Use sample of large dataset for development
large_data <- your_large_dataset
sample_data <- large_data[sample(nrow(large_data), 1000), ]

app <- teal::init(
  data = teal_data(SAMPLE = sample_data),
  modules = teal::modules(...)
)
```

2. **Optimize data types:**

```r
# Convert character columns to factors if appropriate
optimize_data <- function(df) {
  char_cols <- sapply(df, is.character)
  df[char_cols] <- lapply(df[char_cols], as.factor)
  return(df)
}

optimized_data <- optimize_data(your_data)
```

### Debugging Strategies

#### 1. Incremental Development

Start simple and add complexity gradually:

```r
# Step 1: Minimal working application
app_minimal <- teal::init(
  data = teal_data(IRIS = iris),
  modules = teal::modules(
    tm_data_table("Simple Table", dataname = "IRIS")
  )
)

# Step 2: Add more modules one by one
# Step 3: Add custom configurations
# Step 4: Add modifiers
```

#### 2. Check Data Structure

Always inspect your data before using it:

```r
# Data inspection checklist
inspect_data <- function(data, name) {
  cat("Dataset:", name, "\n")
  cat("Dimensions:", dim(data), "\n")
  cat("Column names:", paste(names(data), collapse = ", "), "\n")
  cat("Column types:", paste(sapply(data, class), collapse = ", "), "\n")
  cat("Missing values:", sum(is.na(data)), "\n")
  cat("First few rows:\n")
  print(head(data, 3))
  cat("\n")
}

inspect_data(iris, "IRIS")
```

#### 3. Test Modules Individually

Test each module separately before combining:

```r
# Test individual modules
test_module <- function(data, module_func) {
  tryCatch({
    app <- teal::init(data = data, modules = teal::modules(module_func))
    message("Module test passed")
    return(TRUE)
  }, error = function(e) {
    message("Module test failed:", e$message)
    return(FALSE)
  })
}
```

### Common Warning Messages and Solutions

#### Warning: "No data available for filtering"

**Cause:** Filter panel can't find filterable variables
**Solution:** Ensure your data has appropriate variable types:

```r
# Convert logical/character variables to factors for filtering
data_with_factors <- iris
data_with_factors$Species <- as.factor(data_with_factors$Species)
```

#### Warning: "Module produces no output"

**Cause:** Module configuration doesn't match data structure
**Solution:** Check variable names and types match module expectations

### Quick Diagnostic Checklist

When your `teal` application won't launch, check:

1. ✅ **Data exists and has content** - `nrow(data) > 0`
2. ✅ **All datanames in modules exist in data** - Match names exactly
3. ✅ **Required packages are loaded** - `library()` calls at top
4. ✅ **Variable names are correct** - Check spelling and case
5. ✅ **Data types are appropriate** - Factors for categorical, numeric for continuous
6. ✅ **No circular dependencies** - Modules don't reference each other incorrectly

### Getting Help

When you encounter issues:

1. **Read error messages carefully** - They often contain the exact problem
2. **Check the console** - Look for warnings and additional error details  
3. **Use `traceback()`** - Shows the call stack when errors occur
4. **Simplify your code** - Remove complexity until it works, then add back gradually
5. **Check documentation** - Verify function arguments and usage examples

### Example: Complete Diagnostic Workflow

```r
# Complete troubleshooting workflow
debug_teal_app <- function() {
  # Step 1: Check data
  cat("Checking data...\n")
  if (!exists("iris")) stop("iris dataset not available")
  inspect_data(iris, "IRIS")
  
  # Step 2: Test minimal app
  cat("Testing minimal app...\n")
  minimal_app <- teal::init(
    data = teal_data(IRIS = iris),
    modules = teal::modules()
  )
  cat("Minimal app created successfully\n")
  
  # Step 3: Test with simple module
  cat("Testing with simple module...\n")
  simple_app <- teal::init(
    data = teal_data(IRIS = iris),
    modules = teal::modules(
      tm_data_table("Data Table", dataname = "IRIS")
    )
  )
  cat("Simple app created successfully\n")
  
  # Step 4: Launch if all tests pass
  if (interactive()) {
    shiny::shinyApp(simple_app$ui, simple_app$server)
  }
}

# Run diagnostic
debug_teal_app()
```

Remember: Most `teal` launch issues are due to data-module mismatches or missing dependencies. Start with the basics and build complexity gradually.
