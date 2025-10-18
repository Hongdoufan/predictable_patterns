
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================

   var     = "sd"
   varname = "SD_GDS0_SFC"                                                       ; create a plot [?]
   diri = "/disk4/mssfs/forecast/ecmwf/9/monthly/surface/"
   fill = "sd.2017.grib"
   output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
   outName = var+"_in9_6mon_sona.nc"                       ; set plot name 
   latitude="g0_lat_2"    ;lat name
   longitude="g0_lon_3"   ;lon name
   levelname   = "lv_ISBL2"      
   level  = " "
   nensemble = 51
   nlatitude= 181
   nlongitude=360
   np   = 3        ; number of pictures
   son=addfile("/disk1/fhd/winter_forecast/data/sd_in9_cli.nc","r")
   cli=son->winter_anom
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================    

   f    = addfile(diri+fill,"r")   
   x      = f->$varname$
   x = where(x.lt.0.000001, x@_FillValue, x)
   x = x*1000
;   if(numsize.eq.5) then  
      winter_anom=new((/nensemble,nlatitude,nlongitude/),"float")     
      winter_mean=dim_avg_n(x(:,0:2,:,:),1)
      son_cli=dim_avg_n(cli,0)
      do i=0,nensemble-1
      winter_anom(i,:,:)=winter_mean(i,:,:)-son_cli
      end do

   sd_son_2017=dim_avg_n(winter_anom,0)
   copy_VarCoords(x(0,0,:,:),sd_son_2017)
   printVarSummary(sd_son_2017)

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
                                                   
;   ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)
  ; ensemble_winter=lonFlip(ensemble_winter)
   sstd=sd_son_2017({latSd:latNd},{lonLd:lonRd})
  ;===========================================================================
  
  rad   = 4.*atan(1.)/180.
  lat4   = sstd&g0_lat_2
  clat4  = lat4
  clat4  = sqrt( cos(rad*lat4) ) 
  area_d=wgt_areaave(sd_son_2017({latSd:latNd},{lonLd:lonRd}), clat4, 1.0, 0)
  print(area_d)     ; -12.08121

sd_ea_pc=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son_raw.nc","r")
sd_pc=sd_ea_pc->sic_index
sdtp=new(37,"float")
sdtp(0:35)=sd_pc
sdtp(36)=area_d
aaa=dim_standardize_Wrap(sdtp, 0)
sds=dtrend(aaa,False)   ;-4.805452
;exit()
print(sds)

;  sic_index_=dim_standardize_Wrap(area_d,0)
;system("rm -f /disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc", "c")
;fout->sic_index=sic_index


end
