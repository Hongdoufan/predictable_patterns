begin
; ==============================================================
; leave-1-year-out cross-validation hindcast
; ==============================================================
yrStrt = 1981
yrLast = 2016
nyear  = 36     
year_total = 36
tstart = 35
tend   = 466
output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName =  "msn_cv_hindcast68msn.nc"  

;==========================================================
;read predicable patterns
;==========================================================
all_files = "/disk1/fhd/winter_forecast/data/msn_t2m_cv.nc"
patterns = addfile (all_files, "r")
;---Read "pottmp" in "join" mode and print a summary of the variable

   mode=patterns->msn_t2m  ; note syntax [:]
   printVarSummary(mode) 
   
tren=addfile("/disk1/fhd/degreepaper/data/eof_t2m_leave_obs.nc","r")
trend=tren->eof(:,1,:,:)
trend=trend*7.

;t=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")
;pc1=t->eof_ts
;tren=addfile("/disk1/fhd/winter_forecast/data/cv_trend_obs1.nc","r")
;trend=tren->slope(:,{20:89},{0:360})

;pc2=tren->eof_ts(:,1,:)
printVarSummary(trend)
;exit()

;==========================================================
;read predictors 
;==========================================================
;t2m_eof=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc","r")
;sic_pc=addfile("/disk1/fhd/winter_forecast/data/sic_nov_prd.nc","r")
sic_pc=addfile("/disk1/fhd/winter_forecast/data/sic_projection_index_cv2.nc","r")
sd_ea_pc=addfile("/disk1/fhd/winter_forecast/data/sd_projection_index_cv1.nc","r")
e=addfile("/disk1/fhd/winter_forecast/data/sst_projection_index_cv.nc","r")
t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_cv.nc","r")
;t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_eof2_cv.nc","r")
;t2m_avg=addfile("/disk1/fhd/winter_forecast/data/trend_prd_projection_index.nc", "r")
;t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_cv_prdtrend1.nc","r")
;t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_cv_obstrend.nc","r")

pc1=t2m_avg->mpc1
;pc1=fspan(1,36,36)
pc1!0 = "time"
printVarSummary(pc1)
;pc1=dim_standardize_n(pc1,1,0)
nino=e->nino
emi=e->emi
sic=sic_pc->sic*-1.
sd_ea=sd_ea_pc->sd
 
 
 
;==========================================================
; reforecast using corss-validation
;==========================================================      = ispan(1980,2008,1)
;printVarSummary(varible_file)

lat=mode&latitude
lon=mode&longitude

reforecast=new((/nyear,dimsizes(lat),dimsizes(lon)/),"float")
do i=0,nyear-1
   reforecast(i,:,:)=514*pc1(i)*trend(i,:,:)+214*sd_ea(i)*mode(i,2,:,:)+159*sic(i)*mode(i,3,:,:)+nino(i)*mode(i,1,:,:)*281;++emi(i)*mode(i,2,:,:);;
end do
copy_VarCoords(mode(0,0,:,:), reforecast(0,:,:))
reforecast!0="time"
reforecast&time=ispan(yrStrt,yrLast,1)
;printMinMax(cv_hindacst, False)
;==========================================================
;output the cv_hindacst
;==========================================================

 system("rm -f $output$+$outName$.nc")
 fout=addfile(output+outName, "c")
 fout->cv_hindcast=reforecast
  

end
