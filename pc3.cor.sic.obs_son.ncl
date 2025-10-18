
begin
latS   =  -90.
latN   =  90.
lonL   =  0.
lonR   =  360.
np=2
yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "pc3.cor.obs.sic"      
pltType = "pdf" 

season = "JFM"    
f      = addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
eof_ts=f->eof_ts
a = eof_ts(2,:)
varname1     = "sic"
files_dir    = "/disk3/HadISST/HadISST_ice.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->$varname1$
   obs=month_to_season(var1(1340:1771,:,:),season)
   obs_cli=dim_avg_n(obs,0)
   winter_anom=new((/36,180,360/),"float")
   do i=0,35
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   
   copy_VarCoords(obs, winter_anom)
   winter_anom = dtrend_msg_n(winter_anom&time,winter_anom,True,False,0)

     b =winter_anom({latitude|:},{longitude|:},time|:)
;     printVarSummary(a)
;     printVarSummary(b)
;     print(a)
;     printMinMax(b,False)
     rc    = escorc(a,b)
     printMinMax(rc,False)
 ;    rc =rc*1000.
 ;    rc(3,:,:)=where(b(:,:,0).eq.9.96921e+36, 9.969209968386869e+36, rc(3,:,:))
     nrc=5
;printVarSummary(rc)
  rc!0 = "lat"
  rc!1 = "lon"
  rc&lat = var1&latitude
  rc&lon = var1&longitude
  prob = rc
 ; prob = 0
 ; copy_VarCoords(rc, prob)
prob=where(abs(rc).ge.0.33, 96, prob)
prob=where(abs(rc).ge.0.425, 100, prob)

   file2 = addfile("/disk1/fhd/winter_forecast/data/fig6b.nc","r")

   va=file2->6b
   vap=file2->6bp
   
   
   
 system("rm -f /disk1/fhd/winter_forecast/data/pc3.cor.sic.obs.nc")
 fout=addfile("/disk1/fhd/winter_forecast/data/pc3.cor.sic.obs.nc", "c")
 fout->cor=rc
; exit()
; ==============================================================
; plot
; ==============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"temp_19lev")       ; choose colormap
  plot = new(np,graphic) 
  
  res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
  res@mpFillOn             = False        ; turn off map fill
  res@gsnPolar   = "NH"  
  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = 70         ; zoom in on map
 ; res@mpMaxLatF            = 
 res@mpCenterLonF         = 90.
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
res1@cnLevelSpacingF   =0.2
res1@cnMinLevelValF    =-0.7
res1@cnMaxLevelValF    =0.7
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
 
 res1@gsnLeftStringFontHeightF = 0.01
 res1@gsnRightStringFontHeightF = 0.01
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
res1@gsnLeftString  = "correlation skill "
plot(0) = gsn_csm_contour_map(wks,rc,res1)
res1@gsnLeftString  = "limit of correlation skill   "

res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res1@cnLevelSpacingF   =0.2
plot(1) = gsn_csm_contour_map(wks,rc,res1)
;draw(plot)
;frame(wks)
gsn_panel(wks,plot,(/1,2/),rtsP)     ; now draw as one plot


end
