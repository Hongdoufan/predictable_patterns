
begin
latS   =  25.
latN   =  90.
lonL   =  0.
lonR   =  360.
np    =  4

yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "fig_10"      
pltType = "ps" 

season = "JFM"    
f=addfile("/disk1/fhd/winter_forecast/data/sd_ea_son_prd.nc","r")
a=f->sic_index

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/msl_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->$varname1$
ensemble_winter=dim_avg_n(var1,1)
ensemble_winter=dtrend_n(ensemble_winter,True,0)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)


  nyrs2   = dimsizes(ensemble_winter&nyear)
     nyrs3  = dimsizes(a)
     b =ensemble_winter({latitude|:},{longitude|:},nyear|:)
     rc    = regCoef(a,b)
     rc =rc/100.

;printVarSummary(rc)
  rc!0 = "lat"
  rc!1 = "lon"
  rc&lat = var1&latitude
  rc&lon = var1&longitude
  tval = onedtond(rc@tval , dimsizes(rc))
  df   = onedtond(rc@nptxy, dimsizes(rc))
;  df   = df/floattoint( max(T) )
  df   = onedtond(rc@nptxy, dimsizes(rc)) - 2
  bb    = tval  
  bb=0.5
  prob = ( 1. - betainc(df/(df+tval^2),df/2.0,bb) )
  copy_VarCoords(rc, prob)
  prob = where(rc.gt.0, prob, prob*-1.)
  printVarSummary(rc)
;  exit()
;system("rm -f /Users/nicolesmac/Documents/paper/teof/ERA_Interim/data/reg.t2m.nc")
;fout=addfile("/Users/nicolesmac/Documents/paper/teof/ERA_Interim/data/reg.t2m.nc", "c")
;fout->t2m=rc

   file1 = addfile("/disk1/fhd/winter_forecast/data/fig9a.nc","r")
   file2 = addfile("/disk1/fhd/winter_forecast/data/fig9b.nc","r")
   file3 = addfile("/disk1/fhd/winter_forecast/data/fig9bb.nc","r")
   file4 = addfile("/disk1/fhd/winter_forecast/data/fig9c.nc","r")
   file5 = addfile("/disk1/fhd/winter_forecast/data/fig9d.nc","r")

   a_=file1->9a
   ap=file1->9ap
   ap=abs(ap)
   
   b_=file2->9b
   bp=file2->9bp
   bp=abs(bp)

   bbb=file3->9bb
   bbbp=file3->9bbp

   c_=file4->9c
   cp=file4->9cp

   d_=file5->9d
   dp=file5->9dp
;============================================================
; PLOTS
;============================================================
  wks = gsn_open_wks(pltType,pltDir+pltName)
;  gsn_define_colormap(wks,"temp_diff_18lev")       ; choose colormap
  plot = new(np,graphic)                ; create graphic array
  plota = new(np,graphic)                ; create graphic array
  plotb = new(np,graphic)                ; create graphic array


res2 =True
res2@gsnDraw = False
res2@gsnFrame = False
res2@gsnPolar   = "NH"  

res2@gsnSpreadColors = True
;res2@gsnLeftString  = "300hPa Velocity Potential & Divergent Wind"
res2@gsnRightString = " "
;res2@gsnLeftStringOrthogonalPosF  =-0.2
res2@gsnStringFontHeightF = 0.02
res2@mpCenterLonF         = 180.
res2@vcRefMagnitudeF         = 2             ; define vector ref mag
res2@vcRefLengthF            = 0.05            ; define length of vec ref
;res2@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
res2@vcMinDistanceF          = 0.021
res2@vcRefAnnoFontHeightF    = 0.010
res2@vcRefAnnoSide    = "Top"
res2@vcRefAnnoPerimOn    = True
res2@vcRefAnnoString1  = "2.0"
res2@vcRefAnnoString2On  = False
res2@vcRefAnnoOrthogonalPosF   =  -0.25
res2@vcGlyphStyle    = "FillArrow"         ; turn on curly vectors
res2@vpHeightF = 0.4        ; Changes the aspect ratio
res2@vpWidthF  = 0.7
;res2@vcFillArrowHeadYF = 0.07
;res2@vcFillArrowHeadXF = 0.3
res2@vcMinAnnoPerimOn = True
res2@vcFillArrowEdgeThicknessF = 1.0
res2@vcFillArrowWidthF =0.07
res2@mpFillOn = False
res2@mpMinLatF            = 0.         ; zoom in on map
res2@mpMaxLatF            = 90.
res2@mpGreatCircleLinesOn = False
res2@gsnLeftString  = " "
res2@gsnRightString = " "
res2@tmXBTickSpacingF        =60
;res2@tmYLLabelFontHeightF      =0.2  ;×ø±ê×ÖÌå´óÐ¡
;res2@tmXBLabelFontHeightF      = 0.2






;  delete(res2)
res = True
res@gsnDraw = False
res@gsnFrame = False
res@gsnPolar   = "NH"  

res@mpCenterLonF         = 90.
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN

