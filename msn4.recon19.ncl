
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
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
pltName = "msn4.recon19"                       ; set plot name 
pltType = "ps" 

output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "trend_enso_sn_tp_new.nc"  

; output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
; outName = "msn4_recon19_1.nc"  

neof   = 3        ; number of EOFs
optEOF = True
optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

optETS = False
;==========================================================
;reconstruct t2m data
;==========================================================
t2m_eof=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc","r")
sic_pc=addfile("/disk1/fhd/winter_forecast/data/sic_djf_prd.nc","r")
tp_pc=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc","r")
sd_na_pc=addfile("/disk1/fhd/winter_forecast/data/sd_na_djf_prd.nc","r")
sd_ea_pc=addfile("/disk1/fhd/winter_forecast/data/sd_ea_son_prd.nc","r")
e=addfile("/disk1/fhd/winter_forecast/data/emi_nino34_djf_prd.nc","r")
sst_pc4=addfile("/disk1/fhd/winter_forecast/data/sst_pc4_djf_prd.nc", "r")
msn_t2m_rc=addfile("/disk1/fhd/winter_forecast/data/msn.t2m.reg.t2m.nc","r")
eof=msn_t2m_rc->eof
nino=e->nino34
emi=e->emi
cordinate=varible_file->$varname1$
cordi=cordinate(0,0,{20:89},{0:359})
;eof=t2m_eof->eof
printVarSummary(cordi)
copy_VarCoords(cordi, eof(0,:,:))
printVarSummary(eof)
eof_ts=t2m_eof->eof_ts
sic=sic_pc->sic_index
sd_tp=tp_pc->sic_index
sd_na=sd_na_pc->sic_index
sd_ea=sd_ea_pc->sic_index
pc4=sst_pc4->sic_index

copy_VarCoords(eof_ts(0,:), sic)
copy_VarCoords(eof_ts(0,:), sd_tp)
copy_VarCoords(eof_ts(0,:), sd_na)
copy_VarCoords(eof_ts(0,:), sd_ea)
copy_VarCoords(eof_ts(0,:), nino)
copy_VarCoords(eof_ts(0,:), emi)
copy_VarCoords(eof_ts(0,:), pc4)



new_pc=eof_ts(0:3,:)
;new_pc(0,:)=ispan(1,36,1)
new_pc(1,:)=nino

;new_pc(1,0)=sd_tp(0)
;;new_pc(1,4)=sd_tp(4)
;new_pc(1,8)=sd_tp(8)
;new_pc(1,9)=sd_tp(9)
;;new_pc(1,11)=sd_tp(11)
;new_pc(1,12)=sd_tp(12)
;;new_pc(1,15)=sd_tp(15)
;new_pc(1,22)=sd_tp(22)
;;new_pc(1,23)=sd_tp(23)
;;new_pc(1,24)=sd_tp(24)
;new_pc(1,31)=sd_tp(31)
;;new_pc(1,32)=sd_tp(32)
;;
;;new_pc(1,0)=sd_na(0)
;new_pc(1,6)=sd_na(6)
;;new_pc(1,8)=sd_na(8)
;;new_pc(1,9)=sd_na(9)
;new_pc(1,11)=sd_na(11)
;new_pc(1,15)=sd_na(15)
;;new_pc(1,22)=sd_na(22)
;new_pc(1,23)=sd_na(23)
;;new_pc(1,32)=sd_na(32)
;new_pc(1,35)=sd_na(35)

; new_pc(1,0)=where(sd_na(0,0).gt.sd_tp(0,0),sd_na(0,0),sd_tp(0,0))
; new_pc(1,4)=where(sd_na(0,4).gt.sd_tp(0,4),sd_na(0,4),sd_tp(0,4))
; new_pc(1,6)=where(sd_na(0,6).gt.sd_tp(0,6),sd_na(0,6),sd_tp(0,6))
; new_pc(1,9)=where(sd_na(0,9).gt.sd_tp(0,9),sd_na(0,9),sd_tp(0,9))
; new_pc(1,11)=where(sd_na(0,11).gt.sd_tp(0,11),sd_na(0,11),sd_tp(0,11))
; new_pc(1,12)=where(sd_na(0,12).gt.sd_tp(0,12),sd_na(0,12),sd_tp(0,12))
; new_pc(1,22)=where(sd_na(0,22).gt.sd_tp(0,22),sd_na(0,22),sd_tp(0,22))
; new_pc(1,24)=where(sd_na(0,24).gt.sd_tp(0,24),sd_na(0,24),sd_tp(0,24))
; new_pc(1,35)=where(sd_na(0,35).gt.sd_tp(0,35),sd_na(0,35),sd_tp(0,35))
; new_pc(1,8)=where(sd_na(0,8).gt.sd_tp(0,8),sd_na(0,8),sd_tp(0,8))
; new_pc(1,31)=where(sd_na(0,31).gt.sd_tp(0,31),sd_na(0,31),sd_tp(0,31))

; eof_ts(1,:)=sst(0,:)
;  new_pc(1,:)=where(abs(new_pc(1,:)).lt.0.5.and.abs(sd_na).gt.0.5,sd_na,new_pc(1,:))
;  new_pc(1,:)=where(abs(sd_tp).gt. abs(new_pc(1,:)),sd_tp,new_pc(1,:))



 new_pc(2,:)=sd_ea
 new_pc(3,:)=sd_tp
