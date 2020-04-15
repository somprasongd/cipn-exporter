select t_patient.patient_hn as hn
        ,case when f_patient_prefix.f_patient_prefix_id is not null
            then case when f_patient_prefix.f_patient_prefix_id = '000'
            then '' else f_patient_prefix.patient_prefix_description end else '' end
        || t_patient.patient_firstname || ' ' || t_patient.patient_lastname as pname
        ,lpad(t_visit.visit_vn,9,'0') as invno
        ,sum(t_billing_invoice.billing_invoice_total)::decimal(8,2)::text as amount
        ,(substr(t_visit.visit_begin_visit_time,1,4)::int-543)::text || substr(t_visit.visit_begin_visit_time,5) as visit_begin_visit_time
        ,t_visit.t_visit_id
        from t_billing_invoice
        inner join t_visit on (t_billing_invoice.t_visit_id = t_visit.t_visit_id
                        and t_visit.f_visit_type_id = '1'
                        and t_visit.f_visit_status_id in ('2','3')
                        and t_visit.visit_ipd_discharge_status = '1'
                        and (substr(t_visit.visit_begin_visit_time, 1, 4)::int-543)::text || substr(t_visit.visit_begin_visit_time, 5, 6) between $startDate and $endDate)
        inner join t_patient on (t_patient.t_patient_id = t_visit.t_patient_id
                        and t_patient.patient_hn like $hn
                        and t_patient.patient_firstname ilike $firstname
                        and t_patient.patient_lastname ilike $lastname
                        and t_patient.patient_active = '1')
        left join f_patient_prefix on t_patient.f_patient_prefix_id = f_patient_prefix.f_patient_prefix_id
        left join t_health_family on t_health_family.t_health_family_id = t_patient.t_health_family_id
        left join t_person_foreigner on t_health_family.t_health_family_id = t_person_foreigner.t_person_id
        inner join t_visit_payment on (t_billing_invoice.t_payment_id = t_visit_payment.t_visit_payment_id
                        and t_visit_payment.visit_payment_active = '1'
                        and t_visit_payment.b_contract_plans_id
                            in (select b_map_contract_plans_govoffical.b_contract_plans_id
                                    from b_map_contract_plans_govoffical))
        left join b_contract_plans on b_contract_plans.b_contract_plans_id = t_visit_payment.b_contract_plans_id
        cross join b_site
        where (t_billing_invoice.billing_invoice_active = '1'
        and cast(t_billing_invoice.billing_invoice_payer_share as float) > 0.0)
        group by t_patient.patient_hn
            ,f_patient_prefix.f_patient_prefix_id
            ,t_patient.patient_firstname
            ,t_patient.patient_lastname
            ,t_visit.visit_vn
            ,t_visit.t_visit_id
        order by t_visit.visit_begin_visit_time