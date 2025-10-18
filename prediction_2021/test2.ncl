begin

; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =  20
latN   =  89

; ==============================================================
; 
; ==============================================================
yrStrt = 1981
yrLast = 2016
nyear  = 36
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "test2_2021"                   ; set plot name 
pltType = "pdf" 
season  = "JFM"


;==========================================================
;read predicable patterns
;==========================================================
all_files = "/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc"
patterns = addfile (all_files, "r")
;---Read "pottmp" in "join" mode and print a summary of the variable

   mode=patterns->eof  ; note syntax [:]
   printVarSummary(mode)

tren=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")
trend=tren->eof
trend=trend*7.
;winter_anom(0,{latS:latN},:)
;t=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")

printVarSummary(trend)
;exit()

;==========================================================
;read predictors 2021 
;==========================================================
predictors=addfile("/disk1/fhd/winter_forecast/data/pre_raw_36.nc","r")
t2m_seas5=predictors->t2m({latS:latN},:)
t2m=-2.265994
sst=-0.28114
sic=-1.69236
sd=-0.437038


;==========================================================
; calculate std for SEAS5 and OBS
;==========================================================      = ispan(1980,2008,1)
recon=addfile("/disk1/fhd/winter_forecast/data/msn_cv_hindcast108.nc","r")
t2m_recon=recon->cv_hindcast


   varname2     = "t2m"
   file2 = addfile("/disk1/fhd/data/t2m.mon.mean.1.0.nc","r")
   latitude=file2->latitude
   longitude=file2->longitude
   var2=short2flt(file2->$varname2$)
   obs=month_to_season(var2(35:466,:,:),season)
   obs_cli=dim_avg_n(obs,0)
   t2m_obs=new((/36,181,360/),"float")
   do i=0,35
   t2m_obs(i,:,:)=obs(i,:,:)-obs_cli
   end do
   copy_VarCoords(obs, t2m_obs)

std_recon=dim_stddev_n(t2m_recon(:,{latS:latN},:),0)
std_obs=dim_stddev_n(t2m_obs(:,{latS:latN},:),0)

;==========================================================
; forecast reconstruction
;==========================================================      = ispan(1980,2008,1)

con=t2m_seas5
con=t2m*trend+sst*mode(1,:,:)+sd*mode(2,:,:)+sic*mode(3,:,:)
reforecast=con*std_obs/std_recon
;reforecast=new((/nyear,dimsizes(lat),dimsizes(lon)/),"float")

copy_VarCoords(mode(0,:,:), reforecast)
printVarSummary(reforecast)

t2m_raw=t2m_seas5
t2m_cal=reforecast
;diff=
printMinMax(t2m_raw,False)
printMinMax(t2m_cal,False)

;============================================================
; calibrate SEAS5 output
;============================================================
acc_36=addfile("/disk1/fhd/winter_forecast/data/acc_cv_test108.nc","r")
acc_diff=acc_36->imp
t2m_result=t2m_seas5
t2m_result=where(acc_diff.gt.0, reforecast, t2m_seas5)



;exit()
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"MPL_bwr")       ; choose colormap
  plot = new(3,graphic) 
  
  res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
  res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = 20.         ; zoom in on map
res@mpMaxLatF            = 90.
res@mpCenterLonF         = 180.
res@mpMinLonF=0
res@mpMaxLonF=360
  res@cnFillOn = True
res@cnLinesOn = False
;res@mpShapeMode = "FreeAspect"
 res@vpHeightF = 0.25        ; Changes the aspect ratio
 res@vpWidthF  = 0.5
  

res1 = res
;res1@gsnDraw = False
;res1@gsnFrame = False
res1@cnLineLabelsOn    =False
;res1@cnLineLabelFontHeightF   = 0.012
res1@cnInfoLabelOn            = False
;res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res1@cnLevelSpacingF   =0.2
res1@cnMinLevelValF    =-2
res1@cnMaxLevelValF    =2
;res1@cnLevelSelectionMode        = "ExplicitLevels"
;res1@cnLevels = (/-2, -1, -0.5, -0.2, 0.2,0.5,1.,2./)
;res1@cnFillColors = (/"2", "19", "27", "47","71","118","139","169","194","217","243","255"/)
res1@gsnRightString  = " "
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF  = 1
res1@lbLabelBarOn                   = False
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2

;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.013
 res1@tmYLLabelFontHeightF = 0.013
; res1@tmXBLabelFont = 1
 
 res1@gsnLeftStringFontHeightF = 0.01
 res1@gsnRightStringFontHeightF = 0.01
 res1@tiMainString             = " "
 res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 res1@tmXBTickSpacingF        =60
 res1@tmXTOn  = False
 res1@tmYROn  = False
; res1@tmXBLabelDeltaF =  0.5
 res1@tmXTMinorOn = False
 rtsP                      = True            ; modify the panel plot
 rtsP@gsnMaximize          = True            ; large format
 rtsP@txString             = " "
 rtsP@gsnPanelLabelBar= True                 ; label bar on panel
 rtsP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.05
 rtsP@pmLabelBarWidthF =0.9
 rtsP@lbLabelFontHeightF  =0.025
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2
res1@tiMainString             = "T2m DJF-2021 (wrt 1981-2016)"

res1@gsnLeftString  = "SEAS5 output"
plot(0) = gsn_csm_contour_map_ce(wks,t2m_raw,res1)
res1@gsnLeftString  = "Reconstruction"
plot(1) = gsn_csm_contour_map_ce(wks,t2m_cal,res1)
res1@gsnLeftString  = "Calibration"
plot(2) = gsn_csm_contour_map_ce(wks,t2m_result,res1)

;draw(plot)
;frame(wks)
gsn_panel(wks,plot,(/3,1/),rtsP)     ; now draw as one plot


end

