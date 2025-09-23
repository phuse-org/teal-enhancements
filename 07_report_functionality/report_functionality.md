# Report Functionality

**Learning Objectives:**
- Understand the role of the report in a `teal` application
- Can save and import a report
- Master the report UI structure and editing capabilities
- Understand how to investigate and work with saved reports

The report functionality in `teal` applications provides users with powerful capabilities to generate, customize, and share reproducible analysis reports. This feature leverages the `teal.reporter` package to create professional documentation of analysis workflows, making it easy to communicate findings and maintain analysis reproducibility.

---

## The Structure of the Report UI

**Learning Objective:** Master the report interface components and understand how to interact with report generation tools.

The report functionality in `teal` applications is integrated seamlessly into the user interface, providing intuitive tools for report creation and management.

### Report UI Components Overview

```r
library(teal)
library(teal.modules.general)
library(teal.data)
library(pharmaverseadam)

# Load data for report functionality demonstration
data("adsl", package = "pharmaverseadam")
data("adae", package = "pharmaverseadam")

# Create teal_data object
report_demo_data <- teal_data()
report_demo_data <- within(report_demo_data, {
  ADSL <- adsl
  ADAE <- adae
})

# Application with comprehensive reporting capabilities
report_ui_demo <- teal::init(
  data = report_demo_data,
  modules = teal::modules(
    tm_data_table(
      label = "ADSL Data Explorer",
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
    ),
    tm_g_scatterplot(
      label = "Age vs BMI Scatter",
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
    ),
    tm_t_summary(
      label = "Demographics Summary",
      dataname = "ADSL",
      summarize_vars = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("AGE", "SEX", "RACE", "BMIBL")),
          selected = c("AGE", "SEX", "RACE"),
          multiple = TRUE
        )
      )
    )
  ),
  title = "Clinical Data Analysis - Report Functionality Demo"
)

# When you run this application, you'll see the report interface components:
# 1. "Add to Report" button in each module
# 2. "Report" tab in the main navigation
# 3. Report preview and management tools

if (interactive()) {
  shiny::shinyApp(report_ui_demo$ui, report_ui_demo$server)
}
```

### Report UI Structure Components

When you launch the application, the report functionality provides several key interface elements:

#### **1. Module-Level Report Controls**

Each module in your `teal` application automatically includes:

- **"Add to Report" Button**: Located in each module's interface
- **Content Selection**: Choose which outputs to include (plots, tables, summaries)
- **Custom Naming**: Add descriptive titles and comments for report cards
- **Immediate Feedback**: Visual confirmation when content is added

#### **2. Main Report Tab**

The dedicated "Report" tab provides:

- **Report Preview**: Live view of all added report cards
- **Report Organization**: Drag-and-drop reordering of report sections
- **Report Management**: Tools for editing, removing, and organizing content
- **Export Options**: Download reports in multiple formats

#### **3. Report Card Management**

Individual report cards feature:

- **Card Headers**: Module name, timestamp, and custom titles
- **Content Display**: Plots, tables, and analysis outputs
- **Edit Controls**: Modify titles, add comments, remove cards
- **Reordering**: Drag-and-drop functionality for logical organization

---

## Adding to the Report

**Learning Objective:** Master the process of adding analysis content to reports and customizing report cards.

### Basic Report Addition Workflow

```r
# Comprehensive example demonstrating report addition
report_addition_demo <- teal::init(
  data = report_demo_data,
  modules = teal::modules(
    # Data exploration module
    tm_data_table(
      label = "📊 ADSL Data Table",
      dataname = "ADSL"
    ),
    
    # Visualization modules  
    teal::modules(
      label = "📈 Demographics Analysis",
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
      ),
      tm_g_scatterplot(
        label = "BMI vs Age Relationship",
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
            choices = variable_choices("ADSL", "SEX"),
            selected = "SEX"
          )
        )
      )
    ),
    
    # Summary analysis module
    tm_t_summary(
      label = "📋 Baseline Demographics Summary",
      dataname = "ADSL",
      summarize_vars = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("AGE", "SEX", "RACE", "BMIBL", "HEIGHTBL")),
          selected = c("AGE", "SEX", "RACE"),
          multiple = TRUE
        )
      ),
      by_vars = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", "ARM"),
          selected = "ARM"
        )
      )
    )
  ),
  # Start with some filters to create meaningful analysis context
  filter = teal_slices(
    teal_slice(
      dataname = "ADSL",
      varname = "SAFFL",
      selected = "Y",
      title = "Safety Population"
    )
  ),
  title = "Clinical Study Report Generation"
)

# Step-by-step report addition process:
# 1. Navigate to "Age Distribution by Treatment" module
# 2. Configure the plot (age distribution by treatment arm)
# 3. Click "Add to Report" button
# 4. Add custom title: "Figure 1: Age Distribution Across Treatment Groups"
# 5. Add comment: "Safety population analysis showing age distribution"
# 6. Repeat for other modules to build comprehensive report

if (interactive()) {
  shiny::shinyApp(report_addition_demo$ui, report_addition_demo$server)
}
```

