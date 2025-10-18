load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
nrc=3
latS   =  25.
latN   =  75.
lonL   = 0.
lonR   =  180.
nyear  = 36
yrStrt = 1981
yrLast = 2016
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "msn.pc3.cor.obs.sd.son_era"      
pltType = "pdf" 
neof    = 4
nrc=1
season = "JFM" 
     
f      = addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
eof_ts=f->eof_ts(0:3,:)

ff=addfile ("/disk1/fhd/data/sd.mon.mean.1.0.nc", "r")
  TIME2   = ff->time
  YYYY2   = cd_calendar(TIME2,-2)/100                 
  iYYYY2  = ind(YYYY2.ge.yrStrt .and. YYYY2.le.yrLast)

;aaa=ff->sst
;aaa@_FillValue=-1000
;aaa=runave_n_Wrap (aaa, 3, 1, 0)
var2= short2flt(ff->sd(32:463,:,:)) ;1981.09



;var2=where(var2.eq.-1.8, -1000, var2)

lat=ff->latitude
lon=ff->longitude
;NOV

  xClm     = clmMonTLL(var2(:,:,:))
  xAnom    = calcMonAnomTLL (var2,  xClm )

  sep=xAnom(::12,:,:)
  oct=xAnom(1::12,:,:)
;   obs=var2(0:nyear-1,:,:)
  SST1  = (sep+oct)/2.
;   SST1=dtrend_n(SST1,True,0)     
;   SST1=where(obs1.eq.-1000,9.96921e+36, SST1 )
;   SST1=where(SST1.lt.-20.or.SST1.gt.20, 9.96921e+36, SST1)
   SST1!0 = "time"
   SST1&time = ispan(1981,2016,1)
   copy_VarCoords(xAnom(0,:,:), SST1(0,:,:)) 
   SST1 = dtrend_msg_n(SST1&time,SST1,True,False,0)



nyrs2   = dimsizes(SST1&time)
a = eof_ts(:,:)
nyrs3  = dimsizes(a)
b =SST1(latitude|:,longitude|:,time|:)
rc    = escorc_n(a,b,1,2)
; do i=0,2
; rc1(i,:,:)=where(obs1(0,:,:).eq.-1000,9.96921e+36, rc1(i,:,:) )
; end do

  rc!0 = "evn"
  rc!1 = "lat"
  rc!2 = "lon"
  rc&evn = ispan(1, neof, 1)
  rc&lat = var2&latitude
  rc&lon = var2&longitude
  prob = rc
 ; prob = 0
 ; copy_VarCoords(rc, prob)
prob=where(abs(rc).ge.0.33, 96, prob)
prob=where(abs(rc).ge.0.425, 100, prob)

system("rm -f /disk1/fhd/winter_forecast/data/msn.pc3.cor.obs.sd.so.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/msn.pc3.cor.obs.sd.so.nc", "c")
fout->cor=rc(2,:,:)
fout->corp=prob(2,:,:)
exit()
;============================================================
; PLOTS
;============================================================
  wks = gsn_open_wks(pltType,pltDir+pltName)
  gsn_define_colormap(wks,"temp_19lev")       ; choose colormap
  plot = new(nrc,graphic)                ; create graphic array
  plot1 = new(nrc,graphic)                ; create graphic array

  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnSpreadColors      = True         ; spread out color table

;latS   =  -90.
;latN   =  90.
;lonL   = 0.
;lonR   =  360.
 ; res@gsnPolar   = "NH"  
  res@mpFillOn             = False        ; turn off map fill
   res@mpMinLatF            = latS         ; zoom in on map
   res@mpMaxLatF            = latN  
   res@mpMinLonF            = lonL
   res@mpMaxLonF            = lonR
   res@mpCenterLonF         = 180
  res@cnFillOn = True
res@cnLinesOn = False
;res@mpShapeMode = "FreeAspect"
 res@vpHeightF = 0.25        ; Changes the aspect ratio
 res@vpWidthF  = 0.5
  

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
;symMinMaxPlt(diff, 16, False, res)
;res1@cnLevelSelectionMode        = "ExplicitLevels"
;res1@cnLevels = fspan(-0.2, 0.4, 16)
;res1@cnFillColors = (/"23", "28","33","38","43","48","59",\
;                      "62","67","72","77","82","87","92","94",\
;                      "98","102"/)
res1@gsnRightString  = "  "
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF  = 1
res1@lbLabelBarOn                   = False
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2

;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.012
 res1@tmYLLabelFontHeightF = 0.012
; res1@tmXBLabelFont = 1
 
 res1@gsnLeftStringFontHeightF = 0.015
 res1@gsnRightStringFontHeightF = 0.01
 res1@tiMainString             = " "
 res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 res1@tmXBTickSpacingF        =60
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
 rtsP@pmLabelBarOrthogonalPosF = -0.01       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.04
 rtsP@pmLabelBarWidthF =0.8
 rtsP@lbLabelFontHeightF  =0.015
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


res1@gsnLeftString  = "(b)"
plot(0) = gsn_csm_contour_map_ce(wks,rc(2,:,:),res1)
plot1(0) = gsn_csm_contour(wks,prob(2,:,:),sres)



overlay(plot(0),plot1(0))

resp=True
resp@gsLineThicknessF=3       ;polyline
resp@gsLineColor="black"
;=====================================
;
;=====================================
aa2=(/45,60.,60.,45.,45./)       ;pna
aa1=(/60,60.,140.,140.,60./)

l=new(4,graphic)
do i=0,3
l(i)=gsn_add_polyline(wks,plot(0),aa1(i:i+1),aa2(i:i+1),resp)
end do


  gsn_panel(wks,plot,(/nrc,1/),rtsP)     ; now draw as one plot
  
  end
  