; new_pc(2,0)=sd_ea(0)
; new_pc(2,3)=sd_ea(3)
; new_pc(2,6)=sd_ea(6)
; new_pc(2,14)=sd_ea(14)
; new_pc(2,24)=sd_ea(24)
; new_pc(2,25)=sd_ea(25)
; new_pc(2,31)=sd_ea(31)
; new_pc(2,32)=sd_ea(32)

;new_pc(2,:)=where(abs(sd_ea(0,:)).gt. abs(new_pc(2,:)),sd_ea(0,:),new_pc(2,:))
tren=addfile("/disk1/fhd/winter_forecast/data/y_trend.nc","r")
y_trend=tren->y_trend
prob=tren->prob
trend=tren->trend
aaa=trend({20:89},:)

   Opt                = True
   Opt@ForceOverwrite = True
   Opt@DstGridType    = "1.0x1.0"
   Opt@DstLLCorner    = (/ -90,   0/)
   Opt@DstURCorner    = (/  90, 359/)
   
   var1_regri = ESMF_regrid(trend,Opt)
;   var1_regrid =var1_regrid(:,:,::-1,:)
   printVarSummary(var1_regri)   

;printVarSummary(aaa)
;exit()
ddd=var1_regri({20:89},:)
;eof(0,:,:)=var1_regri({20:89},:)

printVarSummary(ddd)
recon=eof2data(eof(0:3,:,:),new_pc)
var_winter=eof(0,{latS:latN},{lonL:lonR})
area_lat=var_winter&lat

; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
; =================================================================
rad    = 4.*atan(1.)/180.
clat   = area_lat
clat   = sqrt( cos(rad*clat) ) 

do nl=0,dimsizes(clat)-1                  ; remove weighting
      if (clat(nl).ne.0.) then
          recon(nl,:,:)  = recon(nl,:,:)/clat(nl)   ; array syntax
      end if
end do

copy_VarCoords(eof(0,:,:), recon(:,:,0))
copy_VarCoords(new_pc(0,:), recon(0,0,:))

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
   printVarSummary(recon)
   var1=recon(time|:,lat|:,lon|:)
   
   Opt                = True
   Opt@ForceOverwrite = True
   Opt@DstGridType    = "2.5x2.5"
   Opt@DstLLCorner    = (/  0,   0/)
   Opt@DstURCorner    = (/  89,   359/)
   
   var1_regrid1 = ESMF_regrid(var1,Opt)
   var1_regrid =var1_regrid1(:,{latS:latN},:)
   printVarSummary(var1_regrid)



   
   
   varname2     = "t2m"  
   file2 = addfile("/disk3/erainterim2.5/monthly/surface/t2m.mon.mean.nc","r")
   latitude=file2->latitude
   longitude=file2->longitude
   var2=short2flt(file2->$varname2$)
   obs=month_to_season(var2(35:466,:,:),season)
   obs_cli=dim_avg_n(obs,0)
   winter_anom=new((/36,73,144/),"float")
   do i=0,35
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   
   copy_VarCoords(obs, winter_anom)

   printMinMax(winter_anom,False)
   printMinMax(var1_regrid,False)
;   exit()

   ; winter_anom_=winter_anom({latitude|:},{longitude|:},time|:)
   ; printVarSummary(winter_anom_({latS:latN},:,:))

   win_cor=escorc_n(var1_regrid,winter_anom(:,{latS:latN},:),0,0)  
   copy_VarCoords(winter_anom(0,{latS:latN},:),win_cor)  
   win_cor=where(win_cor.lt.0, -0.05, win_cor)  

   printVarSummary(win_cor)
system("rm -f $output$+$outName$.nc")
fout=addfile(output+outName, "c")
fout->recon=win_cor

; system("rm -f $output$+$outName$.nc")
; fout=addfile(output+outName, "c")
; fout->recon=var1_regrid

prob1=win_cor
prob1=where(win_cor.gt.0.33, 0.96, 0)

;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
 gsn_define_colormap(wks,"NCV_jaisnd")       ; choose colormap
  plot = new(1,graphic) 
  plot1= new(1,graphic) 

  
  res                      = True         
res@gsnDraw              = False       ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
  res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = 20.         ; zoom in on map
res@mpMaxLatF            = 87.5
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
 
 res1@gsnLeftStringFontHeightF = 0.018
 res1@gsnRightStringFontHeightF = 0.018
 res1@tiMainString             = " "
 res1@tiMainJust                = "centerleft"
 ;res1@tiMainPosition             = "left"
 res1@tmXBTickSpacingF        =60
 res1@tmYLTickSpacingF        =20

 res1@tmXTOn  = False
 res1@tmYROn  = False
; res1@tmXBLabelDeltaF =  0.5
 res1@tmXTMinorOn = False
 ;============================================================
; stip the d correlation at 95% significant level
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
res1@gsnLeftString  = "(c) "
plot(0) = gsn_csm_contour_map_ce(wks,win_cor,res1)
plot1(0) = gsn_csm_contour(wks,prob1,sres)
overlay(plot(0),plot1(0))

;draw(plot)
;frame(wks)
gsn_panel(wks,plot,(/1,1/),rtsP)     ; now draw as one plot


end
