use graded_assign;
show tables;
select * from product;
select * from appdoc;
select * from appdoctype_lookup;
select * from application;
select * from chemtypelookup;
select * from doctype_lookup;
select * from regactiondate;
select * from product_tecode;
select * from reviewclass_lookup;

/*Determine the number of drugs approved each year */
create view drugs_year as select count(product.drugname) as Drugs,year(regactiondate.actiondate) as reg_year from application inner join product inner join regactiondate on application.applno=product.applno and application.applno=regactiondate.applno where regactiondate.actiontype = "ap" group by year(regactiondate.actiondate)  order by year(actiondate) desc;
select * from drugs_year;
select count(p.drugname) as Drugs,year(r.actiondate) as Year_of_approval from product p inner join regactiondate r on p.applno = r.applno where r.actiontype="AP" group by year(r.actiondate) order by year(r.actiondate) desc;
select * from product inner join regactiondate on product.applno=regactiondate.applno;
/*Identify the top three years that got the highest and lowest approvals, in descending and ascending order, respectively*/
/*Here we are considering the approval of applications*/
select count(applno) from application;
select count(applno) from regactiondate;
/*Highest approvals*/
create view Highest_approval as select count(regactiondate.applno) as Application_count,year(actiondate),rank() over (order by count(regactiondate.applno) desc) as Rank_no from regactiondate where actiontype="ap"  group by year(actiondate) order by count(applno) desc limit 3;
/*lowest approvals*/
/*Explore approval trends over the years based on sponsors.*/
create view lowest_approval as select count(b.applno) as Applications_approved, year(b.actiondate),a.sponsorapplicant from application a inner join regactiondate b on a.applno=b.applno where year(b.actiondate)<>"null" group by year(b.actiondate),a.sponsorapplicant order by year(b.actiondate);
/*Rank sponsors based on the total number of approvals they received each year between 1939
and 1960*/
create view approvals_39_60 as select count(a.applno) as Total_no_of_applications, a.sponsorapplicant,year(r.actiondate),dense_rank() over (order by count(a.applno) desc)  from application a inner join regactiondate r on a.applno=r.applno where year(r.actiondate) between 1939 and 1960 group by sponsorapplicant,year(r.actiondate);
/*Task 2: Segmentation Analysis Based on Drug MarketingStatus*/
/*Group products based on MarketingStatus. Provide meaningful insights into the
segmentation patterns.*/
select count(tecode) from product_tecode;
select count(tecode) from product;
create view products_mktstatus as select count(productno) as Total_products , productmktstatus from product group by productmktstatus;
/*Calculate the total number of applications for each MarketingStatus year-wise after the year
2010*/
create view appl_mktstatus_yearwise as select b.productmktstatus as Product_mkt_status, count(distinct(a.applno)) as Total_applications,year(c.actiondate) as Year_of_Status from application a inner join product b inner join regactiondate c on a.applno= b.applno and a.applno = c.applno 
where year(actiondate)> 2010 
group by b.productmktstatus,year(c.actiondate);

/*Identify the top MarketingStatus with the maximum number of applications and analyze its
trend over time.*/
select distinct(productmktstatus) from product;
create view Mkt_status_vs_appl as select count(applno) as applications, productmktstatus from product 
group by productmktstatus order by count(applno) desc;


/* Task 3: Analyzing Products*/
/*Categorize Products by dosage form and analyze their distribution*/
select count(distinct(dosage)) from product;
select count(distinct(productno)) from product;
create view dosage_products as SELECT 
    Dosage,
    COUNT(productno) AS ProductCount,
    ROUND((COUNT(productno) * 100.0) / SUM(COUNT(productno)) OVER (), 2) AS Percentage
FROM 
    Product
GROUP BY 
    Dosage
ORDER BY 
    ProductCount DESC;
    
    select count(productno), dosage from product group by dosage order by count(productno) desc;
    /*Calculate the total number of approvals for each dosage form and identify the most
successful forms.*/
create view approvals_for_each_dosage as select count(a.applno) as Application_count, a.actiontype,p.dosage from application a inner join product p on a.applno=p.applno where a.actiontype="ap" group by a.actiontype,p.dosage order by count(a.applno) desc;
/*Investigate yearly trends related to successful forms.*/
create view yearly_trends as select count(a.applno) as Application_count, a.actiontype as Approval_status , year(r.actiondate) as Year_of_Approval from application a inner join regactiondate r on a.applno=r.applno 
where r.actiontype="ap" and year(r.actiondate)<>"null" 
group by a.actiontype,year(r.actiondate) order by year(r.actiondate);
select count(distinct(year(actiondate))) from regactiondate;
/*Task 4: Exploring Therapeutic Classes and Approval Trends*/
/*Analyze drug approvals based on therapeutic evaluation code (TE_Code)*/
select count(tecode) from product_tecode;
select count(tecode) from product_tecode;
/*select a.actiontype as Status_of_approval,count(p.productno) as Drug_products,pt.tecode as TE_Code from application a inner join product p inner join product_tecode pt on a.applno=p.applno and pt.productno = p.productno group by pt.tecode,a.actiontype;*/
create view drug_approv_t_code as select a.actiontype as approval_type,count(p.productno) as Drug_products,pt.tecode as TE_Code from application a inner join product p inner join product_tecode pt on a.applno=p.applno and p.applno = pt.applno group by a.actiontype,pt.tecode;
select distinct(actiontype) from application;

/*Determine the therapeutic evaluation code (TE_Code) with the highest number of Approvals in
each year.*/
create view therapeutic_evaluation_code as select count(a.applno) as Application_count,pt.tecode as TE_Code,year(r.actiondate) as Year_of_approval ,dense_rank() over (partition by year(r.actiondate) order by count(a.applno) desc) from application a inner join product_tecode pt inner join regactiondate r on a.applno = pt.applno and a.applno=r.applno where r.actiontype="ap" group by pt.tecode,year(r.actiondate);
select * from application where actiontype="ta"