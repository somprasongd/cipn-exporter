select ipadt.authorid || '-CIPN-' || ipadt.an || '-' || to_char(current_timestamp,'YYYYMMDDhh24miss') as filename
       ,'<CIPN>' || E'\n' || '<Header>' || E'\n' || '<DocClass>IPClaim</DocClass>' 
        || E'\n' || '<DocSysID version="2.0">CIPN</DocSysID>'
        || E'\n' || '<serviceEvent>ADT</serviceEvent>'
        || E'\n' || '<authorID>' || case when ipadt.authorid is not null then ipadt.authorid else '' end || '</authorID>'
        || E'\n' || '<authorName>' || case when ipadt.authorname is not null then ipadt.authorname else '' end || '</authorName>'
        || E'\n' || '<effectiveTime>' || to_char(current_timestamp,'YYYY-MM-DDThh24:mi:ss') || '</effectiveTime>'
        || E'\n' || '</Header>' || E'\n' || '<ClaimAuth>'
        || E'\n' || '<AuthCode>' || case when ipadt.authcode is not null then ipadt.authcode else '' end || '</AuthCode>'
        || E'\n' || '<AuthDT>' || case when ipadt.authdt is not null then ipadt.authdt else '' end || '</AuthDT>'
        || E'\n' || '<UPayPlan>10</UPayPlan>' || E'\n' || '<ServiceType>IP</ServiceType>'
        || E'\n' || '<ProjectCode></ProjectCode>' || E'\n' || '<EventCode></EventCode>'
        || E'\n' || '<UserReserve></UserReserve>' || E'\n' || '</ClaimAuth>' || E'\n' || '<IPADT>'
        || E'\n' || (ipadt.an || '|' || ipadt.hn || '|' || ipadt.idtype || '|' || ipadt.pidpat || '|' || ipadt.title || '|' || ipadt.namepat
        || '|' || ipadt.dob || '|' || ipadt.sex || '|' || ipadt.marriage || '|' || ipadt.changwat || '|' || ipadt.amphur || '|' || ipadt.nation
        || '|' || ipadt.admtype || '|' || ipadt.admsource || '|' || ipadt.dtadm || '|' || ipadt.dtdisch || '|' || ipadt.leaveday || '|' || ipadt.dischstat
        || '|' || ipadt.dischtype || '|' || ipadt.admwt || '|' || ipadt.dischward || '|' || ipadt.dept)
        || E'\n' || '</IPADT>' || E'\n' || '<IPDx Reccount="' || case when ipadt.ipdx_reccount is not null then ipadt.ipdx_reccount else 0 end || '">'
        || case when ipadt.ipdx is not null then E'\n' || ipadt.ipdx else '' end
        || E'\n' || '</IPDx>' || E'\n' || '<IPOp Reccount="' || case when ipadt.ipop_reccount is not null then ipadt.ipop_reccount else 0 end || '">'
        || case when ipadt.ipop is not null then E'\n' || ipadt.ipop else '' end
        || E'\n' || '</IPOp>' || E'\n' || '<Invoices>'
        || E'\n' || '<InvNumber>' ||  case when ipadt.invnumber is not null then ipadt.invnumber else '' end || '</InvNumber>'
        || E'\n' || '<InvDT>' || case when ipadt.invdt is not null then ipadt.invdt else '' end || '</InvDT>'
        || E'\n' || '<BillItems Reccount="' || case when ipadt.billitems_reccount is not null then ipadt.billitems_reccount else 0 end || '">'
        || case when ipadt.billitems_detail is not null then E'\n' || ipadt.billitems_detail else '' end
        || E'\n' || '</BillItems>' || E'\n' || '<InvAddDiscount>' || case when ipadt.invadddiscount is not null then ipadt.invadddiscount else '0.00' end || '</InvAddDiscount>'
        || E'\n' || '<DRGCharge>' || case when ipadt.drgcharge is not null then ipadt.drgcharge else '0.00' end || '</DRGCharge>'
        || E'\n' || '<XDRGClaim>' || case when ipadt.xdrgclaim is not null then ipadt.xdrgclaim else '0.00' end || '</XDRGClaim>'
        || E'\n' || '</Invoices>' || E'\n' || '<CoInsurance>' || E'\n' || '</CoInsurance>'
        || E'\n' || '</CIPN>' as cipn_details
