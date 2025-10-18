begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
   nrc   = 3        ; number of pictufig
   varname1     = "winter_anom"
   varname2     = "t2m"  
   pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
   pltName = "fig_4_new"      
   pltType = "ps" 
   

   file1 = addfile("/disk1/fhd/winter_forecast/data/fig3acd_new.nc","r")

   a=file1->3a
   ap=file1->3ap
   c=file1->3c
   cp=file1->3cp
   d=file1->3d
   dp=file1->3dp
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
; gsn_define_colormap(wks,"BlWhRe")       ; choose colormap
  plot = new(nrc,graphic) 
  plot1= new(nrc,graphic)
  res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = 0         ; zoom in on map
res@mpMaxLatF            = 90
res@mpCenterLonF         = 180.
;res@mpMinLonF=180
;res@mpMaxLonF=360
res@cnFillOn = True
res@cnLinesOn = False
;res@mpShapeMode = "FreeAspect"
res@vpHeightF = 0.25        ; Changes the aspect ratio
res@vpWidthF  = 0.5
res@gsnLeftStringFontHeightF = 0.015
res@gsnRightStringFontHeightF = 0.015
  

res1 = res
res1@gsnDraw = False
res1@gsnFrame = False
res1@cnLineLabelsOn    =False
res1@cnFillPalette       ="BlWhRe"          ; set color map
res1@cnInfoLabelOn            = False
;res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
; res1@cnLevelSpacingF   =0.02
; res1@cnMinLevelValF    =-0.4
; res1@cnMaxLevelValF    =0.4
;symMinMaxPlt(diff, 16, False, res)
res1@cnLevelSelectionMode        = "ExplicitLevels"
;res1@cnLevels = fspan(-3, 3, 16)
symMinMaxPlt(a, 16, False, res1)       ; contributed.ncl

; res1@cnFillColors = (/"23", "28","33","38","43","48","59",\
;                       "62","67","72","77","82","87","92","94",\
;                       "98","102"/)
res1@gsnRightString  = "Unit: "+"~S~o~N~C"+"/10yr"
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
res1@lbLabelBarOn                   = False
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2
res1@lbLabelOffsetF = 0.25
res1@pmLabelBarOrthogonalPosF = 0.3       ; 0.05
 ; rtsP@pmLabelBarHeightF    = 0.04
 res1@pmLabelBarWidthF =0.5
 res1@lbLabelFontHeightF  =0.015
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2

;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.013
 res1@tmYLLabelFontHeightF = 0.013
; res1@tmXBLabelFont = 1
 
 res1@tiMainString             = " "
 res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 res1@tmXBTickSpacingF        =60
 res1@tmXTOn  = False
 res1@tmYROn  = False
; res1@tmXBLabelDeltaF =  0.5
 res1@tmXTMinorOn = False

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
sres@cnFillScales         = (/1,0.8/)    ; change densities
sres@cnMonoFillColor      =True
sres@cnFillDotSizeF       = 0.0005


 rtsP                      = True            ; modify the panel plot
 rtsP@gsnMaximize          = True            ; large format
 rtsP@txString             = " "
 rtsP@gsnPanelLabelBar    = True         ; add common colorbar
 rtsP@pmLabelBarParallelPosF = 0.03
 rtsP@pmLabelBarOrthogonalPosF = -0.025       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.04
 rtsP@pmLabelBarWidthF =0.75
 rtsP@lbLabelFontHeightF  =0.02
 rtsP@lbLabelOffsetF = 0.25

; rtsP@lbLabelBarOn                   = True
; rtsP@lbBottomMarginF = 0.0
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2
; rtsP@lbLabelOffsetF = 0.25
; rtsP@pmLabelBarOrthogonalPosF = 0.3       ; 0.05
; ; rtsP@pmLabelBarHeightF    = 0.04
; rtsP@pmLabelBarWidthF =0.5
; rtsP@lbLabelFontHeightF  =0.015

res1@gsnLeftString  = "(a) Trends in SEAS5"
plot(0) = gsn_csm_contour_map_ce(wks,a,res1)
plot1(0) = gsn_csm_contour(wks,ap,sres)
res1@gsnLeftString  = "(b) Trends in OBS"
plot(1) = gsn_csm_contour_map_ce(wks,c,res1)
plot1(1) = gsn_csm_contour(wks,cp,sres)
res1@gsnLeftString  = "(c) Diff"
plot(2) = gsn_csm_contour_map_ce(wks,d,res1)
plot1(2) = gsn_csm_contour(wks,dp,sres)



overlay(plot(0),plot1(0))
overlay(plot(1),plot1(1))
overlay(plot(2),plot1(2))



gsn_panel(wks,plot,(/3,1/),rtsP)     ; now draw as one plot

end

