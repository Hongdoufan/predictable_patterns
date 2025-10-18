
begin
latS   =  0.
latN   =  90.
lonL   =  0.
lonR   =  360.
nrc=5
yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "t2m.obs.explained"      
pltType = "ps" 

season = "JFM"    
f      = addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
eof_ts=f->eof_ts



  ff=addfile("/disk1/fhd/data/t2m.mon.mean.1.0.nc","r")
  TIME2   = ff->time
  YYYY2   = cd_calendar(TIME2,-2)/100                 
  air= short2flt(ff->t2m(35:466,:,:))
  lat=ff->latitude(:)
  lon=ff->longitude(:)
  obs = month_to_season (air, season)
  obs_cli=dim_avg_n(obs,0)

   winter_anom=new((/36,dimsizes(lat),dimsizes(lon)/),"float")
   do i=0,35
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   
   copy_VarCoords(obs, winter_anom)
 
   cor    = (escorc_n(eof_ts, winter_anom, 1, 0))^2*100
   copy_VarCoords(winter_anom(0,:,:), cor(0,:,:))
   cor!0="time"
   cor&time=ispan(1,5,1)
   printVarSummary(cor)
   printMinMax(cor, False)
   

system("rm -f /disk1/fhd/winter_forecast/data/fig3b.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/fig3b.nc", "c")
fout->data=cor
;============================================================
; PLOTS
;============================================================
  wks = gsn_open_wks(pltType,pltDir+pltName)
  plot = new(nrc,graphic)                ; create graphic array
  gsn_define_colormap(wks,"MPL_Reds")       ; choose colormap

  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnSpreadColors      = True         ; spread out color table


  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN
  res@mpMinLonF            = lonL
  res@mpMaxLonF            = lonR
  res@mpCenterLonF         = 180.
  res@mpShapeMode = "FreeAspect"
  res@tmXBTickSpacingF        =60

;  res@vpHeightF = 0.4       ; Changes the aspect ratio
;  res@vpWidthF  = 0.85
  res@cnInfoLabelOn        = False
  res@gsnAddCyclic         = True
  
  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False
  res@lbLabelBarOn         = False        ; turn off individual lb's
  
  res@gsnStringFontHeightF = 0.025
  res@tmYLLabelFontHeightF      =0.02   ;×ø±ê×ÖÌå´óÐ¡
  res@tmXBLabelFontHeightF      = 0.02
;  symMinMaxPlt(rc, 16, False, res)       ; contributed.ncl
  
  res1 = res
  res1@cnLevelSelectionMode        = "ManualLevels"
  ; res1@cnLevels = (/-0.99, -0.95, 0.95, 0.99/)
  ; res1@cnFillColors = (/"6", "9", "transparent", "14", "17"/)
  
  
  res1@cnMinLevelValF       = 5.              ; set min contour level
  res1@cnMaxLevelValF       = 55.              ; set max contour level
  res1@cnLevelSpacingF      = 10              ; set contour spacing
 ; ; symMinMaxPlt(rc, 16, True, res2)
  
                                          ; set symmetric plot min/max


; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@txString            = " "
  resP@gsnPanelLabelBar= True                 ; label bar on panel
  resP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
  resP@pmLabelBarHeightF    = 0.02
  resP@pmLabelBarWidthF =0.4
  resP@lbLabelFontHeightF  =0.01



  do n=0,nrc-2
  res1@gsnLeftString  = "(b)"
  res1@gsnRightString = "Unit: %"
  plot(n)=gsn_csm_contour_map(wks, cor(n,:,:), res1)
end do
  gsn_panel(wks,plot,(/nrc,1/),resP)     ; now draw as one plot
  
  end
  