### Report Addition Best Practices

1. **Logical Organization**: Add content in the order you want it to appear
2. **Descriptive Titles**: Use clear, professional titles for each report card
3. **Contextual Comments**: Include methodology, interpretation, and limitations
4. **Filter Documentation**: Note the population and filters applied
5. **Cross-References**: Link related analyses and findings

---

## Previewing the Report

**Learning Objective:** Master the report preview functionality and understand how to review and organize report content before finalization.

### Report Preview Interface

The report preview provides a comprehensive view of your analysis documentation:

```r
# Application specifically designed to demonstrate report preview capabilities
preview_demo <- teal::init(
  data = report_demo_data,
  modules = teal::modules(
    # Create a series of analyses for comprehensive report preview
    teal::modules(
      label = "👥 Population Analysis",
      tm_data_table(
        label = "Subject Disposition",
        dataname = "ADSL"
      ),
      tm_t_summary(
        label = "Demographics Summary",
        dataname = "ADSL",
        summarize_vars = data_extract_spec(
          dataname = "ADSL",
          select = select_spec(
            choices = variable_choices("ADSL", c("AGE", "SEX", "RACE")),
            selected = c("AGE", "SEX", "RACE"),
            multiple = TRUE
          )
        ),
        by_vars = data_extract_spec(
          dataname = "ADSL",
          select = select_spec(
            choices = variable_choices("ADSL", "ARM"),
            selected = "ARM"
          )
        )
      )
    ),
    
    teal::modules(
      label = "📊 Exploratory Analysis",
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
      ),
      tm_g_scatterplot(
        label = "Baseline Characteristics",
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
    )
  ),
  title = "Clinical Study Analysis - Report Preview Demo"
)

# Report preview workflow:
# 1. Add multiple analyses to the report from different modules
# 2. Navigate to the "Report" tab to see preview
# 3. Review the complete report structure
# 4. Check content organization and flow
# 5. Verify all analyses are properly documented

if (interactive()) {
  shiny::shinyApp(preview_demo$ui, preview_demo$server)
}
```

### Preview Interface Components

#### **Report Structure View**
- **Table of Contents**: Overview of all report sections
- **Card Sequence**: Visual representation of report flow
- **Content Summary**: Quick overview of included analyses
- **Filter Context**: Documentation of applied data filters

#### **Individual Card Preview**
- **Full Content Display**: Complete view of plots, tables, and outputs
- **Metadata Information**: Timestamps, module sources, filter states
- **Custom Annotations**: Titles, comments, and interpretations
- **Reproducibility Info**: R code and data processing details

#### **Navigation Tools**
- **Section Jumping**: Quick navigation between report sections
- **Search Functionality**: Find specific content within the report
- **Zoom Controls**: Detailed view of individual visualizations
- **Print Preview**: Layout optimization for different output formats

---

## Basic Report Edits: Rearrange Report Cards

**Learning Objective:** Master report organization and editing capabilities to create logically structured analysis documentation.

### Report Card Reordering

```r
# Demonstration of report editing and organization capabilities
report_editing_demo <- teal::init(
  data = report_demo_data,
  modules = teal::modules(
    # Multiple modules to create content for reordering demonstration
    tm_data_table(
      label = "A. Data Overview",
      dataname = "ADSL"
    ),
    tm_g_distribution(
      label = "D. Age Distribution",  # Will be reordered
      dataname = "ADSL",
      dist_var = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", "AGE"),
          selected = "AGE"
        )
      )
    ),
    tm_t_summary(
      label = "B. Demographics Summary",  # Will be reordered
      dataname = "ADSL",
      summarize_vars = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("AGE", "SEX", "RACE")),
          selected = c("AGE", "SEX", "RACE"),
          multiple = TRUE
        )
      )
    ),
    tm_g_scatterplot(
      label = "C. Baseline Correlations",  # Will be reordered
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
  ),
  title = "Report Organization Demo"
)

# Report editing workflow:
# 1. Add content from modules in any order (D, B, C, A)
# 2. Navigate to Report tab to see current organization
# 3. Use drag-and-drop to reorder cards logically (A, B, C, D)
# 4. Verify the new organization makes analytical sense
# 5. Add section headers and transitions between analyses

if (interactive()) {
  shiny::shinyApp(report_editing_demo$ui, report_editing_demo$server)
}
```

