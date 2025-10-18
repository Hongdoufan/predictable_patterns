
begin
latS   =  -90.
latN   =  90.
lonL   =  0.
lonR   =  360.

yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "sd_djf_prd_cor_mpc3"      
pltType = "pdf" 
   output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
   outName = "sd_djf_prd_cor_mpc3.nc"                       ; set plot name 

season = "JFM"    
f      = addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
eof_ts=f->eof_ts

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/sd_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
var1=varible_file->$varname1$
ensemble_winter=dim_avg_n(var1,1)
copy_VarCoords(var1(:,0,:,:), ensemble_winter)
ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)



  nyrs2   = dimsizes(ensemble_winter&nyear)
     a = eof_ts(:,:)
     nyrs3  = dimsizes(a)
     b =ensemble_winter({latitude|:},{longitude|:},nyear|:)
     printVarSummary(a)
     printVarSummary(b)
     rc    = escorc(a,b)
 ;    rc =rc*1000.
 ;    rc(3,:,:)=where(b(:,:,0).eq.9.96921e+36, 9.969209968386869e+36, rc(3,:,:))
     nrc=5
;printVarSummary(rc)
  rc!0 = "evn"
  rc!1 = "lat"
  rc!2 = "lon"
  rc&evn = ispan(1, 5, 1)
  rc&lat = var1&latitude
  rc&lon = var1&longitude
  prob = rc
 ; prob = 0
 ; copy_VarCoords(rc, prob)
prob=where(abs(rc).ge.0.33, 96, prob)
prob=where(abs(rc).ge.0.425, 100, prob)

;system("rm -f $output$+$outName$.nc")
;fout=addfile(output+outName, "c")
;fout->cor=rc(2,:,:)
;fout->corp=prob(2,:,:)
;exit()

;   file2 = addfile("/disk1/fhd/winter_forecast/data/fig6b.nc","r")
;
;   va=file2->6b
;   vap=file2->6bp
;   
;   file3 = addfile("/disk1/fhd/winter_forecast/data/pc3.cor.sic.nc","r")
;   cf=file3->cor
;
;   file4 = addfile("/disk1/fhd/winter_forecast/data/pc3.cor.sic.obs.nc","r")
;   df=file4->cor
;
;   cfp=cf
;   cfp=where(abs(cf).ge.0.33, 96, 0)
;   dfp=df
;   dfp=where(abs(df).ge.0.33, 96, 0)
   
   
;============================================================
; PLOTS
;============================================================
  wks = gsn_open_wks(pltType,pltDir+pltName)
  gsn_define_colormap(wks,"temp_19lev")       ; choose colormap
  plot = new(4,graphic)                ; create graphic array
  plot1 = new(4,graphic)                ; create graphic array

  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnSpreadColors      = True         ; spread out color table
   res@mpFillOn             = False        ; turn off map fill
   res@mpMinLatF            = 20         ; zoom in on map
   res@mpMaxLatF            = 45
   res@mpMinLonF            = 78
   res@mpMaxLonF            = 130
  ; res@mpCenterLonF         = 90
  res@cnFillOn = True
  res@cnLinesOn = False
  

res1 = res
res1@gsnDraw = False
res1@gsnFrame = False
res1@cnLineLabelsOn    =False
;res1@cnLineLabelFontHeightF   = 0.012
res1@cnInfoLabelOn            = False
res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res1@cnLevelSpacingF   =0.2
res1@cnMinLevelValF    =-0.7
res1@cnMaxLevelValF    =0.7
res1@gsnRightString  = "  "
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF  = 1
res1@lbLabelBarOn                   = False
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2
res1@vpHeightF = 0.5;0.9        ; Changes the aspect ratio
res1@vpWidthF  = 0.5;0.9

 res1@tmXBLabelFontHeightF = 0.015
 res1@tmYLLabelFontHeightF = 0.015
; res1@tmXBLabelFont = 1
 
 res1@gsnLeftStringFontHeightF = 0.015
; res1@gs = 0.015
; res1@gsnStringFont   =10
 res1@gsnRightStringFontHeightF = 0.01
 res1@tiMainString             = " "
 res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 res1@tmXBTickSpacingF        =20
 res1@tmXTOn  = False
 res1@tmYROn  = False
; res1@tmXBLabelDeltaF =  0.5
 res1@tmXTMinorOn = False

 opt = True
 opt@gsnShadeFillType = "pattern"       
 opt@gsnShadeHigh= 17          ;打点

 rtsP                      = True            ; modify the panel plot
 rtsP@gsnMaximize          = True            ; large format
 rtsP@txString             = " "
 rtsP@gsnPanelLabelBar= True                 ; label bar on panel
 rtsP@pmLabelBarOrthogonalPosF = -0.04       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.04
 rtsP@pmLabelBarWidthF =0.8
 rtsP@lbLabelFontHeightF  =0.015
 rtsP@lbLabelOffsetF = 0.25

; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2
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
sres@cnLevels    = (/95/)
sres@cnMonoFillPattern    = False            ; want multiple patterns
sres@cnFillPatterns       = (/-1,17/)     ; the patterns
sres@cnMonoFillScale      = False            ; want different densities
sres@cnFillScales         = (/1,0.65/)    ; change densities
sres@cnMonoFillColor      =True
sres@cnFillDotSizeF       = 0.003
res1@gsnLeftString  = "(a) MPC3 Cor: DJF snow "


