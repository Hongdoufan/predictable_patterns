
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

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

decomposition_season="JFM"

var     = "t2m"
unit= ""
files_dir    = "/disk1/fhd/data/t2m.mon.mean.1.0.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
   
;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "eof_"+var+"_obs"                       ; set plot name 
pltType = "pdf" 


neof   = 4        ; number of EOFs
optEOF = True
optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

optETS = False

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================

TIME   = varible_file->time
YYYY   = cd_calendar(TIME,-2)/100                 ; entire file
;iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)

variabl= short2flt(varible_file->$var$)
vare=variabl(35:466,{latS:latN},{lonL:lonR})
;printVarSummary(vwnd)                              ; variable overview
; ==============================================================
; dataset longitudes span 0=>357.5
; Because EOFs of the North Atlantic Oscillation are desired
; use the "lonFlip" (contributed.ncl) to reorder
; longitudes to span -180 to 177.5: facilitate coordinate subscripting
; ==============================================================
;vwnd    = lonFlip( vwnd )
;printVarSummary(vwnd)                              ; note the longitude coord

; ==============================================================
; compute desired global seasonal mean: month_to_season (contributed.ncl)
; ==============================================================

variable =vare
;copy_VarCoords(vare,variable)
xClm      = clmMonTLL(variable)
ariable  = calcMonAnomTLL (variable, xClm)    ; replace with anonamlies
n_variable  =ariable({latitude|:},{longitude|:},time|:)
;n_variable = wgt_runave_Wrap(n_variable, (/0.25, 0.50, 0.25/), 0)
;n_variable@long_name = "ANOMALIES: "+n_variable@long_name
aaa=n_variable(time|:,{latitude|:},{longitude|:})
sea_variable    = month_to_season (aaa, decomposition_season)
nyrs   = dimsizes(sea_variable&time)
printVarSummary(sea_variable)

; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
; =================================================================
rad    = 4.*atan(1.)/180.
clat   = varible_file->latitude({latS:latN})
clat   = sqrt( cos(rad*clat) )                

; =================================================================
; weight all observations
; =================================================================
wsea_variable   = sea_variable                                   ; copy meta data
wsea_variable   = sea_variable*conform(sea_variable, clat, 1)
wsea_variable@long_name = "Wgt: "+sea_variable@long_name

; =================================================================
; Reorder (lat,lon,time) the *weighted* input data
; Access the area of interest via coordinate subscripting
; =================================================================
x     = wsea_variable({latitude|:},{longitude|:},time|:)
eof      = eofunc_Wrap(x, neof, optEOF)
eof_ts   = eofunc_ts_Wrap (x, eof, optETS)


printVarSummary( eof )                         ; examine EOF variables
printVarSummary( eof_ts )
;eof(1:3,:,:)=eof(1:3,:,:)*4
;eof_ts(0,:)=eof_ts(0,:)/4.
;recon=eof2data(eof,eof_ts)
;printMinMax(recon,False)
;exit()

; =================================================================
; Normalize time series: Sum spatial weights over the area of used
; =================================================================
dimx  = dimsizes( x )
mln    = dimx(1)
sumWgt = mln*sum(clat)
eof_ts = eof_ts/sumWgt
eof_ts = dim_standardize_Wrap(eof_ts,0)
; =================================================================
; Extract the YYYYMM from the time coordinate
; associated with eof_ts [same as SLP&time]
; =================================================================
;eof     = eof*4
eof      = eof*-1
eof_ts   = eof_ts*-1
eof(3,:,:) = eof(3,:,:)*-1
eof_ts(3,:)=eof_ts(3,:)*-1

yyyymm = cd_calendar(eof_ts&time,-2)/100
;;yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0); not used here

;============================================================
;
;============================================================

;system("rm -f /disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc", "c")
;fout->eof=eof(1,:,:)
;fout->eof_ts=eof_ts(1,:)

;system("rm -f /disk1/fhd/winter_forecast/data/obs_pc2.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/obs_pc2.nc", "c")
;fout->eof_ts=eof_ts(1,:)



