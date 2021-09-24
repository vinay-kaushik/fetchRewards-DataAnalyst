-- 1 
"""
What are the top 5 brands by receipts scanned for most recent month?
"""

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
order by rank_brand limit 5;

-- 2
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
order by rank_brand ;


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
order by rank_brand ;



select * from cur_month_rank cur,prev_month_rank prev where cur.name=prev.name;


-- 3  

"""
When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’,
which is greater?
"""

SELECT r1.rewardsReceiptStatus, AVG(r1.totalSpent) AS avgTotalSpent
            FROM Receipt AS r1 JOIN Receipt AS r2 ON r1.receiptId = r2.receiptId
            GROUP BY r1.rewardsReceiptStatus
            HAVING r1.rewardsReceiptStatus IN ('ACCEPTED', 'REJECTED', 'FINISHED')
            ORDER BY AVG(r1.totalSpent) desc;
			
			

-- 4
"""
When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of
‘Accepted’ or ‘Rejected’, which is greater?
"""
SELECT r1.rewardsReceiptStatus, SUM(r2.purchasedItemCount) AS totalNumItems
                    FROM Receipt AS r1 JOIN Receipt AS r2 ON r1.receiptId = r2.receiptId
                    GROUP BY r1.rewardsReceiptStatus
                    HAVING r1.rewardsReceiptStatus IN ('ACCEPTED', 'REJECTED', 'FINISHED')
                    ORDER BY SUM(r2.purchasedItemCount) desc;
					
-- 5
"""
Which brand has the most spend among users who were created within the past 6 months?
"""

with tmp as (
select r.barcode,sum(itemprice*quantityPurchased) as total_spent
from rewards r join (
	select userid,receiptid from receipt rec join users u on rec.userid=u.user_id
    where extract(month from now()-u.createdDate)<=6
) x on r.receipt_id= x.receiptid
group by r.barcode)

select br.name,sum(tmp.total_spent) from brand br join tmp on br.barcode=tmp.barcode
group by br.name order by sum(tmp.total_spent) desc
;


-- 6
"""
Which brand has the most transactions among users who were created within the past 6 months?
"""

with tmp as (
select r.barcode,sum(quantityPurchased) as totalQuantity
from rewards r join (
	select userid,receiptid from receipt rec join users u on rec.userid=u.user_id
    where extract(month from now()-u.createdDate)<=6
) x on r.receipt_id= x.receiptid
group by r.barcode)

select br.name,sum(tmp.totalQuantity) from brand br join tmp on br.barcode=tmp.barcode
group by br.name order by sum(tmp.totalQuantity) desc
;

-- end