
begin
latS   =  -60.
latN   =  60.
lonL   =  0.
lonR   =  360.
np =2
yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "msn.t2m.reg.sst"      
pltType = "ps" 
label= (/"","(a)","(b)","",""/)
season = "JFM"    
f      = addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
eof_ts=f->eof_ts

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/sst_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->$varname1$
ensemble_winter=dim_avg_n(var1,1)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)
ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)



  nyrs2   = dimsizes(ensemble_winter&nyear)
     a = eof_ts(:,:)
     nyrs3  = dimsizes(a)
     b =ensemble_winter({latitude|:},{longitude|:},nyear|:)
     rc    = regCoef(a,b)
     nrc=5
;printVarSummary(rc)
  rc!0 = "evn"
  rc!1 = "lat"
  rc!2 = "lon"
  rc&evn = ispan(1, 5, 1)
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
;  prob = where(rc.gt.0, prob, prob*-1.)
  printMinMax(rc(1,:,:),False)
  printMinMax(rc(2,:,:),False)
  prob = where(rc.eq.0, 0, prob)
;  print(prob(0,{80:90},{180}))

system("rm -f /disk1/fhd/winter_forecast/data/fig4.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/fig4.nc", "c")
fout->4a=rc(1,:,:)
fout->4ap=prob(1,:,:)
fout->4b=rc(2,:,:)
fout->4bp=prob(2,:,:)
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"temp_19lev")       ; choose colormap
  plot = new(np,graphic) 
  plot1= new(np,graphic)

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
res1@lbLabelBarOn                   = False
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2

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
 rtsP@gsnPanelLabelBar= True                 ; label bar on panel
 rtsP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.04
 rtsP@pmLabelBarWidthF =0.8
 rtsP@lbLabelFontHeightF  =0.022

res1@gsnLeftString  = "(a)"
res1@gsnRightString = "unit: "+"~S~o~N~C"

plot(0) = gsn_csm_contour_map(wks,rc(1,:,:),res1)
plot1(0) = gsn_csm_contour(wks,prob(1,:,:),sres)
overlay(plot(0),plot1(0))

res1@gsnLeftString  = "(b)"
res1@gsnRightString = "unit: "+"~S~o~N~C"
plot(1) = gsn_csm_contour_map(wks,rc(2,:,:),res1)
plot1(1) = gsn_csm_contour(wks,prob(2,:,:),sres)
overlay(plot(1),plot1(1))


gsn_panel(wks,plot,(/np,1/),rtsP)     ; now draw as one plot

  
  end
  

