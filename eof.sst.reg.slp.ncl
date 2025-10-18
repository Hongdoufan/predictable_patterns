
begin
latS   =  25.
latN   =  90.
lonL   =  0.
lonR   =  360.

yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "msn.sst.reg.slp"      
pltType = "pdf" 

season = "JFM"    
f      = addfile("/disk1/fhd/winter_forecast/data/sst_eof_prd_dtrend.nc", "r")
eof_ts=f->eof_ts
eof_ts(1,:)=eof_ts(1,:)*-1

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/msl_in11_6mon_wina.nc"                            ; input directory
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
     rc =rc/100.

     nrc=3
;printVarSummary(rc)
  rc!0 = "evn"
  rc!1 = "lat"
  rc!2 = "lon"
  rc&evn = ispan(1, 3, 1)
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
  printVarSummary(rc)
;  exit()
 system("rm -f /disk1/fhd/winter_forecast/data/eof.sst.reg.slp.nc")
 fout=addfile("/disk1/fhd/winter_forecast/data/eof.sst.reg.slp.nc", "c")
 fout->rc=rc(1,:,:)
 fout->rcp=prob(1,:,:)
 exit()
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


;  res@gsnPolar   = "NH"  
  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN
  res@mpMinLonF            = lonL
  res@mpMaxLonF            = lonR
;  res@mpCenterLonF         = 90
  res@mpShapeMode = "FreeAspect"
;  res@vpHeightF = 0.4       ; Changes the aspect ratio
;  res@vpWidthF  = 0.85
  res@cnInfoLabelOn        = False
;  res@gsnAddCyclic         = True
  
  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False
  res@lbLabelBarOn         = False        ; turn off individual lb's
  
  res@gsnStringFontHeightF = 0.033  
  res@tmYLLabelFontHeightF      =0.033   ;×ø±ê×ÖÌå´óÐ¡
  res@tmXBLabelFontHeightF      = 0.033

;  res@gsnPolar   = "NH"  
  res@gsnPolarLabelFontHeightF = 0.022
  res@gsnPolarLabelDistance   = 1.07



;  symMinMaxPlt(rc, 16, False, res)       ; contributed.ncl
  
  res1 = res

  res1@cnLevelSelectionMode        = "ExplicitLevels"
  res1@cnLevels = (/-0.99, -0.95, 0.95, 0.99/)
  res1@cnFillColors = (/"6", "9", "transparent", "14", "17"/)
  
  
  
  res2 = True
  res2@cnLineLabelsOn       = False
  res2@cnLineLabelFontHeightF = 0.02
  res2@gsnContourZeroLineThicknessF = 0.    ; doubles thickness of zero contour
  res2@gsnContourNegLineDashPattern = 1     ; sets negative contours to dash pattern 1
  res2@gsnContourLineThicknessesScale = 1.5
  res2@cnInfoLabelOn = False
  
  res2@cnLevelSelectionMode        = "ManualLevels"
 ;res2@cnMinLevelValF       = -150              ; set min contour level
 ;res2@cnMaxLevelValF       =  200              ; set max contour level
  res2@cnLevelSpacingF      =  0.2              ; set contour spacing
  
                                          ; set symmetric plot min/max


; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@txString            = " "
  do n=0,nrc-1
  res1@gsnLeftString  = "(d)" 
  res1@gsnRightString = "CI:0.2hPa"
  plot(n)=gsn_csm_contour_map_overlay(wks, prob(n,:,:), rc(n,:,:), res1, res2)
end do
  gsn_panel(wks,plot,(/nrc,1/),resP)     ; now draw as one plot
  
  end
  

