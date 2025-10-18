
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
   pltName = varname2+"_cor_zonal"      
   pltType = "ps" 
   season="JFM"
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
   
   css_zonal=dim_avg_n(win_cor,1)
   lcss_zonal=dim_avg_n(corlim,1)
   copy_VarCoords(win_cor(:,0), css_zonal)
   copy_VarCoords(win_cor(:,0), lcss_zonal)
   data=new((/2,181/),"float")
   data(0,:)=css_zonal
   data(1,:)=0
  
system("rm -f /disk1/fhd/winter_forecast/data/fig1b.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/fig1b.nc", "c")
fout->data=css_zonal
exit()
;************************************************
; create plot
;************************************************
wks = gsn_open_wks(pltType,pltDir+pltName)
res               = True                        ; plot mods desired
res@gsnDraw= False
res@gsnFrame= False

res@tmXBMode          = "Explicit"              ; explicit labels
;res@tmXBValues        = x                       ; location of labels
;res@tmXBLabels        = warm_yrs                ; labels themselves
res@tmXBLabelFontHeightF  =  0.025
res@tmYLLabelFontHeightF  =  0.025

res@tmLabelAutoStride = True                    ; nice stride on labels
;res@xyLineColors      = (/"white","red"/)  ; line colors


res@tiYAxisString    = "  "    ; y-axis label
res@trXMinF=0
res@trXMaxF=90
res@tiMainString      = " "; title
res@vpHeightF = 0.40        ; Changes the aspect ratio
res@vpWidthF  = 0.75
res@gsnLeftString  = "(b)"
res@gsnLeftStringFontHeightF = 0.028


res_text                    = True                  ; text mods desired
res_text@txFontHeightF      = 0.011                 ; change text size
res_text@txJust             = "CenterLeft"          ; text justification
res_lines                   = True                  ; polyline mods desired
res_lines@gsLineDashPattern = 0.                    ; solid line
res_lines@gsLineThicknessF  = 5.                    ; line thicker
; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format



res@tiMainString      = " "; title
res@xyLineColors      = (/"black"/)
res@xyDashPatterns    = (/0.0/)        ; line patterns
res@xyLineThicknesses =(/5.0/) 
;res@xyDashPatterns	 = (/5.,5./)      ; line thicknesses

;************************************************
; create plot
;************************************************
;  res@pmLegendDisplayMode    = "Always" 
;  res@pmLegendSide           = "Top"               ; Change location of 
;  res@pmLegendParallelPosF   = 0.9                 ; move units right
;  res@pmLegendOrthogonalPosF = -0.4                ; move units down
;  res@pmLegendWidthF         = 0.125               ; Change width and
;  res@pmLegendHeightF        = 0.08                ; height of legend.
;  res@lgPerimOn              = False                ; turn off/on box around
;  res@lgLabelFontHeightF     = .015                ; label font height
;  res@xyExplicitLegendLabels = (/" css"," lcss"/)  ; create explicit labels

plota=new(1,graphic)
plota(0)  = gsn_csm_xy(wks,data&latitude,css_zonal,res)



gsn_panel(wks,plota,(/1,1/),resP)     ; now draw as one plot



end
