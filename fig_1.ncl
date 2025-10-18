
; initial time is november, prediction time is the next december,jan,feb,mar,apr
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
   np   = 3        ; number of pictures
   varname1     = "winter_anom"
   varname2     = "t2m"  
   pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
   pltName = "fig_1"      
   pltType = "pdf" 
   

   file1 = addfile("/disk1/fhd/winter_forecast/data/fig1a.nc","r")
   file2 = addfile("/disk1/fhd/winter_forecast/data/fig1b.nc","r")
   file3 = addfile("/disk1/fhd/winter_forecast/data/fig1c.nc","r")
              ; set plot name 
   var1=file1->1a
   var1p=file1->1ap
   var2=file2->data
   var3=file3->1c
   printMinMax(var3,False)
   printVarSummary(var1)
; ==============================================================
; plot
; ==============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"NCV_jaisnd")       ; choose colormap
  plot = new(np,graphic)
  plot1= new(2,graphic) 
  
res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = 0.         ; zoom in on map
res@mpMaxLatF            = 90.
res@mpCenterLonF         = 180.
;res@mpMinLonF=180
;res@mpMaxLonF=360
res@cnFillOn = True
res@cnLinesOn = False
res@mpShapeMode = "FreeAspect"
 ; res@vpHeightF = 0.3        ; Changes the aspect ratio
 ; res@vpWidthF  = 0.5
  

res1 = res
;res1@gsnDraw = False
;res1@gsnFrame = False
res1@cnLineLabelsOn    =False
;res1@cnFillPalette       = "NCV_jaisnd"          ; set color map
;res1@cnLineLabelFontHeightF   = 0.012
res1@cnInfoLabelOn            = False
;res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
;res1@cnLevelSpacingF   =0.1
;res1@cnMinLevelValF    =-0.9
;res1@cnMaxLevelValF    =0.9
res1@cnLevelSelectionMode        = "ExplicitLevels"
res1@cnLevels = (/-0.1,0,0.1,0.3,0.5,0.7,0.9/)
res1@cnFillColors = (/"35","64","139","169","194","217","243","255"/)
res1@gsnRightString  = " "
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF  = 1
res1@lbLabelBarOn                   = True
res1@lbBottomMarginF = 0.25
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2
;res1@pmLabelBarParallelPosF = 0
res1@pmLabelBarOrthogonalPosF = 0.3
res1@pmLabelBarWidthF =0.7
res1@lbLabelOffsetF = 0.3
;res1@lbBoxMinorExtentF = 1.0
res1@lbLabelFontHeightF = 0.02
res1@tmXBLabelFontHeightF = 0.02
res1@tmYLLabelFontHeightF = 0.02
; res1@tmXBLabelFont = 1
 
 res1@gsnLeftStringFontHeightF = 0.023
 res1@gsnRightStringFontHeightF = 0.023
 res1@tiMainString             = " "
 res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 res1@tmXBTickSpacingF        =60
 res1@tmXTOn  = False
 res1@tmYROn  = False
; res1@tmXBLabelDeltaF =  0.5
 res1@tmXTMinorOn = False

;============================================================
; stip the d correlation at 95% significant level
;============================================================

 opt = True
 opt@gsnShadeFillType = "pattern"       
 opt@gsnShadeHigh= 17          ;打点
sres                 = True
sres@gsnDraw         = False
sres@gsnFrame        = False
sres@cnLineLabelsOn  = False
sres@cnLinesOn       = False
sres@cnInfoLabelOn   = False
sres@cnFillOn        = True
sres@lbLabelBarOn= False
sres@cnLevelSelectionMode = "ExplicitLevels"
sres@cnFillDrawOrder="postDraw"
sres@cnLevels    = (/0.95/)
sres@cnMonoFillPattern    = False            ; want multiple patterns
sres@cnFillPatterns       = (/-1,17/)     ; the patterns
sres@cnMonoFillScale      = False            ; want different densities
sres@cnFillScales         = (/1,1/)    ; change densities
sres@cnMonoFillColor      =True
sres@cnFillDotSizeF       = 0.00007

res1@gsnLeftString  = "(a) T2m ACC"
plot(0) = gsn_csm_contour_map_ce(wks,var1,res1)
plot1(0) = gsn_csm_contour(wks,var1p,sres)
overlay(plot(0),plot1(0))


fig               = True                        ; plot mods desired
fig@gsnDraw= False
fig@gsnFrame= False

fig@tmXBMode          = "Explicit"              ; explicit labels
fig@tmXBLabelFontHeightF  =  0.02
fig@tmYLLabelFontHeightF  =  0.017

fig@tmLabelAutoStride = True                    ; nice stride on labels
;fig@xyLineColors      = (/"white","red"/)  ; line colors


fig@tiYAxisString    = "  "    ; y-axis label
fig@trXMinF=0
fig@trXMaxF=90
fig@trYMinF=0
fig@trYMaxF=0.8

fig@tiMainString      = " "; title
fig@vpHeightF = 0.22        ; Changes the aspect ratio
fig@vpWidthF  = 0.79
fig@gsnLeftString  = "(b) Zonal mean ACC"
fig@gsnLeftStringFontHeightF = 0.023


