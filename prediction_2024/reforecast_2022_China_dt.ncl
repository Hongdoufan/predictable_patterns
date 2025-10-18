load "/disk1/fhd/winter_forecast/paper/prediction_2021/cnmap/cnmap.ncl"
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
pltName = "prediction_2024_China_dt"                   ; set plot name 
pltType = "pdf" 
season  = "JFM"


;==========================================================
;read predicable patterns
;==========================================================
;printMinMax(trend,False)
;winter_anom(0,{latS:latN},:)
;t=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")

;exit()

;==========================================================
;read predictors 2021 
;==========================================================



;==========================================================
; calculate std for SEAS5 and OBS
;==========================================================      = ispan(1980,2008,1)

prediction=addfile("/disk1/fhd/winter_forecast/data/t2m_prediction_2024_dt.nc","r")
t2m_raw=prediction->seas5_forecast
t2m_cal=prediction->msn_forecast
t2m_result=prediction->reforecast


;==========================================================
; forecast reconstruction
;==========================================================      = ispan(1980,2008,1)

;diff=
;printMinMax(t2m_raw,False)
;:printMinMax(t2m_cal,False)

;============================================================
; calibrate SEAS5 output
;============================================================




;system("rm -f /disk1/fhd/winter_forecast/data/e2m_prediction_2021.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/t2m_prediction_2021.nc", "c")
;fout->seas5_forecast=t2m_raw
;fout->msn_forecast=reforecast
;fout->reforecast=t2m_result



;exit()
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"temp_19lev")       ; choose colormap
;  plot = new(3,graphic) 
  
res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
;  res@mpFillOn             = False        ; turn off map fill
;res@mpMinLatF            = 20.         ; zoom in on map
;res@mpMaxLatF            = 90.
;res@mpCenterLonF         = 180.
;res@mpMinLonF=0
;res@mpMaxLonF=180
res@cnFillOn = True
res@cnLinesOn = False
res@mpShapeMode = "FreeAspect"
; res@vpHeightF = 0.25        ; Changes the aspect ratio
; res@vpWidthF  = 0.5
;>--------------------------------------------<
;            set for the map 
;>--------------------------------------------<
 res@mpMinLatF               = 17.                         
 res@mpMaxLatF               = 55.
 res@mpMinLonF               = 72.
 res@mpMaxLonF               = 136.

 res@mpFillOn                = True
 res@mpOutlineOn             = False  ; Use outlines from shapefile
 res@cnFillDrawOrder         = "PreDraw"
 res@mpDataBaseVersion       = "MediumRes"
 res@mpDataSetName           = "Earth..4"
 res@mpAreaMaskingOn         = True
 res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
 res@mpLandFillColor         = "white"
 res@mpInlandWaterFillColor  = "white"
 res@mpOceanFillColor        = "white"
 res@mpOutlineBoundarySets   = "NoBoundaries"  

res1 = res
;res1@gsnDraw = False
;res1@gsnFrame = False
res1@cnLineLabelsOn    =False
;res1@cnLineLabelFontHeightF   = 0.012
res1@cnInfoLabelOn            = False
res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res1@cnLevelSpacingF   =0.5
res1@cnMinLevelValF    =-2.5
res1@cnMaxLevelValF    =2.5
;res1@cnLevelSelectionMode        = "ExplicitLevels"
;res1@cnLevels = (/-2, -1, -0.5, -0.2, 0.2,0.5,1.,2./)
;res1@cnFillColors = (/"2", "19", "27", "47","71","118","139","169","194","217","243","255"/)
res1@gsnRightString  = " "
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF  = 1
res1@lbLabelBarOn                   = True
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2
res1@lbOrthogonalPosF = 0
;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.013
 res1@tmYLLabelFontHeightF = 0.013
; res1@tmXBLabelFont = 1
 
 res1@gsnLeftStringFontHeightF = 0.01
 res1@gsnRightStringFontHeightF = 0.03
 res1@tiMainString             = "SEAS5 T2m anomalies (DJF) for 2024 (wrt 1991-2020)"
; res1@tiMainFont = 0.1
; res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 res1@tmXBTickSpacingF        =10
 res1@tmXTOn  = False
 res1@tmYROn  = False
; res1@tmXBLabelDeltaF =  0.5
 res1@tmXTMinorOn = False
; rtsP                      = True            ; modify the panel plot
; rtsP@gsnMaximize          = True            ; large format
; rtsP@txString             = "T2m DJF-2021 (wrt 1981-2016)"
; rtsP@gsnPanelLabelBar= True                 ; label bar on panel
; rtsP@pmLabelBarOrthogonalPosF = 0       ; 0.05
; rtsP@pmLabelBarHeightF    = 0.05
; rtsP@pmLabelBarWidthF =0.6
; rtsP@lbLabelFontHeightF  =0.015
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2

;res1@gsnLeftString  = "SEAS5 Output"
;plot(0) = gsn_csm_contour_map_ce(wks,t2m_raw,res1)
;res1@gsnLeftString  = "Reconstruction"
;plot(1) = gsn_csm_contour_map_ce(wks,t2m_cal,res1)
res1@gsnRightString  = "Unit:~S~o~N~C"
map = gsn_csm_contour_map_ce(wks,t2m_raw,res1)

;draw(plot)
;frame(wks)
;gsn_panel(wks,plot,(/3,1/),rtsP)     ; now draw as one plot

;>============================================================<
;                      add China map
;>------------------------------------------------------------<
 cnres           = True
 cnres@china     = True       ;draw china map or not
 cnres@river     = True       ;draw changjiang&huanghe or not
 cnres@province  = True       ;draw province boundary or not
 cnres@nanhai    = True       ;draw nanhai or not 
 cnres@diqu      = False       ; draw diqujie or not

 chinamap = add_china_map(wks,map,cnres)
;>============================================================<
draw(map)
frame(wks)

res1@tiMainString             = "SEAS5-Output T2m anomalies (DJF) for 2024 (wrt 1991-2020)"
map1 = gsn_csm_contour_map_ce(wks,t2m_raw,res1)
chinamap1 = add_china_map(wks,map1,cnres)
draw(map1)
frame(wks)

res1@tiMainString             = "MSN-forecast T2m anomalies (DJF) for 2024 (wrt 1991-2020)"
map2 = gsn_csm_contour_map_ce(wks,t2m_cal,res1)
chinamap2 = add_china_map(wks,map2,cnres)
draw(map2)
frame(wks)

res1@tiMainString             = "Calibration T2m anomalies (DJF) for 2024 (wrt 1991-2020)"
map3 = gsn_csm_contour_map_ce(wks,t2m_result,res1)
chinamap3 = add_china_map(wks,map3,cnres)
draw(map3)
frame(wks)




end
