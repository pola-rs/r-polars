# Series as.character v=a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z

    Code
      as.character(pl$Series(v))
    Output
       [1] "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s"
      [20] "t" "u" "v" "w" "x" "y" "z"

---

    Code
      as.character(pl$Series(v), str_length = 15)
    Output
       [1] "\"a\"" "\"b\"" "\"c\"" "\"d\"" "\"e\"" "\"f\"" "\"g\"" "\"h\"" "\"i\""
      [10] "\"j\"" "\"k\"" "\"l\"" "\"m\"" "\"n\"" "\"o\"" "\"p\"" "\"q\"" "\"r\""
      [19] "\"s\"" "\"t\"" "\"u\"" "\"v\"" "\"w\"" "\"x\"" "\"y\"" "\"z\""

---

    Code
      as.character(pl$Series(v), str_length = 2)
    Output
       [1] "\"a…" "\"b…" "\"c…" "\"d…" "\"e…" "\"f…" "\"g…" "\"h…" "\"i…" "\"j…"
      [11] "\"k…" "\"l…" "\"m…" "\"n…" "\"o…" "\"p…" "\"q…" "\"r…" "\"s…" "\"t…"
      [21] "\"u…" "\"v…" "\"w…" "\"x…" "\"y…" "\"z…"

# Series as.character v=1, 2, 3, 4, 5, 6, 7, 8, 9, 10

    Code
      as.character(pl$Series(v))
    Output
       [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10"

---

    Code
      as.character(pl$Series(v), str_length = 15)
    Output
       [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10"

---

    Code
      as.character(pl$Series(v), str_length = 2)
    Output
       [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10"

---

    Code
      as.character(pl$Series(v))
    Output
       [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10"

---

    Code
      as.character(pl$Series(v), str_length = 15)
    Output
       [1] "1.0"  "2.0"  "3.0"  "4.0"  "5.0"  "6.0"  "7.0"  "8.0"  "9.0"  "10.0"

---

    Code
      as.character(pl$Series(v), str_length = 2)
    Output
       [1] "1.0"  "2.0"  "3.0"  "4.0"  "5.0"  "6.0"  "7.0"  "8.0"  "9.0"  "10.0"

# Series as.character v=bar

    Code
      as.character(pl$Series(v))
    Output
      [1] "bar"

---

    Code
      as.character(pl$Series(v), str_length = 15)
    Output
      [1] "\"bar\""

---

    Code
      as.character(pl$Series(v), str_length = 2)
    Output
      [1] "\"b…"

# Series as.character v=TRUE, FALSE

    Code
      as.character(pl$Series(v))
    Output
      [1] "TRUE"  "FALSE"

---

    Code
      as.character(pl$Series(v), str_length = 15)
    Output
      [1] "true"  "false"

---

    Code
      as.character(pl$Series(v), str_length = 2)
    Output
      [1] "true"  "false"

# Series as.character v=1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26

    Code
      as.character(pl$Series(v))
    Output
       [1] "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s"
      [20] "t" "u" "v" "w" "x" "y" "z"

---

    Code
      as.character(pl$Series(v), str_length = 15)
    Output
       [1] "\"a\"" "\"b\"" "\"c\"" "\"d\"" "\"e\"" "\"f\"" "\"g\"" "\"h\"" "\"i\""
      [10] "\"j\"" "\"k\"" "\"l\"" "\"m\"" "\"n\"" "\"o\"" "\"p\"" "\"q\"" "\"r\""
      [19] "\"s\"" "\"t\"" "\"u\"" "\"v\"" "\"w\"" "\"x\"" "\"y\"" "\"z\""

---

    Code
      as.character(pl$Series(v), str_length = 2)
    Output
       [1] "\"a…" "\"b…" "\"c…" "\"d…" "\"e…" "\"f…" "\"g…" "\"h…" "\"i…" "\"j…"
      [11] "\"k…" "\"l…" "\"m…" "\"n…" "\"o…" "\"p…" "\"q…" "\"r…" "\"s…" "\"t…"
      [21] "\"u…" "\"v…" "\"w…" "\"x…" "\"y…" "\"z…"

# Series as.character v=foooo  , barrrrr

    Code
      as.character(pl$Series(v))
    Output
      [1] "foooo"   "barrrrr"

---

    Code
      as.character(pl$Series(v), str_length = 15)
    Output
      [1] "\"foooo\""   "\"barrrrr\""

---

    Code
      as.character(pl$Series(v), str_length = 2)
    Output
      [1] "\"f…" "\"b…"

