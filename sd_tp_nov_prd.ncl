

begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
;  latSd   =  43
;  latNd   =  55
;  lonLd   =  20
;  lonRd   =  120
  
  latSd   =  23    ;1
  latNd   =  30
  lonLd   =  103
  lonRd   =  120

  ; latSd   =  37.5
  ; latNd   =  57.5
  ; lonLd   =  20
  ; lonRd   =  135
   varname1     = "anom"
   varname2     = "sd"  
   pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
   startyear=1981
   endyear=2016
   nyear= 36
   latitude="g0_lat_2"    ;lat name
   longitude="g0_lon_3"   ;lon name
   levelname   = "lv_ISBL2"      
   level  = " "
   ensemble = 25
                                                   
   file1 = addfile("/disk1/fhd/winter_forecast/data/sd_monthly_in11.nc","r")
               
   var1=file1->$varname1$
   ensemble_winter=dim_avg_n(var1(:,:,0,:,:),1)
   copy_VarCoords(var1(:,0,0,:,:), ensemble_winter)
   ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)
   ensemble_winter=lonFlip(ensemble_winter)
   sstd=ensemble_winter(:,{latSd:latNd},{lonLd:lonRd})
  ;===========================================================================
  
  rad   = 4.*atan(1.)/180.
  lat4   = sstd&latitude
  clat4  = lat4
  clat4  = sqrt( cos(rad*lat4) ) 
  area_d=wgt_areaave(ensemble_winter(:,{latSd:latNd},{lonLd:lonRd}), clat4, 1.0, 0)


;  latSd2   =  45
;  latNd2   =  52
;  lonLd2   =  24
;  lonRd2   =  50
;   sstd2=ensemble_winter(:,{latSd2:latNd2},{lonLd2:lonRd2})
;  ;===========================================================================
;  
;  rad   = 4.*atan(1.)/180.
;  lat42   = sstd2&latitude
;  clat42  = lat42
;  clat42  = sqrt( cos(rad*lat42) ) 
;  area_d2=wgt_areaave(ensemble_winter(:,{latSd2:latNd2},{lonLd2:lonRd2}), clat42, 1.0, 0)



  latSd1   =  71
  latNd1   =  64
  lonLd1   =  90
  lonRd1   =  120
   sstd1=ensemble_winter(:,{latSd1:latNd1},{lonLd1:lonRd1})
  ;===========================================================================
  
  rad   = 4.*atan(1.)/180.
  lat41   = sstd1&latitude
  clat41  = lat41
  clat41  = sqrt( cos(rad*lat41) ) 
  area_d1=wgt_areaave(ensemble_winter(:,{latSd1:latNd1},{lonLd1:lonRd1}), clat41, 1.0, 0)



  diff=area_d-area_d1;+area_d2
  sic_index_=dim_standardize_Wrap(diff,0)




  ; printVarSummary(sic_index_)
  ; year=ispan(1,36,1)
  ; sss= dtrend_msg_n(year,sic_index_,True,True,0)
  ; jjj=sss@slope
;  print(jjj)

; system("rm -f /disk1/fhd/winter_forecast/data/sd_ea_nov_prd.nc")
; fout=addfile("/disk1/fhd/winter_forecast/data/sd_ea_nov_prd.nc", "c")
; fout->sic_index=sic_index_

;system("rm -f /disk1/fhd/winter_forecast/data/sd_ea_son_prd_raw.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/sd_ea_son_prd_raw.nc", "c")
;fout->sic_index=area_d
;
; ss=addfile("/disk1/fhd/winter_forecast/data/sd_ea_son_prd.nc","r")
; sst=ss->sic_index
; cor_sst=escorc(sst, sic_index_)
; print(cor_sst)

; diff= sst-sic_index_
; printMinMax(diff,False)
; sst=addfile("/disk1/fhd/winter_forecast/data/emi_nino34_djf_prd.nc", "r")
; nino=sst->nino34
; cor_sst=escorc(nino, sic_index)
; print(cor_sst)

aa=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
t2m_eof=aa->eof_ts(2,:)
c=escorc(t2m_eof,sic_index_)
print(c)
end