;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
gsn_define_colormap(wks,"BlRe")       ; choose colormap
plot = new(neof,graphic)                ; create graphic array
; only needed if paneling
; EOF patterns

res                      = True
res@gsnDraw              = False        ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@gsnSpreadColors      = True         ; spread out color table
res@gsnAddCyclic         = True        ; plotted dataa are not cyclic
;res@gsnPolar   = "NH"  

res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN
res@mpMinLonF            = lonL
res@mpMaxLonF            = lonR

res@cnFillOn             = True         ; turn on color fill
res@cnLinesOn            = False        ; True is default
res@cnLineLabelsOn       = False        ; True is default
res@cnFillPalette        = "BlWhRe"     ; set color map
res@lbLabelBarOn         = False        ; turn off individual lb's
;res@vpHeightF            = 2       ; Changes the aspect ratio
;res@vpWidthF             = 0.85
res@mpCenterLonF         = 180.
res@tmYLLabelFontHeightF      =0.018  ;
res@tmXBLabelFontHeightF      = 0.018
res@gsnLeftStringFontHeightF  = 0.021
res@gsnRightStringFontHeightF  = 0.021
res@tmXBTickSpacingF        =60

res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
;res@cnLevelSpacingF   =0.04
;res@cnMinLevelValF    =-0.2
;res@cnMaxLevelValF    =0.2

; set symmetric plot min/max
symMinMaxPlt(eof, 16, False, res)       ; contributed.ncl

; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = True         ; add common colorbar
resP@pmLabelBarParallelPosF = 0.03
 resP@pmLabelBarOrthogonalPosF = -0.02       ; 0.05
 resP@pmLabelBarHeightF    = 0.03
 resP@pmLabelBarWidthF =0.8
 resP@lbLabelFontHeightF  =0.015

yStrt                    = yyyymm(0)/100
yLast                    = yyyymm(nyrs-1)/100
resP@txString            = var +decomposition_season +yrStrt+"-"+yrLast

;*******************************************
; first plot
;*******************************************
do n=0,neof-1
res@gsnLeftString  = "(i) EOF2 "
res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
plot(n)=gsn_csm_contour_map(wks,eof(n,:,:),res)
end do
gsn_panel(wks,plot,(/neof,1/),resP)     ; now draw as one plot

;*******************************************
; second plot
;*******************************************
; EOF time series  [bar form]

rts           = True
rts@gsnDraw   = False       ; don't draw yet
rts@gsnFrame  = False       ; don't advance frame yet
rts@gsnScale  = True        ; force text scaling

; these four rtsources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

rts@vpHeightF = 0.40        ; Changes the aspect ratio
rts@vpWidthF  = 0.85
rts@vpXF      = 0.10        ; change start locations
rts@vpYF      = 0.75        ; the plot


rts@tiYAxisString = "unit: "+"~S~o~N~C"                    ; y-axis label

rts@gsnYRefLine           = 0.              ; reference line
rts@gsnXYBarChart         = True            ; create bar chart
rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
rts@tmYLLabelFontHeightF      =0.03  ;
rts@tmXBLabelFontHeightF      = 0.03
rts@gsnLeftStringFontHeightF  = 0.04
rts@gsnRightStringFontHeightF  = 0.04

; panel plot only resources
rtsP                      = True            ; modify the panel plot
rtsP@gsnMaximize          = True            ; large format
rtsP@txString             = var +decomposition_season +yrStrt+"-"+yrLast
; polyline parameters used on both plots
;*********************************
polyres                  = True
polyres@gsLineThicknessF = 3.0

year = (yyyymm/100)-1

; create individual plots
plotb = new(neof,graphic)                ; create graphic array
plota=new(neof,graphic)
do n=0,neof-1
rts@gsnLeftString  = "(j)"
rts@gsnRightString = ""
plotb(n) = gsn_csm_xy (wks,year,eof_ts(n,:),rts)
;plota(n)=gsn_add_polyline(wks,plotb(n),year,y(n,:),polyres)
end do
;draw(plotb)
gsn_panel(wks,plotb,(/neof,1/),rtsP)     ; now draw as one plot


;printVarSummary(eof)

end