res@cnLinesOn       = True
res@cnFillOn        = False
res@cnLineLabelsOn  = False
res@mpFillOn             = False 
; res@mpMinLonF=180
; res@mpMaxLonF=360
res@vpHeightF = 0.4        ; Changes the aspect ratio
res@vpWidthF  = 0.7

res@cnLineThicknessF     = 1.5
res@cnLineLabelFontHeightF = 0.01
res@gsnContourNegLineDashPattern = 1    ; sets negative contours to dash pattern 1
res@gsnContourLineThicknessesScale = 1.5
res@cnInfoLabelOn = False
res@cnLevelSelectionMode = "ManualLevels"
;res@cnMinLevelValF       = -50     ; Min contour
;res@cnMaxLevelValF       =  100     ; Max contour
res@cnLevelSpacingF      = 0.2    ; Spacing
res@cnInfoLabelOn=False
res@gsnSpreadColors = True
res@cnLineColor= "1"
res@gsnContourZeroLineThicknessF = 0
res@tmXBTickSpacingF        =60
res@gsnPolarLabelFontHeightF = 0.016
res@gsnPolarLabelDistance = 1.06

;res@mpCenterLonF         = 180.
res@cnExplicitLineLabelsOn = False


res1 = True
res1@gsnDraw = False
res1@gsnFrame = False
res1@gsnPolar   = "NH"  
res1@mpCenterLonF         = 90.
res1@mpMinLatF            = latS         ; zoom in on map
res1@mpMaxLatF            = latN
res1@gsnAddCyclic= True
res1@cnFillOn = True
res1@cnLinesOn =False
res1@cnFillPalette       ="temp_diff_18lev"          ; set color map
res1@cnLineLabelsOn  =False
res1@cnInfoLabelOn=False
res1@cnLevelSelectionMode        = "ManualLevels"
res1@cnMinLevelValF       = -0.5              ; set min contour level
res1@cnMaxLevelValF       =  0.5              ; set max contour level
res1@cnLevelSpacingF      =  0.1              ; set contour spacing
res1@cnFillDrawOrder = "Predraw"
;res1@lbBottomMarginF = 0.1
;res1@lbLeftMarginF = 0.1
;res1@lbTopMarginF = 0.4
res1@lbLabelBarOn                   = True
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2
;  res1@lbLabelOffsetF = 0.25
  res1@pmLabelBarOrthogonalPosF = 0.06      ; 0.05
  res1@pmLabelBarHeightF = 0.1
  res1@pmLabelBarWidthF =0.5
  res1@lbLabelFontHeightF  =0.022

res1@gsnStringFontHeightF = 0.035
res1@gsnRightString  = "CI:0.2hPa"
res1@gsnRightStringOrthogonalPosF  =0.05
res1@gsnLeftStringOrthogonalPosF  =0.05
;res@gsnLeftStringParallelPosF = 0.98
;res@gsnStringFontHeightF = 0.039


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
sres@cnFillDotSizeF       = 0.0027
;============================================================
; PLOT1
;============================================================
  
  res1@gsnLeftString  = "(a) SON LBSI"
  plot(0)  =gsn_csm_contour_map(wks,rc,res)
  plota(0) =gsn_csm_contour(wks,a_,res1)
  plotb(0) = gsn_csm_contour(wks,ap,sres)

  overlay(plot(0),plota(0))
  overlay(plot(0),plotb(0))

;============================================================
; PLOT2
;============================================================
  
  res1@gsnLeftString  = "(b) PC2 of SLP"
  plot(1)  =gsn_csm_contour_map(wks,bbb,res)
  plota(1) =gsn_csm_contour(wks,b_,res1)
  plotb(1) = gsn_csm_contour(wks,bp,sres)

  overlay(plot(1),plota(1))
  overlay(plot(1),plotb(1))

;============================================================
; PLOT3
;============================================================
  res1@gsnLeftString  = "(c) SON LBSI"
  res1@gsnRightString  = "CI:2gpm"

  res@cnLevelSpacingF      = 2    ; Spacing
  res1@cnFillPalette       ="BkBlAqGrYeOrReViWh200"          ; set color map
  res1@cnLevelSelectionMode        = "ExplicitLevels"
  res1@cnLevels = (/-0.99, -0.95, 0.95, 0.99/)
  res1@cnFillColors = (/"77", "92", "transparent", "121", "139"/)
  res1@lbLabelBarOn                   = False


  plot(2)  =gsn_csm_contour_map(wks,c_,res)
  plota(2) =gsn_csm_contour(wks,cp,res1)
  overlay(plot(2),plota(2))
;  overlay(plot(1),plotb(1))

;============================================================
; PLOT4
;============================================================
  res1@gsnLeftString  = "(d) DJF SICI"
  plot(3)  =gsn_csm_contour_map(wks,d_,res)
  plota(3) =gsn_csm_contour(wks,dp,res1)
  overlay(plot(3),plota(3))



resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = False      ; add common colorbar
resP@lbLabelAutoStride   = False         ; auto stride on labels
resP@txString            = " "
resP@txFontHeightF       = 0.035


gsn_panel(wks,plot,(/2,2/),resP)     ; now draw as one plot

end
