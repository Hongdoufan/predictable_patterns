
; initial time is november, prediction time is the next december,jan,feb,mar,apr
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
   np   = 2        ; number of pictures
   varname1     = "winter_anom"
   varname2     = "t2m"  
   pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
   pltName = varname2+"_sn_ratio_map"      
   pltType = "ps" 
   season="DJF"
   tstart=""
   tend=""
   startyear=1981
   endyear=2016
   nyear= 36
   level  = " "
   ensemble = 25
                                                           ; create a plot [?]
   file1 = addfile("/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc","r")
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

   int_variance=dim_avg_n(dim_variance_n(var1,1),0)
;   int_variance=(dim_variance_n(int_variance_,0))*(nyear-1)/nyear
;   cli=dim_avg_n(dim_avg_n(var1,1),0)
   en_variance=dim_variance_n((dim_avg_n(var1,1)),0)
;   sst_variance=en_variance-int_variance/ensemble
   sn_ratio=(en_variance-int_variance/ensemble)/int_variance
   sn_ratio=where(sn_ratio.lt.0, 9.96921e+36, sn_ratio)  
   corlim=sqrt(sn_ratio/(sn_ratio+1))
   copy_VarCoords(var1(0,0,:,:), sn_ratio)
   copy_VarCoords(var1(0,0,:,:), corlim)
   
;   printVarSummary(sn_ratio)
;   printVarSummary(corlim)
   printMinMax(sn_ratio,False)
   printMinMax(corlim,False)

 system("rm -f /disk1/fhd/winter_forecast/data/fig1c.nc")
 fout=addfile("/disk1/fhd/winter_forecast/data/fig1c.nc", "c")
 fout->1c=sn_ratio
exit()
; ==============================================================
; plot
; ==============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")       ; choose colormap
  plot = new(np,graphic) 
  
  res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
  res@mpFillOn             = False        ; turn off map fill
;res@mpMinLatF            = 0.         ; zoom in on map
;res@mpMaxLatF            = 90.
res@mpCenterLonF         = 180.
;res@mpMinLonF=180
;res@mpMaxLonF=360
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
res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res1@cnLevelSpacingF   =0.1
res1@cnMinLevelValF    =0
res1@cnMaxLevelValF    =1
;res1@cnLevelSelectionMode        = "ExplicitLevels"
;res1@cnLevels = (/-0.9, -0.7, -0.5, -0.3, -0.2,0.2,0.3,0.5,0.7,0.9/)
;res1@cnFillColors = (/"2", "19", "27", "47","71","0","139","169","194","217","243"/)
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

 res1@tmXBLabelFontHeightF = 0.013
 res1@tmYLLabelFontHeightF = 0.013
; res1@tmXBLabelFont = 1
 
 res1@gsnLeftStringFontHeightF = 0.02
 res1@gsnRightStringFontHeightF = 0.02
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
 rtsP@gsnPanelLabelBar= True                 ; label bar on panel
 rtsP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.05
 rtsP@pmLabelBarWidthF =0.9
 rtsP@lbLabelFontHeightF  =0.025
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2
res1@gsnLeftString  = "signal-to-noise ratio "
plot(0) = gsn_csm_contour_map_ce(wks,sn_ratio,res1)


;draw(plot)
;frame(wks)

gsn_panel(wks,plot,(/1,1/),rtsP)     ; now draw as one plot


end



     
