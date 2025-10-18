

begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
  latSd   =  24
  latNd   =  40
  lonLd   =  70
  lonRd   =  105
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
  ; ensemble_winter=lonFlip(ensemble_winter)
   sstd=ensemble_winter(:,{latSd:latNd},{lonLd:lonRd})
  ;===========================================================================
  
  rad   = 4.*atan(1.)/180.
  lat4   = sstd&latitude
  clat4  = lat4
  clat4  = sqrt( cos(rad*lat4) ) 
  area_d=wgt_areaave(ensemble_winter(:,{latSd:latNd},{lonLd:lonRd}), clat4, 1.0, 0)

; print(area_d)
; exit()

  sic_index_=dim_standardize_Wrap(area_d,0)

 fout=addfile("/disk1/fhd/winter_forecast/data/emi_nino34_djf_prd.nc", "r")
 nino=fout->nino34
 tp_reg=regCoef(nino,sic_index_)
 sic_index=sic_index_-tp_reg*nino

;system("rm -f /disk1/fhd/winter_forecast/data/sd_tp_djf_son_raw.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son_raw.nc", "c")
;fout->sic_index=area_d
;
; system("rm -f /disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc")
; fout=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc", "c")
; fout->sic_index=sic_index_


;exit()

ss=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc","r")
sst=ss->eof_ts
cor_sst=escorc(sst, sic_index)
print(cor_sst)

;ss=addfile("/disk1/fhd/winter_forecast/data/msn_eof_sd_tp.nc","r")
;sst=ss->eof_ts
;cor_sst=escorc(sst, sic_index)
;print(cor_sst)


end
