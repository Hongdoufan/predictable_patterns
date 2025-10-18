load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =   20
latN   =   89
lonL   =   0
lonR   =   360
pltDir  =  "/disk1/fhd/degreepaper/result/"                            ; directory for plot output
pltName = "nao_22_index"      
pltType = "pdf" 
   varname2     = "t2m"  
   season="JFM"

   np   = 3        ; number of pictures
   varname1     = "winter_anom"
   tstart=""
   tend=""
   startyear=1993
   endyear=2014
   nyear= 22
   latitude="g0_lat_2"    ;lat name
   longitude="g0_lon_3"   ;lon name
   levelname   = "lv_ISBL2"      
   level  = " "
;************************************************
; read scand_index, scand_pattern, and hindcast 500hgt
;************************************************
   file1 = addfile("/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc","r")
   var1=file1->$varname1$
;   copy_VarCoords(var1(:,0,:,:), ensemble_winter)

   Opt                = True
   Opt@ForceOverwrite = True
   Opt@DstGridType    = "2.5x2.5"
   Opt@DstLLCorner    = (/ -90,   0/)
   Opt@DstURCorner    = (/  90, 357.5/)
   
   var1_regrid = ESMF_regrid(var1,Opt)
   var1_regrid =var1_regrid(:,:,::-1,:)
   ensemble_winter=dim_avg_n(var1_regrid,1)
   copy_VarCoords(var1_regrid(:,0,:,:), ensemble_winter)

   winter=ensemble_winter(:,{latS:latN},{lonL:lonR})

printVarSummary(winter)
fout1=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc","r")
scand_obs=fout1->eof_ts(0,:)

;tren=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")
;scand_pattern=tren->eof





tren=addfile("/disk1/fhd/winter_forecast/data/fig3acd.nc","r")
scand_pattern=tren->3c({latS:latN},{lonL:lonR})

;ensemble_winter=ensemble_winte(:,{latS:latN},:)
;   ensemble_winter=lonFlip(ensemble_winter)

;************************************************
; project prd_500hgt onto scand_pattern to get scand_index_prd
; consider weight
; for ECMWF 
;************************************************
rad    = 4.*atan(1.)/180.
clat   = winter&lat
clat   = sqrt( cos(rad*clat) )                
at   = doubletofloat(clat)
at!0 = "lat"
wsea_variable   = winter                                   ; copy meta data
wsea_variable   = winter*conform(winter, at, 1)
ensemble     = wsea_variable({lat|:},{lon|:},{nyear|:})
   printVarSummary(scand_pattern)
   printVarSummary(ensemble)
   scand=new((/1,28,144/),"float")
   scand(0,:,:)=scand_pattern({latS:latN},:)

   latS1=20
   latN1=89
   lonL1=0
   lonR1=360
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
sumWgt = mln*sum(at)
scand_prd = scand_prd/sumWgt
scand_prd = dim_standardize_Wrap(scand_prd,0)


cor=escorc(scand_prd,scand_obs)
print(cor)

aaa=addfile("/disk1/fhd/winter_forecast/data/cor.nc","r")
cc=aaa->recon
jk=escorc(scand_prd,cc)
print(jk)
exit()


;************************************************
; project prd_500hgt onto scand_pattern to get scand_index_prd
; consider weight
; for KUMO 
;************************************************

wsea_variable3   = winter3                                   ; copy meta data
wsea_variable3   = winter3*conform(winter3, clat, 1)
ensemble3     = wsea_variable3({latitude|:},{longitude|:},{nyear|:})
   printVarSummary(ensemble3)
   scand3_prd_= eofunc_ts(ensemble3({latS1:latN1},{lonL1:lonR1},:),scand(:,{latS1:latN1},{lonL1:lonR1}), optETS)
   scand3_prd=scand3_prd_(0,:)
; =================================================================
; Normalize time series: Sum spatial weights over the area of used
; =================================================================
dimx  = dimsizes( ensemble3 )
mln    = dimx(1)
sumWgt = mln*sum(clat)
scand3_prd = scand3_prd/sumWgt
scand3_prd = dim_standardize_Wrap(scand3_prd,0)