plot(0) = gsn_csm_contour_map_ce(wks,rc(2,:,:),res1)
plot1(0) = gsn_csm_contour(wks,prob(2,:,:),sres)
overlay(plot(0),plot1(0))

res1@gsnLeftString  = "(b) MPC4 Cor: DJF snow"
plot(1) = gsn_csm_contour_map_ce(wks,rc(3,:,:),res1)
plot1(1) = gsn_csm_contour(wks,prob(3,:,:),sres)
overlay(plot(1),plot1(1))


;=====================================
; sic plot
;=====================================
  fig                      = True         
  fig@gsnDraw              = False       ; don't draw yet
  fig@gsnFrame             = False        ; don't advance frame yet
  fig@mpFillOn             = False        ; turn off map fill
  fig@gsnPolar   = "NH"  
  fig@gsnAddCyclic= True
  fig@mpFillOn             = False        ; turn off map fill
  fig@mpMinLatF            = 70         ; zoom in on map
  fig@mpCenterLonF         = 90.
  fig@cnFillOn = True
  fig@cnLinesOn = False
  fig@vpHeightF = 0.4;0.7        ; Changes the aspect ratio
  fig@vpWidthF  = 0.4;0.7
  

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

fig@gsnPolarLabelFontHeightF = 0.015
fig@gsnPolarLabelDistance = 1.06

 fig@gsnLeftStringFontHeightF = 0.015
 fig@gsnRightStringFontHeightF = 0.015
 fig@gsnLeftStringOrthogonalPosF = 0.04
 fig@tiMainString             = " "
 fig@tiMainJust                = "centerleft"
 ;fig@tiMainPosition             = "left"
 fig@tmXBTickSpacingF        =60
 fig@tmXTOn  = False
 fig@tmYROn  = False
; fig@tmXBLabelDeltaF =  0.5
 fig@tmXTMinorOn = False
 
fig@gsnLeftString  = "(c) Cor: SEAS5 SIC"
;plot(2) = gsn_csm_contour_map_polar(wks,cf,fig)
;plot1(2) = gsn_csm_contour(wks,cfp,sres)
;overlay(plot(2),plot1(2))
;
;fig@gsnLeftString  = "(d) Cor: OBS SIC"
;plot(3) = gsn_csm_contour_map_polar(wks,df,fig)
;plot1(3) = gsn_csm_contour(wks,dfp,sres)
;overlay(plot(3),plot1(3))



;=====================================
; add box 
;=====================================

resp=True
resp@gsLineThicknessF=1.5        ;polyline
resp@gsLineColor="black"
;=====================================
;
;=====================================
aa2=(/43,55.,55.,43.,43./)       ;pna
aa1=(/72,72.,117.,117.,72./)

l=new(4,graphic)
do i=0,3
l(i)=gsn_add_polyline(wks,plot(0),aa1(i:i+1),aa2(i:i+1),resp)
end do

;dl=new(4,graphic)
;do i=0,3
;dl(i)=gsn_add_polyline(wks,plot(1),aa1(i:i+1),aa2(i:i+1),resp)
;end do

;=====================================
;
;=====================================
aa2=(/62,70.,70.,62.,62./)       ;pna
aa1=(/90,90.,123.,123.,90./)

lf=new(4,graphic)
do i=0,3
lf(i)=gsn_add_polyline(wks,plot(0),aa1(i:i+1),aa2(i:i+1),resp)
end do

;=====================================
;
;=====================================
aa2=(/25,32.,32.,25.,25./)       ;  south
aa1=(/103,103.,120.,120.,103./)

lfj=new(4,graphic)
do i=0,3
lfj(i)=gsn_add_polyline(wks,plot(1),aa1(i:i+1),aa2(i:i+1),resp)
end do


;=====================================
;
;=====================================
aa2=(/36,43.,43.,36.,36./)       ;north
aa1=(/103,103.,114.,114.,103./)

lfjf=new(4,graphic)
do i=0,3
lfjf(i)=gsn_add_polyline(wks,plot(1),aa1(i:i+1),aa2(i:i+1),resp)
end do

;=====================================
;
;=====================================
;aa2=(/23,30.,30.,23.,23./)       ;pna
;aa1=(/103,103.,110.,110.,103./)
aa2=(/25,43.,43.,25.,25./)       ;pna
aa1=(/103,103.,120.,120.,103./)

lj=new(4,graphic)
do i=0,3
lj(i)=gsn_add_polyline(wks,plot(1),aa1(i:i+1),aa2(i:i+1),resp)
end do

dlj=new(4,graphic)
do i=0,3
dlj(i)=gsn_add_polyline(wks,plot(3),aa1(i:i+1),aa2(i:i+1),resp)
end do


gsn_panel(wks,plot,(/2,2/),rtsP)     ; now draw as one plot

;  do n=0,nrc-1
;  res1@gsnLeftString  = "";" PC"+(n+1)+ ".reg.sd" 
;  res1@gsnRightString = "CI:2mm"
;  plot(n)=gsn_csm_contour_map(wks, rc(2,:,:), res1)
;end do
;  gsn_panel(wks,plot,(/1,1/),resP)     ; now draw as one plot
  
  end
  

