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
from (select b_site.b_visit_office_id as authorid
       ,b_site.site_name as authorname
       ,case when (t_visit.visit_ipd_authen_code is not null and t_visit.visit_ipd_authen_code <> '')
             then t_visit.visit_ipd_authen_code 
             else '' end as authcode
       ,case when t_visit.visit_ipd_authen_date_time is not null
             then to_char(t_visit.visit_ipd_authen_date_time,'YYYY-MM-DDThh24:mi:ss')
             else '' end as authdt
       ,t_visit.visit_vn as an
       ,t_patient.patient_hn as hn
       ,case when t_patient.patient_pid <> '' and length(t_patient.patient_pid) = 13
             then '0'
             when t_patient.patient_pid = '' and t_person_foreigner.passport_no <> '' 
             then '3'
             when t_person_foreigner.f_person_foreigner_id = '23' and length(t_person_foreigner.foreigner_no) = 13
             then '9'
             when (t_patient.f_patient_foreigner_id in ('2','3','4') or t_person_foreigner.f_person_foreigner_id in ('11','12','13','14','21','22','23'))
             then '1'
             else '9' end as idtype
       ,case when t_patient.patient_pid <> '' and length(t_patient.patient_pid) = 13
             then t_patient.patient_pid
             when t_person_foreigner.passport_no <> '' 
             then t_person_foreigner.passport_no
             when t_person_foreigner.f_person_foreigner_id = '23' and length(t_person_foreigner.foreigner_no) = 13
             then t_person_foreigner.foreigner_no
             when (t_patient.f_patient_foreigner_id in ('2','3','4') or t_person_foreigner.f_person_foreigner_id in ('11','12','13','14','21','22','23'))
             then case when length(t_health_family.t_health_family_id) = 18
                       then '234' || substring(t_health_family.t_health_family_id,9)
                       when length(t_health_family.t_health_family_id) = 15
                       then '234' || substring(t_health_family.t_health_family_id,4)
                       else '' end
               else '' end as pidpat
       ,f_patient_prefix.patient_prefix_description as title
       ,t_patient.patient_firstname || ' ' ||  t_patient.patient_lastname as namepat
       ,case when text_to_timestamp(t_patient.patient_birthday) is not null 
             then to_char(text_to_timestamp(t_patient.patient_birthday),'YYYY-MM-DD') 
             else '' end AS dob
       ,t_patient.f_sex_id as sex
       ,case when f_patient_marriage_status.r_rp1853_marriage_id = '1' then '1'
             when f_patient_marriage_status.r_rp1853_marriage_id = '2' then '2'
             when f_patient_marriage_status.r_rp1853_marriage_id in ('3','4') then '3'
             else '4' end as marriage
       ,substring(t_patient.patient_changwat from 1 for 2) as changwat
       ,substring(t_patient.patient_amphur from 3 for 2) as amphur
       ,case when f_patient_nation.f_patient_nation_id = '44' then '44'
             when f_patient_nation.f_patient_nation_id = '45' then '45'
             when f_patient_nation.f_patient_nation_id = '46' then '46'
             when f_patient_nation.f_patient_nation_id = '48' then '48'
             when f_patient_nation.f_patient_nation_id = '56' then '56'
             when f_patient_nation.f_patient_nation_id = '57' then '57'
             when f_patient_nation.f_patient_nation_id = '99' then '99'
             else '97' end as nation
    ,case when (t_accident.t_visit_id is not null) then 'A'
          when t_visit.f_emergency_status_id = '3' then 'E'
          when t_visit.f_emergency_status_id = '2' then 'U'
          else 'O' end as admtype
    ,case when t_visit_refer_in_out.t_visit_id is not null then 'T'
          else 'O' end as admsource
       ,case when text_to_timestamp(t_visit.visit_begin_admit_date_time) is not null 
             then to_char(text_to_timestamp(t_visit.visit_begin_admit_date_time),'YYYY-MM-DDThh24:mi:ss') 
             else '' end AS dtadm
       ,case when text_to_timestamp(t_visit.visit_staff_doctor_discharge_date_time) is not null 
             then to_char(text_to_timestamp(t_visit.visit_staff_doctor_discharge_date_time),'YYYY-MM-DDThh24:mi:ss') 
             else '' end AS dtdisch
       ,case when date_part('days',text_to_timestamp(t_admit_leave_day.date_in) - text_to_timestamp(t_admit_leave_day.date_out)) is not null
             then date_part('days',text_to_timestamp(t_admit_leave_day.date_in) - text_to_timestamp(t_admit_leave_day.date_out))
             else 0 end::text as leaveday
       ,t_visit.f_visit_ipd_discharge_status_id AS dischstat
       ,case when t_visit.f_visit_ipd_discharge_type_id in ('1','2','3','4','5','8','9') 
             then t_visit.f_visit_ipd_discharge_type_id 
             else '5' end AS dischtype
       ,(case when t_visit_vital_sign.visit_vital_sign_weight  is null
              then 0.000
              else t_visit_vital_sign.visit_vital_sign_weight::decimal(7,3) end)::text AS admwt
       ,case when  b_visit_ward.visit_ward_number is not null 
             then b_visit_ward.visit_ward_number 
             else '' end AS dischward
       ,case when  b_report_12files_map_clinic.b_report_12files_std_clinic_id in ('01','02','03','04','05','06','07','08','09','10','11') 
             then b_report_12files_map_clinic.b_report_12files_std_clinic_id
             else '12' end as dept
       ,ipdx.ipdx_reccount as ipdx_reccount
       ,ipdx.ipdx_detail as ipdx
       ,ipop.ipop_reccount as ipop_reccount
       ,ipop.ipop_detail as ipop
       ,lpad(t_visit.visit_vn,9,'0') as invnumber
       ,max(case when text_to_timestamp(t_billing_invoice.t_billing_invoice_date_time) is not null 
             then to_char(text_to_timestamp(t_billing_invoice.t_billing_invoice_date_time),'YYYY-MM-DDThh24:mi:ss') 
             else '' end) AS invdt
       ,billitems.billitems_reccount as billitems_reccount
       ,billitems.billitems_detail as billitems_detail
       ,'0.00' as invadddiscount
       ,billitems.drgcharge
       ,billitems.xdrgclaim
       ,t_visit.t_visit_id
from t_billing_invoice
    inner join t_visit on (t_billing_invoice.t_visit_id = t_visit.t_visit_id
                and t_visit.f_visit_type_id = '1'
                and t_visit.f_visit_status_id in ('2','3')
                and t_visit.visit_ipd_discharge_status = '1'
                and t_visit.t_visit_id = ANY ($visitIds))
    left join (select t_visit_vital_sign.t_visit_id
                              ,t_visit_vital_sign.visit_vital_sign_weight 
                              ,t_visit_vital_sign.record_date||','||t_visit_vital_sign.record_time
                              ,row_number() OVER (partition by  t_visit_vital_sign.t_visit_id order by (t_visit_vital_sign.record_date||','||t_visit_vital_sign.record_time) desc) as seq
                      from t_visit_vital_sign 
                           inner join t_visit on t_visit_vital_sign.t_visit_id = t_visit.t_visit_id
                      where t_visit_vital_sign.visit_vital_sign_active = '1'
                            and t_visit_vital_sign.visit_vital_sign_weight <> ''
                            and t_visit.f_visit_type_id = '1'
                            and t_visit.f_visit_status_id in ('2','3')
                            and t_visit.visit_ipd_discharge_status = '1'
                            and t_visit.t_visit_id = ANY ($visitIds)
                            ) as t_visit_vital_sign on t_visit.t_visit_id = t_visit_vital_sign.t_visit_id
                                                    and t_visit_vital_sign.seq = 1
    left join (select t_accident.t_visit_id
            from t_accident 
                inner join t_visit on (t_accident.t_visit_id = t_visit.t_visit_id
                           and t_visit.f_visit_type_id = '1'
                           and t_visit.f_visit_status_id in ('2','3')
                           and t_visit.visit_ipd_discharge_status = '1'
                           and t_visit.t_visit_id = ANY ($visitIds))
            where t_accident.accident_active = '1'
            ) as t_accident on t_visit.t_visit_id = t_accident.t_visit_id
    left join (select t_visit_refer_in_out.t_visit_id
            from t_visit_refer_in_out 
                inner join t_visit on (t_visit_refer_in_out.t_visit_id = t_visit.t_visit_id
                           and t_visit.f_visit_type_id = '1'
                           and t_visit.f_visit_status_id in ('2','3')
                           and t_visit.visit_ipd_discharge_status = '1'
                           and t_visit.t_visit_id = ANY ($visitIds))
            where f_visit_refer_type_id = '0'
                and t_visit_refer_in_out.visit_refer_in_out_active = '1'
            ) as t_visit_refer_in_out on t_visit.t_visit_id = t_visit_refer_in_out.t_visit_id
    left join (select ipdx.t_visit_id
                   ,max(ipdx.seq) as ipdx_reccount
                   ,array_to_string(array_agg(ipdx.ipdx_detail order by ipdx.seq),E'\n') as ipdx_detail
                from (select ipdx.t_visit_id
                               ,ipdx.seq
                               ,array_agg(ipdx.seq || '|' || ipdx.dxtype || '|' || ipdx.codesys || '|' || ipdx.code || '|' || ipdx.diagterm || '|' || ipdx.dr || '|' || ipdx.datediag) as ipdx_detail
                        from (select t_diag_icd10.diag_icd10_vn as t_visit_id
                               ,row_number() OVER (partition by t_diag_icd10.diag_icd10_vn 
                                            order by t_diag_icd10.diag_icd10_vn
                                                    ,case when (t_diag_icd10.f_diag_icd10_type_id not in ('1','2','3','4','5')) then '4' else t_diag_icd10.f_diag_icd10_type_id end
                                                    ,t_diag_icd10.diag_icd10_record_date_time) as seq
                               ,case when (t_diag_icd10.f_diag_icd10_type_id not in ('1','2','3','4','5')) 
                                     then '4' 
                                     else t_diag_icd10.f_diag_icd10_type_id end AS dxtype
                               ,case when b_icd10.icd10_codeset = 'TT'
                                     then 'ICD-10-TM'
                                     else 'ICD-10' end as codesys
                               ,case when t_diag_icd10.diag_icd10_number is not null
                                     then replace(t_diag_icd10.diag_icd10_number,'.','')
                                     else '' end as code
                               ,case when t_diag_icd10.diag_icd10_number is not null
                                     then replace(regexp_replace(b_icd10.icd10_description, E'[\r\n\t]', '', 'g'),'&','and')
                                     else '' end as diagterm
                               ,case when b_employee.f_employee_authentication_id = '3' and b_employee.employee_number  <> ''
									 and (case when t_person.t_person_id is not null
											  then f_patient_prefix.patient_prefix_description not ilike 'ทพ.%' or f_patient_prefix.patient_prefix_description not ilike 'ทพญ.%'
											  else b_employee.employee_firstname not ilike 'ทพ.%' or b_employee.employee_firstname not ilike 'ทพญ.%'  end )
									 then  'ว'||b_employee.employee_number
									 when b_employee.f_employee_authentication_id = '3' and b_employee.employee_number  <> ''
									 and (case when t_person.t_person_id is not null
											   then f_patient_prefix.patient_prefix_description ilike 'ทพ.%' or f_patient_prefix.patient_prefix_description ilike 'ทพญ.%'
											   else b_employee.employee_firstname ilike 'ทพ.%' or b_employee.employee_firstname ilike 'ทพญ.%'  end)
									 then  'ท'||b_employee.employee_number
									 when b_employee.f_employee_authentication_id = '2' and b_employee.employee_number  <> ''  then  'พ'||b_employee.employee_number
									 when b_employee.f_employee_authentication_id = '6' and b_employee.employee_number  <> ''  then  'ภ'||b_employee.employee_number
									 when b_employee.f_employee_authentication_id not in ('2','3','6') and b_employee.employee_number  <> ''  then  '-'||b_employee.employee_number
									 else ''  end as dr
                               ,case when text_to_timestamp(t_diag_icd10.diag_icd10_diagnosis_date) is not null 
                                     then to_char(text_to_timestamp(t_diag_icd10.diag_icd10_diagnosis_date),'YYYY-MM-DD') 
                                     else '' end AS datediag
                        from t_diag_icd10
                            inner join t_visit on (t_diag_icd10.diag_icd10_vn = t_visit.t_visit_id
                                        and t_visit.f_visit_type_id = '1'
                                        and t_visit.f_visit_status_id in ('2','3')
                                        and t_visit.visit_ipd_discharge_status = '1'
                                        and t_visit.t_visit_id = ANY ($visitIds))
                            left join b_employee ON t_diag_icd10.diag_icd10_staff_doctor = b_employee.b_employee_id
                            left join b_icd10 on t_diag_icd10.diag_icd10_number = b_icd10.icd10_number
                            left join t_person on b_employee.t_person_id = t_person.t_person_id
                            left join f_patient_prefix on t_person.f_prefix_id = f_patient_prefix.f_patient_prefix_id
                        where t_diag_icd10.diag_icd10_active = '1'
                        order by t_diag_icd10.diag_icd10_vn
                            ,case when (t_diag_icd10.f_diag_icd10_type_id IN ('6','7')) then '4' else t_diag_icd10.f_diag_icd10_type_id end
                            ,t_diag_icd10.diag_icd10_record_date_time) as ipdx
                        group by ipdx.t_visit_id
                            ,ipdx.seq) as ipdx
                        group by ipdx.t_visit_id) as ipdx on t_visit.t_visit_id = ipdx.t_visit_id
    left join (select ipop.t_visit_id
                   ,max(ipop.seq) as ipop_reccount
                    ,array_to_string(array_agg(ipop.ipop_detail order by ipop.seq),E'\n') as ipop_detail
                from (select ipop.t_visit_id
                       ,ipop.seq
                       ,array_agg(ipop.seq || '|' || ipop.codesys || '|' || ipop.code || '|' || ipop.procterm || '|' || ipop.dr || '|' || ipop.datein || '|' || ipop.dateout || '|XXXX:Undefine') as ipop_detail
                from (select t_diag_icd9.diag_icd9_vn as t_visit_id
                       ,row_number() OVER (partition by t_diag_icd9.diag_icd9_vn 
                                    order by t_diag_icd9.diag_icd9_vn,t_diag_icd9.diag_icd9_start_time) as seq
                       ,case when (b_icd9.icd_10_tm <> '' and b_icd9.icd_10_tm is not null)
                             then 'ICD-10-TM'
                             else 'ICD9CM' end as codesys
                       ,case when t_diag_icd9.diag_icd9_icd9_number is not null
                             then replace(t_diag_icd9.diag_icd9_icd9_number,'.','')
                             else '' end as code
                       ,case when t_diag_icd9.diag_icd9_icd9_number is not null
                             then replace(regexp_replace(b_icd9.icd9_description, E'[\r\n\t]', '', 'g'),'&','and')
                             else '' end as procterm
                       ,case when b_employee.f_employee_authentication_id = '3' and b_employee.employee_number  <> ''
									 and (case when t_person.t_person_id is not null
											  then f_patient_prefix.patient_prefix_description not ilike 'ทพ.%' or f_patient_prefix.patient_prefix_description not ilike 'ทพญ.%'
											  else b_employee.employee_firstname not ilike 'ทพ.%' or b_employee.employee_firstname not ilike 'ทพญ.%'  end )
									 then  'ว'||b_employee.employee_number
									 when b_employee.f_employee_authentication_id = '3' and b_employee.employee_number  <> ''
									 and (case when t_person.t_person_id is not null
											   then f_patient_prefix.patient_prefix_description ilike 'ทพ.%' or f_patient_prefix.patient_prefix_description ilike 'ทพญ.%'
											   else b_employee.employee_firstname ilike 'ทพ.%' or b_employee.employee_firstname ilike 'ทพญ.%'  end)
									 then  'ท'||b_employee.employee_number
									 when b_employee.f_employee_authentication_id = '2' and b_employee.employee_number  <> ''  then  'พ'||b_employee.employee_number
									 when b_employee.f_employee_authentication_id = '6' and b_employee.employee_number  <> ''  then  'ภ'||b_employee.employee_number
									 when b_employee.f_employee_authentication_id not in ('2','3','6') and b_employee.employee_number  <> ''  then  '-'||b_employee.employee_number
									 else ''  end as dr
                       ,case when text_to_timestamp(t_diag_icd9.diag_icd9_start_time) is not null 
                             then to_char(text_to_timestamp(t_diag_icd9.diag_icd9_start_time),'YYYY-MM-DDThh24:mi:ss') 
                             else '' end AS datein
                       ,case when text_to_timestamp(t_diag_icd9.diag_icd9_finish_time) is not null 
                             then to_char(text_to_timestamp(t_diag_icd9.diag_icd9_finish_time),'YYYY-MM-DDThh24:mi:ss') 
                             else '' end AS dateout
                from t_diag_icd9
                    inner join t_visit on (t_diag_icd9.diag_icd9_vn = t_visit.t_visit_id
                                and t_visit.f_visit_type_id = '1'
                                and t_visit.f_visit_status_id in ('2','3')
                                and t_visit.visit_ipd_discharge_status = '1'
                                and t_visit.t_visit_id = ANY ($visitIds))
                    left join b_employee ON t_diag_icd9.diag_icd9_staff_doctor = b_employee.b_employee_id
                    left join b_icd9 on t_diag_icd9.diag_icd9_icd9_number = b_icd9.icd9_number
                    left join t_person on b_employee.t_person_id = t_person.t_person_id
                    left join f_patient_prefix on t_person.f_prefix_id = f_patient_prefix.f_patient_prefix_id
                where t_diag_icd9.diag_icd9_active = '1'
                order by t_diag_icd9.diag_icd9_vn
                    ,t_diag_icd9.diag_icd9_start_time) as ipop
                group by ipop.t_visit_id
                    ,ipop.seq
                ) as ipop
                group by ipop.t_visit_id) as ipop on t_visit.t_visit_id = ipop.t_visit_id
    left join(select billitems.t_visit_id
                   ,max(billitems.seq) as billitems_reccount
                   ,array_to_string(array_agg(billitems.billitems_detail order by billitems.seq),E'\n') as billitems_detail
                   ,sum(billitems.drgcharge)::decimal(8,2)::text as drgcharge
                   ,sum(billitems.xdrgclaim)::decimal(8,2)::text as xdrgclaim
            from (select billitems.t_visit_id
                   ,billitems.seq
                   ,billitems.drgcharge
                   ,billitems.xdrgclaim
                   ,array_agg(billitems.seq || '|' || billitems.servdate || '|' || billitems.billgr || '|' || billitems.lccode || '|' || billitems.descript || '|' || billitems.qty 
                            || '|' || billitems.unitprice|| '|' || billitems.chargeamt|| '|' || billitems.discount|| '|' || billitems.procedureseq|| '|' || billitems.diagnosisseq 
                            || '|' || billitems.claimsys|| '|' || billitems.billgrcs|| '|' || billitems.cscode|| '|' || billitems.codesys|| '|' || billitems.stdcode
                            || '|' || billitems.claimcat|| '|' || billitems.daterev|| '|' || billitems.claimup|| '|' || billitems.claimamt) as billitems_detail
            from (select billitems.t_visit_id
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
            from (select t_visit.t_visit_id
                   ,case when text_to_timestamp(t_order.order_verify_date_time) is not null 
                         then to_char(text_to_timestamp(t_order.order_verify_date_time),'YYYY-MM-DD') 
                         else '' end AS servdate
                   ,b_item_billing_subgroup.f_item_billing_group_id as billgr
                   ,case when (b_site.b_visit_office_id = '28850' and t_order.f_item_group_id = '1') then  trim(b_item.item_number) else b_item.b_item_id end  as lccode
                   ,replace(replace(replace(regexp_replace(b_item.item_common_name, E'[\r\n\t]', '', 'g'),'<','('),'>',')'),'&','and') as descript
                   ,t_order.order_qty as qty
                   ,t_order.order_price::decimal(8,2)::text as unitprice
                   ,t_billing_invoice_item.billing_invoice_item_total as chargeamt
                   ,t_billing_invoice_item.billing_invoice_item_total-billing_invoice_item_payer_share as discount
                   ,'0' as procedureseq
                   ,'0' as diagnosisseq
                   ,'CS' as claimsys
                   ,case when b_item_16_group.item_16_group_number in ('1','2','3','5','6','7','8','9') then lpad(b_item_16_group.item_16_group_number,2,'0')
					     when b_item_16_group.item_16_group_number ilike '4%' then '04'
                         when b_item_16_group.item_16_group_number ilike 'A' then '10'
                         when b_item_16_group.item_16_group_number ilike 'B' then '11'
                         when b_item_16_group.item_16_group_number ilike 'C' then '12'
                         when b_item_16_group.item_16_group_number ilike 'D' then '13'
                         when b_item_16_group.item_16_group_number ilike 'E' then '14'
                         when b_item_16_group.item_16_group_number ilike 'F' then '15'
                         when b_item_16_group.item_16_group_number ilike 'G' then '16'
                         when b_item_16_group.item_16_group_number ilike 'H' then '17'
                         when b_item_16_group.item_16_group_number ilike 'I' then '88'
                         else '90' end as billgrcs
                   ,case when t_order.f_item_group_id = '2' then b_item.item_general_number
                         else case when b_map_drug_tmt.b_drug_tmt_tpucode is null then '' else b_map_drug_tmt.b_drug_tmt_tpucode end end as cscode
                   ,'' as codesys
                   ,'' as stdcode
                   ,case when b_item_16_group.item_16_group_number in ('1','2')
                         then 'T'
                         else 'D' end as claimcat
                   ,case when b_item.modify_datetime is not null 
                         then to_char(b_item.modify_datetime,'YYYY-MM-DD') 
                         else '0000-00-00' end AS daterev
                   ,case when t_billing_invoice_item.billing_invoice_item_patient_share::float > 0
                         then '0.00'
                         else t_order.order_price end::decimal(8,2)::text as claimup
                   ,t_billing_invoice_item.billing_invoice_item_payer_share as claimamt
                   ,t_order.t_order_id
            from t_billing_invoice
                inner join t_billing_invoice_item on t_billing_invoice.t_billing_invoice_id = t_billing_invoice_item.t_billing_invoice_id
                            and t_billing_invoice_item.billing_invoice_item_active = '1'
                inner join t_order on t_order.t_order_id = t_billing_invoice_item.t_order_item_id
                            and t_order.f_order_status_id not in ('0','3')
                            and t_order.order_qty > 0
                inner join b_item on b_item.b_item_id = t_billing_invoice_item.b_item_id
                left join b_item_16_group on b_item_16_group.b_item_16_group_id = b_item.b_item_16_group_id
                left join b_item_billing_subgroup on b_item_billing_subgroup.b_item_billing_subgroup_id = b_item.b_item_billing_subgroup_id
                left join b_map_drug_tmt on b_item.b_item_id = b_map_drug_tmt.b_item_id
                inner join t_visit on (t_billing_invoice.t_visit_id = t_visit.t_visit_id
                            and t_visit.f_visit_type_id = '1'
                            and t_visit.f_visit_status_id in ('2','3')
                            and t_visit.visit_ipd_discharge_status = '1'
                            and t_visit.t_visit_id = ANY ($visitIds))
                cross join b_site
            where t_billing_invoice.billing_invoice_active = '1'
                and cast(t_billing_invoice.billing_invoice_payer_share as float) > 0.0
            group by t_visit.t_visit_id
                ,t_order.order_verify_date_time
                ,b_item_billing_subgroup.f_item_billing_group_id
                ,b_site.b_visit_office_id
                ,t_order.f_item_group_id
                ,b_item.item_number
                ,b_item.b_item_id
                ,t_order.t_order_id
                ,t_billing_invoice_item.billing_invoice_item_total
                ,t_billing_invoice_item.billing_invoice_item_payer_share
                ,b_item_16_group.item_16_group_number
                ,b_map_drug_tmt.b_drug_tmt_tpucode
                ,t_billing_invoice_item.billing_invoice_item_patient_share
            ) as billitems
            group by billitems.t_visit_id
                    ,billitems.servdate
                    ,billitems.descript
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
            group by billitems.t_visit_id) as billitems on t_visit.t_visit_id = billitems.t_visit_id
    left join b_visit_ward on (t_visit.b_visit_ward_id  = b_visit_ward.b_visit_ward_id)
    left join b_report_12files_map_clinic on (t_visit.b_visit_clinic_id = b_report_12files_map_clinic.b_visit_clinic_id)
    left join t_admit_leave_day on t_visit.t_visit_id = t_admit_leave_day.t_visit_id
                and t_admit_leave_day.active = '1'
    inner join t_patient on (t_patient.t_patient_id = t_visit.t_patient_id
                and t_patient.patient_active = '1')
    left join f_patient_prefix on f_patient_prefix.f_patient_prefix_id = t_patient.f_patient_prefix_id
    left join f_patient_marriage_status on t_patient.f_patient_marriage_status_id = f_patient_marriage_status.f_patient_marriage_status_id
    left join f_patient_nation on t_patient.f_patient_nation_id = f_patient_nation.f_patient_nation_id
    left join t_health_family on t_health_family.t_health_family_id = t_patient.t_health_family_id
    left join t_person_foreigner on t_health_family.t_health_family_id = t_person_foreigner.t_person_id
    inner join t_visit_payment on (t_billing_invoice.t_payment_id = t_visit_payment.t_visit_payment_id
                and t_visit_payment.visit_payment_active = '1'
                and t_visit_payment.b_contract_plans_id
                    in (select b_map_contract_plans_govoffical.b_contract_plans_id
                        from b_map_contract_plans_govoffical))
    cross join b_site
where t_billing_invoice.billing_invoice_active = '1'
    and cast(t_billing_invoice.billing_invoice_payer_share as float) > 0.0
group by b_site.b_visit_office_id
    ,b_site.site_name
    ,t_visit.visit_vn
    ,t_patient.patient_hn
    ,t_patient.patient_pid
    ,t_person_foreigner.passport_no
    ,t_person_foreigner.f_person_foreigner_id
    ,t_person_foreigner.foreigner_no
    ,t_patient.f_patient_foreigner_id
    ,t_health_family.t_health_family_id
    ,f_patient_prefix.patient_prefix_description
    ,t_patient.patient_firstname
    ,t_patient.patient_lastname
    ,t_patient.patient_birthday
    ,t_patient.f_sex_id
    ,f_patient_marriage_status.r_rp1853_marriage_id
    ,t_patient.patient_changwat
    ,t_patient.patient_amphur
    ,f_patient_nation.f_patient_nation_id
    ,t_visit.visit_begin_admit_date_time
    ,t_visit.visit_staff_doctor_discharge_date_time
    ,t_admit_leave_day.date_in
    ,t_admit_leave_day.date_out
    ,t_visit.f_visit_ipd_discharge_status_id
    ,t_visit.f_visit_ipd_discharge_type_id
    ,t_visit_vital_sign.visit_vital_sign_weight
    ,b_visit_ward.visit_ward_number
    ,b_report_12files_map_clinic.b_report_12files_std_clinic_id
    ,t_accident.t_visit_id
    ,t_visit_refer_in_out.t_visit_id
    ,t_visit.t_visit_id
    ,ipdx.ipdx_reccount
    ,ipdx.ipdx_detail
    ,ipop.ipop_reccount
    ,ipop.ipop_detail
    ,billitems.billitems_reccount
    ,billitems.billitems_detail
    ,billitems.drgcharge
    ,billitems.xdrgclaim
    ) as ipadt