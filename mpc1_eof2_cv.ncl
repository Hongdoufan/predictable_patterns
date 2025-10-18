;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "mpc1_cv.nc"  
year = 36
optETS = False
neof   = 1
;==========================================================
;read predicable patterns
;==========================================================
tren=addfile("/disk1/fhd/degreepaper/data/eof_t2m_leave_obs.nc","r")
trend=tren->eof(:,1,:,:)
trend=trend*7.

   scand_pattern=trend

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")

   var1=varible_file->$varname1$
   ensemble_winte=dim_avg_n(var1,1)
   copy_VarCoords(var1(:,0,:,:), ensemble_winte)
   winte = ensemble_winte(:,{latS:latN},{lonL:lonR})
   copy_VarCoords(var1(:,0,{latS:latN},{lonL:lonR}), winte)
   ensemble_winter=winte(:,{latS:latN},{lonL:lonR})
   lat=ensemble_winter&latitude
   lon=ensemble_winte&longitude
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

printVarSummary(scand(0,:,:))
printVarSummary(scand_pattern(0,:,:))

 do i=0,year-1
     bbb(:,:,0)=ensemble(:,:,i)
     scand(0,:,:)=scand_pattern(i,:,:)
     temp   = eofunc_ts_Wrap (bbb, scand, optETS)
     printVarSummary(temp(:,0))
     printVarSummary(eof_ts)
     eof_ts(i,:)= temp(:,0)
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
;eof&time=ispan(1,36,1)
printVarSummary(eof_ts)

system("rm -f /disk1/fhd/winter_forecast/data/mpc1_eof2_cv.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/mpc1_eof2_cv.nc", "c")
fout->mpc1=eof_ts(:,0)

t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_projection_index.nc","r")
pc1=t2m_avg->mpc1
pc1!0 = "time"

   cor1=escorc(pc1,eof_ts(:,0))
   print(cor1)
   print(eof_ts(:,0))
   print(pc1)





end