### Report Editing Capabilities

#### **Drag-and-Drop Reordering**
- **Visual Interface**: Intuitive drag-and-drop controls
- **Section Management**: Organize cards into logical sections
- **Real-time Preview**: See changes immediately
- **Undo Functionality**: Reverse unwanted changes

#### **Card Editing Options**
- **Title Modification**: Update titles for clarity and professionalism
- **Comment Addition**: Add interpretation, methodology notes, limitations
- **Card Removal**: Delete unnecessary or outdated content
- **Duplicate Detection**: Identify and manage similar content

#### **Content Enhancement**
- **Section Headers**: Add organizational structure
- **Transition Text**: Connect related analyses
- **Methodology Notes**: Document analytical approaches
- **Interpretation Comments**: Provide clinical context and conclusions

---

## Saving the Report

**Learning Objective:** Master the report export process and understand different output formats for various use cases.

### Report Export Options

```r
# Comprehensive example for report saving demonstration
report_saving_demo <- teal::init(
  data = report_demo_data,
  modules = teal::modules(
    # Create a complete analysis workflow for export
    teal::modules(
      label = "📊 Study Population",
      tm_data_table(
        label = "Subject Listing",
        dataname = "ADSL"
      ),
      tm_t_summary(
        label = "Demographic Characteristics",
        dataname = "ADSL",
        summarize_vars = data_extract_spec(
          dataname = "ADSL",
          select = select_spec(
            choices = variable_choices("ADSL", c("AGE", "SEX", "RACE", "BMIBL")),
            selected = c("AGE", "SEX", "RACE"),
            multiple = TRUE
          )
        ),
        by_vars = data_extract_spec(
          dataname = "ADSL",
          select = select_spec(
            choices = variable_choices("ADSL", "ARM"),
            selected = "ARM"
          )
        )
      )
    ),
    
    teal::modules(
      label = "📈 Exploratory Analysis",
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
      ),
      tm_g_scatterplot(
        label = "BMI vs Age Analysis",
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
    )
  ),
  # Apply meaningful filters for the analysis context
  filter = teal_slices(
    teal_slice(
      dataname = "ADSL",
      varname = "SAFFL",
      selected = "Y",
      title = "Safety Population"
    ),
    teal_slice(
      dataname = "ADSL",
      varname = "ARM",
      selected = c("Placebo", "Xanomeline High Dose"),
      title = "Primary Analysis Arms"
    )
  ),
  title = "Clinical Study Analysis - Export Demo"
)

# Report saving workflow:
# 1. Complete your analysis and add content to report
# 2. Navigate to Report tab and review content
# 3. Click "Download Report" button
# 4. Choose export format (HTML, PDF, Word)
# 5. Add report metadata (title, author, date)
# 6. Customize export settings
# 7. Save report to desired location

if (interactive()) {
  shiny::shinyApp(report_saving_demo$ui, report_saving_demo$server)
}
```

### Export Format Options

#### **HTML Reports**
- **Interactive plots and tables**
- **Embedded R code for reproducibility**
- **Cross-references and navigation**
- **Responsive design for different devices**
- **Easy sharing via web browsers**

#### **PDF Reports**
- **High-quality graphics and tables**
- **Consistent formatting across platforms**
- **Professional layout and typography**
- **Suitable for regulatory submissions**
- **Offline accessibility**

#### **Word Document Reports**
- **Editable text and formatting**
- **Comment and review capabilities**
- **Integration with Microsoft Office**
- **Template customization options**
- **Track changes functionality**

---

## Investigating a Saved `teal` Report

**Learning Objective:** Master the process of examining, understanding, and working with previously saved `teal` reports.

### Report Structure Analysis

When investigating a saved `teal` report, you can extract comprehensive information:

```r
# Example of metadata found in a saved teal report
report_investigation_info <- list(
  # Basic Report Information
  report_title = "Baseline Demographics Analysis",
  creation_date = "2024-01-15 14:30:22 UTC",
  teal_version = "0.15.2",
  
  # Data Context
  datasets_used = c("ADSL", "ADAE"),
  filter_state = list(
    ADSL = list(
      SAFFL = "Y",
      ARM = c("Placebo", "Xanomeline High Dose")
    )
  ),
  n_subjects = 254,
  
  # Analysis Components
  modules_used = c(
    "tm_t_summary",
    "tm_g_distribution",
    "tm_g_scatterplot"
  ),
  n_report_cards = 5,
  
  # Reproducibility Information
  r_version = "4.3.0",
  package_versions = list(
    teal = "0.15.2",
    teal.modules.general = "0.3.0",
    pharmaverseadam = "0.2.0"
  )
)

# Investigating this information helps understand:
# - What analysis was performed
# - What data subset was used
# - When the analysis was conducted
# - How to reproduce the results
```

