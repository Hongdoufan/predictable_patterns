;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
latS   =  70
latN   =  89
lonL   =  -180
lonR   =  180
pltDir  =  "/disk1/fhd/degreepaper/result/"                            ; directory for plot output
pltName = "nao_index"      
pltType = "pdf" 

;************************************************
; read scand_index, scand_pattern, and hindcast 500hgt
;************************************************

fout1=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
scand_obs=fout1->eof_ts

fout=addfile("/disk1/fhd/winter_forecast/data/eof_sic_djf.nc", "r")
scand_pattern=fout->eof(0,:,:)
;printVarSummary(scand_pattern)

varname1     = "winter_anom"
files_dir    = "/disk1/fhd/winter_forecast/data/sic_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
   var1=varible_file->$varname1$
   winte=dim_avg_n(var1,1)
   copy_VarCoords(var1(:,0,:,:), winte)
   printVarSummary(winte)
   winte = dtrend_msg_n(winte&nyear,winte,True,False,0)
   winte=lonFlip(winte)

   ensemble_winter=winte(:,{latS:latN},{lonL:lonR});   ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)
   lat=ensemble_winter&latitude
   lon=ensemble_winter&longitude


;************************************************
; project predicted sst  onto sst eof1 to get projection index
; consider weight
;************************************************
rad    = 4.*atan(1.)/180.
clat   = ensemble_winter&latitude
clat   = sqrt( cos(rad*clat) )                

wsea_variable   = ensemble_winter                                   ; copy meta data
wsea_variable   = ensemble_winter*conform(ensemble_winter, clat, 1)
ensemble     = wsea_variable({latitude|:},{longitude|:},{nyear|:})

   printVarSummary(ensemble)
   scand=new((/1,dimsizes(lat),dimsizes(lon)/),"float")
   scand(0,:,:)=scand_pattern({latS:latN},{lonL:lonR})

latS1   =  70
latN1   =  89
lonL1   =  -180
lonR1   =  180
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



system("rm -f /disk1/fhd/winter_forecast/data/sic_projection_index.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/sic_projection_index.nc", "c")
fout->sic=scand_prd

   cor1=escorc(scand_prd,scand_obs(3,:))
   
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