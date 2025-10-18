
begin
latS   =  70.
latN   =  90.
lonL   =  0.
lonR   =  360.
np=2
yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "trendobs.dtrend.reg.sic"      
pltType = "pdf" 
nrc=1
season = "JFM"    
f      = addfile("/disk1/fhd/winter_forecast/data/trend_obs_projection_index.nc","r") ;eof_sd_djf
eof_ts=f->prd_index
eof_ts=dtrend(eof_ts,False)

files_dir    = "/disk3/HadISST/HadISST_ice.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->sic
   ob=var1(1342:1773,:,:)
   obs=ob(::12,:,:)
   obs_cli=dim_avg_n(obs,0)
   
   
   winter_anom=new((/36,180,360/),"float")
   do i=0,35
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   
   copy_VarCoords(obs, winter_anom)
   winter_anom = dtrend_msg_n(winter_anom&time,winter_anom,True,False,0)


  a=eof_ts
     nyrs3  = dimsizes(a)
     b =winter_anom ({latitude|:},{longitude|:},time|:)
     rc    = regCoef(a,b)
;printVarSummary(rc)
  rc!0 = "lat"
  rc!1 = "lon"
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
  printMinMax(rc,False)
;  rc=where(abs(prob).lt.0.95,rc@_FillValue, rc)

;system("rm -f /disk1/fhd/winter_forecast/data/fig5bd.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/fig5bd.nc", "c")
;fout->5b=rc(0,:,:)
;fout->5d=rc(1,:,:)
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
res@gsnPolar   = "NH"  
res@mpMinLatF            = latS         ; zoom in on map
;res@mpMaxLatF            = latN
res@mpCenterLonF         = 90.
;res@mpMinLonF=110
;res@mpMaxLonF=270
res@cnFillOn = True
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@tmXBTickSpacingF        =60
; res@vpHeightF = 0.25        ; Changes the aspect ratio
; res@vpWidthF  = 0.5
res@lbLabelBarOn                   = True
res@lbBottomMarginF = 0.05
res@lbLeftMarginF = 0.08
res@lbTopMarginF = 0.2
res@pmLabelBarOrthogonalPosF = 0.33


res1 = res
;res1@gsnDraw = False
;res1@gsnFrame = False
res1@cnLineLabelFontHeightF   = 0.012
res1@cnInfoLabelOn            = False
res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res1@cnLevelSpacingF   =0.05
res1@cnMinLevelValF    =-0.3
res1@cnMaxLevelValF    =0.3
res1@gsnRightString  = " "
res1@cnLineLabelsOn = False
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF
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

  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@txString            = " "
  resP@gsnPanelLabelBar= False   
  resP@pmLabelBarParallelPosF = 0.018              ; label bar on panel
  resP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
  resP@pmLabelBarHeightF    = 0.04
  resP@pmLabelBarWidthF =0.5
  resP@lbLabelFontHeightF  =0.015

;res1@gsnLeftString  = label(0)
res1@gsnRightString = "unit: "+"~S~o~N~C"
;res@gsnRightString = "unit: "+"~S~o~N~C"

plot(0) = gsn_csm_contour_map(wks,rc,res1)
plot1(0) = gsn_csm_contour(wks,prob,sres)
overlay(plot(0),plot1(0))

gsn_panel(wks,plot,(/nrc,1/),resP)     ; now draw as one plot
  
  end
  