from (select base_site.base_site_id as authorid
    ,base_site.site_name as authorname
    ,case when admit.permit_no is not null and admit.permit_no <> '' then admit.permit_no else '' end as authcode
    ,to_char(current_timestamp,'YYYY-MM-DDThh24:mi:ss') as authdt
    ,visit.an as an
    ,patient.hn as hn
    ,case when (patient.base_labor_type_id in ('02','03','04','11','12','13','14','21','22','23'))
          then '1'
          when (patient.base_labor_type_id = '' and patient.passport_no <> '')
          then '3'
          when (patient.pid <> '')
          then '0'
          else '9' end as idtype
    ,case when (patient.base_labor_type_id in ('02','03','04','11','12','13','14','21','22','23'))
          then case when patient.passport_no <> ''
                    then patient.passport_no
                    else '' end
          else patient.pid
          end as pidpat
    ,patient.prename as title
    ,patient.firstname || ' ' || patient.lastname as namepat
    ,case when length(patient.birthdate) >= 10 
          then patient.birthdate
          else '' end as dob
    ,patient.fix_gender_id as sex
    ,case when patient.fix_marriage_id = '1' then '1'
          when patient.fix_marriage_id = '2' then '2'
          when patient.fix_marriage_id in ('4','5') then '3'
          else '4' end as marriage
    ,patient.fix_changwat_id as changwat
    ,patient.fix_amphur_id as amphur
    ,case when patient.fix_nationality_id = 'CN' then '44'
          when patient.fix_nationality_id = 'IN' then '45'
          when patient.fix_nationality_id = 'CN' then '46'
          when patient.fix_nationality_id = 'MR' then '48'
          when patient.fix_nationality_id = 'LA' then '56'
          when patient.fix_nationality_id = 'CB' then '57'
          when patient.fix_nationality_id = 'TH' then '99'
          else '97' end as nation
    ,case when (vital_sign_extend.visit_id is not null and custom_medical_data.ref_id is not null) then 'A'
          when visit.fix_emergency_type_id = '2' then 'E'
          when visit.fix_emergency_type_id = '3' then 'U'
          else 'O' end as admtype
    ,case when refer_in.visit_id is not null then 'T'
          else 'O' end as admsource
    ,admit.admit_date || 't' || admit.admit_time as dtadm
    ,admit.ipd_discharge_date || 't' || admit.ipd_discharge_time as dtdisch
    ,case when leave_days.leave_datetime is not null and leave_days.comeback_datetime is not null
          then date_part('day',age((leave_days.comeback_datetime at time zone 'utc' at time zone 'ict')
                            ,(leave_days.leave_datetime at time zone 'utc' at time zone 'ict')))::text
          else '0' end::text as leaveday
    ,doctor_discharge_ipd.fix_ipd_discharge_status_id as dischstat
    ,doctor_discharge_ipd.fix_ipd_discharge_type_id as dischtype
    ,(case when vital_sign.weight is not null
          then vital_sign.weight
          else '0' end)::decimal(12,3)::text as admwt
    ,case when admit.ward_stay is not null 
          then admit.ward_stay
          else '' end as dischward
    ,case when sc_clinic.code is not null
          then sc_clinic.code
          else '' end as dept
    ,ipdx.ipdx_reccount as ipdx_reccount
    ,ipdx.ipdx_detail as ipdx
    ,ipop.ipop_reccount as ipop_reccount
    ,ipop.ipop_detail as ipop
    ,max(receipt_invno.invno) as invnumber
    ,max(billitems.invdt) as invdt
    ,billitems.billitems_reccount
    ,billitems.billitems_detail
    ,'0.00' as invadddiscount
    ,billitems.drgcharge
    ,billitems.xdrgclaim
    ,visit.visit_id
from receipt
    inner join receipt_billing_group on receipt.receipt_id = receipt_billing_group.receipt_id
    inner join (select receipt.visit_id
                ,max(case when receipt.plan_id <> '10' then receipt.plan_id else '' end) as ofc
                ,max(case when receipt.plan_id = '10' then receipt.plan_id else '' end) as cash
                ,max(replace(case when receipt.fix_receipt_status_id = '2' and receipt.cut_from_receipt_id = ''
                                   and (cast(receipt.cost as float) > 0.0) 
                                   and (receipt_plan.base_plan_group_id = 'OFC' and receipt.receipt_number ilike 'C%')
                      then format_receipt_smart_report(receipt.receipt_number ,receipt.fix_receipt_type_id ,receipt.fix_receipt_status_id ,receipt.credit_number ,receipt.fix_visit_type_id)::text 
                      else '' end,' ','')) as invno
                from receipt
                    inner join visit on receipt.visit_id = visit.visit_id
                                    and visit.fix_visit_type_id = '1'
                                    and visit.active = '1'
                                    and visit.visit_id = ANY ($visitIds)
                    inner join visit_payment on visit.visit_id = visit_payment.visit_id
                    inner join plan on visit_payment.plan_id = plan.plan_id
                               and plan.base_plan_group_id = 'OFC'
                               and plan.plan_id not in ('OFC_C3','OFL07','OFC_O7','OFC04')
                inner join plan as receipt_plan on receipt.plan_id = receipt_plan.plan_id
                               and (receipt_plan.plan_id = '10' or receipt_plan.base_plan_group_id = 'OFC')
                               and receipt_plan.plan_id not in ('OFC_C3','OFL07','OFC_O7','OFC04')
                group by receipt.visit_id
            ) as receipt_invno on receipt.visit_id = receipt_invno.visit_id
                        and receipt_invno.ofc <> ''
    inner join visit on receipt.visit_id = visit.visit_id
                    and visit.fix_visit_type_id = '1'
                    and visit.active = '1'
                    and visit.doctor_discharge = '1'
                    and visit.financial_discharge = '1'
                    and visit.visit_id = ANY ($visitIds)
    inner join doctor_discharge_ipd on visit.visit_id = doctor_discharge_ipd.visit_id
    inner join admit on visit.visit_id = admit.visit_id
                    and admit.active = '1'
                    and admit.ipd_discharge = '1'
    left join (select vital_sign_ipd.admit_id
                    ,case when length(replace(vital_sign_ipd.weight,'.','')) >= 4 and vital_sign_ipd.weight not ilike '%.%' and regexp_replace(vital_sign_ipd.weight , '[^0-9]*', '', 'g') <> ''
                          then (vital_sign_ipd.weight::numeric/1000)::text
                          else vital_sign_ipd.weight end as weight
                from vital_sign_ipd
                inner join (select vital_sign_ipd.admit_id
                            ,min(vital_sign_ipd.measure_date || ',' || vital_sign_ipd.measure_time) as vital_sign_datetime
                        from vital_sign_ipd
                            inner join admit on vital_sign_ipd.admit_id = admit.admit_id
                            inner join visit on admit.visit_id = visit.visit_id
                            and admit.active = '1'
                            and visit.active = '1'
                            and visit.fix_visit_type_id = '1'
                            and visit.financial_discharge = '1'
                            and visit.doctor_discharge = '1'
                            and vital_sign_ipd.weight <> ''
                            and visit.visit_id = ANY ($visitIds)
                        group by vital_sign_ipd.admit_id
                        ) as max_vital_sign on vital_sign_ipd.admit_id = max_vital_sign.admit_id
                                           and (vital_sign_ipd.measure_date || ',' || vital_sign_ipd.measure_time) = max_vital_sign.vital_sign_datetime
                ) as vital_sign on admit.admit_id = vital_sign.admit_id
    inner join patient on visit.patient_id = patient.patient_id
    inner join visit_payment on visit.visit_id = visit_payment.visit_id
    inner join plan on visit_payment.plan_id = plan.plan_id
                   and plan.base_plan_group_id = 'OFC'
                   and plan.plan_id not in ('OFC_C3','OFL07','OFC_O7','OFC04')
    inner join plan as receipt_plan on receipt.plan_id = receipt_plan.plan_id
    left join vital_sign_extend on visit.visit_id = vital_sign_extend.visit_id
                                and (length(vital_sign_extend.modify_date) >= 10 and length(vital_sign_extend.modify_time) > 0)
                                and vital_sign_extend.is_er_assessment = '1'
    left join custom_medical_data on vital_sign_extend.vital_sign_extend_id = custom_medical_data.ref_id
                                and custom_medical_data.base_custom_form_id = 'er_accident'
    left join survey.leave_days on leave_days.visit_id = visit.visit_id
    left join (select visit.visit_id
                from visit
                    inner join refer_in on visit.visit_id = refer_in.visit_id
                where visit.active = '1'
                    and (refer_in.refer_in_id is not null)
                    and visit.fix_visit_type_id = '1'
                    and visit.doctor_discharge = '1'
                    and visit.financial_discharge = '1'
                    and visit.visit_id = ANY ($visitIds)
                 group by visit.visit_id
                        ,refer_in.refer_in_id) as refer_in on visit.visit_id = refer_in.visit_id
    left join (select ipdx.t_visit_id
                   ,max(ipdx.seq) as ipdx_reccount
                   ,array_to_string(array_agg(ipdx.ipdx_detail order by ipdx.seq),E'\n') as ipdx_detail
                from (select ipdx.t_visit_id
                               ,ipdx.seq
                               ,array_agg(ipdx.seq || '|' || ipdx.dxtype || '|' || ipdx.codesys || '|' || ipdx.code || '|' || ipdx.diagterm || '|' || ipdx.dr || '|' || ipdx.datediag) as ipdx_detail
                        from (select diagnosis_icd10.visit_id as t_visit_id
                            ,row_number() OVER (partition by diagnosis_icd10.visit_id 
                                                order by diagnosis_icd10.visit_id
                                                ,case when (diagnosis_icd10.fix_diagnosis_type_id not in ('1','2','3','4','5')) then '4' else diagnosis_icd10.fix_diagnosis_type_id end
                                                ,diagnosis_icd10.diagnosis_date) as seq
                            ,case when (diagnosis_icd10.fix_diagnosis_type_id not in ('1','2','3','4','5')) 
                                  then '4' 
                                  else diagnosis_icd10.fix_diagnosis_type_id end AS dxtype
                            ,case when icd_10_tm.codeset is not null and icd_10_cm.codeset is not null
                                  then 'ICD-10'
                                  when icd_10_tm.codeset is not null and icd_10_cm.codeset is null
                                  then 'ICD-10-TM'
                                  else 'ICD-10' end as codesys
                            ,case when diagnosis_icd10.icd10_code is not null
                                  then replace(diagnosis_icd10.icd10_code,'.','')
                                  else '' end as code
                            ,case when diagnosis_icd10.icd10_code is not null
                                  then replace(replace(replace(regexp_replace(diagnosis_icd10.icd10_description, E'[\r\n\t]', '', 'g'),'<','('),'>',')'),'&','and')
                                  else '' end as diagterm
                            ,case when employee.fix_employee_type_id = '2' and employee.profession_code  <> ''
                                        and (employee.prename not ilike 'ทพ.%' or employee.prename not ilike 'ทพญ.%'
                                            or employee.prename not ilike '%.ทพ.%' or employee.prename not ilike '%.ทพญ.%') 
                                  then  'ว'|| employee.profession_code
                                  when employee.fix_employee_type_id = '2' and employee.profession_code  <> ''
                                        and (employee.prename ilike 'ทพ.%' or employee.prename ilike 'ทพญ.%'
                                            or employee.prename ilike '%.ทพ.%' or employee.prename ilike '%.ทพญ.%')
                                  then  'ท'|| employee.profession_code
                                  when employee.fix_employee_type_id in ('1','5') and employee.profession_code <> '' then  'พ'|| employee.profession_code
                                  when employee.fix_employee_type_id = '3' and employee.profession_code <> ''  then  'ภ'|| employee.profession_code
                                  when employee.fix_employee_type_id not in ('1','2','3','5') and employee.profession_code <> ''  then  '-'|| employee.profession_code
                                  else '' end as dr
                            ,case when diagnosis_icd10.diagnosis_date is not null 
                                  then diagnosis_icd10.diagnosis_date
                                  else '' end AS datediag
                        from diagnosis_icd10
                            inner join visit on diagnosis_icd10.visit_id = visit.visit_id
                                            and visit.fix_visit_type_id = '1'
                                            and visit.active = '1'
                                            and visit.financial_discharge = '1'
                                            and visit.doctor_discharge = '1'
                                            and visit.visit_id = ANY ($visitIds)
                            inner join doctor_discharge_ipd on visit.visit_id = doctor_discharge_ipd.visit_id
                            left join health_insurance.icd_10_cm on icd_10_cm.code = replace(diagnosis_icd10.icd10_code,'.','')
                            left join health_insurance.icd_10_tm on icd_10_tm.code = replace(diagnosis_icd10.icd10_code,'.','')
                            left join employee on diagnosis_icd10.doctor_eid = employee.employee_id
                        where diagnosis_icd10.icd10_code <> ''
                        group by diagnosis_icd10.visit_id
                        ,case when (diagnosis_icd10.fix_diagnosis_type_id not in ('1','2','3','4','5')) 
                              then '4' else diagnosis_icd10.fix_diagnosis_type_id end
                        ,icd_10_tm.codeset
                        ,icd_10_cm.codeset
                        ,diagnosis_icd10.icd10_code
                        ,diagnosis_icd10.icd10_description
                        ,employee.fix_employee_type_id
                        ,employee.profession_code
                        ,employee.prename
                        ,diagnosis_icd10.diagnosis_date) as ipdx
                        group by ipdx.t_visit_id
                            ,ipdx.seq) as ipdx
                        group by ipdx.t_visit_id) as ipdx on visit.visit_id = ipdx.t_visit_id
    left join (select ipop.t_visit_id
                   ,max(ipop.seq) as ipop_reccount
                    ,array_to_string(array_agg(ipop.ipop_detail order by ipop.seq),E'\n') as ipop_detail
                from (select ipop.t_visit_id
                       ,ipop.seq
                       ,array_agg(ipop.seq || '|' || ipop.codesys || '|' || ipop.code || '|' || ipop.procterm || '|' || ipop.dr || '|' || ipop.datein || '|' || ipop.dateout || '|XXXX:Undefine') as ipop_detail
                from (select diagnosis_icd9.visit_id as t_visit_id
                           ,row_number() OVER (partition by diagnosis_icd9.visit_id
                                    order by diagnosis_icd9.visit_id,diagnosis_icd9.modify_date) as seq
                           ,case when (diagnosis_icd9.icd9_code is not null and diagnosis_icd9.icd9_code <> '')
                                 then 'ICD9CM'
                                 else '' end as codesys
                           ,case when diagnosis_icd9.icd9_code is not null
                                 then replace(diagnosis_icd9.icd9_code,'.','')
                                 else '' end as code
                           ,case when diagnosis_icd9.icd9_code is not null
                                 then replace(replace(replace(regexp_replace(diagnosis_icd9.icd9_description, E'[\r\n\t]', '', 'g'),'<','('),'>',')'),'&','and')
                                 else '' end as procterm
                            ,case when employee.fix_employee_type_id = '2' and employee.profession_code  <> ''
                                        and (employee.prename not ilike 'ทพ.%' or employee.prename not ilike 'ทพญ.%'
                                            or employee.prename not ilike '%.ทพ.%' or employee.prename not ilike '%.ทพญ.%') 
                                  then  'ว'|| employee.profession_code
                                  when employee.fix_employee_type_id = '2' and employee.profession_code  <> ''
                                        and (employee.prename ilike 'ทพ.%' or employee.prename ilike 'ทพญ.%'
                                            or employee.prename ilike '%.ทพ.%' or employee.prename ilike '%.ทพญ.%')
                                  then  'ท'|| employee.profession_code
                                  when employee.fix_employee_type_id in ('1','5') and employee.profession_code <> '' then  'พ'|| employee.profession_code
                                  when employee.fix_employee_type_id = '3' and employee.profession_code <> ''  then  'ภ'|| employee.profession_code
                                  when employee.fix_employee_type_id not in ('1','2','3','5') and employee.profession_code <> ''  then  '-'|| employee.profession_code
                                  else '' end as dr
                       ,case when diagnosis_icd9.date_in || 'T' || diagnosis_icd9.time_in is not null 
                             then diagnosis_icd9.date_in || 'T' || diagnosis_icd9.time_in
                             else '' end AS datein
                       ,case when diagnosis_icd9.date_out || 'T' || diagnosis_icd9.time_out is not null 
                             then diagnosis_icd9.date_out || 'T' || diagnosis_icd9.time_out
                             else '' end AS dateout
                        from diagnosis_icd9
                            inner join visit on diagnosis_icd9.visit_id = visit.visit_id
                                            and visit.fix_visit_type_id = '1'
                                            and visit.active = '1'
                                            and visit.financial_discharge = '1'
                                            and visit.doctor_discharge = '1'
                                            and visit.visit_id = ANY ($visitIds)
                            inner join doctor_discharge_ipd on visit.visit_id = doctor_discharge_ipd.visit_id
                            left join employee on diagnosis_icd9.doctor_eid = employee.employee_id
                        where diagnosis_icd9.icd9_code <> ''
                        group by diagnosis_icd9.visit_id
                         ,diagnosis_icd9.icd9_code
                         ,diagnosis_icd9.icd9_description
                         ,employee.fix_employee_type_id
                         ,employee.profession_code
                         ,employee.prename
                         ,diagnosis_icd9.date_in
                         ,diagnosis_icd9.time_in
                         ,diagnosis_icd9.date_out
                         ,diagnosis_icd9.time_out
                         ,diagnosis_icd9.modify_date) as ipop
                group by ipop.t_visit_id
                    ,ipop.seq
                ) as ipop
                group by ipop.t_visit_id) as ipop on visit.visit_id = ipop.t_visit_id
    left join (select billitems.t_visit_id
                ,max(billitems.invdt) as invdt
                ,max(billitems.seq) as billitems_reccount
                ,array_to_string(array_agg(billitems.billitems_detail order by billitems.seq),E'\n') as billitems_detail
                ,sum(billitems.drgcharge)::decimal(8,2)::text as drgcharge
                ,sum(billitems.xdrgclaim)::decimal(8,2)::text as xdrgclaim
            from (select billitems.t_visit_id
                    ,max(billitems.invdt) as invdt
                    ,billitems.seq
                    ,billitems.drgcharge
                    ,billitems.xdrgclaim
                    ,array_agg(billitems.seq || '|' || billitems.servdate || '|' || billitems.billgr || '|' || billitems.lccode || '|' || billitems.descript || '|' || billitems.qty 
                              || '|' || billitems.unitprice|| '|' || billitems.chargeamt|| '|' || billitems.discount|| '|' || billitems.procedureseq|| '|' || billitems.diagnosisseq 
                              || '|' || billitems.claimsys|| '|' || billitems.billgrcs|| '|' || billitems.cscode|| '|' || billitems.codesys|| '|' || billitems.stdcode
                              || '|' || billitems.claimcat|| '|' || billitems.daterev|| '|' || billitems.claimup|| '|' || billitems.claimamt) as billitems_detail
                from (select billitems.t_visit_id
                        ,max(billitems.invdt) as invdt
                        ,row_number() OVER (partition by  billitems.t_visit_id order by billitems.servdate,billitems.descript) as seq
                        ,billitems.servdate
                        ,billitems.billgr
                        ,billitems.lccode
                        ,billitems.descript
                        ,case when POSITION('.' in(sum(billitems.qty))::text)::int > 0 
                              then (sum(billitems.qty))::decimal(8,2)::text
                              else (sum(billitems.qty))::integer::text end as qty
                        ,billitems.unitprice
                         ,sum(billitems.chargeamt)::decimal(8,2)::text as chargeamt
                        ,sum(billitems.discount)::decimal(8,2)::text as discount
                        ,billitems.procedureseq
                        ,billitems.diagnosisseq
                        ,billitems.claimsys
                        ,billitems.billgrcs
                        ,billitems.cscode
                        ,billitems.codesys
                        ,billitems.stdcode
                        ,billitems.claimcat
                        ,billitems.daterev
                        ,billitems.claimup
                        ,sum(billitems.claimamt)::decimal(8,2)::text as claimamt
                        ,sum(case when billitems.claimcat = 'D' then billitems.claimamt else 0 end)::decimal(8,2) as drgcharge
                        ,sum(case when billitems.claimcat = 'T' then billitems.claimamt else 0 end)::decimal(8,2) as xdrgclaim
                    from(select order_item.t_visit_id
                            ,max(order_item.invdt) as invdt
                            ,order_item.servdate
                            ,case when order_item.base_billing_group_id = '01.01.01.00.00.00' then '01'
                                  when order_item.base_billing_group_id = '01.01.01.01.00.00' then '02'
                                  when order_item.base_billing_group_id IN ('01.01.01.02.00.00','01.01.14.01.00.00','01.01.14.02.00.00') then '03'
                                  when order_item.base_billing_group_id = '01.01.01.03.00.00' then '04'
                                  when order_item.base_billing_group_id IN ('01.01.01.01.01.01','01.02.01.04.00.00','01.02.01.05.00.00','01.02.01.06.00.00') then '05'
                                  when order_item.base_billing_group_id = '01.01.02.01.00.00' then '06'
                                  when order_item.base_billing_group_id = '01.01.02.02.00.00' then '07'
                                  when order_item.base_billing_group_id = '01.01.02.03.00.00' then '08'
                                  when order_item.base_billing_group_id = '01.01.03.00.00.00' then '09'
                                  when order_item.base_billing_group_id = '01.01.04.00.00.00' then '10'
                                  when order_item.base_billing_group_id IN ('01.01.04.01.00.00','01.02.01.03.00.00') then '11'
                                  when order_item.base_billing_group_id IN ('01.01.01.12.01.04','01.01.01.12.01.05','01.01.05.00.00.00') then '12'
                                  when order_item.base_billing_group_id = '01.01.05.01.00.00' then '13'
                                  when order_item.base_billing_group_id = '01.01.05.02.00.00' then '14'
                                  when order_item.base_billing_group_id = '01.01.05.03.00.00' then '15'
                                  when order_item.base_billing_group_id IN ('01.01.06.00.00.00','02.02.00.00.00.00','02.09.00.00.00.00') then '16'
                                  else '00' end as billgr
                            ,case when order_item.fix_item_type_id in ('0') then order_item.item_code
                                  when order_item.reg_no <> '' then order_item.reg_no
                                  else order_item.item_code end as lccode
                            ,order_item.descript
                            ,(order_item.quantity::numeric-(case when order_item.return_quantity is null then 0 else order_item.return_quantity::int end)) as qty
                            ,order_item.unit_price_sale::decimal(8,2)::text as unitprice
                            ,((order_item.unit_price_sale::float - ((order_item.unit_price_sale::float*order_item.discount_percent::float)/100))
                              *(order_item.quantity::numeric-(case when order_item.return_quantity is null 
                                                                   then 0 else order_item.return_quantity::int end)))::decimal(8,2)  as chargeamt
                            ,((((order_item.unit_price_sale::float*order_item.discount_percent::float)/100))
                              *(order_item.quantity::numeric-(case when order_item.return_quantity is null 
                                                                   then 0 else order_item.return_quantity::int end)))::decimal(8,2) as discount
                            ,'0' as procedureseq
                            ,'0' as diagnosisseq
                            ,'CS' as claimsys
                            ,case when order_item.fix_chrgitem_id in ('1','2','3','5','6','7','8','9') then lpad(order_item.fix_chrgitem_id,2,'0')
                                  when order_item.fix_chrgitem_id ilike '4%' then '04'
                                  when order_item.fix_chrgitem_id ilike 'A' then '10'
                                  when order_item.fix_chrgitem_id ilike 'B' then '11'
                                  when order_item.fix_chrgitem_id ilike 'C' then '12'
                                  when order_item.fix_chrgitem_id ilike 'D' then '13'
                                  when order_item.fix_chrgitem_id ilike 'E' then '14'
                                  when order_item.fix_chrgitem_id ilike 'F' then '15'
                                  when order_item.fix_chrgitem_id ilike 'G' then '16'
                                  when order_item.fix_chrgitem_id ilike 'H' then '17'
                                  when order_item.fix_chrgitem_id ilike 'I' then '88'
                                  else '90' end as billgrcs
                            ,case when order_item.fix_item_type_id in ('1') then order_item.reg_no
                                  else case when order_item.tmtid is null then '' else order_item.tmtid end end as cscode
                            ,'' as codesys
                            ,'' as stdcode
                            ,case when replace(order_item.fix_chrgitem_id,'0','') in ('1','2')
                                  then 'T'
                                  else 'D' end as claimcat
                            ,case when order_item.modify_date is not null 
                                  then order_item.modify_date 
                                  else '0000-00-00' end AS daterev
                            ,sum(case when order_item.payer_share::decimal(8,2) > 0
                                   then case when replace(order_item.fix_chrgitem_id,'0','') in ('J','K')
                                             then '0.00'::decimal(8,2)
                                             else (order_item.payer_share_unit::float - ((order_item.payer_share_unit::float*order_item.discount_percent::float)/100)) end
                                   else '0.00' end::decimal(8,2))::text as claimup
                            ,sum(case when order_item.payer_share::decimal(8,2) > 0
                                   then case when replace(order_item.fix_chrgitem_id,'0','') in ('J','K')
                                             then '0.00'::decimal(8,2)
                                             else ((order_item.payer_share_unit::float - ((order_item.payer_share_unit::float*order_item.discount_percent::float)/100))
                                                  *(order_item.quantity::numeric-(CASE WHEN order_item.return_quantity is null then 0 else order_item.return_quantity::int end)))::decimal(8,2) end
                                   else '0' end::decimal(8,2))  as claimamt
                            ,order_item.order_item_id
                        from (select receipt.visit_id as t_visit_id
                                ,max(receipt.receive_date || 'T' || receipt.receive_time) as invdt
                                ,case when (order_item.verify_date) is not null
                                      then order_item.verify_date
                                      else '' end as servdate
                                ,receipt_billing_group.base_billing_group_id
                                ,item.item_code
                                ,replace(replace(replace(regexp_replace(item.common_name, E'[\r\n\t]', '', 'g'),'<','('),'>',')'),'&','and') as descript
                                ,order_item.unit_price_sale
                                ,order_item.fix_item_type_id
                                ,item.reg_no
                                ,sc_drug_tmt.tmtid
                                ,item.fix_chrgitem_id
                                ,item.modify_date
                                ,receipt_plan.base_plan_group_id
                                ,receipt_billing_group.discount_percent
                                ,order_item.quantity
                                ,return_drug.return_quantity
                                ,sum(case when receipt_plan.base_plan_group_id = 'OFC'
                                          then case when receipt_billing_group.payer_share::decimal(8,2) > 0 
                                          then receipt_billing_group.payer_share
                                          else receipt_billing_group.patient_share end::decimal(8,2)
                                          else '0.00'::decimal(8,2) end) as payer_share
                                ,sum(case when receipt_plan.base_plan_group_id = 'OFC'
                                          then case when receipt_billing_group.payer_share_unit::decimal(8,2) > 0 
                                                    then receipt_billing_group.payer_share_unit
                                                    else receipt_billing_group.patient_share_unit end::decimal(8,2)
                                          else '0.00'::decimal(8,2) end) as payer_share_unit
                                ,sum(case when receipt_plan.base_plan_group_id <> 'OFC'
                                          then case when receipt_billing_group.payer_share::decimal(8,2) > 0 
                                                    then receipt_billing_group.payer_share
                                                    else receipt_billing_group.patient_share end::decimal(8,2)
                                          else '0.00'::decimal(8,2) end) as patient_share
                                ,sum(case when receipt_plan.base_plan_group_id <> 'OFC'
                                          then case when receipt_billing_group.payer_share_unit::decimal(8,2) > 0 
                                                    then receipt_billing_group.payer_share_unit
                                                    else receipt_billing_group.patient_share_unit end::decimal(8,2)
                                          else '0.00'::decimal(8,2) end) as patient_share_unit
                                ,order_item.order_item_id
                            from receipt 
                                inner join plan as receipt_plan on receipt.plan_id = receipt_plan.plan_id
                                inner join (select receipt_billing_group.receipt_billing_group_id
                                   ,receipt_billing_group.receipt_id
                                   ,receipt_billing_group.discount_percent
                                   ,receipt_billing_group.base_billing_group_id
                                   ,receipt_order_detail.order_item_id
                                   ,receipt_order.item_id
                                   ,receipt_order.payer_share
                                   ,receipt_order.patient_share
                                   ,receipt_order.payer_share_unit
                                   ,receipt_order.patient_share_unit
                                            from receipt_billing_group
                                                 inner join receipt_order on receipt_billing_group.receipt_billing_group_id = receipt_order.receipt_billing_group_id
                                                 inner join receipt_order_detail on receipt_order.receipt_order_id = receipt_order_detail.receipt_order_id
                                                 inner join visit on receipt_billing_group.visit_id = visit.visit_id
                                                                 and visit.fix_visit_type_id = '1'
                                                                 and visit.active = '1'
                                                                 and visit.doctor_discharge = '1'
                                                                 and visit.financial_discharge = '1'
                                                                 and visit.visit_id = ANY ($visitIds)
                                                 inner join visit_payment on visit.visit_id = visit_payment.visit_id
                                                 inner join plan on visit_payment.plan_id = plan.plan_id
                                                                 and plan.base_plan_group_id = 'OFC'
                                                                 and plan.plan_id not in ('OFC_C3','OFL07','OFC_O7','OFC04')
                                           ) as receipt_billing_group on receipt.receipt_id = receipt_billing_group.receipt_id
                                inner join order_item on receipt_billing_group.order_item_id = order_item.order_item_id
                                                     and order_item.fix_order_status_id not in ('0','5')
                                                     and (case when order_item.quantity = '' then '0' else order_item.quantity end)::integer > 0
                                left join return_drug on order_item.order_item_id = return_drug.dispense_order_id
                                inner join item on receipt_billing_group.item_id = item.item_id
                                left join sm_drug_tmt on item.item_id = sm_drug_tmt.source
                                left join sc_drug_tmt on sm_drug_tmt.standard = sc_drug_tmt.id
                            where (cast(receipt.cost as float) > 0.0)
                                and receipt.fix_receipt_status_id = '2'
                                and receipt.cut_from_receipt_id = ''
                            group by receipt.visit_id
                                ,order_item.verify_date
                                ,order_item.verify_time
                                ,receipt_billing_group.base_billing_group_id
                                ,item.common_name
                                ,order_item.unit_price_sale
                                ,order_item.fix_item_type_id
                                ,item.reg_no
                                ,sc_drug_tmt.tmtid
                                ,item.fix_chrgitem_id
                                ,item.modify_date
                                ,receipt_plan.base_plan_group_id
                                ,receipt_billing_group.discount_percent
                                ,order_item.quantity
                                ,return_drug.return_quantity
                                ,order_item.order_item_id
                                ,item.item_code
                        ) as order_item
                        where (order_item.quantity::numeric-(case when order_item.return_quantity is null then 0 else order_item.return_quantity::int end))::integer > 0
                            and order_item.unit_price_sale::float > 0
                        group by order_item.t_visit_id
                            ,order_item.servdate
                            ,order_item.base_billing_group_id
                            ,order_item.fix_item_type_id
                            ,order_item.item_code
                            ,order_item.reg_no
                            ,order_item.descript
                            ,order_item.quantity
                            ,order_item.return_quantity
                            ,order_item.unit_price_sale
                            ,order_item.discount_percent
                            ,order_item.fix_chrgitem_id
                            ,order_item.tmtid
                            ,order_item.modify_date
                            ,order_item.order_item_id
                    ) as billitems
                    group by billitems.t_visit_id
                        ,billitems.servdate
                        ,billitems.billgr
                        ,billitems.lccode
                        ,billitems.descript
                        ,billitems.unitprice
                        ,billitems.procedureseq
                        ,billitems.diagnosisseq
                        ,billitems.claimsys
                        ,billitems.billgrcs
                        ,billitems.cscode
                        ,billitems.codesys
                        ,billitems.stdcode
                        ,billitems.claimcat
                        ,billitems.daterev
                        ,billitems.claimup
                ) as billitems
                group by billitems.t_visit_id
                    ,billitems.seq
                    ,billitems.drgcharge
                    ,billitems.xdrgclaim          
            ) as billitems
            group by billitems.t_visit_id) as billitems on visit.visit_id = billitems.t_visit_id
    left join sm_clinic on admit.ward_stay = sm_clinic.source
    left join sc_clinic on sm_clinic.standard = sc_clinic.id
    cross join base_site
where patient.active = '1'
    and receipt.fix_receipt_status_id = '2'
    and receipt.cut_from_receipt_id = ''
    and (cast(receipt.cost as float) > 0.0)
    and visit.financial_discharge = '1'
    and visit.doctor_discharge = '1'
group by base_site.base_site_id
    ,admit.permit_no
    ,visit.an
    ,patient.hn
    ,patient.base_labor_type_id
    ,patient.passport_no
    ,patient.pid
    ,patient.prename
    ,patient.firstname
    ,patient.lastname
    ,patient.birthdate
    ,patient.fix_gender_id
    ,patient.fix_marriage_id
    ,patient.fix_changwat_id
    ,patient.fix_amphur_id
    ,patient.fix_nationality_id
    ,vital_sign_extend.visit_id
    ,custom_medical_data.ref_id
    ,visit.fix_emergency_type_id
    ,refer_in.visit_id
    ,admit.admit_date
    ,admit.admit_time
    ,admit.ipd_discharge_date
    ,admit.ipd_discharge_time
    ,leave_days.leave_datetime
    ,leave_days.comeback_datetime
    ,doctor_discharge_ipd.fix_ipd_discharge_status_id
    ,doctor_discharge_ipd.fix_ipd_discharge_type_id
    ,vital_sign.weight
    ,admit.ward_stay
    ,sc_clinic.code
    ,ipdx.ipdx_reccount
    ,ipdx.ipdx_detail
    ,ipop.ipop_reccount
    ,ipop.ipop_detail
    ,billitems.billitems_reccount
    ,billitems.billitems_detail
    ,billitems.drgcharge
    ,billitems.xdrgclaim
    ,visit.visit_id
    ) as ipadt