
; initial time is november, prediction time is the next december,jan,feb,mar,apr
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
   np   = 1        ; number of pictures
   varname1     = "winter_anom"
   varname2     = "t2m"  
   pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
   pltName = varname2+"_cor_map_in10"      
   pltType = "pdf" 
   season="JFM"
   tstart=""
   tend=""
   startyear=1981
   endyear=2016
   nyear= 36
   level  = " "
   ensemble = 25
                                                           ; create a plot [?]
   file1 = addfile("/disk1/fhd/winter_forecast/data/t2m_in10_6mon_wina.nc","r")
   file2 = addfile("/disk1/fhd/data/t2m.mon.mean.1.0.nc","r")
                ; set plot name 
   var1=file1->$varname1$
   var2=short2flt(file2->$varname2$)
   
   
   
   ensemble_winter=dim_avg_n(var1,1)
   obs=month_to_season(var2(35:466,:,:),season)
   obs_cli=dim_avg_n(obs,0)
   winter_anom=new((/36,181,360/),"float")
   do i=0,35
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   
   copy_VarCoords(obs, winter_anom)
   win_cor=escorc_n(ensemble_winter,winter_anom,0,0)
 
   copy_VarCoords(obs(0,:,:),win_cor)  
   printVarSummary(win_cor)
   printMinMax(win_cor,False)
    
;=======
;area average
;=======
; latS2   = 30       ; east north america
; latN2   = 60
; lonL2   = 260
; lonR2   = 290

latS2   = 60       ; north russia
latN2   = 75
lonL2   = 5
lonR2   = 130

; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
; =================================================================
rad    = 4.*atan(1.)/180.
clat2   = file2->latitude({latS2:latN2})
clat2   = sqrt( cos(rad*clat2) )                 ; gw for gaussian grid

; =================================================================
; weight all observations
; =================================================================
xAnom_avg2 = wgt_areaave_Wrap(win_cor({latS2:latN2},{lonL2:lonR2}), clat2, 1.0, 1)
print(xAnom_avg2)
;exit()
prob=win_cor
prob=where(win_cor.gt.0.33, 0.96, 0)

;system("rm -f /disk1/fhd/winter_forecast/data/fig1a.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/fig1a.nc", "c")
;fout->1a=win_cor
;fout->1ap=prob
; ==============================================================
; plot
; ==============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"NCV_jaisnd")       ; choose colormap
  plot = new(np,graphic)
  plot1= new(np,graphic) 
  
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
res1@lbLabelBarOn                   = False
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2

;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

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
 rtsP@pmLabelBarHeightF    = 0.05
 rtsP@pmLabelBarWidthF =0.9
 rtsP@lbLabelFontHeightF  =0.025
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2
;res1@gsnStringFontHeightF = 0.05
res1@gsnLeftString  = "(a) T2m ACC"
plot = gsn_csm_contour_map_ce(wks,win_cor,res1)
plot1 = gsn_csm_contour(wks,prob,sres)
overlay(plot,plot1)

gsn_panel(wks,plot,(/np,1/),rtsP)     ; now draw as one plot


end
