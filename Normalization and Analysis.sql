#add FK - fact table
ALTER TABLE `Pharmacy Claims`.`fact_pharmacy` 
ADD CONSTRAINT `member_id`
  FOREIGN KEY (`﻿member_id`)
  REFERENCES `Pharmacy Claims`.`dim_member` (`﻿member_id`)
  ON DELETE RESTRICT
  ON UPDATE RESTRICT;
  
ALTER TABLE `Pharmacy Claims`.`fact_pharmacy` 
ADD CONSTRAINT `drug_ndc`
  FOREIGN KEY (`﻿drug_ndc`)
  REFERENCES `Pharmacy Claims`.`dim_drug` (`﻿drug_ndc`)
  ON DELETE RESTRICT
  ON UPDATE RESTRICT;

ALTER TABLE `Pharmacy Claims`.`fact_pharmacy` 
ADD CONSTRAINT `drug_form_code`
  FOREIGN KEY (`﻿drug_form_code`)
  REFERENCES `Pharmacy Claims`.`dim_drugcode` (`﻿drug_form_code`)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `Pharmacy Claims`.`fact_pharmacy` 
ADD CONSTRAINT `drug_brand_generic_code`
  FOREIGN KEY (`﻿drug_brand_generic_code`)
  REFERENCES `Pharmacy Claims`.`dim_drugbrand` (`﻿drug_brand_generic_code`)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

#add FK - dim_drug
ALTER TABLE `Pharmacy Claims`.`dim_drug` 
ADD CONSTRAINT `drug_form_code`
  FOREIGN KEY (`﻿drug_form_code`)
  REFERENCES `Pharmacy Claims`.`dim_drugcode` (`﻿drug_form_code`)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `Pharmacy Claims`.`dim_drug` 
ADD CONSTRAINT `drug_brand_generic_code`
  FOREIGN KEY (`﻿drug_brand_generic_code`)
  REFERENCES `Pharmacy Claims`.`dim_drugbrand` (`﻿drug_brand_generic_code`)
  ON DELETE CASCADE
  ON UPDATE CASCADE;


#add claimsID - fact table
alter table fact_pharmacy
add claimsID int not null auto_increment primary key;
select * from fact_pharmacy;

#------------------------------------------------------------------------------------------------------------------------
#start to analyze data

#number of prescriptions
select f.drug_ndc, d.drug_name, count( f.drug_ndc) as number_prescription
from fact_pharmacy f,dim_drug d
where d.﻿drug_ndc = f.drug_ndc
group by f.drug_ndc
order by f.drug_ndc desc;

#count total prescriptions, counts unique members, sums copay $$, 
#sums insurance paid $$, for members grouped as either ‘age 65+’ or ’ < 65’.
select case when m.member_age >= 65 then 'age 65+'
when m.member_age < 65 then '< 65'
end as member_group, 
count(f.drug_ndc) as total_prescriptions,
count(distinct m.﻿member_id) as unique_member,
sum(f.copay) as total_copay,
sum(f.insurancepaid) as total_insurancepaid
from dim_member m, fact_pharmacy f
group by member_group
order by member_group;

#amount paid by the insurance
drop table if exists drug_paid;
create table drug_paid as
select m.﻿member_id, m.member_first_name, m.member_last_name, d.drug_name,
f.fill_date, f.insurancepaid
from fact_pharmacy f,dim_member m, dim_drug d
where  f.﻿member_id = m.﻿member_id and d.﻿drug_ndc=f.drug_ndc
group by f.claimsID
order by f.claimsID asc;
 
select * from
(select p.﻿member_id, p.member_first_name, p.member_last_name, p.drug_name,
p.fill_date, p.insurancepaid, row_number() over (partition by p.﻿member_id order by p.﻿member_id, p.fill_date desc) as flag
from drug_paid p) as t1
where t1.flag=1;

