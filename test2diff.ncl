
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360

yrStrt = 1981
yrLast = 2016

tstart= 35
tend=466
varname1     = "winter_anom"
decomposition_season="JFM"
season="JFM"

var     = "t2m"
unit= ""
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
   
;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "test2diff"                       ; set plot name 
pltType = "pdf" 

output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "test5_cor_arcavg.nc"  
;outName = "test5_recon_arcavg.nc"  

neof   = 3        ; number of EOFs
optEOF = True
optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

optETS = False
;==========================================================
;reconstruct t2m data
;==========================================================
test5_eof2=addfile("/disk1/fhd/winter_forecast/data/test2_cor.nc","r")
win_cor_mode=test5_eof2->recon
prob2=test5_eof2->reconp
;prob1=jjj
;prob1=where(win_cor.gt.0.33, 0.96, 0)
;prob1=where(jjj.gt.0.28, 0.91, 0)
test5_trend=addfile("/disk1/fhd/winter_forecast/data/test2_cor_trend.nc","r")
win_cor_ec=test5_trend->recon
prob1=test5_trend->reconp




;   win_cor_ec=jjj({latS:latN},{lonL:lonR})

   diff=win_cor_ec-win_cor_mode
   copy_VarCoords(win_cor_ec,diff)  


;   win_cor_ec=where(win_cor_ec.lt.0, -0.05, win_cor_ec)  
;   win_cor_mode=where(win_cor_mode.lt.0, -0.05, win_cor_mode)  
;   diff=where(win_cor_ec.gt.0.and.win_cor_mode.lt.0, -win_cor_ec, diff)
;   diff=where(win_cor_ec.lt.0.and.win_cor_mode.gt.0, win_cor_mode, diff)
;   diff=where(win_cor_ec.lt.0.and.win_cor_mode.lt.0, 0, diff)

  printMinMax(win_cor_ec, False)
  printMinMax(win_cor_mode,False)
  printMinMax(diff,False)

;============================================================
; test the difference
;============================================================
n1=36
n2=36
df=36
alpha=0.05   ;significance level
     
     p_v     = 1-alpha
     mean  = 0.0
     sd    = 1.0

     z_alpha = cdfnor_x(p_v,mean,sd)

r1=win_cor_ec
r2=win_cor_mode
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

;printMinMax(power, False)
number=num(power({40:70},{0:140}).gt.0.9)
;print(number)
; exit()
prob1=power
prob2=power
prob1=where(r1.ge.0.28, 0.91, 0)
prob2=where(r2.ge.0.28, 0.91, 0)
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"NCV_jaisnd")       ; choose colormap
  plot = new(3,graphic) 
  plot1= new(3,graphic)
  
  res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
  res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN
;res@mpCenterLonF         = 180.
res@mpMinLonF=0
res@mpMaxLonF=180
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
;res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
;res1@cnLevelSpacingF   =0.1
;res1@cnMinLevelValF    =-0.9
;res1@cnMaxLevelValF    =0.9
res1@cnLevelSelectionMode        = "ExplicitLevels"
res1@cnLevels = (/0,0.1,0.3,0.5,0.7,0.9/)
res1@cnFillColors = (/"64","139","169","194","217","243","255"/)
res1@gsnRightString  = " "
;res1@cnFillDrawOrder = "Predraw"
res1@cnInfoLabelParallelPosF = 2.0
;res1@lbLabelOffsetF  = 1
res1@lbLabelBarOn                   = True
res1@lbBottomMarginF = 0.05
res1@lbLeftMarginF = 0.08
res1@lbTopMarginF = 0.2

;res1@lbBoxMinorExtentF = 1.0
;res1@lbLabelFontHeightF = 1.0

 res1@tmXBLabelFontHeightF = 0.01
 res1@tmYLLabelFontHeightF = 0.01
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
 rtsP@gsnPanelLabelBar= False                ; label bar on panel
 rtsP@pmLabelBarOrthogonalPosF = -0.03       ; 0.05
 rtsP@pmLabelBarHeightF    = 0.04
 rtsP@pmLabelBarWidthF =0.6
 rtsP@lbLabelFontHeightF  =0.015
; rtsP@pmLabelBarHeightF = 0.05
; rtsP@lbLeftMarginF = 0.08
; rtsP@lbTopMarginF = 0.2
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
sres@cnLevels    = (/0.90/)
sres@cnMonoFillPattern    = False            ; want multiple patterns
sres@cnFillPatterns       = (/-1,17/)     ; the patterns
sres@cnMonoFillScale      = False            ; want different densities
sres@cnFillScales         = (/1,1/)    ; change densities
sres@cnMonoFillColor      =True
sres@cnFillDotSizeF       = 0.00007

res1@gsnLeftString  = "Figure 12b trend"
plot(0) = gsn_csm_contour_map_ce(wks,win_cor_ec,res1)
plot1(0) = gsn_csm_contour(wks,prob1,sres)
overlay(plot(0),plot1(0))

res1@gsnLeftString  = "EOF2"
plot(1) = gsn_csm_contour_map_ce(wks,win_cor_mode,res1)
plot1(1) = gsn_csm_contour(wks,prob2,sres)
overlay(plot(1),plot1(1))

res1@cnLevelSelectionMode        = "ExplicitLevels"
res1@cnLevels = (/-0.05,-0.025,0,0.025,0.05,0.075/)
res1@cnFillColors = (/"17","33","64","139","169","194","217"/)


res1@gsnLeftString  = "trend-EOF2"
plot(2) = gsn_csm_contour_map_ce(wks,diff,res1)
plot1(2) = gsn_csm_contour(wks,power,sres)
overlay(plot(2),plot1(2))
;draw(plot)
;frame(wks)
gsn_panel(wks,plot,(/3,1/),rtsP)     ; now draw as one plot


end

