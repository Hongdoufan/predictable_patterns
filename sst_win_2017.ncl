
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================

   var     = "sst"
   varname = "SSTK_GDS0_SFC"                                                        ; create a plot [?]
   diri = "/disk4/mssfs/forecast/ecmwf/11/monthly/surface/"
   fill = "sst.2017.grib"
;   output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
;   outName = var+"_in9_6mon_sona.nc"                       ; set plot name 
   latitude="g0_lat_2"    ;lat name
   longitude="g0_lon_3"   ;lon name
   levelname   = "lv_ISBL2"      
   level  = " "
   nensemble = 51
   nlatitude= 181
   nlongitude=360
   np   = 3        ; number of pictures
   son=addfile("/disk1/fhd/winter_forecast/data/sst_in11_cli.nc","r")
   cli=son->winter_anom
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================    

   f    = addfile(diri+fill,"r")   
   x      = f->$varname$
;   x = where(x.lt.0.000001, x@_FillValue, x)
;   x = x*1000
;   if(numsize.eq.5) then  
      winter_anom=new((/nensemble,nlatitude,nlongitude/),"float")     
      winter_mean=dim_avg_n(x(:,0:2,:,:),1)-273.15  
      son_cli=dim_avg_n(cli,0)
      do i=0,nensemble-1
      winter_anom(i,:,:)=winter_mean(i,:,:)-son_cli
      end do

   ensemble_winter=dim_avg_n(winter_anom,0)
   copy_VarCoords(x(0,0,:,:),ensemble_winter)
   printMinMax(winter_anom,False)
;exit()
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
; modoki area 
   latSa   = -10.0
   latNa   =  10.0
   lonLa   = 165.0       ;a 
   lonRa   = 220.0
          
   latSb   = -15.0
   latNb   =  5.0
   lonLb   = 250.0       ;b
   lonRb   = 310.0

   latSc   = -10.0
   latNc   =  20.0
   lonLc   = 125.0       ;c 
   lonRc   = 145.0

   latSd   = -5.0
   latNd   =  5.0
   lonLd   = 190.0       ;nino3.4
   lonRd   = 240.0


   ssta=ensemble_winter({latSa:latNa},{lonLa:lonRa})
   sstb=ensemble_winter({latSb:latNb},{lonLb:lonRb})
   sstc=ensemble_winter({latSc:latNc},{lonLc:lonRc})
   sstd=ensemble_winter({latSd:latNd},{lonLd:lonRd})
  ;===========================================================================
  
  rad   = 4.*atan(1.)/180.
  lat1   = ssta&g0_lat_2
  clat1  =lat1
  clat1  = sqrt( cos(rad*lat1) ) 
  
  lat2   = sstb&g0_lat_2
  clat2  =lat2
  clat2  = sqrt( cos(rad*lat2) ) 

  lat3   = sstc&g0_lat_2
  clat3  =lat3
  clat3  = sqrt( cos(rad*lat3) ) 

  lat4   = sstd&g0_lat_2
  clat4  = lat4
  clat4  = sqrt( cos(rad*lat4) ) 

  area_a=wgt_areaave(ensemble_winter({latSa:latNa},{lonLa:lonRa}), clat1, 1.0, 0)
  area_b=wgt_areaave(ensemble_winter({latSb:latNb},{lonLb:lonRb}), clat2, 1.0, 0)
  area_c=wgt_areaave(ensemble_winter({latSc:latNc},{lonLc:lonRc}), clat3, 1.0, 0)
  nino34=wgt_areaave(ensemble_winter({latSd:latNd},{lonLd:lonRd}), clat4, 1.0, 0)

  print(area_a)
  print(area_b)
  print(area_c)
  
  modoki_mod=area_a-0.5*area_b-0.5*area_c
;  modoki_mod=dim_standardize_Wrap(modoki_mod,0)
;  nino34=dim_standardize_Wrap(area_d,0)
  print(modoki_mod)  ;0.3883877
  print(nino34)      ; -0.7129048

sd_ea_pc=addfile("/disk1/fhd/winter_forecast/data/emi_nino34_djf_prd_raw.nc","r")
sd_pc=sd_ea_pc->nino34
sdtp=new(37,"float")
sdtp(0:35)=sd_pc
sdtp(36)=nino34
aaa=dim_standardize_Wrap(sdtp, 0)
sds=dtrend(aaa,False)   ;-0.5829623
;exit()
print(sds)



;  sic_index_=dim_standardize_Wrap(area_d,0)
;system("rm -f /disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc", "c")
;fout->sic_index=sic_index


end
