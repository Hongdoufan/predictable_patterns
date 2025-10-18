

load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
   np   = 3        ; number of pictures
   varname1     = "winter_anom"
   varname2     = "t2m"  
   pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
   pltName = "com_skill_nino34"       
   pltType = "ps" 

   pos=(/1,7,10,16,17,26,29,34/)      ; high
   neg=(/8,9,11,12,20,22,31,32/)  ; low
   
  
   season = "JFM"   
   latS   =  90.
   latN   =  -90.
   lonL   =  0.
   lonR   =  360.

   tstart=""
   tend=""
   startyear=1981
   endyear=2016
   nyear= 36

   level  = " "
   ensemble = 25
                                                           ; create a plot [?]
   file1 = addfile("/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc","r")
   file2 = addfile("/disk3/erainterim2.5/monthly/surface/t2m.mon.mean.nc","r")
                ; set plot name 
   var1=file1->$varname1$
   var2=short2flt(file2->$varname2$)
   
   
   Opt                = True
   Opt@ForceOverwrite = True
   Opt@DstGridType    = "2.5x2.5"
   Opt@DstLLCorner    = (/ -90,   0/)
   Opt@DstURCorner    = (/  90, 357.5/)
   
   var1_regrid = ESMF_regrid(var1,Opt)
   var1_regrid =var1_regrid(:,:,::-1,:)
   printVarSummary(var1_regrid)   
   ensemble_winter=dim_avg_n(var1_regrid,1)

   obs=month_to_season(var2(35:466,:,:),season)
   obs_cli=dim_avg_n(obs,0)
   winter_anom=new((/36,73,144/),"float")
   do i=0,35
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   

   copy_VarCoords(obs, winter_anom)
;   winter_anom = dtrend_msg_n(winter_anom&time,winter_anom,True,False,0)
   copy_VarCoords(obs,ensemble_winter)
;   ensemble_winter = dtrend_msg_n(ensemble_winter&time,ensemble_winter,True,False,0)


   cor_pos=escorc_n(winter_anom(pos,:,:),ensemble_winter(pos,:,:),0,0)
   cor_neg=escorc_n(winter_anom(neg,:,:),ensemble_winter(neg,:,:),0,0)
   diff=cor_pos-cor_neg

   copy_VarCoords(var2(0,:,:), diff)
   copy_VarCoords(var2(0,:,:), cor_pos)
   copy_VarCoords(var2(0,:,:), cor_neg)
   diff=where(cor_neg({latS:latN},{lonL:lonR}).gt.0.and.cor_pos.lt.0, -cor_neg({latS:latN},{lonL:lonR}), diff)
   diff=where(cor_neg({latS:latN},{lonL:lonR}).lt.0.and.cor_pos.gt.0, cor_pos, diff)
   diff=where(cor_neg({latS:latN},{lonL:lonR}).lt.0.and.cor_pos.lt.0, 0.05, diff)
;============================================================
; test the difference
;============================================================
n1=8
n2=8
df=8
alpha=0.05   ;significance level
     
     p_v     = 1-alpha
     mean  = 0.0
     sd    = 1.0

     z_alpha = cdfnor_x(p_v,mean,sd)

r1=cor_pos({latS:latN},{lonL:lonR})
r2=cor_neg
z1=(1/2.)*log((1+r1)/(1-r1))
z2=(1/2.)*log((1+r2)/(1-r2))
st_diff=sqrt(1./(n1-3)+1./(n2-3))
;print(st_diff)
xa=z1-z2+z_alpha*st_diff
za=xa/st_diff
t=za

power=new((/dimsizes(diff&latitude),dimsizes(diff&longitude)/),"float")
do i=0,dimsizes(diff&latitude)-1
   do j=0,dimsizes(diff&longitude)-1
      power(i,j)=betainc( df/(df+t(i,j)^2), df/2.0, 0.5)
   end do
end do
copy_VarCoords(diff,power)  

