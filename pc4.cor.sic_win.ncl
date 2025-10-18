
begin
latS   =  -90.
latN   =  90.
lonL   =  0.
lonR   =  360.
np=2
yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "pc4.cor.sic_win"      
pltType = "pdf" 

season = "JFM"    
f      = addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
eof_ts=f->eof_ts

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/sic_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->$varname1$
ensemble_winter=dim_avg_n(var1,1)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)
ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)



  nyrs2   = dimsizes(ensemble_winter&nyear)
     a = eof_ts(3,:)
     nyrs3  = dimsizes(a)
     b =ensemble_winter({latitude|:},{longitude|:},nyear|:)
     printVarSummary(a)
     printVarSummary(b)
     print(a)
     printMinMax(b,False)
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

   file2 = addfile("/disk1/fhd/winter_forecast/data/pc3.cor.sic.obs.nc","r")

   va=file2->cor
   
 system("rm -f /disk1/fhd/winter_forecast/data/pc3.cor.sic.nc")
 fout=addfile("/disk1/fhd/winter_forecast/data/pc3.cor.sic.nc", "c")
 fout->cor=rc
; exit()
; ==============================================================
; plot
; ==============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"temp_19lev")       ; choose colormap
  plot = new(np,graphic) 
  
  fig                      = True         
  fig@gsnDraw              = False       ; don't draw yet
  fig@gsnFrame             = False        ; don't advance frame yet
  fig@mpFillOn             = False        ; turn off map fill
  fig@gsnPolar   = "NH"  
  fig@mpFillOn             = False        ; turn off map fill
  fig@mpMinLatF            = 70         ; zoom in on map
  fig@mpCenterLonF         = 90.
  fig@cnFillOn = True
  fig@cnLinesOn = False
  fig@vpHeightF = 0.25        ; Changes the aspect ratio
  fig@vpWidthF  = 0.5
  

fig@cnLineLabelsOn    =False
;fig@cnLineLabelFontHeightF   = 0.012
fig@cnInfoLabelOn            = False
fig@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
fig@cnLevelSpacingF   =0.2
fig@cnMinLevelValF    =-0.7
fig@cnMaxLevelValF    =0.7
;fig@cnLevelSelectionMode        = "ExplicitLevels"
;fig@cnLevels = (/-0.9, -0.7, -0.5, -0.3, -0.2,0.2,0.3,0.5,0.7,0.9/)
;fig@cnFillColors = (/"2", "19", "27", "47","71","0","139","169","194","217","243"/)
fig@gsnRightString  = " "
fig@cnFillDrawOrder = "Predraw"
fig@cnInfoLabelParallelPosF = 2.0
;fig@lbLabelOffsetF  = 1
fig@lbLabelBarOn                   = False
fig@lbBottomMarginF = 0.05
fig@lbLeftMarginF = 0.08
fig@lbTopMarginF = 0.2

;fig@lbBoxMinorExtentF = 1.0
;fig@lbLabelFontHeightF = 1.0

 fig@tmXBLabelFontHeightF = 0.013
 fig@tmYLLabelFontHeightF = 0.013
; fig@tmXBLabelFont = 1
 
 fig@gsnLeftStringFontHeightF = 0.01
 fig@gsnRightStringFontHeightF = 0.01
 fig@tiMainString             = " "
 fig@tiMainJust                = "centerleft"
 ;fig@tiMainPosition             = "left"
 fig@tmXBTickSpacingF        =60
 fig@tmXTOn  = False
 fig@tmYROn  = False
; fig@tmXBLabelDeltaF =  0.5
 fig@tmXTMinorOn = False
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
fig@gsnLeftString  = "predicted "
plot(0) = gsn_csm_contour_map(wks,rc,fig)
fig@gsnLeftString  = "observed "

fig@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
fig@cnLevelSpacingF   =0.2
plot(1) = gsn_csm_contour_map(wks,va,fig)
;draw(plot)
;frame(wks)

figp=True
figp@gsLineThicknessF=3        ;polyline
figp@gsLineColor="black"
;=====================================
;
;=====================================
aa2=(/70,88.,88.,70.,70./)       ;pna
aa1=(/-20,-20.,60.,60.,-20./)

l=new(4,graphic)
do i=0,3
l(i)=gsn_add_polyline(wks,plot(0),aa1(i:i+1),aa2(i:i+1),figp)
end do

dl=new(4,graphic)
do i=0,3
dl(i)=gsn_add_polyline(wks,plot(1),aa1(i:i+1),aa2(i:i+1),figp)
end do

gsn_panel(wks,plot,(/1,2/),rtsP)     ; now draw as one plot


end