fig_text                    = True                  ; text mods desired
fig_text@txFontHeightF      = 0.011                 ; change text size
fig_text@txJust             = "CenterLeft"          ; text justification
fig_lines                   = True                  ; polyline mods desired
fig_lines@gsLineDashPattern = 0.                    ; solid line
fig_lines@gsLineThicknessF  = 5.                    ; line thicker

fig@tiMainString      = " "; title
fig@xyLineColors      = (/"black"/)
fig@xyDashPatterns    = (/0.0/)        ; line patterns
fig@xyLineThicknesses =(/5.0/) 
;fig@xyDashPatterns  = (/5.,5./)      ; line thicknesses

 rtsP                      = True            ; modify the panel plot
 rtsP@gsnMaximize          = True            ; large format
 rtsP@txString             = " "


plot(1)  = gsn_csm_xy(wks,var2&latitude,var2,fig)

res3 = res
;res1@gsnDraw = False
;res1@gsnFrame = False
;res3@cnLinesOn    =False
;res3@cnMonoFillPattern  =False

;res3@cnLineLabelFontHeightF   = 0.012
res3@cnInfoLabelOn            = False
res3@cnFillPalette       = "WhiteBlueGreenYellowRed"          ; set color map
res3@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res3@cnLevelSpacingF   =0.1
res3@cnMinLevelValF    =0
res3@cnMaxLevelValF    =1

;sres@cnLevelSelectionMode = "ExplicitLevels"
;sres@cnFillDrawOrder="postDraw"
;sres@cnLevels    = (/0.95/)
;sres@cnMonoFillPattern    = False            ; want multiple patterns
;sres@cnFillPatterns       = (/-1,17/)     ; the patterns

;res3@cnLevelSelectionMode        = "ExplicitLevels"
;res3@cnLevels = (/-0.9, -0.7, -0.5, -0.3, -0.2,0.2,0.3,0.5,0.7,0.9/)
;res3@cnFillColors = (/"2", "19", "27", "47","71","0","139","169","194","217","243"/)
res3@gsnRightString  = " "
res3@cnFillDrawOrder = "Predraw"
res3@cnInfoLabelParallelPosF = 2.0
res3@lbLabelBarOn                   = True
res3@lbBottomMarginF = 0.25
res3@lbLeftMarginF = 0.08
res3@lbTopMarginF = 0.2
;res1@pmLabelBarParallelPosF = 0
res3@pmLabelBarOrthogonalPosF = 0.3
res3@pmLabelBarWidthF =0.7
res3@lbLabelOffsetF = 0.3
;re31@lbBoxMinorExtentF = 1.0
res3@lbLabelFontHeightF = 0.02
res3@tmXBLabelFontHeightF = 0.02
res3@tmYLLabelFontHeightF = 0.02

; res3@tmXBLabelFont = 1
 res3@gsnLeftString  = "(c) S-N ratio"
 res3@gsnLeftStringFontHeightF = 0.023
 res3@tiMainString             = " "
 res3@tiMainJust                = "centerleft"
 ;res3@tiMainPosition             = "left"
 res3@tmXBTickSpacingF        =60
 res3@tmXTOn  = False
 res3@tmYROn  = False
 res3@cnFillDrawOrder = "Predraw"
 
 res4 = True
 res4@gsnDraw              = False       ; don't draw yet
 res4@gsnFrame             = False        ; don't advance frame yet
 res4@cnLinesOn    =True
 res4@cnFillOn = False
 res4@cnLineColor= "white"
 res4@cnLineLabelsOn  = False
; res4@cnLevelSelectionMode        = "ExplicitLevels"
; res4@cnLevels = (/1,2,3,4,5,6,7,8,9,10/)
; res4@cnLevels = (/1,3,5,7,9,11/)
 res4@cnLevelSelectionMode = "ManualLevels"
 res4@cnLevelSpacingF      = 3    ; Spacing
 res4@cnMinLevelValF       = 1              ; set max contour level
 res4@cnMaxLevelValF       = 40              ; set max contour level
 res4@cnLineThicknessF     = 2

 plot(2) = gsn_csm_contour_map_ce(wks,var3,res3)
 plot1(1) = gsn_csm_contour(wks,var3,res4)

 overlay(plot(2),plot1(1))

; ;====================================================
; ; add polyline and text
; ;====================================================
; txres               = True       ;text
; txres@txFontHeightF = 0.015     
; resp=True
; resp@gsLineThicknessF=3        ;polyline
; resp@gsLineColor="black";"dodgerblue4"
; aa2=(/45,85.,85.,45.,45./)       ;pna
; aa1=(/0,0.,140.,140.,0./)

; l=new(4,graphic)
; do i=0,3
; l(i)=gsn_add_polyline(wks,plot(0),aa1(i:i+1),aa2(i:i+1),resp)
; end do

; ll=new(4,graphic)
; do i=0,3
; ll(i)=gsn_add_polyline(wks,plot(1),aa1(i:i+1),aa2(i:i+1),resp)
; end do

gsn_panel(wks,plot,(/np,1/),rtsP)     ; now draw as one plot

end
