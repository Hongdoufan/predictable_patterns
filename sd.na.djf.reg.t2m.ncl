  

begin
latS   =  20.
latN   =  90.
lonL   =  0.
lonR   =  360.

yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "sd_na_.djf.reg.t2m"      
pltType = "pdf" 
varname1     = "winter_anom"
nrc=2
season = "JFM"    
data = addfile("/disk1/fhd/winter_forecast/data/sd_na_djf_prd.nc","r")
sd_raw=data->sd_raw
sd_rnino=data->sd_rnino

ff=addfile ("/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc","r")
var1=ff->$varname1$
ensemble_winter=dim_avg_n(var1,1)
ensemble_winter=dtrend_n(ensemble_winter,True,0)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)

     a=new((/2,36/),"float")
     a(0,:) = sd_raw
     a(1,:) = sd_rnino
     nyrs3  = dimsizes(a)
     b =ensemble_winter({latitude|:},{longitude|:},nyear|:)
     rc    = regCoef(a,b)
  rc!0 = "evn"   
  rc!1 = "lat"
  rc!2 = "lon"
  rc&evn = ispan(1,2,1)
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

;system("rm -f /Users/nicolesmac/Documents/paper/teof/ERA_Interim/data/reg.t2m.nc")
;fout=addfile("/Users/nicolesmac/Documents/paper/teof/ERA_Interim/data/reg.t2m.nc", "c")
;fout->t2m=rc
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

;latS   =  -30.
;latN   =  90.
;lonL   = 0.
;lonR   =  360.
;  res@gsnPolar   = "NH"  
  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = 20         ; zoom in on map
  res@mpMaxLatF            = 90
  res@mpMinLonF            = lonL
  res@mpMaxLonF            = lonR
  res@mpCenterLonF         = 180.
  res@mpShapeMode = "FreeAspect"
;  res@vpHeightF = 0.4       ; Changes the aspect ratio
;  res@vpWidthF  = 0.85
  res@cnInfoLabelOn        = False
  res@gsnAddCyclic         = True
  
  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False
  res@lbLabelBarOn         = True        ; turn off individual lb's
  
  res@gsnStringFontHeightF = 0.025
  res@tmYLLabelFontHeightF      =0.02   ;×ø±ê×ÖÌå´óÐ¡
  res@tmXBLabelFontHeightF      = 0.02
  res@tmXBTickSpacingF        =60
  


;  symMinMaxPlt(rc, 16, False, res)       ; contributed.ncl
   
;============================================================
; stip the difference in correlation at 95% significant level
;============================================================

 opt = True
 opt@gsnShadeFillType = "pattern"       
 opt@gsnShadeHigh= 17          ;打点
sres                = True 
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
  
  
  res2 = res
  res2@cnFillOn             = True         ; turn on color fill
  res2@cnLinesOn            = False        ; True is default
  res2@cnLineLabelsOn       = False
  res2@lbLabelBarOn         = False        ; turn off individual lb's
;  res2@lbBottomMarginF = 0.05
;  res2@lbLeftMarginF = 0.08
;  res2@lbTopMarginF = 0.2
;  res2@pmLabelBarOrthogonalPosF = 0.33

;  res2@cnLineLabelFontHeightF = 0.02
;  res2@gsnContourZeroLineThicknessF = 0.    ; doubles thickness of zero contour
;  res2@gsnContourNegLineDashPattern = 1     ; sets negative contours to dash pattern 1
;  res2@gsnContourLineThicknessesScale = 1.5
  res2@cnInfoLabelOn = False
  
  res2@cnLevelSelectionMode        = "ManualLevels"
  res2@cnMinLevelValF       = -0.8             ; set min contour level
  res2@cnMaxLevelValF       =  0.8             ; set max contour level
  res2@cnLevelSpacingF      =  0.2              ; set contour spacing
  res2@gsnRightString = " "
  
                                          ; set symmetric plot min/max


; panel plot only resources
  resP                     = True         ; modify the panel plot
;  resP@gsnMaximize         = True         ; large format
  resP@txString            = " "
  resP@gsnPanelLabelBar= True                 ; label bar on panel
  resP@pmLabelBarOrthogonalPosF = -0.02       ; 0.05
  resP@pmLabelBarHeightF    = 0.03
  resP@pmLabelBarWidthF =0.7
  resP@lbLabelFontHeightF  =0.015

  res2@gsnRightString  = "Unit:"+"~S~o~N~C"
  plot(0)=gsn_csm_contour_map_overlay(wks, rc(0,:,:), prob(0,:,:), res2, sres)
  plot(1)=gsn_csm_contour_map_overlay(wks, rc(1,:,:), prob(0,:,:), res2, sres)

  gsn_panel(wks,plot,(/2,1/),resP)     ; now draw as one plot
  
  end
  

