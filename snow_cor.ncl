
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
   np   = 2        ; number of pictures
   varname1     = "winter_anom"
   varname2     = "t2m"  
   pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
   pltName = "snow_cor"      
   pltType = "ps" 
   

   file1 = addfile("/disk1/fhd/winter_forecast/data/son_snow_obs.nc","r")
   file2 = addfile("/disk1/fhd/winter_forecast/data/son_snow.nc","r")
              ; set plot name 
   var1=file1->snow
   var2=file2->snow

   var11 = dtrend_msg_n(var1&time,var1,True,False,0)
   var22 = dtrend_msg_n(var2&nyear,var2,True,False,0)
   copy_VarCoords(var1, var11)
   copy_VarCoords(var2, var22)

   rr=var1(time|:,lat|:,lon|:)
   rrr=var11(time|:,lat|:,lon|:)
   Opt                = True
   Opt@ForceOverwrite = True
   Opt@DstGridType    = "1.0 x 1.0"
   Opt@DstLLCorner    = (/ -90,   0/)
   Opt@DstURCorner    = (/  90,   359/)
   
   var1_regrid1 = ESMF_regrid(rr,Opt)
   var1_regrid  = var1_regrid1(:,::-1,:)

   var1_regrid0 = ESMF_regrid(rrr,Opt)
   var1_regrid00  = var1_regrid0(:,::-1,:)

   printVarSummary(var1_regrid)
   printVarSummary(var2)
   cor1=escorc_n(var2, var1_regrid, 0, 0)
   cor2=escorc_n(var22, var1_regrid00, 0, 0)
   copy_VarCoords(var2(0,:,:), cor1)
   copy_VarCoords(var2(0,:,:), cor2)

; ==============================================================
; plot
; ==============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"NCV_jaisnd")       ; choose colormap
  plot = new(np,graphic)
  
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
res1@cnLevels = (/-0.9, -0.7, -0.5, -0.3, -0.2,0.2,0.3,0.5,0.7,0.9/)
res1@cnFillColors = (/"2", "19", "27", "47","71","0","139","169","194","217","243"/)
res1@gsnRightString  = " "
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF  = 1
res1@lbLabelBarOn                   = False
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
 rtsP                      = True            ; modify the panel plot
 rtsP@gsnMaximize          = True            ; large format
 rtsP@txString             = " "
 rtsP@gsnPanelLabelBar= True                 ; label bar on panel
 rtsP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.04
 rtsP@pmLabelBarWidthF =0.4
 rtsP@lbLabelFontHeightF  =0.015

res1@gsnLeftString  = " "
plot(0) = gsn_csm_contour_map_ce(wks,cor1,res1)
res1@gsnLeftString  = "dtrend"
plot(1) = gsn_csm_contour_map_ce(wks,cor2,res1)

gsn_panel(wks,plot,(/np,1/),rtsP)     ; now draw as one plot

end
