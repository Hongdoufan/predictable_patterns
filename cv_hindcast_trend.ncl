
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =  20
latN   =  90
lonL   =  0
lonR   =  360
yrStrt = 1981
yrLast = 2016
nyear  = 36        
tstart = 35
tend   = 466
varname1     = "winter_anom"
decomposition_season="JFM"
season="JFM"
nrc=3
var     = "t2m"
unit= ""
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "trendpattern_obs.nc" 

;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "cv_hindcast_trend68"                       ; set plot name 
pltType = "pdf" 


;   var1=varible_file->$varname1$
;   Opt                = True
;   Opt@ForceOverwrite = True
;   Opt@DstGridType    = "2.5x2.5"
;   Opt@DstLLCorner    = (/ -90,   0/)
;   Opt@DstURCorner    = (/  90, 357.5/)
;   
;   var1_regrid = ESMF_regrid(var1,Opt)
;   var1_regrid =var1_regrid(:,:,::-1,:)
;   printVarSummary(var1_regrid)   
;   ensemble_winter=dim_avg_n(var1_regrid,1)
;   copy_VarCoords(var1_regrid(:,0,:,:), ensemble_winter)
;
;   aa_=ensemble_winter
   tt=ispan(1,36,1)
;   slope_ec = regCoef_n(tt,ensemble_winter,0,0)
;   copy_VarCoords(var1_regrid(0,0,:,:), slope_ec)
;   yint_ec    = onedtond(slope_ec@yintercept, (/73,144/) )
;   copy_VarCoords(var1_regrid(0,0,:,:), yint_ec)
   
  ff=addfile("/disk1/fhd/winter_forecast/data/msn_cv_hindcast68.nc","r")
  air= ff->cv_hindcast
  lat=ff->latitude(:)
  lon=ff->longitude(:)

   bb_=air
   slope_obs = regCoef_n(tt,bb_,0,0)
   copy_VarCoords(air(0,:,:), slope_obs)
   yint_obs    = onedtond(slope_obs@yintercept, (/dimsizes(lat),dimsizes(lon)/) )
   copy_VarCoords(air(0,:,:), yint_obs)
 
;; ==============================================================
;;  calculate the significance of trends by evaluating the incomplete beta function using betainc.
;; ==============================================================
;  rc=slope_ec
;  tval = onedtond(rc@tval , dimsizes(rc))
;  df   = onedtond(rc@nptxy, dimsizes(rc))
;;  df   = df/floattoint( max(T) )
;  df   = onedtond(rc@nptxy, dimsizes(rc)) - 2
;  bb    = tval  
;  bb=0.5
;  prob = ( 1. - betainc(df/(df+tval^2),df/2.0,bb) )
;  copy_VarCoords(rc, prob)
; ; prob = where(rc.gt.0, prob, prob*-1.)
 
  rc1=slope_obs
  tval1 = onedtond(rc1@tval , dimsizes(rc1))
  df1   = onedtond(rc1@nptxy, dimsizes(rc1))
;  df   = df/floattoint( max(T) )
  df1   = onedtond(rc1@nptxy, dimsizes(rc1)) - 2
  bb1    = tval1  
  bb1=0.5
  prob1 = ( 1. - betainc(df1/(df1+tval1^2),df1/2.0,bb1) )
  copy_VarCoords(rc1, prob1)
  ;prob1 = where(rc1.gt.0, prob1, prob1*-1.)
 
