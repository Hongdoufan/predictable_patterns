;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
;latS   =  70
;latN   =  85
;lonL   =  -10
;lonR   =  60
latS   =  70
latN   =  89
lonL   =  -180
lonR   =  180

output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "sic_projection_index_cv1.nc"  
year = 36
optETS = False
neof   = 2
;==========================================================
;read predicable patterns
;==========================================================
all_files = "/disk1/fhd/winter_forecast/data/eof_sic_cv1.nc"
patterns = addfile (all_files, "r")
   mode=patterns->eof  ; note syntax [:]
   printVarSummary(mode) 
   scand_pattern=mode
  
varname1     = "anom"
files_dir    = "/disk1/fhd/winter_forecast/data/sic_monthly_in11.nc"                             ; input directory
varible_file      = addfile (files_dir, "r")
   var1=varible_file->$varname1$
   winte=dim_avg_n(var1(:,:,0,:,:),1)
   printVarSummary(winte)
   printVarSummary(var1(:,0,0,:,:))
   copy_VarCoords(var1(:,0,0,:,:), winte)

;   winte = dtrend_msg_n(winte&nyear,winte,True,False,0)
   winte=lonFlip(winte)

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

   printVarSummary(scand_pattern)
   printVarSummary(ensemble)


; ==============================================================
; calculate the prejection (PC for every year) in prediction
; ==============================================================
eof_ts=new((/year,neof/),"float")
eof_ts1=new((/year,neof/),"float")
bbb=new((/dimsizes(lat),dimsizes(lon),2/),"float")
bbb(:,:,1)=1
scand=new((/1,dimsizes(ensemble_winter&latitude),dimsizes(ensemble_winter&longitude)/),"float")
;scand(0,:,:)=scand_pattern({latS:latN},:)

printVarSummary(scand_pattern(0,0,:,:))
printVarSummary(scand(0,:,:))
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


system("rm -f /disk1/fhd/winter_forecast/data/sic_projection_index_cv1.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/sic_projection_index_cv1.nc", "c")
fout->sic=eof_ts(:,0)

t2m_avg=addfile("/disk1/fhd/winter_forecast/data/eof_sic_nov.nc","r")
pc1=t2m_avg->eof_ts(0,:)

   cor1=escorc(pc1,eof_ts(:,0))
   print(cor1)
   ;print(eof_ts(:,0))
   ;print(pc1)
   ;print(eof_ts1(:,0))




end
