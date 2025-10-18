n
latS   =  45
latN   =  75
lonL   =  20
lonR   =  130
output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "sst_projection_index_cv.nc"  
year = 31
optETS = False
neof   = 2
;==========================================================
;read predicable patterns
;==========================================================
all_files = "/disk1/fhd/winter_forecast/data/eof_sd_cv_2020.nc"
patterns = addfile (all_files, "r")
   mode=patterns->eof  ; note syntax [:]
patterns_36 = addfile ("/disk1/fhd/winter_forecast/data/eof_sd_djf_2020.nc", "r")   
mode_36=patterns_36->eof   
   
   printVarSummary(mode)
   lat=mode&latitude
   lon=mode&longitude
   
   scand_pattern=new((/year,dimsizes(lat),dimsizes(lon)/),"float")
    
   scand_pattern(0:29,:,:)=mode(:,0,:,:)
   scand_pattern(30,:,:)=mode_36
  
varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/sd_in11_6mon_wina_2020.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")

   var1=varible_file->$varname1$
   ensemble_winte=dim_avg_n(var1,1)
   copy_VarCoords(var1(:,0,:,:), ensemble_winte)
   winte = ensemble_winte(:,{latS:latN},{lonL:lonR})
;   copy_VarCoords(var1(:,0,{latS:latN},{lonL:lonR}), winte)
   ensemble_winter=new((/year,dimsizes(lat),dimsizes(lon)/),"float")
   ensemble_winter(0:29,:,:)=winte

   prediction = addfile ("/disk1/fhd/winter_forecast/data/prediction_raw_2022.nc", "r")
   var=prediction->sd({latS:latN},{lonL:lonR})
   var@_FillValue=9.96921e+36
   copy_VarCoords(winte(0,:,:), var)
   ensemble_winter(30,:,:)=var
  
ensemble_winter&nyear=ispan(1991,2021,1)

   ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)
;   ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)
;************************************************
; project predicted t2m  onto msn eof1 to get projection index
; consider weight
;************************************************
rad    = 4.*atan(1.)/180.
clat   = ensemble_winter&latitude
clat   = sqrt( cos(rad*clat) )                

wsea_variable   = ensemble_winter                                   ; copy meta data
wsea_variable   = ensemble_winter*conform(ensemble_winter, clat, 1)
ensemble     = wsea_variable({latitude|:},{longitude|:},{nyear|:})

   printVarSummary(scand_pattern)
   printVarSummary(ensemble)


; ==============================================================
; calculate the prejection (PC for every year) in prediction
; ==============================================================
eof_ts=new((/year,neof/),"float")
bbb=new((/dimsizes(lat),dimsizes(lon),2/),"float")
bbb(:,:,1)=1
scand=new((/1,dimsizes(ensemble_winter&latitude),dimsizes(ensemble_winter&longitude)/),"float")
;scand(0,:,:)=scand_pattern({latS:latN},:)

;printVarSummary(scand_pattern(0,0,:,:))
;printVarSummary(scand(0,:,:))
;exit()

 do i=0,year-1
     bbb(:,:,0)=ensemble(:,:,i)
     scand(0,:,:)=scand_pattern(i,:,:)
     temp   = eofunc_ts_Wrap (bbb, scand, optETS)
     eof_ts(i,:)= temp
 end do



 
; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
; =================================================================
rad    = 4.*atan(1.)/180.
clat   = ensemble_winter&latitude
clat   = sqrt( cos(rad*clat) )                


; =================================================================
; Normalize time series: Sum spatial weights over the area of used
; =================================================================
dimx  = dimsizes( ensemble )
mln    = dimx(1)
sumWgt = mln*sum(clat)
eof_ts = eof_ts/sumWgt

eof_ts = dim_standardize_n_Wrap(eof_ts,1,0)
eof_ts!0= "time"
print(eof_ts(:,0))

;system("rm -f /disk1/fhd/winter_forecast/data/sst_projection_index_cv_37.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/sst_projection_index_cv_37.nc", "c")
;fout->sd=eof_ts(:,0)




