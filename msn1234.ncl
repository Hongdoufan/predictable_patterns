
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
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
pltName = "test4"                       ; set plot name 
pltType = "pdf" 

output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "msn1234.nc"  
;outName = "msn2.recon.ea14_obs_recon.nc"  

neof   = 3        ; number of EOFs
optEOF = True
optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

optETS = False
;==========================================================
;reconstruct t2m data
;==========================================================
t2m_eof=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc","r")
sic_pc=addfile("/disk1/fhd/winter_forecast/data/sic_projection_index.nc","r")
tp_pc=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc","r")
sd_na_pc=addfile("/disk1/fhd/winter_forecast/data/sd_na_djf_prd.nc","r")
sd_ea_pc=addfile("/disk1/fhd/winter_forecast/data/sd_projection_index.nc","r")
e=addfile("/disk1/fhd/winter_forecast/data/sst_projection_index.nc","r")
tren=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")
trend=tren->eof
pc2=tren->eof_ts

t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_projection_index.nc","r")
pc1=t2m_avg->mpc1
pc1!0 = "time"

nino=e->nino
emi=e->emi

cordinate=varible_file->$varname1$
cordi=cordinate(0,0,{20:89},{0:359})
eof=t2m_eof->eof
printVarSummary(cordi)
copy_VarCoords(cordi, eof(0,:,:))
eof_ts=t2m_eof->eof_ts
sic=sic_pc->sic
; sd_tp=tp_pc->sic_index
; sd_na=sd_na_pc->sic_index
sd_ea=sd_ea_pc->sd

copy_VarCoords(eof_ts(0,:), sic)
; copy_VarCoords(eof_ts(0,:), sd_tp)
; copy_VarCoords(eof_ts(0,:), sd_na)
copy_VarCoords(eof_ts(0,:), sd_ea)
copy_VarCoords(eof_ts(0,:), nino)
copy_VarCoords(eof_ts(0,:), emi)

printVarSummary(eof)



;exit()
eof(0,{latS:latN},{lonL:lonR})=trend({latS:latN},{lonL:lonR})*7.
;eof(1,:,:)=eof(2,:,:)
new_pc=eof_ts(0:3,:)
new_pc(0,:)=pc1
new_pc(1,:)=nino
new_pc(2,:)=sd_ea
new_pc(3,:)=sic


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
   var1_regrid =recon

 ; system("rm -f $output$+$outName$.nc")
 ; fout=addfile(output+outName, "c")
 ; fout->recon=var1_regrid
 ; exit()
   
   
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
   

    winter_anom_=winter_anom({latitude|:},{longitude|:},time|:)
    printVarSummary(winter_anom_({latS:latN},:,:))
    printVarSummary(var1_regrid)
;    exit()
   win_cor=escorc_n(var1_regrid,winter_anom_({latS:latN},:,:),2,2)  
   copy_VarCoords(winter_anom(0,{latS:latN},:),win_cor)  
   win_cor=where(win_cor.lt.0, -0.05, win_cor)  

   printVarSummary(win_cor)
   printMinMax(win_cor,False)

prob1=win_cor
prob1=where(win_cor.gt.0.33, 0.96, 0)

system("rm -f $output$+$outName$.nc")
fout=addfile(output+outName, "c")
fout->recon=win_cor
fout->reconp=prob1
exit()
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
 res1@gsnRightStringFontHeightF = 0.02
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
res1@gsnLeftString  = "(c)"
plot(0) = gsn_csm_contour_map_ce(wks,win_cor,res1)
plot1(0) = gsn_csm_contour(wks,prob1,sres)
overlay(plot(0),plot1(0))

;draw(plot)
;frame(wks)
gsn_panel(wks,plot,(/1,1/),rtsP)     ; now draw as one plot


end
