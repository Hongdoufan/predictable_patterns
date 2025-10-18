
begin
latS   =  -45.
latN   =  45.
lonL   =  0.
lonR   =  360.
np =3
yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "fig_8"      
pltType = "ps" 
label= (/"(a) SST ","(b) T2m & SLP","(c) T2m & SLP"/)

fout=addfile("/disk1/fhd/winter_forecast/data/fig4.nc", "r")
fig5a=fout->4b
fig5ap=fout->4bp

   file2 = addfile("/disk1/fhd/winter_forecast/data/fig8b.nc","r")
   fig5b=file2->8b

   file1 = addfile("/disk1/fhd/winter_forecast/data/fig5bd.nc","r")
   fig5c=file1->5d

   file3 = addfile("/disk1/fhd/winter_forecast/data/msn.t2m.reg.slp.nc","r")
   bslp=file3->rc
   bp=file3->rcp
   file4 = addfile("/disk1/fhd/winter_forecast/data/msn.sst.reg.slp.nc","r")
   cslp=file4->rc
   cp=file4->rcp
   
;   bslp=where(abs(bp).ge.0.95,bslp, bslp@_FillValue)
;   cslp=where(abs(cp).ge.0.95,cslp, cslp@_FillValue)
   
   


;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"temp_19lev")       ; choose colormap
  plot = new(np,graphic) 
  plot1= new(np,graphic)
  plot2= new(np,graphic)
  res                      = True         
res@gsnDraw              = False        ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN
res@mpCenterLonF         = 180.
;res@mpMinLonF=110
;res@mpMaxLonF=270
res@cnFillOn = True
res@cnLinesOn = False
res@tmXBTickSpacingF        =60
; res@vpHeightF = 0.25        ; Changes the aspect ratio
; res@vpWidthF  = 0.5
res@lbLabelBarOn                   = True
res@lbBottomMarginF = 0.05
res@lbLeftMarginF = 0.08
res@lbTopMarginF = 0.2
res@pmLabelBarOrthogonalPosF = 0.33


res1 = res
;res1@gsnDraw = False
;res1@gsnFrame = False
res1@cnLineLabelFontHeightF   = 0.012
res1@cnInfoLabelOn            = False
res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res1@cnLevelSpacingF   =0.1
res1@cnMinLevelValF    =-0.5
res1@cnMaxLevelValF    =0.5
res1@gsnRightString  = " "
res1@cnLineLabelsOn = False
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF
;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.023
 res1@tmYLLabelFontHeightF = 0.023
; res1@tmXBLabelFont = 1
 res1@gsnLeftStringFontHeightF = 0.03
 res1@gsnRightStringFontHeightF = 0.03
 res1@tiMainString             = " "
 res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 ;symMinMaxPlt(rc(2,:,:), 16, False, res1)       ; contributed.ncl

;============================================================
; stip the difference in correlation at 95% significant level
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
 ; rtsP@gsnPanelLabelBar= True                 ; label bar on panel
 ; rtsP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
 ; rtsP@pmLabelBarHeightF    = 0.04
 ; rtsP@pmLabelBarWidthF =0.8
 ; rtsP@lbLabelFontHeightF  =0.022

res1@gsnLeftString  = label(0)
res1@gsnRightString = "unit: "+"~S~o~N~C"
res@gsnRightString = "CI:0.2hPa "

plot(0) = gsn_csm_contour_map(wks,fig5a,res1)
plot1(0) = gsn_csm_contour(wks,fig5ap,sres)
overlay(plot(0),plot1(0))

  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF       = -0.8              ; set min contour level
  res@cnMaxLevelValF       =  0.8              ; set max contour level
  res@cnLevelSpacingF      =  0.2              ; set contour spacing
  res@mpMinLatF            = 0        ; zoom in on map
  res@mpMaxLatF            = 90
  res@mpMinLonF            = lonL
  res@mpMaxLonF            = lonR
  res@mpCenterLonF         = 180.

  res@gsnLeftString  = label(1)
  
  
fig = True
fig@gsnDraw = False
fig@gsnFrame = False

;fig@mpCenterLonF         = 90.
;fig@mpMinLatF            = latS         ; zoom in on map
;fig@mpMaxLatF            = latN

fig@cnLinesOn       = True
fig@cnFillOn        = False
fig@cnLineLabelsOn  = False
fig@mpFillOn             = False 
; fig@mpMinLonF=180
; fig@mpMaxLonF=360
;fig@vpHeightF = 0.4        ; Changes the aspect ratio
;fig@vpWidthF  = 0.7

fig@cnLineThicknessF     = 1.5
fig@cnLineLabelFontHeightF = 0.01
fig@gsnContourNegLineDashPattern = 1    ; sets negative contours to dash pattern 1
fig@gsnContourLineThicknessesScale = 1.5
fig@cnInfoLabelOn = False
fig@cnLevelSelectionMode = "ManualLevels"
;fig@cnMinLevelValF       = -50     ; Min contour
;fig@cnMaxLevelValF       =  100     ; Max contour
fig@cnLevelSpacingF      = 0.2    ; Spacing
fig@cnInfoLabelOn=False
fig@gsnSpreadColors = True
fig@cnLineColor= "1"
fig@gsnContourZeroLineThicknessF = 0

  
  
  
  plot(1)=gsn_csm_contour_map(wks,fig5b, res)
  plot2(0) = gsn_csm_contour(wks,bslp,fig)
  overlay(plot(1),plot2(0))

  res@gsnLeftString  = label(2)
  plot(2)=gsn_csm_contour_map(wks,fig5c, res)
  plot2(1) = gsn_csm_contour(wks,cslp,fig)
  overlay(plot(2),plot2(1))

gsn_panel(wks,plot,(/np,1/),rtsP)     ; now draw as one plot

  
  end
  

