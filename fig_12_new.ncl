
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
np     = 4
yrStrt = 1981
yrLast = 2016

tstart= 35
tend=466
varname1     = "winter_anom"
decomposition_season="JFM"
season="JFM"

var     = "t2m"
unit= ""
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
   
;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "fig_12_new"                       ; set plot name 
pltType = "pdf" 

;==========================================================
;read data
;==========================================================
fig11ab=addfile("/disk1/fhd/winter_forecast/data/test15_cor_new.nc", "r")
a=fig11ab->recon
ap=fig11ab->reconp

fig12b=addfile ("/disk1/fhd/winter_forecast/data/test2_cor_new.nc","r")
b=fig12b->recon
bp=fig12b->reconp

fig12c=addfile ("/disk1/fhd/winter_forecast/data/msn2.recon.ea14_obs_cor_new.nc","r")
c=fig12c->recon
cp=fig12c->reconp

fig12d=addfile("/disk1/fhd/winter_forecast/data/test4_cor_new.nc", "r")
d=fig12d->recon
dp=fig12d->reconp


;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"NCV_jaisnd")       ; choose colormap
  plot = new(np,graphic) 
  plot1= new(np,graphic) 

  res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = 20.         ; zoom in on map
res@mpMaxLatF            = 87.5
;res@mpCenterLonF         = 180.
res@mpMinLonF=0
res@mpMaxLonF=180
res@cnFillOn = True
res@cnLinesOn = False
;res@mpShapeMode = "FreeAspect"
 ; res@vpHeightF = 0.25        ; Changes the aspect ratio
 ; res@vpWidthF  = 0.5
  

res1 = res
;res1@gsnDraw = False
;res1@gsnFrame = False
res1@cnLineLabelsOn    =False
;res1@cnLineLabelFontHeightF   = 0.012
res1@cnInfoLabelOn            = False
;res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
;res1@cnLevelSpacingF   =0.1
;res1@cnMinLevelValF    =-0.9
;res1@cnMaxLevelValF    =0.9
res1@cnLevelSelectionMode        = "ExplicitLevels"
res1@cnLevels = (/0,0.1,0.3,0.5,0.7,0.9/)
res1@cnFillColors = (/"64","139","169","194","217","243","255"/)
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

 res1@tmXBLabelFontHeightF = 0.022
 res1@tmYLLabelFontHeightF = 0.022
; res1@tmXBLabelFont = 1
 
 res1@gsnLeftStringFontHeightF = 0.032
 res1@gsnRightStringFontHeightF = 0.02
 res1@tiMainString             = " "
 res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 res1@tmXBTickSpacingF        =60
 res1@tmYLTickSpacingF        =20

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
sres@cnFillDotSizeF       = 0.002
 
 rtsP                      = True            ; modify the panel plot
 rtsP@gsnMaximize          = True            ; large format
 rtsP@txString             = " "
 rtsP@gsnPanelLabelBar= True                 ; label bar on panel
 rtsP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.05
 rtsP@pmLabelBarWidthF =0.75
 rtsP@lbLabelFontHeightF  =0.014
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2
res1@gsnLeftString  = "(a) MSN EOF1"
plot(0) = gsn_csm_contour_map_ce(wks,a,res1)
plot1(0) = gsn_csm_contour(wks,ap,sres)
overlay(plot(0),plot1(0))

res1@gsnLeftString  = "(b) EOF2(Obs)"
plot(1) = gsn_csm_contour_map_ce(wks,b,res1)
plot1(1) = gsn_csm_contour(wks,bp,sres)
overlay(plot(1),plot1(1))

res1@gsnLeftString  = "(c) EOF2(Obs) + LB snow"
plot(2) = gsn_csm_contour_map_ce(wks,c,res1)
plot1(2) = gsn_csm_contour(wks,cp,sres)
overlay(plot(2),plot1(2))

res1@gsnLeftString  = "(d) EOF2(Obs) + ENSO + LB snow"
plot(3) = gsn_csm_contour_map_ce(wks,d,res1)
plot1(3) = gsn_csm_contour(wks,dp,sres)
overlay(plot(3),plot1(3))


gsn_panel(wks,plot,(/2,2/),rtsP)     ; now draw as one plot


end
