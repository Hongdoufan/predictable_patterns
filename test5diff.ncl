
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
pltName = "test5diff1"                       ; set plot name 
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
t2m_eof=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc","r")
sic_pc=addfile("/disk1/fhd/winter_forecast/data/sic_djf_prd.nc","r")
tp_pc=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc","r")
sd_na_pc=addfile("/disk1/fhd/winter_forecast/data/sd_na_djf_prd.nc","r")
sd_ea_pc=addfile("/disk1/fhd/winter_forecast/data/sd_ea_son_prd.nc","r")
e=addfile("/disk1/fhd/winter_forecast/data/emi_nino34_djf_prd.nc","r")
tren=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")

t2m_avg=addfile("/disk1/fhd/degreepaper/data/t2m_djf_prd_ndtrend.nc","r")
pc1=t2m_avg->sic_index
pc1!0 = "time"

trend=tren->eof
;pc2=fit->vartime


nino=e->nino34
emi=e->emi

cordinate=varible_file->$varname1$
cordi=cordinate(0,0,{20:89},{0:359})
eof=t2m_eof->eof
printVarSummary(cordi)
copy_VarCoords(cordi, eof(0,:,:))
eof_ts=t2m_eof->eof_ts
sic=sic_pc->sic_index
sd_tp=tp_pc->sic_index
sd_na=sd_na_pc->sic_index
sd_ea=sd_ea_pc->sic_index

copy_VarCoords(eof_ts(0,:), sic)
copy_VarCoords(eof_ts(0,:), sd_tp)
copy_VarCoords(eof_ts(0,:), sd_na)
copy_VarCoords(eof_ts(0,:), sd_ea)
copy_VarCoords(eof_ts(0,:), nino)
copy_VarCoords(eof_ts(0,:), emi)

printVarSummary(eof)

;==========================================================
;regression to adjust msn pc1
;==========================================================
;pc1=eof_ts(0,:)
;reg=regCoef(pc1,pc2)
;print(reg)
;pc1_fit=pc1*reg+reg@yintercept
;aaa=escorc(pc1,pc2)
;bbb=escorc(pc1_fit,pc2)
;print(aaa)
;print(bbb)
;printVarSummary(pc1_fit)
;;exit()




   
eof(0,{latS:latN},{lonL:lonR})=trend({latS:latN},{lonL:lonR})*7.
;eof(1,:,:)=eof(2,:,:)
new_pc=eof_ts(0:3,:)
new_pc(0,:)=pc1
new_pc(1,:)=nino
new_pc(2,:)=sd_ea
new_pc(3,:)=sd_tp

recon=eof2data(eof(0:3,:,:),new_pc)
var_winter=eof(1,{latS:latN},{lonL:lonR})
printVarSummary(var_winter)
;exit()

area_lat=var_winter&latitude
printVarSummary(area_lat)

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
   
   cv_t2m = recon(time|:,{latitude|:},{longitude|:})
   var1_regrid = recon

;  system("rm -f $output$+$outName$.nc")
;  fout=addfile(output+outName, "c")
;  fout->recon=var1_regrid
;  exit()
   
   
   varname2     = "t2m"  
   file2 = addfile("/disk1/fhd/data/t2m.mon.mean.1.0.nc","r")
   latitude=file2->latitude
   longitude=file2->longitude
   var2=short2flt(file2->$varname2$)
   obs=month_to_season(var2(35:466,:,:),season)
   obs_cli=dim_avg_n(obs,0)
   winter_anom=new((/36,181,360/),"float")
   do i=0,35
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   
   copy_VarCoords(obs, winter_anom)

   ; printVarSummary(recon)
   ; printVarSummary(winter_anom(:,{latS:latN},:))
   var1=varible_file->$varname1$
   ensemble_winter=dim_avg_n(var1,1)
   copy_VarCoords(var1(:,0,:,:), ensemble_winter)
   
    winter_anom_=winter_anom(time|:,{latitude|:},{longitude|:})
    printVarSummary(cv_t2m)
    printVarSummary(winter_anom_)
;    exit()
   win_cor=escorc_n(cv_t2m,winter_anom_(:,{latS:latN},:),0,0)  
   copy_VarCoords(winter_anom(0,{latS:latN},:),win_cor)  
   win_cor=where(win_cor.lt.0, -0.05, win_cor)  
;
;   printVarSummary(win_cor)
;   printMinMax(win_cor,False)
;

;system("rm -f $output$+$outName$.nc")
;fout=addfile(output+outName, "c")
;fout->recon=win_cor
;fout->reconp=prob1
;exit()
test5=addfile("/disk1/fhd/winter_forecast/data/test5trend.nc","r")
jjj=test5->recon
jjjp=test5->reconp
prob1=jjj
;prob1=where(win_cor.gt.0.33, 0.96, 0)
prob1=where(jjj.gt.0.28, 0.91, 0)

   win_cor_mode=escorc_n(cv_t2m,winter_anom(:,{latS:latN},{lonL:lonR}),0,0)  
   copy_VarCoords(winter_anom(0,{latS:latN},{lonL:lonR}),win_cor_mode)  
   printMinMax(win_cor_mode,False)
;   exit() 
   win_cor_ec=jjj({latS:latN},{lonL:lonR})

   diff=win_cor_ec-win_cor_mode
   copy_VarCoords(winter_anom(0,{latS:latN},{lonL:lonR}),diff)  

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

res1@gsnLeftString  = "trend"
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

