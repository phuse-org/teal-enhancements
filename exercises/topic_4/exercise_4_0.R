# Topic 5

# Task 1: Create a `teal_data` object
# * load `teal.data`
# * create a `teal_data` object named `basic_data` that bundles the built-in `iris` and `mtcars` datasets
# * inspect the resulting object with `print()` and `get_code()`


# Task 2:
# * use `teal_data()` together with `within()` (or an equivalent approach) to
#   construct an object named `tracked_data`.
# * make at least one transformation to each dataset (e.g., convert a column
#   to a factor, create a derived variable).
# * confirm that `get_code(tracked_data)` records the transformation steps.


# Task 3: Recreate CDISC join keys manually with `teal_data`
# * load the `pharmaverseadam` package and pull the datasets `adsl`, `adae`,
#   and `adtte`.
# * build a single `teal_data` object named `adam_manual` containing those
#   three datasets.
# * define custom join keys that mimic the automatic CDISC relationships:
#     - `ADSL` -> `ADAE` on `c("STUDYID", "USUBJID")`
#     - `ADSL` -> `ADTTE` on `c("STUDYID", "USUBJID")`
#     - Optionally add subject-level self keys for each table if helpful.
# * assign the custom keys with `join_keys(adam_manual) <- ...`.
# * confirm the structure by printing the join keys.


# Task 4: Launch the a `teal` application using your `adam_manual` dataset:
# * use one of the application defined by you in exercises or one of the
#   applications shown as examples during workshops
# * debug issues with join keys if any
# * use the Show R Code button to verify the application returns
#   code that you can use to reproduce the output