### Report Validation and Quality Assessment

```r
# Framework for validating saved teal reports
validate_teal_report <- function(report_path) {
  validation_checklist <- list(
    # Data Integrity
    data_validation = list(
      data_source_documented = TRUE,
      filter_logic_clear = TRUE,
      population_definition_appropriate = TRUE,
      missing_data_handling_documented = TRUE
    ),
    
    # Analysis Quality
    analysis_validation = list(
      methods_appropriate = TRUE,
      statistical_assumptions_met = TRUE,
      results_interpretation_sound = TRUE,
      clinical_relevance_assessed = TRUE
    ),
    
    # Reproducibility
    reproducibility_check = list(
      r_code_available = TRUE,
      package_versions_documented = TRUE,
      random_seeds_set = TRUE,
      data_provenance_clear = TRUE
    ),
    
    # Documentation Quality
    documentation_assessment = list(
      methodology_described = TRUE,
      limitations_acknowledged = TRUE,
      conclusions_supported = TRUE,
      regulatory_standards_met = TRUE
    )
  )
  
  return(validation_checklist)
}

# Report validation ensures:
# - Scientific rigor and accuracy
# - Regulatory compliance
# - Reproducibility and transparency
# - Professional documentation standards
```

---

## Importing the Report

**Learning Objective:** Master the process of importing and working with previously saved `teal` reports in new analysis sessions.

### Report Import Workflow

```r
# Demonstration of report import capabilities
report_import_demo <- teal::init(
  data = report_demo_data,
  modules = teal::modules(
    tm_data_table(
      label = "Import Demo - Data Table",
      dataname = "ADSL"
    ),
    tm_t_summary(
      label = "Import Demo - Summary",
      dataname = "ADSL",
      summarize_vars = data_extract_spec(
        dataname = "ADSL",
        select = select_spec(
          choices = variable_choices("ADSL", c("AGE", "SEX", "RACE")),
          selected = c("AGE", "SEX"),
          multiple = TRUE
        )
      )
    )
  ),
  title = "Report Import Demonstration"
)

# Report import process:
# 1. Launch teal application
# 2. Navigate to Report tab
# 3. Click "Import Report" button
# 4. Select previously saved report file
# 5. Review imported content
# 6. Merge with current session or replace current report

if (interactive()) {
  shiny::shinyApp(report_import_demo$ui, report_import_demo$server)
}
```

### Import Use Cases

#### **Collaborative Analysis Workflow**
- **Team collaboration**: Multiple analysts contributing to comprehensive reports
- **Quality assurance**: Peer review and validation processes
- **Version control**: Maintaining audit trails and analysis history
- **Consistent methodology**: Standardized approaches across team members

#### **Template-Based Analysis**
- **Standardized reporting**: Using proven analysis templates for new studies
- **Efficiency gains**: Reduced development time for similar analyses
- **Quality assurance**: Consistent reporting formats and methodologies
- **Best practices**: Leveraging validated analytical approaches

#### **Regulatory Submission Preparation**
- **Integrated summaries**: Combining multiple analysis reports
- **Documentation trails**: Comprehensive analysis documentation
- **Standardized formatting**: Meeting regulatory submission requirements
- **Quality validation**: Ensuring GCP compliance and scientific rigor

### Advanced Import Features

#### **Selective Import Options**
- **Module-specific import**: Import only relevant analysis components
- **Date-based filtering**: Import recent analyses or specific time periods
- **Population-based selection**: Import analyses for specific study populations
- **Treatment-specific content**: Focus on particular treatment comparisons

#### **Cross-Study Comparisons**
- **Multi-study analysis**: Import and compare reports from different studies
- **Meta-analysis capabilities**: Pooled analysis across multiple studies
- **Standardized comparisons**: Aligned methodologies for valid comparisons
- **Regulatory briefings**: Comprehensive cross-study documentation

The report functionality in `teal` provides a comprehensive solution for creating, managing, and sharing professional analysis documentation. By mastering these capabilities, users can create reproducible, high-quality reports that meet the demanding standards of pharmaceutical research and regulatory submission requirements.