;   diff=slope_ec-slope_obs
;   copy_VarCoords(winter_anom(0,:,:),diff)
;   y_trend=new((/nyear,dimsizes(lat),dimsizes(lon)/),"float")
;   do i=0,35
;      y_trend(i,:,:)=yint_obs+slope_obs*tt(i)
;   end do
;   copy_VarCoords(winter_anom,y_trend)
;   printVarSummary(y_trend)
; ; ==============================================================
; ; output the y value associated with trend for every year
; ; ==============================================================
;  system("rm -f $output$+$outName$.nc")
;  fout=addfile(output+outName, "c")
;  fout->y_trend=rc1
;  fout->prob=prob1
;  fout->trend=rc1 
;  ==============================================================
;  ust the difference of two series and test whether the trend of 
; differences is significantly different from zero
; ==============================================================
;   diff_series=aa_-bb_   ; EC-OBS
;   copy_VarCoords(aa_, diff_series)
;   slope_diff = regCoef_n(tt,diff_series,0,0)
;   copy_VarCoords(var1_regrid(0,0,:,:), slope_diff)
; 
;; ==============================================================
;;  calculate the significance of trends by evaluating the incomplete beta function using betainc.
;; ==============================================================
;  
;  rc2=slope_diff
;  tval2 = onedtond(rc2@tval , dimsizes(rc2))
;  df2   = onedtond(rc2@nptxy, dimsizes(rc2))
;;  df   = df/floattoint( max(T) )
;  df2   = onedtond(rc2@nptxy, dimsizes(rc2)) - 2
;  bb2    = tval2  
;  bb2=0.5
;  pro = ( 1. - betainc(df2/(df2+tval2^2),df2/2.0,bb2) )
;  copy_VarCoords(rc2, pro)
;  exit()

;  rc=rc*10
;  copy_VarCoords(slope_ec, rc)
  rc1=rc1*200
  copy_VarCoords(slope_obs, rc1)
  printMinMax(rc1,False)
 
;  diff=diff*10
;  copy_VarCoords(winter_anom(0,:,:), diff)
;  printMinMax(rc, False)  
;  printMinMax(rc1, False)  
;  printMinMax(diff, False)  
;
;system("rm -f /disk1/fhd/winter_forecast/data/fig3acd.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/fig3acd.nc", "c")
;fout->3a=rc
;fout->3c=rc1
;fout->3d=diff
;fout->3ap=prob
;fout->3cp=prob1
;fout->3dp=pro

;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"BlWhRe")       ; choose colormap
  plot = new(nrc,graphic) 
  plot1= new(nrc,graphic)
  res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
  res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN
res@mpCenterLonF         = 180.
;res@mpMinLonF=180
;res@mpMaxLonF=360
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
 res1@cnLevelSpacingF   =0.4
 res1@cnMinLevelValF    =-2
 res1@cnMaxLevelValF    =2
;symMinMaxPlt(diff, 16, False, res)
;res1@cnLevelSelectionMode        = "ExplicitLevels"
;res1@cnLevels = fspan(-3, 3, 16)
;symMinMaxPlt(rc1, 16, False, res1)       ; contributed.ncl

; res1@cnFillColors = (/"23", "28","33","38","43","48","59",\
;                       "62","67","72","77","82","87","92","94",\
;                       "98","102"/)
res1@gsnRightString  = "Unit: "+"~S~o~N~C"+"/decade"
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF  = 1
res1@lbLabelBarOn                   = False
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2

;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.01
 res1@tmYLLabelFontHeightF = 0.01
; res1@tmXBLabelFont = 1
 
 res1@gsnLeftStringFontHeightF = 0.015
 res1@gsnRightStringFontHeightF = 0.015
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
 rtsP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.04
 rtsP@pmLabelBarWidthF =0.6
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
sres@cnLevels    = (/0.95/)
sres@cnMonoFillPattern    = False            ; want multiple patterns
sres@cnFillPatterns       = (/-1,17/)     ; the patterns
sres@cnMonoFillScale      = False            ; want different densities
sres@cnFillScales         = (/1,1/)    ; change densities
sres@cnMonoFillColor      =True
sres@cnFillDotSizeF       = 0.00007

res1@gsnLeftString  = "(a)"
plot(0) = gsn_csm_contour_map_ce(wks,rc1,res1)
plot1(0) = gsn_csm_contour(wks,prob1,sres)
;res1@gsnLeftString  = "(c)"
;plot(1) = gsn_csm_contour_map_ce(wks,rc1,res1)
;plot1(1) = gsn_csm_contour(wks,prob1,sres)
;res1@gsnLeftString  = "(d)"
;plot(2) = gsn_csm_contour_map_ce(wks,diff,res1)
;plot1(2) = gsn_csm_contour(wks,pro,sres)



overlay(plot(0),plot1(0))

; draw(plot)
; frame(wks)
gsn_panel(wks,plot,(/nrc,1/),rtsP)     ; now draw as one plot


end

