

begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
  latSd   =  45
  latNd   =  60
  lonLd   =  60
  lonRd   =  165
  ; latSd   =  37.5
  ; latNd   =  57.5
  ; lonLd   =  20
  ; lonRd   =  135
   varname1     = "winter_anom"
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
                                                   
   file1 = addfile("/disk1/fhd/winter_forecast/data/sd_in9_6mon_sona.nc","r")
               
   var1=file1->$varname1$
   ensemble_winter=dim_avg_n(var1,1)
   copy_VarCoords(var1(:,0,:,:), ensemble_winter)
   ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)
   printMinMax(ensemble_winter, False)
   ensemble_winter=lonFlip(ensemble_winter)
   sstd=ensemble_winter(:,{latSd:latNd},{lonLd:lonRd})
  ;===========================================================================
  
  rad   = 4.*atan(1.)/180.
  lat4   = sstd&latitude
  clat4  = lat4
  clat4  = sqrt( cos(rad*lat4) ) 
  area_d=wgt_areaave(ensemble_winter(:,{latSd:latNd},{lonLd:lonRd}), clat4, 1.0, 0)
  sic_index_=dim_standardize_Wrap(area_d,0)




  ; printVarSummary(sic_index_)
  ; year=ispan(1,36,1)
  ; sss= dtrend_msg_n(year,sic_index_,True,True,0)
  ; jjj=sss@slope
;  print(jjj)

 system("rm -f /disk1/fhd/winter_forecast/data/sd_ea_son_prd.nc")
 fout=addfile("/disk1/fhd/winter_forecast/data/sd_ea_son_prd.nc", "c")
 fout->sic_index=sic_index_

;system("rm -f /disk1/fhd/winter_forecast/data/sd_ea_son_prd_raw.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/sd_ea_son_prd_raw.nc", "c")
;fout->sic_index=area_d

 ss=addfile("/disk1/fhd/winter_forecast/data/sd_ea_djf_prd.nc","r")
 sst=ss->sic_index
 cor_sst=escorc(sst, sic_index_)
 print(cor_sst)

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