printMinMax(power({latS:latN},{lonL:lonR}), False)
number=num(power({latS:latN},{lonL:lonR}).gt.0.9)
; print(number)
; exit()

prob1=power
prob2=power
prob1=where(r1.ge.0.71, 0.96, 0)
prob2=where(r2.ge.0.71, 0.96, 0)
          
; ==============================================================
; plot
; ==============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"NCV_jaisnd")       ; choose colormap
  plot = new(np,graphic) 
  plot1= new(np,graphic)

  res                      = True         
res@gsnDraw              = False        ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = 0.         ; zoom in on map
res@mpMaxLatF            = 90.
;res@mpCenterLonF         = 180.
res@mpMinLonF=110
res@mpMaxLonF=270
res@cnFillOn = True
res@cnLinesOn = False
;res@mpShapeMode = "FreeAspect"
; res@vpHeightF = 0.25        ; Changes the aspect ratio
; res@vpWidthF  = 0.5
  

res1 = res
;res1@gsnDraw = False
;res1@gsnFrame = False
res1@cnLineLabelFontHeightF   = 0.012
res1@cnInfoLabelOn            = False
res1@cnLevelSelectionMode        = "ExplicitLevels"
res1@cnLevels = (/0,0.1,0.3,0.5,0.7,0.9/)
res1@cnFillColors = (/"64","139","169","194","217","243","255"/)
res1@gsnRightString  = " "
res1@cnLineLabelsOn = False
res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF
res1@lbLabelBarOn                   = False
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2

;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.03
 res1@tmYLLabelFontHeightF = 0.03
; res1@tmXBLabelFont = 1
 res1@gsnLeftStringFontHeightF = 0.035
 res1@gsnRightStringFontHeightF = 0.035
 res1@tiMainString             = " "
 res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 
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
sres@cnFillScales         = (/1,0.7/)    ; change densities
sres@cnMonoFillColor      =True
sres@cnFillDotSizeF       = 0.00007

 rtsP                      = True            ; modify the panel plot
 rtsP@gsnMaximize          = True            ; large format
 rtsP@txString             = " "
 rtsP@gsnPanelLabelBar= True                 ; label bar on panel
 rtsP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.03
 rtsP@pmLabelBarWidthF =0.9
 rtsP@lbLabelFontHeightF  =0.020

res1@gsnLeftString  = "(a)"
plot(0) = gsn_csm_contour_map(wks,cor_pos,res1)
plot1(0) = gsn_csm_contour(wks,prob1,sres)
overlay(plot(0),plot1(0))

res1@gsnLeftString  = "(b)"
plot(1) = gsn_csm_contour_map(wks,cor_neg,res1)
plot1(1) = gsn_csm_contour(wks,prob2,sres)
overlay(plot(1),plot1(1))

res1@gsnLeftString  = "(c)"
plot(2) = gsn_csm_contour_map(wks,diff,res1)
plot1(2) = gsn_csm_contour(wks,power,sres)
overlay(plot(2),plot1(2))


;====================================================
; add polyline and text
;====================================================
txres               = True       ;text
txres@txFontHeightF = 0.015     
resp=True
resp@gsLineThicknessF=3        ;polyline
resp@gsLineColor="black";"dodgerblue4"
aa2=(/20,60.,60.,20.,20./)       ;pna
aa1=(/120,120.,250.,250.,120./)

l=new(4,graphic)
do i=0,3
l(i)=gsn_add_polyline(wks,plot(2),aa1(i:i+1),aa2(i:i+1),resp)
end do





;=====================================
;add text
;=====================================
text1=new(4,graphic)
;text1(0) = gsn_add_text(wks,plot(0),"nino3.4",195,10,txres)

text1(2)=gsn_add_text(wks,plot(2),"PNA",280,37,txres)


gsn_panel(wks,plot,(/np,1/),rtsP)     ; now draw as one plot


end



     