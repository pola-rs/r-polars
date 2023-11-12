# sink_csv: null_values works

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      mpg,cyl,disp,hp,drat,wt,qsec,vs,am,gear,carb
      21.0,6.0,hello,hello,hello,2.62,16.46,0.0,1.0,4.0,4.0
      21.0,6.0,160.0,110.0,3.9,2.875,17.02,0.0,1.0,4.0,4.0
      22.8,4.0,hello,hello,hello,2.32,18.61,1.0,1.0,4.0,1.0
      21.4,6.0,258.0,110.0,3.08,3.215,19.44,1.0,0.0,3.0,1.0
      18.7,8.0,360.0,175.0,3.15,3.44,17.02,0.0,0.0,3.0,2.0
      18.1,6.0,225.0,105.0,2.76,3.46,20.22,1.0,0.0,3.0,1.0
      14.3,8.0,360.0,245.0,3.21,3.57,15.84,0.0,0.0,3.0,4.0
      24.4,4.0,146.7,62.0,3.69,3.19,20.0,1.0,0.0,4.0,2.0
      22.8,4.0,hello,hello,hello,3.15,22.9,1.0,0.0,4.0,2.0
      19.2,6.0,167.6,123.0,3.92,3.44,18.3,1.0,0.0,4.0,4.0
      17.8,6.0,167.6,123.0,3.92,3.44,18.9,1.0,0.0,4.0,4.0
      16.4,8.0,hello,hello,hello,4.07,17.4,0.0,0.0,3.0,3.0
      17.3,8.0,275.8,180.0,3.07,3.73,17.6,0.0,0.0,3.0,3.0
      15.2,8.0,275.8,180.0,3.07,3.78,18.0,0.0,0.0,3.0,3.0
      10.4,8.0,472.0,205.0,2.93,5.25,17.98,0.0,0.0,3.0,4.0

# sink_csv: separator works

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      mpg|cyl|disp|hp|drat|wt|qsec|vs|am|gear|carb
      21.0|6.0||||2.62|16.46|0.0|1.0|4.0|4.0
      21.0|6.0|160.0|110.0|3.9|2.875|17.02|0.0|1.0|4.0|4.0
      22.8|4.0||||2.32|18.61|1.0|1.0|4.0|1.0
      21.4|6.0|258.0|110.0|3.08|3.215|19.44|1.0|0.0|3.0|1.0
      18.7|8.0|360.0|175.0|3.15|3.44|17.02|0.0|0.0|3.0|2.0
      18.1|6.0|225.0|105.0|2.76|3.46|20.22|1.0|0.0|3.0|1.0
      14.3|8.0|360.0|245.0|3.21|3.57|15.84|0.0|0.0|3.0|4.0
      24.4|4.0|146.7|62.0|3.69|3.19|20.0|1.0|0.0|4.0|2.0
      22.8|4.0||||3.15|22.9|1.0|0.0|4.0|2.0
      19.2|6.0|167.6|123.0|3.92|3.44|18.3|1.0|0.0|4.0|4.0
      17.8|6.0|167.6|123.0|3.92|3.44|18.9|1.0|0.0|4.0|4.0
      16.4|8.0||||4.07|17.4|0.0|0.0|3.0|3.0
      17.3|8.0|275.8|180.0|3.07|3.73|17.6|0.0|0.0|3.0|3.0
      15.2|8.0|275.8|180.0|3.07|3.78|18.0|0.0|0.0|3.0|3.0
      10.4|8.0|472.0|205.0|2.93|5.25|17.98|0.0|0.0|3.0|4.0

# sink_csv: quote_style quote_style=necessary

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      a,b,c
      """foo""",1,a
      bar,2,b

# sink_csv: quote_style quote_style=always

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      "a","b","c"
      """foo""","1","a"
      "bar","2","b"

# sink_csv: quote_style quote_style=non_numeric

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      "a","b","c"
      """foo""",1,"a"
      "bar",2,"b"

# sink_csv: quote_style quote_style=never

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      a,b,c
      "foo",1,a
      bar,2,b

# sink_csv: date_format works

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      date
      2020
      2021
      2022
      2023

---

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      date
      01/01/2020
      01/01/2021
      01/01/2022
      01/01/2023

# sink_csv: datetime_format works

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      date
      00h00m - 01/01/2020
      06h00m - 01/01/2020
      12h00m - 01/01/2020
      18h00m - 01/01/2020
      00h00m - 02/01/2020

# sink_csv: time_format works

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      date
      00h00m00s
      08h00m00s
      16h00m00s
      00h00m00s

# sink_csv: float_precision works

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      x
      1.2
      5.6

---

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      x
      1.234
      5.600

