load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
latS   =  25.
latN   =  75.
lonL   = 0.
lonR   =  180.
nyear  = 36
yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "sd_comparison"      
pltType = "pdf" 
neof    = 3
nrc=4
season = "JFM" 
     


file1=addfile("/disk1/fhd/winter_forecast/data/sd_djf_prd_cor_mpc3.nc", "r")
djf=file1->cor
djfp=file1->corp

file4=addfile("/disk1/fhd/winter_forecast/data/sd_djf_obs_cor_mpc3.nc", "r")
djfobs=file4->cor
djfobsp=file4->corp


file2=addfile("/disk1/fhd/winter_forecast/data/sd_nov_prd_cor_mpc3.nc", "r")
nov=file2->cor
novp=file2->corp

file3=addfile("/disk1/fhd/winter_forecast/data/msn.pc3.cor.obs.sd.so.nc", "r")
so=file3->cor
sop=file3->corp


;============================================================
; PLOTS
;============================================================
  wks = gsn_open_wks(pltType,pltDir+pltName)
  gsn_define_colormap(wks,"temp_19lev")       ; choose colormap
  plot = new(nrc,graphic)                ; create graphic array
  plot1 = new(nrc,graphic)                ; create graphic array

  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnSpreadColors      = True         ; spread out color table

;latS   =  -90.
;latN   =  90.
;lonL   = 0.
;lonR   =  360.
 ; res@gsnPolar   = "NH"  
  res@mpFillOn             = False        ; turn off map fill
   res@mpMinLatF            = latS         ; zoom in on map
   res@mpMaxLatF            = latN  
   res@mpMinLonF            = lonL
   res@mpMaxLonF            = lonR
   res@mpCenterLonF         = 180
  res@cnFillOn = True
res@cnLinesOn = False
;res@mpShapeMode = "FreeAspect"
 res@vpHeightF = 0.25        ; Changes the aspect ratio
 res@vpWidthF  = 0.5
  

res1 = res
res1@gsnDraw = False
res1@gsnFrame = False
res1@cnLineLabelsOn    =False
;res1@cnLineLabelFontHeightF   = 0.012
res1@cnInfoLabelOn            = False
res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res1@cnLevelSpacingF   =0.2
res1@cnMinLevelValF    =-0.7
res1@cnMaxLevelValF    =0.7
;symMinMaxPlt(diff, 16, False, res)
;res1@cnLevelSelectionMode        = "ExplicitLevels"
;res1@cnLevels = fspan(-0.2, 0.4, 16)
;res1@cnFillColors = (/"23", "28","33","38","43","48","59",\
;                      "62","67","72","77","82","87","92","94",\
;                      "98","102"/)
res1@gsnRightString  = "  "
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF  = 1
res1@lbLabelBarOn                   = False
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2

;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.012
 res1@tmYLLabelFontHeightF = 0.012
; res1@tmXBLabelFont = 1
 
 res1@gsnLeftStringFontHeightF = 0.015
 res1@gsnRightStringFontHeightF = 0.01
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

 rtsP                      = True            ; modify the panel plot
 rtsP@gsnMaximize          = True            ; large format
 rtsP@txString             = " "
 rtsP@gsnPanelLabelBar= True                 ; label bar on panel
 rtsP@pmLabelBarOrthogonalPosF = -0.01       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.04
 rtsP@pmLabelBarWidthF =0.8
 rtsP@lbLabelFontHeightF  =0.015
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2
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
sres@cnLevels    = (/95/)
sres@cnMonoFillPattern    = False            ; want multiple patterns
sres@cnFillPatterns       = (/-1,17/)     ; the patterns
sres@cnMonoFillScale      = False            ; want different densities
sres@cnFillScales         = (/1,0.65/)    ; change densities
sres@cnMonoFillColor      =True
sres@cnFillDotSizeF       = 0.003


res1@gsnLeftString  = "SEAS5 DJF sd"
plot(0) = gsn_csm_contour_map_ce(wks,djf,res1)
plot1(0) = gsn_csm_contour(wks,djfp,sres)
overlay(plot(0),plot1(0))

res1@gsnLeftString  = "SEAS5 NOV sd"
plot(2) = gsn_csm_contour_map_ce(wks,nov,res1)
plot1(2) = gsn_csm_contour(wks,novp,sres)
overlay(plot(2),plot1(2))

res1@gsnLeftString  = "Obs Sep.Oct sd"
plot(3) = gsn_csm_contour_map_ce(wks,so,res1)
plot1(3) = gsn_csm_contour(wks,sop,sres)
overlay(plot(3),plot1(3))


res1@gsnLeftString  = "Obs DJF sd"
plot(1) = gsn_csm_contour_map_ce(wks,so,res1)
plot1(1) = gsn_csm_contour(wks,sop,sres)
overlay(plot(1),plot1(1))

resp=True
resp@gsLineThicknessF=3       ;polyline
resp@gsLineColor="black"
;=====================================
;
;=====================================
aa2=(/42,55.,55.,42.,42./)       ;pna
aa1=(/72,72.,115.,115.,72./)

l=new(4,graphic)
do i=0,3
l(i)=gsn_add_polyline(wks,plot(2),aa1(i:i+1),aa2(i:i+1),resp)
end do


;=====================================
;
;=====================================
aa2=(/71,64.,64.,71.,71./)       ;pna
aa1=(/90,90.,120.,120.,90./)

lf=new(4,graphic)
do i=0,3
lf(i)=gsn_add_polyline(wks,plot(2),aa1(i:i+1),aa2(i:i+1),resp)
end do

  gsn_panel(wks,plot,(/nrc,1/),rtsP)     ; now draw as one plot
  
  end
  
