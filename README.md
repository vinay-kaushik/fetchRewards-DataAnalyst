# FetchRewards Data Analyst Assessment


All the files have been uploaded to the Github repository




## Question 1: Data Modelling

I have used [lucidchart.com](https://www.lucidchart.com/) to design the [ER diagram](https://github.com/vinay-kaushik/fetchRewards-DataAnalyst/blob/master/Database%20ER%20diagram%20Fetch%20Rewards.jpg).

I have received 3 files.
1. users.json
2. brands.json
3. receipts.json

While looking at the data of all the files, I observed that receipts.json file has a nested JSON with receiptItemList in it. So I separated the receipts and rewards table and linked them with receiptId in common.



## Question 2: Queries that answers the business model

I have done questions 2 and 3 simultaneously, by following the process below.

1. Converted the JSON files into dataframes.
2. Observed that receiptRewardItemList is a list with JSON in it, hence converted that into a separate dataframe.
3. Analysed the data which will be discussed in the next section.
4. Converted the dataframes into csv files and dumped the csv files into database using MySQL Workbench

You can find the queries in the [queries.sql](https://github.com/vinay-kaushik/fetchRewards-DataAnalyst/blob/master/queries.sql) file in the repository

For the second question, I have created views and compared the data.

```sql

"""
How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking
for the previous month?
"""

create view cur_month_rank as 
with temp as 
(
	select b.name as name,sum(x.itemtotal) as itemtotal
    from brand b join (select barcode,sum(quantitypurchased) as itemtotal
    from rewards rew join receipt rec on rew.receipt_Id=rec.receiptId
    where extract(day from now()- rec.rec_scannedDate) <=30
    ) x on
    b.barcode=x.barcode
    where topbrand=TRUE
    group by b.name
)
select temp.name ,dense_rank() over (order by temp.itemtotal desc) rank_brand
from temp
order by rank_brand;


create view prev_month_rank as 
with temp as 
(
	select b.name as name,sum(x.itemtotal) as itemtotal
    from brand b join (select barcode,sum(quantitypurchased) as itemtotal
    from rewards rew join receipt rec on rew.receipt_Id=rec.receiptId
    where extract(day from now()- rec.rec_scannedDate)>=30 and extract(day from now()- rec.rec_scannedDate) <=60
    ) x on
    b.barcode=x.barcode
    where topbrand=TRUE
    group by b.name
)
select temp.name ,dense_rank() over (order by temp.itemtotal desc) rank_brand
from temp
order by rank_brand;

--Final query after creating views
select * from cur_month_rank cur,prev_month_rank prev where cur.name=prev.name;
```

## Question 3: Checking Data Quality Issue using Python
I have created a [notebook](https://github.com/vinay-kaushik/fetchRewards-DataAnalyst/blob/master/FetchRewards.ipynb) that would take in the files and convert the JSON files to Dataframes and later convert it into csv files.


**Analysis of the data**
1. There are a lot of null and missing values present in the data. If they are not relevant to the data analysis, they can be eliminated.
2. User_id was actually supposed to be a unique key, but the users.json file consisted of duplicate rows. These records should be reviewed carefully.
3. There were cases where reward points were awarded although there is no information on the receipt item list.
4. The column name brandCode is present in brands.json and receipts.json files. But the values do not match each other. I am assuming that both the columns have different meanings, hence the names of those columns need to be changed accordingly.

## Question 4: Email to the stakeholders

Please find the pdf to that email [here](https://github.com/vinay-kaushik/fetchRewards-DataAnalyst/blob/master/Email-to-stakeholders.pdf)

This pdf consists of few analysis and concerns regarding the data to the business stakeholder.



