
begin
latS   =  0.
latN   =  90.
lonL   =  0.
lonR   =  360.

yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "fig5"      
pltType = "ps" 

season = "JFM"    
f      = addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
eof_ts=f->eof_ts

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->$varname1$
ensemble_winter=dim_avg_n(var1,1)
ensemble_winter=dtrend_n(ensemble_winter,True,0)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)


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
  prob = where(rc.gt.0, prob, prob*-1.)
  printMinMax(rc,False)
  printVarSummary(rc)
;  rc=where(abs(prob).lt.0.95,rc@_FillValue, rc)

; system("rm -f /disk1/fhd/winter_forecast/data/fig5b.nc")
; fout=addfile("/disk1/fhd/winter_forecast/data/fig5b.nc", "c")
; fout->5b=rc(1,:,:)

;system("rm -f /disk1/fhd/winter_forecast/data/fig8b.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/fig8b.nc", "c")
;fout->8b=rc(2,:,:)
 system("rm -f /disk1/fhd/winter_forecast/data/msn.reg.t2m.nc")
 fout=addfile("/disk1/fhd/winter_forecast/data/msn.reg.t2m.nc", "c")
 fout->rc=rc
 fout->rcp=prob

   exit()

   file1 = addfile("/disk1/fhd/winter_forecast/data/fig5bd.nc","r")

   vb=file1->5b
   vd=file1->5d

;============================================================
; PLOTS
;============================================================
  wks = gsn_open_wks(pltType,pltDir+pltName)
  gsn_define_colormap(wks,"temp_diff_18lev")       ; choose colormap
  plot = new(nrc,graphic)                ; create graphic array

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
;  res@vpHeightF = 0.4       ; Changes the aspect ratio
;  res@vpWidthF  = 0.85
  res@cnInfoLabelOn        = False
  res@gsnAddCyclic         = True
  res@tmXBTickSpacingF        =60

  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False
  res@lbLabelBarOn         = False        ; turn off individual lb's
  
  res@gsnStringFontHeightF      = 0.025
  res@tmYLLabelFontHeightF      =0.023   ;×ø±ê×ÖÌå´óÐ¡
  res@tmXBLabelFontHeightF      = 0.023
  


  
  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF       = -0.8              ; set min contour level
  res@cnMaxLevelValF       =  0.8              ; set max contour level
  res@cnLevelSpacingF      =  0.2              ; set contour spacing
 ; symMinMaxPlt(rc, 16, True, res2)
  
                                          ; set symmetric plot min/max


; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@txString            = " "
  resP@gsnPanelLabelBar= True   
  resP@pmLabelBarParallelPosF = 0.018              ; label bar on panel
  resP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
  resP@pmLabelBarHeightF    = 0.04
  resP@pmLabelBarWidthF =0.7
  resP@lbLabelFontHeightF  =0.015

  res@gsnLeftString  = "(a)" 
  res@gsnRightString = "unit: "+"~S~o~N~C"
  plot(0)=gsn_csm_contour_map(wks,rc(1,:,:), res)
  res@gsnLeftString  = "(b)" 
  plot(1)=gsn_csm_contour_map(wks,vb, res)
  res@gsnLeftString  = "(c)" 
  plot(2)=gsn_csm_contour_map(wks,rc(2,:,:), res)
  res@gsnLeftString  = "(d)" 
  plot(3)=gsn_csm_contour_map(wks,vd, res)

  gsn_panel(wks,plot,(/2,2/),resP)     ; now draw as one plot
  
  end
  
