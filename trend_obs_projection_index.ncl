;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
pltDir  =  "/disk1/fhd/degreepaper/result/"                            ; directory for plot output
pltName = "nao_index"      
pltType = "pdf" 
season = "JFM"   

;************************************************
; read scand_index, scand_pattern, and hindcast 500hgt
;************************************************

f      = addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r") ;eof_sd_djf
scand_obs=f->eof_ts

;system("rm -f /disk1/fhd/winter_forecast/data/fig3acd_new.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/fig3acd_new.nc", "c")
;fout->3a=rc
;fout->3c=rc1

fout=addfile("/disk1/fhd/winter_forecast/data/fig3acd_new.nc", "r")
mode=fout->3c
scand_pattern=mode({latS:latN},{lonL:lonR})
scand_pattern=scand_pattern/10.
   file2 = addfile("/disk1/fhd/data/t2m.mon.mean.1.0.nc","r")
   var2=short2flt(file2->t2m)
   
   
   
   obs=month_to_season(var2(35:466,:,:),season)
   obs_cli=dim_avg_n(obs,0)
   winter_anom=new((/36,181,360/),"float")
   do i=0,35
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   
   copy_VarCoords(obs, winter_anom)  

;   copy_VarCoords(scand_pattern, ensemble_winte(0,:,:))
;   copy_VarCoords(var1(:,0,0,0), ensemble_winte(:,0,0))  
;   printVarSummary(ensemble_winter)   
   ensemble_winter=winter_anom(:,{latS:latN},{lonL:lonR})
;   ensemble_winter=lonFlip(ensemble_winter)

;************************************************
; project predicted sst  onto sst eof1 to get projection index
; consider weight
;************************************************
rad    = 4.*atan(1.)/180.
clat   = ensemble_winter&latitude
clat   = sqrt( cos(rad*clat) )                

wsea_variable   = ensemble_winter                                   ; copy meta data
wsea_variable   = ensemble_winter*conform(ensemble_winter, clat, 1)
ensemble     = wsea_variable({latitude|:},{longitude|:},{time|:})

   printVarSummary(ensemble)
   scand=new((/1,70,360/),"float")
   scand(0,:,:)=scand_pattern({latS:latN},:)

latS1   =  20
latN1   =  89
lonL1   =  0
lonR1   =  360
   optETS = False
;   scand=lonFlip(scand)
   printVarSummary(scand)
   printVarSummary(ensemble)
   scand_prd_= eofunc_ts(ensemble({latS1:latN1},{lonL1:lonR1},:),scand(:,{latS1:latN1},{lonL1:lonR1}), optETS)
   scand_prd=scand_prd_(0,:)
; =================================================================
; Normalize time series: Sum spatial weights over the area of used
; =================================================================
dimx  = dimsizes( ensemble )
mln    = dimx(1)
sumWgt = mln*sum(clat)
scand_prd = scand_prd/sumWgt
scand_prd = dim_standardize_Wrap(scand_prd,0)

; =================================================================
; Normalize time series: Sum spatial weights over the area of used
; =================================================================

;printVarSummary(scand_index)

;system("rm -f /disk1/fhd/winter_forecast/data/trend_obs_projection_index.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/trend_obs_projection_index.nc", "c")
;fout->prd_index=scand_prd

   cor1=escorc(scand_prd,scand_obs)
   printVarSummary(scand_prd)   
   print(cor1)
   exit()
   
   
   
   d_stz=new((/2,36/),"float")
   d_stz(0,:)=scand_prd    ;model
   d_stz(1,:)=scand_obs
   year=ispan(1981,2016,1)
   
;************************************************
; create plot
;************************************************
wks = gsn_open_wks(pltType,pltDir+pltName)
res               = True                        ; plot mods desired
res@gsnDraw= False
res@gsnFrame= False

res@tmXBMode          = "Explicit"              ; explicit labels
;res@tmXBValues        = x                       ; location of labels
;res@tmXBLabels        = warm_yrs                ; labels themselves
res@tmLabelAutoStride = True                    ; nice stride on labels
res@xyLineColors      = (/"black","red"/)  ; line colors
res@xyLineThicknesses	 = (/5.,5./)      ; line thicknesses
res@xyDashPatterns    = (/0.0,0.0/)        ; line patterns
res@tiYAxisString    = "  "    ; y-axis label
res@tiMainString      = " "; title
res@vpHeightF = 0.40        ; Changes the aspect ratio
res@vpWidthF  = 0.75

;res@gsnYRefLine           = 0.0
;res@gsnYRefLineThicknessF = 2.0
;res@txString             = "VWND: "+season+": "+yStrt+"-"+yLast
;
res_text                    = True                  ; text mods desired
res_text@txFontHeightF      = 0.011                 ; change text size
res_text@txJust             = "CenterLeft"          ; text justification
res_lines                   = True                  ; polyline mods desired
res_lines@gsLineDashPattern = 0.                    ; solid line
res_lines@gsLineThicknessF  = 5.                    ; line thicker
; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format

res@tiMainString      = "DJF nao index "; title
res@xyLineColors      = (/"black","red"/)
res@gsnLeftString  = "R=0.38"

plota=new(1,graphic)
plota(0)  = gsn_csm_xy(wks,year,d_stz,res)
xx = (/1981,1985/)
yy = (/2.5,2.5/)
res_lines@gsLineColor       = "black"
abbcd=new(2,graphic)
abbcd(0) = gsn_add_polyline(wks,plota,xx,yy,res_lines)                ; add polyline
res_lines@gsLineColor       = "red"
yy = (/2.7,2.7/)
abbcd(1) = gsn_add_polyline(wks,plota,xx,yy,res_lines)                ; add polyline
dum6q = gsn_add_text(wks,plota,"PRD",1986,2.4,res_text) ; add text
dum6q = gsn_add_text(wks,plota,"OBS",1986,2.7,res_text) ; add text
gsn_panel(wks,plota,(/1,1/),resP)     ; now draw as one plot





end
