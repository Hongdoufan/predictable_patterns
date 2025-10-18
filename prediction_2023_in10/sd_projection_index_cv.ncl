;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
latS   =  45
latN   =  75
lonL   =  20
lonR   =  130

output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "sic_projection_index_cv7.nc"  
year = 30
optETS = False
neof   = 2
;==========================================================
;read predicable patterns
;==========================================================
all_files = "/disk1/fhd/winter_forecast/data/eof_sd_cv_2020.nc"
patterns = addfile (all_files, "r")
   mode=patterns->eof  ; note syntax [:]
   printVarSummary(mode) 
   scand_pattern=mode

;   scand_pattern(14,:,:,:)=scand_pattern(14,:,:,:)*-1
;   scand_pattern(15,:,:,:)=scand_pattern(15,:,:,:)*-1
;   scand_pattern(17,:,:,:)=scand_pattern(17,:,:,:)*-1
   

  
varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/sd_in11_6mon_wina_2020.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
   var1=varible_file->$varname1$
   winte=dim_avg_n(var1,1)
   printVarSummary(winte)
   printVarSummary(var1)
   copy_VarCoords(var1(:,0,:,:), winte)
;exit()
;   winte = dtrend_msg_n(winte&nyear,winte,True,False,0)

   ensemble_winter=winte(:,{latS:latN},{lonL:lonR});   ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)
   lat=ensemble_winter&latitude
   lon=ensemble_winter&longitude
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



; ==============================================================
; calculate the prejection (PC for every year) in prediction
; ==============================================================
eof_ts=new((/year,neof/),"float")
eof_ts1=new((/year,neof/),"float")
bbb=new((/dimsizes(lat),dimsizes(lon),2/),"float")
bbb(:,:,1)=1
scand=new((/1,dimsizes(ensemble_winter&latitude),dimsizes(ensemble_winter&longitude)/),"float")
;scand(0,:,:)=scand_pattern({latS:latN},:)

;exit()

printVarSummary(scand(0,:,:))
printVarSummary(scand_pattern(0,0,:,:))
;exit()
 do i=0,year-1
     bbb(:,:,0)=ensemble(:,:,i)
     scand(0,:,:)=scand_pattern(i,0,:,:)
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

;exit()
system("rm -f /disk1/fhd/winter_forecast/data/sd_projection_index_cv_2020.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/sd_projection_index_cv_2020.nc", "c")
fout->sd=eof_ts(:,0)

t2m_avg=addfile("/disk1/fhd/winter_forecast/data/eof_sd_djf_2020.nc","r")
pc1=t2m_avg->eof_ts

   cor1=escorc(pc1,eof_ts(:,0))
   print(cor1)
   ;print(eof_ts(:,0))
   ;print(pc1)
   ;print(eof_ts1(:,0))




end
