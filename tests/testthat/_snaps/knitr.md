# Snapshot test of knitr

    Code
      .knit_file("dataframe.Rmd")
    Output
      
      ```r
      df = data.frame(a = 1:3, b = letters[1:3])
      pl$DataFrame(df)
      ```
      
      polars DataFrame: shape: (3, 2)
      
      | a (i32) | b (str) |
      |---------|---------|
      | 1       | a       |
      | 2       | b       |
      | 3       | c       |

---

    Code
      .knit_file("dataframe.Rmd")
    Output
      
      ```r
      df = data.frame(a = 1:3, b = letters[1:3])
      pl$DataFrame(df)
      ```
      
      polars DataFrame: shape: (3, 2)
      
      ┌─────┬─────┐
      │ a   ┆ b   │
      │ --- ┆ --- │
      │ i32 ┆ str │
      ╞═════╪═════╡
      │ 1   ┆ a   │
      │ 2   ┆ b   │
      │ 3   ┆ c   │
      └─────┴─────┘

---

    Code
      .knit_file("dataframe.Rmd")
    Output
      
      ```r
      df = data.frame(a = 1:3, b = letters[1:3])
      pl$DataFrame(df)
      ```
      
      polars DataFrame: shape: (3, 2)
      
      ┌─────┬─────┐
      │ a   ┆ b   │
      │ --- ┆ --- │
      │ i32 ┆ str │
      ╞═════╪═════╡
      │ 1   ┆ a   │
      │ 2   ┆ b   │
      │ 3   ┆ c   │
      └─────┴─────┘