;************************************************
; project prd_500hgt onto scand_pattern to get scand_index_prd
; consider weight
; for METEO 
;************************************************
wsea_variable4   = winter4                                   ; copy meta data
wsea_variable4   = winter4*conform(winter4, clat, 1)
ensemble4     = wsea_variable4({latitude|:},{longitude|:},{nyear|:})
   printVarSummary(ensemble4)
   scand4_prd_= eofunc_ts(ensemble4({latS1:latN1},{lonL1:lonR1},:),scand(:,{latS1:latN1},{lonL1:lonR1}), optETS)
   scand4_prd=scand4_prd_(0,:)
; =================================================================
; Normalize time series: Sum spatial weights over the area of used
; =================================================================
dimx  = dimsizes( ensemble4 )
mln    = dimx(1)
sumWgt = mln*sum(clat)
scand4_prd = scand4_prd/sumWgt
scand4_prd = dim_standardize_Wrap(scand4_prd,0)



;   printVarSummary(f)
;===========================================================================
 
  
  d_stz=new((/4,22/),"float")
  d_stz(0,:)=scand_obs  ;obs 
  d_stz(1,:)=scand_prd  ;ec
  d_stz(2,:)=scand3_prd  ;uk
  d_stz(3,:)=scand4_prd  ;meteo

  year=ispan(1993,2014,1)
;  print(d_stz)
  
  cor=escorc(d_stz(0,:),d_stz(1:3,:))
  print(cor)   ;0.98
  
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
res@xyLineColors      = (/"black","blue","blue","blue"/)  ; line colors
res@xyLineThicknesses	 = (/3.,3.3,3/)      ; line thicknesses
res@xyDashPatterns    = (/0,0,1.0,2.0/)        ; line patterns
res@tiYAxisString    = "  "    ; y-axis label
res@tiMainString      = " "; title
res@vpHeightF = 0.40        ; Changes the aspect ratio
res@vpWidthF  = 0.75

;res@gsnYRefLine           = 0.0
;res@gsnYRefLineThicknessF = 2.0
;res@txString             = "VWND: "+season+": "+yStrt+"-"+yLast
;
res_text                    = True                  ; text mods desired
res_text@txFontHeightF      = 0.009                 ; change text size
res_text@txJust             = "CenterLeft"          ; text justification
res_lines                   = True                  ; polyline mods desired
res_lines@gsLineDashPattern = 0.                    ; solid line
res_lines@gsLineThicknessF  = 5.                    ; line thicker
; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format

res@tiMainString      = "DJF NAO index "; title
;res@xyLineColors      = (/"black","red"/)
res@gsnLeftString  = "DJF NAO index"

plota=new(1,graphic)
plota(0)  = gsn_csm_xy(wks,year,d_stz,res)

xx = (/1992.2,1994.5/)
yy = (/1.2,1.2/)
res_lines@gsLineColor       = "black"
res_lines@gsLineDashPattern    = 0        ; line patterns
abbcd=new(4,graphic)
abbcd(0) = gsn_add_polyline(wks,plota,xx,yy,res_lines)                ; add polyline
res_lines@gsLineColor       = "blue"
res_lines@gsLineDashPattern    = 0        ; line patterns
yy = (/1.4,1.4/)
abbcd(1) = gsn_add_polyline(wks,plota,xx,yy,res_lines)                ; add polyline
res_lines@gsLineColor       = "blue"
res_lines@gsLineDashPattern    = 1        ; line patterns
yy = (/1.6,1.6/)
abbcd(2) = gsn_add_polyline(wks,plota,xx,yy,res_lines)
res_lines@gsLineColor       = "blue"
res_lines@gsLineDashPattern    = 2        ; line patterns
yy = (/1.8,1.8/)
abbcd(3) = gsn_add_polyline(wks,plota,xx,yy,res_lines)

dum6q = gsn_add_text(wks,plota,"OBS",1994.7,1.2,res_text) ; add text
dum6q = gsn_add_text(wks,plota,"ECMWF 0.35",1994.7,1.4,res_text) ; add text
dum6q = gsn_add_text(wks,plota,"UKMO 0.30",1994.7,1.6,res_text) ; add text
dum6q = gsn_add_text(wks,plota,"METEO 0.15",1994.7,1.8,res_text) ; add text

gsn_panel(wks,plota,(/1,1/),resP)     ; now draw as one plot





end



     