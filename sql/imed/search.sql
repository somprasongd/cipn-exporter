select q.hn
       ,q.pname
       ,max(q.invno) as invno
       ,sum(q.amount)::text as amount
       ,q.visit_begin_visit_time
       ,q.t_visit_id
from (select patient.hn as hn
    ,case when patient.prename is not null and patient.prename <> ''
            then patient.prename else '' end
        || patient.firstname || ' ' || patient.lastname as pname
    ,max(receipt_invno.invno) as invno
    ,receipt_billing_group.cost::decimal(8,2) as amount
    ,visit.visit_id as t_visit_id
    ,(visit.visit_date || ',' || visit.visit_time) as visit_begin_visit_time
from receipt
    inner join receipt_billing_group on receipt.receipt_id = receipt_billing_group.receipt_id
    inner join (select receipt.visit_id
                        ,max(case when receipt.plan_id <> '10' then receipt.plan_id else '' end) as ofc
                        ,max(case when receipt.plan_id = '10' then receipt.plan_id else '' end) as cash
                from receipt
                    inner join visit on receipt.visit_id = visit.visit_id
                                    and visit.fix_visit_type_id = '1'
                                    and visit.active = '1'
                                    and substr(visit.visit_date, 1, 10) between $startDate and $endDate
                    inner join visit_payment on visit.visit_id = visit_payment.visit_id
                    inner join plan on visit_payment.plan_id = plan.plan_id
                                   and plan.base_plan_group_id = 'OFC'
                                   and plan.plan_id not in ('OFC_C3','OFL07','OFC_O7','OFC04')
                    inner join plan as receipt_plan on receipt.plan_id = receipt_plan.plan_id
                                   and (receipt_plan.plan_id = '10' or receipt_plan.base_plan_group_id = 'OFC')
                                   and receipt_plan.plan_id not in ('OFC_C3','OFL07','OFC_O7','OFC04')
                group by receipt.visit_id
            ) as payment on receipt.visit_id = payment.visit_id
                        and payment.ofc <> ''
    inner join visit on receipt.visit_id = visit.visit_id
                    and visit.fix_visit_type_id = '1'
                    and visit.active = '1'
                    and substr(visit.visit_date, 1, 10) between $startDate and $endDate
    inner join visit_payment on visit.visit_id = visit_payment.visit_id
    inner join plan on visit_payment.plan_id = plan.plan_id
                   and plan.base_plan_group_id = 'OFC'
                   and plan.plan_id not in ('OFC_C3','OFL07','OFC_O7','OFC04')
    inner join plan as receipt_plan on receipt.plan_id = receipt_plan.plan_id
    inner join patient on visit.patient_id = patient.patient_id
                      and patient.hn like $hn
                      and patient.firstname ilike $firstname
                      and patient.lastname ilike $lastname
    left join (select max(replace(case when (receipt_plan.base_plan_group_id = 'OFC' AND receipt.receipt_number ilike 'C%')
                      then format_receipt_smart_report(receipt.receipt_number ,receipt.fix_receipt_type_id ,receipt.fix_receipt_status_id ,receipt.credit_number ,receipt.fix_visit_type_id)::text 
                       else '' end,' ','')) as invno
                    ,visit.visit_id
             from receipt
             inner join visit on receipt.visit_id = visit.visit_id
             inner join plan as receipt_plan on receipt.plan_id = receipt_plan.plan_id
             where visit.fix_visit_type_id = '1'
                and visit.active = '1'
                and receipt.fix_receipt_status_id = '2'
                and receipt.cut_from_receipt_id = ''
                and (cast(receipt.cost as float) > 0.0)
                and visit.financial_discharge = '1'
                and visit.doctor_discharge = '1'
                and substr(visit.visit_date, 1, 10) between $startDate and $endDate
             group by visit.visit_id
                ) as receipt_invno on receipt_invno.visit_id = visit.visit_id
    cross join base_site
where patient.active = '1'
    and receipt.fix_receipt_status_id = '2'
    and receipt.cut_from_receipt_id = ''
    and (cast(receipt.cost as float) > 0.0)
    and visit.financial_discharge = '1'
    and visit.doctor_discharge = '1'
group by patient.hn
    ,patient.prename
    ,patient.firstname
    ,patient.lastname
    ,visit.visit_id
    ,receipt_billing_group.cost
    ,receipt_billing_group.receipt_billing_group_id
) as q
group by q.hn
       ,q.pname
       ,q.t_visit_id
       ,q.visit_begin_visit_time
order by q.visit_begin_visit_time