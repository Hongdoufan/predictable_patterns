;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "sst_projection_index_cv.nc"  
year = 36
optETS = False
neof   = 2
yrStrt = 1981
yrLast = 2016

tstart= 35
tend=466
varname1     = "winter_anom"
decomposition_season="JFM"

var     = "sst"
unit= ""
files_dir    = "/disk1/fhd/winter_forecast/data/sst_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
   
;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "trend_diff_test"                       ; set plot name 
pltType = "pdf"

output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
;outName = var+"_eof_prd_dtrend.nc"  
outName = "sst_eof.nc"  

optEOF = True
optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

optETS = False
;==========================================================
;read predicable patterns
;==========================================================
all_files = "/disk1/fhd/winter_forecast/data/cv_trend_obs1.nc"
patterns = addfile (all_files, "r")
   trend=patterns->slope(:,{20:89},{0:360})  

tren=addfile("/disk1/fhd/degreepaper/data/eof_t2m_leave_obs.nc","r")
eof2=tren->eof(:,1,:,:)
eof2=eof2*7.

diff=eof2-trend
copy_VarCoords(eof2,diff)

;   eof=eof
;   printVarSummary(mode) 
;   eof=mode(:,0,:,:)
;   eof_ts=patterns->eof_ts(:,0,:)
  
;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
gsn_define_colormap(wks,"BlRe")       ; choose colormap
plot = new(year,graphic)                ; create graphic array
; only needed if paneling
; EOF patterns

res                      = True
res@gsnDraw              = False        ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@gsnSpreadColors      = True         ; spread out color table
res@gsnAddCyclic         = False        ; plotted dataa are not cyclic

res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN
res@mpMinLonF            = lonL
res@mpMaxLonF            = lonR

res@cnFillOn             = True         ; turn on color fill
res@cnLinesOn            = False        ; True is default
;res@cnLineLabelsOn       = False        ; True is default
res@cnFillPalette        = "BlWhRe"     ; set color map
res@lbLabelBarOn         = False        ; turn off individual lb's
;res@vpHeightF            = 2       ; Changes the aspect ratio
;res@vpWidthF             = 0.85
; res@mpCenterLonF         = 180.
res@tmYLLabelFontHeightF      =0.020  ;
res@tmXBLabelFontHeightF      = 0.020
res@gsnLeftStringFontHeightF  = 0.01
res@gsnRightStringFontHeightF  = 0.01

res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels

 res@cnMinLevelValF       = -0.16             ; set min contour level
 res@cnMaxLevelValF       =  0.16           ; set max contour level
 res@cnLevelSpacingF      =  0.04              ; set contour spacing

; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = True         ; add common colorbar
resP@pmLabelBarOrthogonalPosF = -0.07         ; add common colorbar


resP@txString            =""

;*******************************************
; first plot
;*******************************************
do n=0,year-1
res@gsnLeftString  = 1981+(n)
;res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
plot(n)=gsn_csm_contour_map(wks,eof2(n,:,:),res)
end do
gsn_panel(wks,plot,(/9,4/),resP)     ; now draw as one plot

;*******************************************
; second plot
;*******************************************
do n=0,year-1
res@gsnLeftString  = 1981+(n)
;res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
plot(n)=gsn_csm_contour_map(wks,trend(n,:,:),res)
end do
gsn_panel(wks,plot,(/9,4/),resP)     ; now draw as one plot

do n=0,year-1
res@gsnLeftString  = 1981+(n)
;res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
plot(n)=gsn_csm_contour_map(wks,diff(n,:,:),res)
end do
gsn_panel(wks,plot,(/9,4/),resP)     ; now draw as one plot

;printVarSummary(eof)

end
