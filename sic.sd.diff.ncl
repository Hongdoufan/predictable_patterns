
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360

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
pltName = "sicrecon.diff"                       ; set plot name 
pltType = "pdf" 

output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "test5_cor_arcavg.nc"  
;outName = "test5_recon_arcavg.nc"  

neof   = 3        ; number of EOFs
optEOF = True
optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

optETS = False
;==========================================================
;reconstruct t2m data
;==========================================================
;test1=addfile("/disk1/fhd/winter_forecast/data/test5_cor_arcavg_test1.nc","r")
;test11=addfile("/disk1/fhd/winter_forecast/data/test5_cor_arcavg_improve_test1.nc","r")
;
;
;cor_1=test1->recon
;cor_1p=test1->reconp
;cor_i1=test11->recon
;cor_i1p=test11->reconp


test2=addfile("/disk1/fhd/winter_forecast/data/test5_cor_arcavg_test2.nc","r")
test22=addfile("/disk1/fhd/winter_forecast/data/test5_cor_arcavg_improve_test2.nc","r")


cor_1=test2->recon
cor_1p=test2->reconp
cor_i1=test22->recon
cor_i1p=test22->reconp


test3=addfile("/disk1/fhd/winter_forecast/data/test5_cor_arcavg_test4.nc","r")
test33=addfile("/disk1/fhd/winter_forecast/data/test5_cor_arcavg_improve_test4.nc","r")


cor_3=test3->recon
cor_3p=test3->reconp
cor_i3=test33->recon
cor_i3p=test33->reconp


;diff1=cor_1-cor_2
diff1=cor_1-cor_3
;diff3=cor_2-cor_3


idiff1=cor_i1-cor_i3


copy_VarCoords(cor_1,diff1)
copy_VarCoords(cor_1,idiff1)



;   win_cor_ec=jjj({latS:latN},{lonL:lonR})

;   diff=win_cor_ec-win_cor_mode
;   copy_VarCoords(win_cor_ec,diff)  
;
;
;;   win_cor_ec=where(win_cor_ec.lt.0, -0.05, win_cor_ec)  
;;   win_cor_mode=where(win_cor_mode.lt.0, -0.05, win_cor_mode)  
;;   diff=where(win_cor_ec.gt.0.and.win_cor_mode.lt.0, -win_cor_ec, diff)
;;   diff=where(win_cor_ec.lt.0.and.win_cor_mode.gt.0, win_cor_mode, diff)
;;   diff=where(win_cor_ec.lt.0.and.win_cor_mode.lt.0, 0, diff)
;
;  printMinMax(win_cor_ec, False)
;  printMinMax(win_cor_mode,False)
;  printMinMax(diff,False)


;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"NCV_jaisnd")       ; choose colormap
  plot = new(10,graphic) 
  plot1= new(10,graphic)
  
  res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
  res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN
;res@mpCenterLonF         = 180.
res@mpMinLonF=0
res@mpMaxLonF=180
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
;res1@cnLevelSpacingF   =0.1
;res1@cnMinLevelValF    =-0.9
;res1@cnMaxLevelValF    =0.9
res1@cnLevelSelectionMode        = "ExplicitLevels"
res1@cnLevels = (/0,0.1,0.3,0.5,0.7,0.9/)
res1@cnFillColors = (/"64","139","169","194","217","243","255"/)
res1@gsnRightString  = " "
;res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF  = 1
res1@lbLabelBarOn                   = True
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2

;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.01
 res1@tmYLLabelFontHeightF = 0.01
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
 rtsP@gsnPanelLabelBar= False                ; label bar on panel
 rtsP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.04
 rtsP@pmLabelBarWidthF =0.6
 rtsP@lbLabelFontHeightF  =0.015
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2
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
sres@cnLevels    = (/0.90/)
sres@cnMonoFillPattern    = False            ; want multiple patterns
sres@cnFillPatterns       = (/-1,17/)     ; the patterns
sres@cnMonoFillScale      = False            ; want different densities
sres@cnFillScales         = (/1,1/)    ; change densities
sres@cnMonoFillColor      =True
sres@cnFillDotSizeF       = 0.00007

res1@gsnLeftString  = "NOVSIC-EOF3"
plot(0) = gsn_csm_contour_map_ce(wks,cor_1,res1)
plot1(0) = gsn_csm_contour(wks,cor_1p,sres)
overlay(plot(0),plot1(0))

res1@gsnLeftString  = "NOV snow"
plot(1) = gsn_csm_contour_map_ce(wks,cor_3,res1)
plot1(1) = gsn_csm_contour(wks,cor_3p,sres)
overlay(plot(1),plot1(1))




res1@cnLevelSelectionMode        = "ExplicitLevels"
res1@cnLevels = (/-0.05,-0.025,0,0.025,0.05,0.075/)
res1@cnFillColors = (/"17","33","64","139","169","194","217"/)

res1@gsnLeftString  = "(NOVSIC-EOF3)-(NOV snow)"
plot(2) = gsn_csm_contour_map_ce(wks,diff1,res1)



gsn_panel(wks,plot,(/6,1/),rtsP)     ; now draw as one plot


res1@cnLevelSelectionMode        = "ExplicitLevels"
res1@cnLevels = (/0,0.1,0.3,0.5,0.7,0.9/)
res1@cnFillColors = (/"64","139","169","194","217","243","255"/)


res1@gsnLeftString  = "NOVSIC-EOF3 (improved compared with EC)"
plot(0) = gsn_csm_contour_map_ce(wks,cor_i1,res1)
plot1(0) = gsn_csm_contour(wks,cor_i1p,sres)
overlay(plot(0),plot1(0))

res1@gsnLeftString  = "NOV snow"
plot(1) = gsn_csm_contour_map_ce(wks,cor_i3,res1)
plot1(1) = gsn_csm_contour(wks,cor_i3p,sres)
overlay(plot(1),plot1(1))


res1@cnLevelSelectionMode        = "ExplicitLevels"
res1@cnLevels = (/-0.05,-0.025,0,0.025,0.05,0.075/)
res1@cnFillColors = (/"17","33","64","139","169","194","217"/)

res1@gsnLeftString  =  "(NOVSIC-EOF3)-(NOV snow)"
plot(2) = gsn_csm_contour_map_ce(wks,idiff1,res1)



gsn_panel(wks,plot,(/6,1/),rtsP)     ; now draw as one plot
;res1@gsnLeftString  = "trend-EOF2"
;plot(2) = gsn_csm_contour_map_ce(wks,diff,res1)
;plot1(2) = gsn_csm_contour(wks,power,sres)
;overlay(plot(2),plot1(2))
;;draw(plot)
;;frame(wks)
;gsn_panel(wks,plot,(/5,2/),rtsP)     ; now draw as one plot


end

