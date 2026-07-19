# What I Learned - Week 5 (Apache Spark)

During this week's assignment, I learned the fundamentals of Apache Spark and how it is different from Hadoop MapReduce. I understood that Spark is much faster because it performs in-memory processing, which reduces disk I/O and improves execution speed.

I learned how to create and work with Spark DataFrames. I explored different DataFrame operations such as filtering records, selecting specific columns, renaming columns, changing data types, and grouping data using `groupBy()`.

While working on the dataset, I practiced data cleaning by checking for duplicate records, handling missing values, and understanding why clean data is important before performing any analysis. I also learned the difference between `.na.drop()` and `.na.fill()` and when each method can be useful.

Another important concept I learned was DataFrame immutability. I understood that every transformation creates a new DataFrame instead of modifying the existing one. This was a new concept for me compared to working with normal Python data structures.

I also learned about aggregation functions such as `count()`, `sum()`, `avg()`, `min()`, and `max()`, and how to use them with `groupBy()` to analyze data.

Finally, I gained a basic understanding of shuffle operations and wide transformations. Although these concepts are new to me, I now understand that they can affect Spark job performance and should be used carefully when processing large datasets.

Overall, this assignment gave me practical exposure to PySpark and helped me understand how data cleaning and transformation are performed in a Data Engineering workflow. I feel more confident working with Spark DataFrames than I did before starting this assignment.
